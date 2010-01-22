From: Jiri Pirko <jpirko@redhat.com>
Subject: [RFC, PATCH net-next-2.6] net: introduce a macro to traverse through
 uc_list easily
Date: Fri, 22 Jan 2010 16:13:02 +0100
Message-ID: <20100122151301.GC2609@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755122Ab0AVPNQ@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm thinking how to convert mc_list into list_head in the smoothest way.
It's almost impossible to convert it at once in all drivers (It's used in almost
all of them). From the mc_list of structures (either old or new list), only one
member is needed in drivers' code - addr.

Therefore that would be good to introduce a macro that can be used to traverse
through addresses in the list without caller knowing anything about the type of
the list. I think this kind of an abstraction is appropriate on this place.
Also during the phase of changing, the macro can use the original list and once
all drivers are using this macro, the list itself (so as the macro) can be
converted into list_head.

This patch shows the macro on uc_list (previously converted into list_head).

What do you think about this? Please comment.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 0e260cf..85d490b 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -22,7 +22,6 @@
 #include <linux/log2.h>
 #include <linux/jiffies.h>
 #include <linux/crc32.h>
-#include <linux/list.h>
 
 #include <linux/io.h>
 
@@ -6359,7 +6358,7 @@ static void niu_set_rx_mode(struct net_device *dev)
 	struct niu *np = netdev_priv(dev);
 	int i, alt_cnt, err;
 	struct dev_addr_list *addr;
-	struct netdev_hw_addr *ha;
+	unsigned char *ha;
 	unsigned long flags;
 	u16 hash[16] = { 0, };
 
@@ -6381,8 +6380,8 @@ static void niu_set_rx_mode(struct net_device *dev)
 	if (alt_cnt) {
 		int index = 0;
 
-		list_for_each_entry(ha, &dev->uc.list, list) {
-			err = niu_set_alt_mac(np, index, ha->addr);
+		netdev_for_each_uc_addr(ha, dev) {
+			err = niu_set_alt_mac(np, index, ha);
 			if (err)
 				printk(KERN_WARNING PFX "%s: Error %d "
 				       "adding alt mac %d\n",
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 727d265..c11d117 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -263,6 +263,19 @@ struct netdev_hw_addr_list {
 	int			count;
 };
 
+#define netdev_hw_addr_get_by_addr(a) \
+	container_of((void *) a, struct netdev_hw_addr, addr)
+
+#define netdev_for_each_addr(a, head)						\
+	for (a = list_entry((head)->next, struct netdev_hw_addr, list)->addr;	\
+	     prefetch(netdev_hw_addr_get_by_addr(a)->list.next),		\
+	     &netdev_hw_addr_get_by_addr(a)->list != (head);			\
+	     a = list_entry(netdev_hw_addr_get_by_addr(a)->list.next,		\
+			    struct netdev_hw_addr, list)->addr)
+
+#define netdev_for_each_uc_addr(a, dev)	\
+	netdev_for_each_addr(a, &dev->uc.list)
+
 struct hh_cache {
 	struct hh_cache *hh_next;	/* Next entry			     */
 	atomic_t	hh_refcnt;	/* number of users                   */
