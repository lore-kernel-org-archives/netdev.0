From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: FW: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel
	when promiscuous mode
Date: Fri, 16 Nov 2007 20:49:02 +0900
Message-ID: <006601c82846$b0f99eb0$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Kok, Auke'" <auke-jan.h.kok@intel.com>,
	'Herbert Xu' <herbert@gondor.apana.org.au>,
	e1000-devel@lists.sourceforge.net,
	djohnson+linux-kernel@sw.starentnetworks.com,
	'Patrick McHardy' <kaber@trash.net>, cfriesen@nortel.com, w@1wt.eu
To: <netdev@vger.kernel.org>, "'David Miller'" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <greearb@candelatech.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

2007/11/11, Joonwoo Park <joonwpark81@gmail.com>:
> IMHO even though netdevice is in the promiscuous mode, we should receive all of ingress packets.
> This disable the vlan filtering feature when a vlan hw accel configured e1000 device goes into promiscuous mode.
> This make packets visible to sniffers though it's not vlan id of itself.
> Any check, comments will be appreciated.

Hi,
Not anymore about just e1000 :)
I made an another patch with different approach which doesn't fix nic driver.
In addition, this patch does disable all hw vlan acceleration features (rx, tx, filter) for promiscuous netdevice. (It makes
possible tcpdump -i eth0 vlan)
Actually, my previous patch did just disable filter for e1000, so we can't see vlan header of packet. (e1000 stripped off the
header)
I think this patch is much better than previous of mine.
How do you think?

Any assist will be appreciated.

Thanks.
Joonwoo


[NET]: Disable vlan hw acceleration when promiscuous mode

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

---
 include/linux/if_vlan.h |    5 ++-
 net/8021q/vlan.c        |   84 ++++++++++++++++++++++++++++++++++++++++++++---
 net/8021q/vlan.h        |    3 ++
 net/core/dev.c          |    8 ++++-
 4 files changed, 93 insertions(+), 7 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 976d4b1..b931bee 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -63,6 +63,8 @@ struct vlan_hdr {
 
 /* found in socket.c */
 extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *));
+extern void vlan_dev_disable_hwaccel(struct net_device *any_dev);
+void vlan_dev_enable_hwaccel(struct net_device *any_dev);
 
 #define VLAN_NAME "vlan"
 
