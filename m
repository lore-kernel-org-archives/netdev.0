From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: Question about skb_flow_dissect() and 802.1q/802.1ad
Date: Fri, 07 Feb 2014 20:44:12 +0200
Message-ID: <1396838.WXqPOv9eKS@tuxracer>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback1.mail.ru ([94.100.176.18]:49091 "EHLO
	fallback1.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbaBGSof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 13:44:35 -0500
Received: from smtp9.mail.ru (smtp9.mail.ru [94.100.176.54])
	by fallback1.mail.ru (mPOP.Fallback_MX) with ESMTP id F1E1333A957C
	for <netdev@vger.kernel.org>; Fri,  7 Feb 2014 22:44:32 +0400 (MSK)
Received: from [2a01:6d80:103:13::c3ea:4404] (port=50426 helo=tuxracer.localnet)
	by smtp9.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1WBqPU-0002th-8f
	for netdev@vger.kernel.org; Fri, 07 Feb 2014 22:44:20 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello.

skb_flow_dissect() adds good code reuse for common task
of finding information in protocol headers and used in various
places.

One of such place since commit 32819dc183 (bonding: modify the old and add
new xmit hash policies) is bonding interface.

My question is following:
-------------------------
  why network offset is used in skb_flow_dissector() when looking for 
  802.1q/802.1ad header instead of skb->data?

At least affects stacked vlans setup on top of bonding interface (where not
HW VLAN TX available, tag is put into skb in xmit path, and skb->protocol ==
htons(ETH_P_8021Q). Bonding is setup on top of HW VLAN TX capable network
interface (igb) with 802.3ad (LACP) mode and xmit_hash_policy encap2+3.

In this setup skb_flow_dissect() fails to get information from protocol headers
encapsulated within inner vlan, probably because it uses network offset instead
of skb->data.

Hashing is performed on layer 2 information as fallback when skb_flow_dissect()
fails. Which affects packet distribution accross slaves.

However, stacked vlans on top of bonding interface was not working in the past,
so commit 32819dc183 does not introduce regression. Furthermore starting from
such one I expect stacked vlans on top of bonding to work in encap2+3 and
encap3+4 xmit hash policies, as skb_flow_dissect() knowns about such
encapsulations and should take case of them.

Simple patch, that seems to work for me listed below.

---
 net/core/flow_dissector.c |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index b4f9af8..7cdf13b 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -52,6 +52,7 @@ EXPORT_SYMBOL(skb_flow_get_ports);
 bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
 {
 	int nhoff = skb_network_offset(skb);
+	int vhoff = offsetof(struct vlan_ethhdr, h_vlan_TCI);
 	u8 ip_proto;
 	__be16 proto = skb->protocol;
 
@@ -91,15 +92,19 @@ ipv6:
 	}
 	case __constant_htons(ETH_P_8021AD):
 	case __constant_htons(ETH_P_8021Q): {
-		const struct vlan_hdr *vlan;
-		struct vlan_hdr _vlan;
+		const struct vlan_hdr *hdr;
+		struct vlan_hdr _hdr;
 
-		vlan = skb_header_pointer(skb, nhoff, sizeof(_vlan), &_vlan);
-		if (!vlan)
+		BUILD_BUG_ON(sizeof(struct vlan_ethhdr) !=
+			     offsetof(struct vlan_ethhdr, h_vlan_TCI) +
+			     sizeof(*hdr));
+
+		hdr = skb_header_pointer(skb, vhoff, sizeof(_hdr), &_hdr);
+		if (!hdr)
 			return false;
 
-		proto = vlan->h_vlan_encapsulated_proto;
-		nhoff += sizeof(*vlan);
+		proto = hdr->h_vlan_encapsulated_proto;
+		vhoff += sizeof(*hdr);
 		goto again;
 	}
 	case __constant_htons(ETH_P_PPP_SES): {
-- 
1.7.10.4


SP5474-RIPE
Sergey Popovich
