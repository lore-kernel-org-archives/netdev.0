From: Jouni Malinen <jkm@devicescape.com>
Subject: [PATCH wireless-dev 4/6] d80211: Send Layer 2 Update frames in kernel
Date: Mon, 07 Aug 2006 16:16:12 -0700
Message-ID: <20060807231938.455373487@localhost>
References: <20060807231608.888744720@localhost>
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	jkm@devicescape.com, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-32.dex002.intermedia.net ([64.78.21.117]:22277 "EHLO
	dhost002-32.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751197AbWHGXYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:24:00 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline; filename=layer2update.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Send Layer 2 Update frame from the 802.11 code in kernel to the netdev
that the STA is bound to. If the STA is bound to another VLAN netdev,
send another update frame. This fixes an issue in which a local bridge
table was not updated when hostapd sent this frame.

Signed-off-by: Jouni Malinen <jkm@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -15,6 +15,7 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/skbuff.h>
+#include <linux/etherdevice.h>
 #include <linux/if_arp.h>
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
@@ -215,6 +216,52 @@ static int ieee80211_ioctl_flush(struct 
 }
 
 
+/* Layer 2 Update frame (802.2 Type 1 LLC XID Update response) */
+struct iapp_layer2_update {
+	u8 da[ETH_ALEN]; /* broadcast */
+	u8 sa[ETH_ALEN]; /* STA addr */
+	u16 len; /* 6 */
+	u8 dsap; /* 0 */
+	u8 ssap; /* 0 */
+	u8 control;
+	u8 xid_info[3];
+} __attribute__ ((packed));
+
+static void ieee80211_send_layer2_update(struct net_device *dev,
+					 const u8 *addr)
+{
+	struct iapp_layer2_update *msg;
+	struct sk_buff *skb;
+
+	/* Send Level 2 Update Frame to update forwarding tables in layer 2
+	 * bridge devices */
+
+	skb = dev_alloc_skb(sizeof(*msg));
+	if (skb == NULL)
+		return;
+	msg = (struct iapp_layer2_update *) skb_put(skb, sizeof(*msg));
+
+	/* 802.2 Type 1 Logical Link Control (LLC) Exchange Identifier (XID)
+	 * Update response frame; IEEE Std 802.2-1998, 5.4.1.2.1 */
+
+	memset(msg->da, 0xff, ETH_ALEN);
+	memcpy(msg->sa, addr, ETH_ALEN);
+	msg->len = htons(6);
+	msg->dsap = 0;
+	msg->ssap = 0x01; /* NULL LSAP, CR Bit: Response */
+	msg->control = 0xaf; /* XID response lsb.1111F101.
+			      * F=0 (no poll command; unsolicited frame) */
+	msg->xid_info[0] = 0x81; /* XID format identifier */
+	msg->xid_info[1] = 1; /* LLC types/classes: Type 1 LLC */
+	msg->xid_info[2] = 0; /* XID sender's receive window size (RW) */
+
+	skb->dev = dev;
+	skb->protocol = eth_type_trans(skb, dev);
+	memset(skb->cb, 0, sizeof(skb->cb));
+	netif_rx(skb);
+}
+
+
 static int ieee80211_ioctl_add_sta(struct net_device *dev,
 				   struct prism2_hostapd_param *param)
 {
@@ -296,6 +343,10 @@ static int ieee80211_ioctl_add_sta(struc
 
 	sta_info_put(sta);
 
+	if (sdata->type == IEEE80211_IF_TYPE_AP ||
+	    sdata->type == IEEE80211_IF_TYPE_VLAN)
+		ieee80211_send_layer2_update(dev, param->sta_addr);
+
 	return 0;
 }
 
@@ -1168,6 +1219,10 @@ static int ieee80211_ioctl_set_sta_vlan(
 			       dev->name, MAC_ARG(param->sta_addr),
                                new_vlan_dev->name);
 #endif
+			if (sta->dev != new_vlan_dev) {
+				ieee80211_send_layer2_update(new_vlan_dev,
+							     sta->addr);
+			}
                         sta->dev = new_vlan_dev;
 			sta->vlan_id = param->u.set_sta_vlan.vlan_id;
                         dev_put(new_vlan_dev);

--
-- 
Jouni Malinen                                            PGP id EFC895FA