@@ -367,7 +369,8 @@ static inline int __vlan_hwaccel_get_tag(struct sk_buff *skb, unsigned short *ta
  */
 static inline int vlan_get_tag(struct sk_buff *skb, unsigned short *tag)
 {
-	if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
+	if (skb->dev->features & NETIF_F_HW_VLAN_TX &&
+		!(skb->dev->flags & IFF_PROMISC)) {
 		return __vlan_hwaccel_get_tag(skb, tag);
 	} else {
 		return __vlan_get_tag(skb, tag);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 6567213..bac04a3 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -339,7 +339,8 @@ static int vlan_dev_init(struct net_device *dev)
 	if (is_zero_ether_addr(dev->broadcast))
 		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
 
-	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
+	if (real_dev->features & NETIF_F_HW_VLAN_TX &&
+		!(real_dev->flags & IFF_PROMISC)) {
 		dev->header_ops      = real_dev->header_ops;
 		dev->hard_header_len = real_dev->hard_header_len;
 		dev->hard_start_xmit = vlan_dev_hwaccel_hard_start_xmit;
@@ -471,10 +472,12 @@ int register_vlan_dev(struct net_device *dev)
 	 * it into our local structure.
 	 */
 	vlan_group_set_device(grp, vlan_id, dev);
-	if (ngrp && real_dev->features & NETIF_F_HW_VLAN_RX)
-		real_dev->vlan_rx_register(real_dev, ngrp);
-	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
-		real_dev->vlan_rx_add_vid(real_dev, vlan_id);
+	if (!real_dev->flags & IFF_PROMISC) {
+		if (ngrp && real_dev->features & NETIF_F_HW_VLAN_RX)
+			real_dev->vlan_rx_register(real_dev, ngrp);
+		if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
+			real_dev->vlan_rx_add_vid(real_dev, vlan_id);
+	}
 
 	if (vlan_proc_add_dev(dev) < 0)
 		printk(KERN_WARNING "VLAN: failed to add proc entry for %s\n",
@@ -700,6 +703,77 @@ out:
 	return NOTIFY_DONE;
 }
 
+void vlan_dev_disable_hwaccel(struct net_device *any_dev)
+{
+	struct vlan_group *grp;
+	struct net_device *real_dev;
+	int i;
+
+	if (any_dev->priv_flags & IFF_802_1Q_VLAN)
+		return;
+
+	real_dev = any_dev;
+
+	grp = __vlan_find_group(real_dev->ifindex);
+	if (!grp)
+		return;
+
+	local_irq_disable();
+	for (i = 0; i < VLAN_VID_MASK; i++) {
+		struct net_device *dev = vlan_group_get_device(grp, i);
+		if (dev) {
+			if (real_dev->features &
+			    (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER)) {
+				real_dev->vlan_rx_kill_vid(real_dev, i);
+				vlan_group_set_device(grp, i, dev);
+			}
+			if (real_dev->features & NETIF_F_HW_VLAN_TX) {
+				dev->header_ops = &vlan_header_ops;
+				dev->hard_header_len = real_dev->hard_header_len + VLAN_HLEN;
+				dev->hard_start_xmit = vlan_dev_hard_start_xmit;
+			}
+		}
+	}
+
+	if (real_dev->features & NETIF_F_HW_VLAN_RX)
+		real_dev->vlan_rx_register(real_dev, NULL);
+	local_irq_enable();
+}
+
+void vlan_dev_enable_hwaccel(struct net_device *any_dev)
+{
+	struct vlan_group *grp;
+	struct net_device *real_dev;
+	int i;
+
+	if (any_dev->priv_flags & IFF_802_1Q_VLAN)
+		return;
+
+	real_dev = any_dev;
+
+	grp = __vlan_find_group(real_dev->ifindex);
+	if (!grp)
+		return;
+
+	local_irq_disable();
+	for (i = 0; i < VLAN_VID_MASK; i++) {
+		struct net_device *dev = vlan_group_get_device(grp, i);
+		if (dev) {
+			if (real_dev->features & (NETIF_F_HW_VLAN_FILTER))
+				real_dev->vlan_rx_add_vid(real_dev, i);
+			if (real_dev->features & NETIF_F_HW_VLAN_TX) {
+				dev->header_ops      = real_dev->header_ops;
+				dev->hard_header_len = real_dev->hard_header_len;
+				dev->hard_start_xmit = vlan_dev_hwaccel_hard_start_xmit;
+			}
+		}
+	}
+
+	if (real_dev->features & NETIF_F_HW_VLAN_RX)
+		real_dev->vlan_rx_register(real_dev, grp);
+	local_irq_enable();
+}
+
 /*
  *	VLAN IOCTL handler.
  *	o execute requested action or pass command to the device driver
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 2cd1393..e2e10a5 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -81,6 +81,9 @@ int unregister_vlan_device(struct net_device *dev);
 int vlan_netlink_init(void);
 void vlan_netlink_fini(void);
 
+void vlan_dev_disable_hwaccel(struct net_device *any_dev);
+void vlan_dev_enable_hwaccel(struct net_device *any_dev);
+
 extern struct rtnl_link_ops vlan_link_ops;
 
 #endif /* !(__BEN_VLAN_802_1Q_INC__) */
diff --git a/net/core/dev.c b/net/core/dev.c
index dd7e307..aea35ea 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -119,6 +119,7 @@
 #include <linux/err.h>
 #include <linux/ctype.h>
 #include <linux/if_arp.h>
+#include <linux/if_vlan.h>
 
 #include "net-sysfs.h"
 
@@ -2782,8 +2783,13 @@ void dev_set_promiscuity(struct net_device *dev, int inc)
 	unsigned short old_flags = dev->flags;
 
 	__dev_set_promiscuity(dev, inc);
-	if (dev->flags != old_flags)
+	if (dev->flags != old_flags) {
 		dev_set_rx_mode(dev);
+		if (dev->flags & IFF_PROMISC)
+			vlan_dev_disable_hwaccel(dev);
+		else
+			vlan_dev_enable_hwaccel(dev);
+	}
 }
 
 /**
---


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
