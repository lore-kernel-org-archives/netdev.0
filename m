From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH] [NET]: Fix TX bug VLAN in VLAN
Date: Fri, 23 Nov 2007 21:12:52 +0900
Message-ID: <003f01c82dca$305acd40$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <tristan_schmelcher@alumni.uwaterloo.ca>,
	<acme@ghostprotocols.net>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.191]:10894 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720AbXKWMNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 07:13:05 -0500
Received: by rv-out-0910.google.com with SMTP id k20so2628185rvb
        for <netdev@vger.kernel.org>; Fri, 23 Nov 2007 04:13:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=8766

Is it possible? 
BUG((veth->h_vlan_proto != htons(ETH_P_8021Q)) && !(VLAN_DEV_INFO(dev)->flags & VLAN_FLAG_REORDER_HDR))
I'm afraid, queued packet before vconfig set_flag would do that.

Thanks.
Joonwoo


[NET]: Fix TX bug VLAN in VLAN
Fix misbehavior of vlan_dev_hard_start_xmit() for recursive encapsulations.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

---
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 7a36878..3e34990 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -454,7 +454,9 @@ int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device_stats *stats = vlan_dev_get_stats(dev);
+#ifdef VLAN_DEBUG
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
+#endif
 
 	/* Handle non-VLAN frames if they are sent to us, for example by DHCP.
 	 *
@@ -462,7 +464,7 @@ int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * OTHER THINGS LIKE FDDI/TokenRing/802.3 SNAPs...
 	 */
 
-	if (veth->h_vlan_proto != htons(ETH_P_8021Q)) {
+	if (VLAN_DEV_INFO(dev)->flags & VLAN_FLAG_REORDER_HDR) {
 		int orig_headroom = skb_headroom(skb);
 		unsigned short veth_TCI;
 
---

