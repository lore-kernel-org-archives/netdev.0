From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] net: avoid uninitialized variable
Date: Thu, 27 Oct 2016 11:56:09 +0800
Message-ID: <1477540569-12199-1-git-send-email-zhongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <aduyck@mirantis.com>,
        <tom@herbertland.com>, <jiri@mellanox.com>, <fgao@ikuai8.com>,
        <hadarh@mellanox.com>, <amir@vadai.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: zhong jiang <zhongjiang@huawei.com>

when I compiler the newest kernel, I hit the following error with
Werror=may-uninitalized.

net/core/flow_dissector.c: In function ?._skb_flow_dissect?
include/uapi/linux/swab.h:100:46: error: ?.lan?.may be used uninitialized in this function [-Werror=maybe-uninitialized]
net/core/flow_dissector.c:248:26: note: ?.lan?.was declared here

This adds an additional check for proto to explicitly tell the compiler
that vlan pointer have the correct value before it is used.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 net/core/flow_dissector.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1a7b80f..a04d9cf 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -245,7 +245,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	}
 	case htons(ETH_P_8021AD):
 	case htons(ETH_P_8021Q): {
-		const struct vlan_hdr *vlan;
+		const struct vlan_hdr *vlan = NULL;
 
 		if (skb_vlan_tag_present(skb))
 			proto = skb->protocol;
@@ -276,7 +276,8 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 				key_vlan->vlan_id = skb_vlan_tag_get_id(skb);
 				key_vlan->vlan_priority =
 					(skb_vlan_tag_get_prio(skb) >> VLAN_PRIO_SHIFT);
-			} else {
+			} else if (proto == cpu_to_be16(ETH_P_8021Q) ||
+						proto == cpu_to_be16(ETH_P_8021AD)) {
 				key_vlan->vlan_id = ntohs(vlan->h_vlan_TCI) &
 					VLAN_VID_MASK;
 				key_vlan->vlan_priority =
-- 
1.8.3.1
