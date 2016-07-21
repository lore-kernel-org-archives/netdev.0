From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v2 05/10] pidns: Add a limit on the number of pid namespaces
Date: Thu, 21 Jul 2016 11:40:09 -0500
Message-ID: <20160721164014.17534-5-ebiederm@xmission.com>
References: <87d1m754jc.fsf@x220.int.ebiederm.org>
	<20160721164014.17534-1-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160721164014.17534-1-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/user_namespace.h |  1 +
 kernel/pid_namespace.c         | 22 ++++++++++++++++++----
 kernel/user_namespace.c        |  1 +
 3 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index f74a0facc696..47733637741a 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -24,6 +24,7 @@ struct uid_gid_map {	/* 64 bytes -- 1 cache line */
 
 enum ucounts {
 	UCOUNT_USER_NAMESPACES,
+	UCOUNT_PID_NAMESPACES,
 	UCOUNT_COUNTS,
 };
 
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index a65ba137fd15..049cc14ae37a 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -79,6 +79,16 @@ static void proc_cleanup_work(struct work_struct *work)
 /* MAX_PID_NS_LEVEL is needed for limiting size of 'struct pid' */
 #define MAX_PID_NS_LEVEL 32
 
+static bool inc_pid_namespaces(struct user_namespace *ns)
+{
+	return inc_ucount(ns, UCOUNT_PID_NAMESPACES);
+}
+
+static void dec_pid_namespaces(struct user_namespace *ns)
+{
+	dec_ucount(ns, UCOUNT_PID_NAMESPACES);
+}
+
 static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns,
 	struct pid_namespace *parent_pid_ns)
 {
@@ -87,15 +97,16 @@ static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns
 	int i;
 	int err;
 
-	if (level > MAX_PID_NS_LEVEL) {
-		err = -EINVAL;
+	err = -EINVAL;
+	if (level > MAX_PID_NS_LEVEL)
+		goto out;
+	if (!inc_pid_namespaces(user_ns))
 		goto out;
-	}
 
 	err = -ENOMEM;
 	ns = kmem_cache_zalloc(pid_ns_cachep, GFP_KERNEL);
 	if (ns == NULL)
-		goto out;
+		goto out_dec;
 
 	ns->pidmap[0].page = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!ns->pidmap[0].page)
@@ -129,6 +140,8 @@ out_free_map:
 	kfree(ns->pidmap[0].page);
 out_free:
 	kmem_cache_free(pid_ns_cachep, ns);
+out_dec:
+	dec_pid_namespaces(user_ns);
 out:
 	return ERR_PTR(err);
 }
@@ -146,6 +159,7 @@ static void destroy_pid_namespace(struct pid_namespace *ns)
 	ns_free_inum(&ns->ns);
 	for (i = 0; i < PIDMAP_ENTRIES; i++)
 		kfree(ns->pidmap[i].page);
+	dec_pid_namespaces(ns->user_ns);
 	put_user_ns(ns->user_ns);
 	call_rcu(&ns->rcu, delayed_free_pidns);
 }
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 728d7e4995ff..02a03ead7afc 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -77,6 +77,7 @@ static int count_max = COUNT_MAX;
 	}
 static struct ctl_table userns_table[] = {
 	UCOUNT_ENTRY("max_user_namespaces"),
+	UCOUNT_ENTRY("max_pid_namespaces"),
 	{ }
 };
 #endif /* CONFIG_SYSCTL */
-- 
2.8.3
