From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch net-next RFC v3 08/10] net: add
	netdev_for_each_all_lower_dev_rcu helper
Date: Thu, 17 Apr 2014 14:14:35 +0200
Message-ID: <1397736876-11771-9-git-send-email-jiri@resnulli.us>
References: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
 vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1397736876-11771-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 include/linux/netdevice.h | 18 +++++++++++++-----
 net/core/dev.c            | 26 ++++++++++++++------------
 2 files changed, 27 insertions(+), 17 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 14bd8b3..bee9673 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3076,15 +3076,23 @@ extern int		weight_p;
 extern int		bpf_jit_enable;
 
 bool netdev_has_upper_dev(struct net_device *dev, struct net_device *upper_dev);
-struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
-						     struct list_head **iter);
+struct net_device *netdev_all_adj_get_next_dev_rcu(struct net_device *dev,
+						   struct list_head **iter,
+						   struct list_head *adj_list);
 
 /* iterate through upper list, must be called under RCU read lock */
 #define netdev_for_each_all_upper_dev_rcu(dev, updev, iter) \
-	for (iter = &(dev)->all_adj_list.upper, \
-	     updev = netdev_all_upper_get_next_dev_rcu(dev, &(iter)); \
+	for (iter = NULL, \
+	     updev = netdev_all_adj_get_next_dev_rcu(dev, &(iter), &(dev)->all_adj_list.upper); \
 	     updev; \
-	     updev = netdev_all_upper_get_next_dev_rcu(dev, &(iter)))
+	     updev = netdev_all_adj_get_next_dev_rcu(dev, &(iter), &(dev)->all_adj_list.upper))
+
+/* iterate through lower list, must be called under RCU read lock */
+#define netdev_for_each_all_lower_dev_rcu(dev, lodev, iter) \
+	for (iter = NULL, \
+	     lodev = netdev_all_adj_get_next_dev_rcu(dev, &(iter), &(dev)->all_adj_list.lower); \
+	     lodev; \
+	     lodev = netdev_all_adj_get_next_dev_rcu(dev, &(iter), &(dev)->all_adj_list.lower))
 
 void *netdev_lower_get_next_private(struct net_device *dev,
 				    struct list_head **iter);
diff --git a/net/core/dev.c b/net/core/dev.c
index a0de81c..62bcec9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4542,30 +4542,32 @@ void *netdev_adjacent_get_private(struct list_head *adj_list)
 EXPORT_SYMBOL(netdev_adjacent_get_private);
 
 /**
- * netdev_all_upper_get_next_dev_rcu - Get the next dev from upper list
+ * netdev_all_adj_get_next_dev_rcu - Get the next dev from adjacent list
  * @dev: device
  * @iter: list_head ** of the current position
+ * @adj_list: adjacent list to go through
  *
- * Gets the next device from the dev's upper list, starting from iter
+ * Gets the next device from the dev's adjacent list, starting from iter
  * position. The caller must hold RCU read lock.
  */
-struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
-						     struct list_head **iter)
+struct net_device *netdev_all_adj_get_next_dev_rcu(struct net_device *dev,
+						   struct list_head **iter,
+						   struct list_head *adj_list)
 {
-	struct netdev_adjacent *upper;
+	struct netdev_adjacent *adj;
 
 	WARN_ON_ONCE(!rcu_read_lock_held() && !lockdep_rtnl_is_held());
 
-	upper = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
-
-	if (&upper->list == &dev->all_adj_list.upper)
+	if (!*iter)
+		*iter = adj_list;
+	if ((*iter)->next == adj_list)
 		return NULL;
 
-	*iter = &upper->list;
-
-	return upper->dev;
+	adj = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
+	*iter = &adj->list;
+	return adj->dev;
 }
-EXPORT_SYMBOL(netdev_all_upper_get_next_dev_rcu);
+EXPORT_SYMBOL(netdev_all_adj_get_next_dev_rcu);
 
 /**
  * netdev_lower_get_next_private - Get the next ->private from the
-- 
1.9.0
