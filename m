From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 4/4] bridge: Notify port device of encap header length
Date: Fri, 23 Oct 2015 12:49:33 +0900
Message-ID: <1445572173-15402-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1445572173-15402-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:37473 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478AbbJWDuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 23:50:04 -0400
In-Reply-To: <1445572173-15402-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If vlan is assigned to a port, notify the port of 4 bytes header length,
or 8 bytes if 802.1ad.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_vlan.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 5f0d0cc..9c678de 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -208,6 +208,8 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 	}
 
 	if (p) {
+		int enc_hdr_len;
+
 		/* Add VLAN to the device filter if it is supported.
 		 * This ensures tagged traffic enters the bridge when
 		 * promiscuous mode is disabled by br_manage_promisc().
@@ -228,6 +230,13 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 		if (!masterv)
 			goto out_filt;
 		v->brvlan = masterv;
+
+		if (!vg->num_vlans) {
+			enc_hdr_len = VLAN_HLEN;
+			if (br->vlan_proto == htons(ETH_P_8021AD))
+				enc_hdr_len += VLAN_HLEN;
+			dev_set_enc_hdr_len(dev, enc_hdr_len);
+		}
 	}
 
 	/* Add the dev mac and count the vlan only if it's usable */
@@ -667,6 +676,15 @@ int __br_vlan_set_proto(struct net_bridge *br, __be16 proto)
 		}
 	}
 
+	if (proto == htons(ETH_P_8021AD)) {
+		list_for_each_entry(p, &br->port_list, list) {
+			if (!p->vlgrp->num_vlans)
+				continue;
+
+			dev_set_enc_hdr_len(p->dev, VLAN_HLEN * 2);
+		}
+	}
+
 	oldproto = br->vlan_proto;
 	br->vlan_proto = proto;
 
-- 
1.8.1.2
