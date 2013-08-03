From: Wang Sheng-Hui <shhuiw@gmail.com>
Subject: [PATCH] vlan: cleanup the usage of vlan_dev_priv(dev)
Date: Sat, 03 Aug 2013 16:54:50 +0800
Message-ID: <51FCC55A.808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:44264 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab3HCIzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 04:55:04 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so1501896pad.14
        for <netdev@vger.kernel.org>; Sat, 03 Aug 2013 01:55:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch cleanup 2 points for the usage of vlan_dev_priv(dev):
* In vlan_dev.c/vlan_dev_hard_header, we should use the var *vlan directly
  after grabing the pointer at the beginning with
        *vlan = vlan_dev_priv(dev);
  when we need to access the fields of *vlan.
* In vlan.c/register_vlan_device, add the var *vlan pointer
        struct vlan_dev_priv *vlan;
to cleanup the code to access the fields of vlan_dev_priv(new_dev).

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 net/8021q/vlan.c     |   12 +++++++-----
 net/8021q/vlan_dev.c |    6 +++---
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 2fb2d88..b9d3d7e 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -210,6 +210,7 @@ out_vid_del:
 static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 {
 	struct net_device *new_dev;
+	struct vlan_dev_priv *vlan;
 	struct net *net = dev_net(real_dev);
 	struct vlan_net *vn = net_generic(net, vlan_net_id);
 	char name[IFNAMSIZ];
@@ -260,11 +261,12 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	new_dev->mtu = real_dev->mtu;
 	new_dev->priv_flags |= (real_dev->priv_flags & IFF_UNICAST_FLT);
 
-	vlan_dev_priv(new_dev)->vlan_proto = htons(ETH_P_8021Q);
-	vlan_dev_priv(new_dev)->vlan_id = vlan_id;
-	vlan_dev_priv(new_dev)->real_dev = real_dev;
-	vlan_dev_priv(new_dev)->dent = NULL;
-	vlan_dev_priv(new_dev)->flags = VLAN_FLAG_REORDER_HDR;
+	vlan = vlan_dev_priv(new_dev);
+	vlan->vlan_proto = htons(ETH_P_8021Q);
+	vlan->vlan_id = vlan_id;
+	vlan->real_dev = real_dev;
+	vlan->dent = NULL;
+	vlan->flags = VLAN_FLAG_REORDER_HDR;
 
 	new_dev->rtnl_link_ops = &vlan_link_ops;
 	err = register_vlan_dev(new_dev);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1cd3d2a..9ab8a7e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -107,10 +107,10 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	u16 vlan_tci = 0;
 	int rc;
 
-	if (!(vlan_dev_priv(dev)->flags & VLAN_FLAG_REORDER_HDR)) {
+	if (!(vlan->flags & VLAN_FLAG_REORDER_HDR)) {
 		vhdr = (struct vlan_hdr *) skb_push(skb, VLAN_HLEN);
 
-		vlan_tci = vlan_dev_priv(dev)->vlan_id;
+		vlan_tci = vlan->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
 		vhdr->h_vlan_TCI = htons(vlan_tci);
 
@@ -133,7 +133,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 		saddr = dev->dev_addr;
 
 	/* Now make the underlying real hard header */
-	dev = vlan_dev_priv(dev)->real_dev;
+	dev = vlan->real_dev;
 	rc = dev_hard_header(skb, dev, type, daddr, saddr, len + vhdrlen);
 	if (rc > 0)
 		rc += vhdrlen;
-- 
1.7.10.4
