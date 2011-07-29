From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: [PATCH 02/14] allow root in container to copy namespaces (v3)
Date: Fri, 29 Jul 2011 17:27:48 +0000
Message-ID: <20110729172748.GB18935@hallyn.com>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
 <1311706717-7398-3-git-send-email-serge@hallyn.com>
 <m1hb67fh9l.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, dhowells@redhat.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 50-56-35-84.static.cloud-ips.com ([50.56.35.84]:47797 "EHLO
	mail" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751392Ab1G2R1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2011 13:27:46 -0400
Content-Disposition: inline
In-Reply-To: <m1hb67fh9l.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Serge Hallyn <serge@hallyn.com> writes:
> 
> > From: Serge E. Hallyn <serge.hallyn@canonical.com>
> >
> > Othewise nested containers with user namespaces won't be possible.
> >
> > It's true that user namespaces are not yet fully isolated, but for
> > that same reason there are far worse things that root in a child
> > user ns can do.  Spawning a child user ns is not in itself bad.
> >
> > This patch also allows setns for root in a container:
> > @Eric Biederman: are there gotchas in allowing setns from child
> > userns?
> 
> Yes.  We need to ensure that the target namespaces are namespaces
> that have been created in from user_namespace or from a child of this
> user_namespace.
> 
> Aka we need to ensure that we have CAP_SYS_ADMIN for the new namespace.

[New patch below]

Othewise nested containers with user namespaces won't be possible.

It's true that user namespaces are not yet fully isolated, but for
that same reason there are far worse things that root in a child
user ns can do.  Spawning a child user ns is not in itself bad.

This patch also allows setns for root in a container:
@Eric Biederman: are there gotchas in allowing setns from child
userns?

Changelog:
  Jul 29: setns: target capability check for setns
          When changing to another namespace, make sure that we have
          the CAP_SYS_ADMIN capability targeted at the user namespace
          owning the new ns.

Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
 ipc/namespace.c          |    3 +++
 kernel/fork.c            |    4 ++--
 kernel/nsproxy.c         |    7 ++-----
 kernel/utsname.c         |    3 +++
 net/core/net_namespace.c |    3 +++
 5 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/ipc/namespace.c b/ipc/namespace.c
index ce0a647..f527e49 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -163,6 +163,9 @@ static void ipcns_put(void *ns)
 
 static int ipcns_install(struct nsproxy *nsproxy, void *ns)
 {
+	struct ipc_namespace *newns = ns;
+	if (!ns_capable(newns->user_ns, CAP_SYS_ADMIN))
+		return -1;
 	/* Ditch state from the old ipc namespace */
 	exit_sem(current);
 	put_ipc_ns(nsproxy->ipc_ns);
diff --git a/kernel/fork.c b/kernel/fork.c
index e7ceaca..f9fac70 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1488,8 +1488,8 @@ long do_fork(unsigned long clone_flags,
 		/* hopefully this check will go away when userns support is
 		 * complete
 		 */
-		if (!capable(CAP_SYS_ADMIN) || !capable(CAP_SETUID) ||
-				!capable(CAP_SETGID))
+		if (!nsown_capable(CAP_SYS_ADMIN) || !nsown_capable(CAP_SETUID) ||
+				!nsown_capable(CAP_SETGID))
 			return -EPERM;
 	}
 
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 9aeab4b..cadcee0 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -134,7 +134,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 				CLONE_NEWPID | CLONE_NEWNET)))
 		return 0;
 
-	if (!capable(CAP_SYS_ADMIN)) {
+	if (!nsown_capable(CAP_SYS_ADMIN)) {
 		err = -EPERM;
 		goto out;
 	}
@@ -191,7 +191,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 			       CLONE_NEWNET)))
 		return 0;
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!nsown_capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
 	*new_nsp = create_new_namespaces(unshare_flags, current,
@@ -241,9 +241,6 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
 	struct file *file;
 	int err;
 
-	if (!capable(CAP_SYS_ADMIN))
-		return -EPERM;
-
 	file = proc_ns_fget(fd);
 	if (IS_ERR(file))
 		return PTR_ERR(file);
diff --git a/kernel/utsname.c b/kernel/utsname.c
index bff131b..8f648cc 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -104,6 +104,9 @@ static void utsns_put(void *ns)
 
 static int utsns_install(struct nsproxy *nsproxy, void *ns)
 {
+	struct uts_namespace *newns = ns;
+	if (!ns_capable(newns->user_ns, CAP_SYS_ADMIN))
+		return -1;
 	get_uts_ns(ns);
 	put_uts_ns(nsproxy->uts_ns);
 	nsproxy->uts_ns = ns;
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 5bbdbf0..90c97f6 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -620,6 +620,9 @@ static void netns_put(void *ns)
 
 static int netns_install(struct nsproxy *nsproxy, void *ns)
 {
+	struct net *net = ns;
+	if (!ns_capable(net->user_ns, CAP_SYS_ADMIN))
+		return -1;
 	put_net(nsproxy->net_ns);
 	nsproxy->net_ns = get_net(ns);
 	return 0;
-- 
1.7.5.4

