From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 01/17] netns: Deduplicate and fix copy_net_ns when
	!CONFIG_NET_NS
Date: Fri, 16 Nov 2012 05:02:56 -0800
Message-ID: <1353070992-5552-1-git-send-email-ebiederm@xmission.com>
References: <87d2zd8zwn.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d2zd8zwn.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

The copy of copy_net_ns used when the network stack is not
built is broken as it does not return -EINVAL when attempting
to create a new network namespace.  We don't even have
a previous network namespace.

Since we need a copy of copy_net_ns in net/net_namespace.h that is
available when the networking stack is not built at all move the
correct version of copy_net_ns from net_namespace.c into net_namespace.h
Leaving us with just 2 versions of copy_net_ns.  One version for when
we compile in network namespace suport and another stub for all other
occasions.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/net/net_namespace.h |   15 +++++++++------
 net/core/net_namespace.c    |    7 -------
 2 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 95e6466..32dcb60 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -126,16 +126,19 @@ struct net {
 /* Init's network namespace */
 extern struct net init_net;
 
-#ifdef CONFIG_NET
+#ifdef CONFIG_NET_NS
 extern struct net *copy_net_ns(unsigned long flags, struct net *net_ns);
 
-#else /* CONFIG_NET */
-static inline struct net *copy_net_ns(unsigned long flags, struct net *net_ns)
+#else /* CONFIG_NET_NS */
+#include <linux/sched.h>
+#include <linux/nsproxy.h>
+static inline struct net *copy_net_ns(unsigned long flags, struct net *old_net)
 {
-	/* There is nothing to copy so this is a noop */
-	return net_ns;
+	if (flags & CLONE_NEWNET)
+		return ERR_PTR(-EINVAL);
+	return old_net;
 }
-#endif /* CONFIG_NET */
+#endif /* CONFIG_NET_NS */
 
 
 extern struct list_head net_namespace_list;
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 42f1e1c..2c1c590 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -347,13 +347,6 @@ struct net *get_net_ns_by_fd(int fd)
 }
 
 #else
-struct net *copy_net_ns(unsigned long flags, struct net *old_net)
-{
-	if (flags & CLONE_NEWNET)
-		return ERR_PTR(-EINVAL);
-	return old_net;
-}
-
 struct net *get_net_ns_by_fd(int fd)
 {
 	return ERR_PTR(-EINVAL);
-- 
1.7.5.4
