From: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 02/15] user ns: setns: move capable checks into per-ns attach
	helper
Date: Fri,  2 Sep 2011 19:56:27 +0000
Message-ID: <1314993400-6910-5-git-send-email-serge@hallyn.com>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm-3NddpPZAyC0@public.gmane.org, segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1314993400-6910-1-git-send-email-serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 ipc/namespace.c          |    7 +++++++
 kernel/fork.c            |    5 +++++
 kernel/nsproxy.c         |   11 ++++++++---
 kernel/utsname.c         |    7 +++++++
 net/core/net_namespace.c |    7 +++++++
 5 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/ipc/namespace.c b/ipc/namespace.c
index ce0a647..a0a7609 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -163,6 +163,13 @@ static void ipcns_put(void *ns)
 
 static int ipcns_install(struct nsproxy *nsproxy, void *ns)
 {
+#if 0
+	struct ipc_namespace *newns = ns;
+	if (!ns_capable(newns->user_ns, CAP_SYS_ADMIN))
+#else
+	if (!capable(CAP_SYS_ADMIN))
+#endif
+		return -1;
 	/* Ditch state from the old ipc namespace */
 	exit_sem(current);
 	put_ipc_ns(nsproxy->ipc_ns);
diff --git a/kernel/fork.c b/kernel/fork.c
index 8e6b6f4..ca712f5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1489,8 +1489,13 @@ long do_fork(unsigned long clone_flags,
 		/* hopefully this check will go away when userns support is
 		 * complete
 		 */
+#if 0
+		if (!nsown_capable(CAP_SYS_ADMIN) || !nsown_capable(CAP_SETUID) ||
+				!nsown_capable(CAP_SETGID))
+#else
 		if (!capable(CAP_SYS_ADMIN) || !capable(CAP_SETUID) ||
 				!capable(CAP_SETGID))
+#endif
 			return -EPERM;
 	}
 
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 9aeab4b..e274577 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -134,7 +134,11 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 				CLONE_NEWPID | CLONE_NEWNET)))
 		return 0;
 
+#if 0
+	if (!nsown_capable(CAP_SYS_ADMIN)) {
+#else
 	if (!capable(CAP_SYS_ADMIN)) {
+#endif
 		err = -EPERM;
 		goto out;
 	}
@@ -191,7 +195,11 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 			       CLONE_NEWNET)))
 		return 0;
 
+#if 0
+	if (!nsown_capable(CAP_SYS_ADMIN))
+#else
 	if (!capable(CAP_SYS_ADMIN))
+#endif
 		return -EPERM;
 
 	*new_nsp = create_new_namespaces(unshare_flags, current,
@@ -241,9 +249,6 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
 	struct file *file;
 	int err;
 
-	if (!capable(CAP_SYS_ADMIN))
-		return -EPERM;
-
 	file = proc_ns_fget(fd);
 	if (IS_ERR(file))
 		return PTR_ERR(file);
diff --git a/kernel/utsname.c b/kernel/utsname.c
index bff131b..4638a54 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -104,6 +104,13 @@ static void utsns_put(void *ns)
 
 static int utsns_install(struct nsproxy *nsproxy, void *ns)
 {
+#if 0
+	struct uts_namespace *newns = ns;
+	if (!ns_capable(newns->user_ns, CAP_SYS_ADMIN))
+#else
+	if (!capable(CAP_SYS_ADMIN))
+#endif
+		return -1;
 	get_uts_ns(ns);
 	put_uts_ns(nsproxy->uts_ns);
 	nsproxy->uts_ns = ns;
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 5bbdbf0..6f6698d 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -620,6 +620,13 @@ static void netns_put(void *ns)
 
 static int netns_install(struct nsproxy *nsproxy, void *ns)
 {
+#if 0
+	struct net *net = ns;
+	if (!ns_capable(net->user_ns, CAP_SYS_ADMIN))
+#else
+	if (capable(CAP_SYS_ADMIN))
+#endif
+		return -1;
 	put_net(nsproxy->net_ns);
 	nsproxy->net_ns = get_net(ns);
 	return 0;
-- 
1.7.5.4
