From: "Serge E. Hallyn" <serge.hallyn@canonical.com>
Subject: Re: [PATCH 02/14] allow root in container to copy namespaces (v3)
Date: Thu, 4 Aug 2011 17:01:15 -0500
Message-ID: <20110804220115.GA28300@sergelap>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
 <1311706717-7398-3-git-send-email-serge@hallyn.com>
 <m1hb67fh9l.fsf@fess.ebiederm.org>
 <20110729172748.GB18935@hallyn.com>
 <m1ei146a6t.fsf@fess.ebiederm.org>
 <20110802140832.GA26646@sergelap>
 <m1oc074gkb.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serge@hallyn.com>, dhowells@redhat.com,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:37473 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755833Ab1HDWBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 18:01:24 -0400
Content-Disposition: inline
In-Reply-To: <m1oc074gkb.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
> "Serge E. Hallyn" <serge.hallyn@canonical.com> writes:
> 
> > Quoting Eric W. Biederman (ebiederm@xmission.com):
> >> The dangers of changing the namespace of a process remain the same,
> >> confused suid programs.  I don't believe there are any unique new
> >> dangers. 
> >> 
> >> Not allowing joining namespaces you already have a copy of is just
> >> a matter of making it hard to get things wrong.
> >> 
> >> I would feel more a bit more comfortable if the way we did this was
> >> to move all of the capable calls into the per namespace methods
> >> and then changed them one namespace at a time.  I don't think
> >
> > The patch belows moves them into the per namespace methods, for
> > what it's worth.  If you like I can change them, for now, to
> > 'capable(CAP_SYS_ADMIN)' targeted at init_user_ns, but if we're
> > targetting at the userns owning the destination namespace, it
> > seems this must be sufficient...
> 
> I like the was this was done.  I was mostly thinking of the non
> setns case when I was talking about moving the calls.

Oh, you mean unshare and copy namespaces?

(The flow on those paths is scary to touch :)

> >> there are any fundmanetal dangers of allowing unshare without
> >> the global CAP_SYS_ADMIN, but it would be good to be able to audit
> >
> > If you have suspicions that there may in fact be dangers, then
> > perhaps this whole patch should be delayed, and copy_namespaces()
> > and unshare_nsproxy_namespaces() should continue to check global
> > CAP_SYS_ADMIN?  The only part which would remain would be the
> > moving of the setns capable check into the per-ns ->install
> > method, but it would check the global CAP_SYS_ADMIN?
> 
> Yes.  I am in favor of delaying this and making the changes one
> namespace at a time.  I don't think there are real dangers but I do
> think we should try and think through the possible dangers.

Ok, so for now here is a patch to fold into the previous one
which I think sets us at a reasonable point.

>From 78e1a4efa464086e8df95fc3ffd35c385e363957 Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serge.hallyn@canonical.com>
Date: Thu, 4 Aug 2011 22:10:12 +0100
Subject: [PATCH 1/2] fold up - dont yet target the capable checks for
 namespace manipulation

Signed-off-by: Serge Hallyn <serge.hallyn@canonical.com>
---
 ipc/namespace.c          |    4 ++++
 kernel/fork.c            |    5 +++++
 kernel/nsproxy.c         |    8 ++++++++
 kernel/utsname.c         |    4 ++++
 net/core/net_namespace.c |    4 ++++
 5 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/ipc/namespace.c b/ipc/namespace.c
index f527e49..a0a7609 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -163,8 +163,12 @@ static void ipcns_put(void *ns)
 
 static int ipcns_install(struct nsproxy *nsproxy, void *ns)
 {
+#if 0
 	struct ipc_namespace *newns = ns;
 	if (!ns_capable(newns->user_ns, CAP_SYS_ADMIN))
+#else
+	if (!capable(CAP_SYS_ADMIN))
+#endif
 		return -1;
 	/* Ditch state from the old ipc namespace */
 	exit_sem(current);
diff --git a/kernel/fork.c b/kernel/fork.c
index f9fac70..a25343c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1488,8 +1488,13 @@ long do_fork(unsigned long clone_flags,
 		/* hopefully this check will go away when userns support is
 		 * complete
 		 */
+#if 0
 		if (!nsown_capable(CAP_SYS_ADMIN) || !nsown_capable(CAP_SETUID) ||
 				!nsown_capable(CAP_SETGID))
+#else
+		if (!capable(CAP_SYS_ADMIN) || !capable(CAP_SETUID) ||
+				!capable(CAP_SETGID))
+#endif
 			return -EPERM;
 	}
 
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 62a995d..752b477 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -136,7 +136,11 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 				CLONE_NEWPID | CLONE_NEWNET)))
 		return 0;
 
+#if 0
 	if (!nsown_capable(CAP_SYS_ADMIN)) {
+#else
+	if (!capable(CAP_SYS_ADMIN)) {
+#endif
 		err = -EPERM;
 		goto out;
 	}
@@ -193,7 +197,11 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 			       CLONE_NEWNET)))
 		return 0;
 
+#if 0
 	if (!nsown_capable(CAP_SYS_ADMIN))
+#else
+	if (!capable(CAP_SYS_ADMIN))
+#endif
 		return -EPERM;
 
 	*new_nsp = create_new_namespaces(unshare_flags, current,
diff --git a/kernel/utsname.c b/kernel/utsname.c
index 8f648cc..4638a54 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -104,8 +104,12 @@ static void utsns_put(void *ns)
 
 static int utsns_install(struct nsproxy *nsproxy, void *ns)
 {
+#if 0
 	struct uts_namespace *newns = ns;
 	if (!ns_capable(newns->user_ns, CAP_SYS_ADMIN))
+#else
+	if (!capable(CAP_SYS_ADMIN))
+#endif
 		return -1;
 	get_uts_ns(ns);
 	put_uts_ns(nsproxy->uts_ns);
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 8778a0a..5ca95cc 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -623,8 +623,12 @@ static void netns_put(void *ns)
 
 static int netns_install(struct nsproxy *nsproxy, void *ns)
 {
+#if 0
 	struct net *net = ns;
 	if (!ns_capable(net->user_ns, CAP_SYS_ADMIN))
+#else
+	if (capable(CAP_SYS_ADMIN))
+#endif
 		return -1;
 	put_net(nsproxy->net_ns);
 	nsproxy->net_ns = get_net(ns);
-- 
1.7.5.4

