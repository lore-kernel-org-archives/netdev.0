From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] wireless extensions: play with netns
Date: Thu, 18 Jun 2009 01:41:38 +0200
Message-ID: <1245282099.31588.69.camel@johannes.local>
References: <1245263058.31588.38.camel@johannes.local>
	 <m1y6rqwpur.fsf@fess.ebiederm.org>
	 <1245276899.31588.57.camel@johannes.local>
	 <m1r5xitpdh.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-BGArkANP9klv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
	Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m1r5xitpdh.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-06-17 at 16:24 -0700, Eric W. Biederman wrote:

> > So it looks like I can also use rcu_read_lock(), but there's no
> > for_each_net_rcu(), should there be?
> 
> I'm not using rcu safe list manipulation.  What makes it look like
> rcu_read_lock() is safe?

Indeed. I was looking at rcu_barrier() only. How about the patch below?

johannes

Subject: net: make namespace iteration possible under RCU

We already call rcu_barrier(), so all we need to take
care of is using proper RCU list add/del primitives.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 include/net/net_namespace.h |    3 +++
 net/core/net_namespace.c    |    7 ++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

--- wireless-testing.orig/include/net/net_namespace.h	2009-06-18 01:36:26.000000000 +0200
+++ wireless-testing/include/net/net_namespace.h	2009-06-18 01:39:35.000000000 +0200
@@ -211,6 +211,9 @@ static inline struct net *read_pnet(stru
 #define for_each_net(VAR)				\
 	list_for_each_entry(VAR, &net_namespace_list, list)
 
+#define for_each_net_rcu(VAR)				\
+	list_for_each_entry_rcu(VAR, &net_namespace_list, list)
+
 #ifdef CONFIG_NET_NS
 #define __net_init
 #define __net_exit
--- wireless-testing.orig/net/core/net_namespace.c	2009-06-18 01:36:39.000000000 +0200
+++ wireless-testing/net/core/net_namespace.c	2009-06-18 01:38:36.000000000 +0200
@@ -6,6 +6,7 @@
 #include <linux/delay.h>
 #include <linux/sched.h>
 #include <linux/idr.h>
+#include <linux/rculist.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -134,7 +135,7 @@ struct net *copy_net_ns(unsigned long fl
 	err = setup_net(new_net);
 	if (!err) {
 		rtnl_lock();
-		list_add_tail(&new_net->list, &net_namespace_list);
+		list_add_tail_rcu(&new_net->list, &net_namespace_list);
 		rtnl_unlock();
 	}
 	mutex_unlock(&net_mutex);
@@ -163,7 +164,7 @@ static void cleanup_net(struct work_stru
 
 	/* Don't let anyone else find us. */
 	rtnl_lock();
-	list_del(&net->list);
+	list_del_rcu(&net->list);
 	rtnl_unlock();
 
 	/* Run all of the network namespace exit methods */
@@ -227,7 +228,7 @@ static int __init net_ns_init(void)
 	err = setup_net(&init_net);
 
 	rtnl_lock();
-	list_add_tail(&init_net.list, &net_namespace_list);
+	list_add_tail_rcu(&init_net.list, &net_namespace_list);
 	rtnl_unlock();
 
 	mutex_unlock(&net_mutex);


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
