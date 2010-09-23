From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 7/8] net: Allow setting the network namespace by fd
Date: Thu, 23 Sep 2010 01:51:30 -0700
Message-ID: <m1hbhgq1v1.fsf@fess.ebiederm.org>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
        Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
        Ulrich Drepper <drepper-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>,
        linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
        Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ocborgq7.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org> (Eric W. Biederman's message
	of "Thu, 23 Sep 2010 01:45:04 -0700")
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


Take advantage of the new abstraction and allow network devices
to be placed in any network namespace that we have a fd to talk
about.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/if_link.h     |    1 +
 include/net/net_namespace.h |    1 +
 net/core/net_namespace.c    |   26 ++++++++++++++++++++++++++
 net/core/rtnetlink.c        |    4 +++-
 4 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 2fc66dd..ae73d5e 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -116,6 +116,7 @@ enum {
 	IFLA_STATS64,
 	IFLA_VF_PORTS,
 	IFLA_PORT_SELF,
+	IFLA_NET_NS_FD,
 	__IFLA_MAX
 };
 
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index bd10a79..68672ce 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -114,6 +114,7 @@ static inline struct net *copy_net_ns(unsigned long flags, struct net *net_ns)
 extern struct list_head net_namespace_list;
 
 extern struct net *get_net_ns_by_pid(pid_t pid);
+extern struct net *get_net_ns_by_fd(int pid);
 
 #ifdef CONFIG_NET_NS
 extern void __put_net(struct net *net);
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 581a088..a9b54a7 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -8,6 +8,8 @@
 #include <linux/idr.h>
 #include <linux/rculist.h>
 #include <linux/nsproxy.h>
+#include <linux/proc_fs.h>
+#include <linux/file.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -341,6 +343,30 @@ struct net *get_net_ns_by_pid(pid_t pid)
 }
 EXPORT_SYMBOL_GPL(get_net_ns_by_pid);
 
+struct net *get_net_ns_by_fd(int fd)
+{
+	struct proc_inode *ei;
+	struct file *file;
+	struct net *net;
+
+	file = NULL;
+	net = ERR_PTR(-EINVAL);
+	file = proc_ns_fget(fd);
+	if (!fd)
+		goto out;
+		return ERR_PTR(-EINVAL);
+
+	ei = PROC_I(file->f_dentry->d_inode);
+	if (ei->ns_ops != &netns_operations)
+		goto out;
+
+	net = get_net(ei->ns);
+out:
+	if (file)
+		fput(file);
+	return net;
+}
+
 static int __init net_ns_init(void)
 {
 	struct net_generic *ng;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index f78d821..771d8be 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1003,6 +1003,8 @@ struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 	 */
 	if (tb[IFLA_NET_NS_PID])
 		net = get_net_ns_by_pid(nla_get_u32(tb[IFLA_NET_NS_PID]));
+	else if (tb[IFLA_NET_NS_FD])
+		net = get_net_ns_by_fd(nla_get_u32(tb[IFLA_NET_NS_FD]));
 	else
 		net = get_net(src_net);
 	return net;
@@ -1077,7 +1079,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	int send_addr_notify = 0;
 	int err;
 
-	if (tb[IFLA_NET_NS_PID]) {
+	if (tb[IFLA_NET_NS_PID] || tb[IFLA_NET_NS_FD]) {
 		struct net *net = rtnl_link_get_net(dev_net(dev), tb);
 		if (IS_ERR(net)) {
 			err = PTR_ERR(net);
-- 
1.6.5.2.143.g8cc62
