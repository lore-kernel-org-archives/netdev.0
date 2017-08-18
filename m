From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 3/3] net: hns3: Fixes the static check warning due to missing unsupp L3 proto check
Date: Fri, 18 Aug 2017 12:31:39 +0100
Message-ID: <20170818113139.153200-4-salil.mehta@huawei.com>
References: <20170818113139.153200-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <lipeng321@huawei.com>, <dan.carpenter@oracle.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818113139.153200-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the static check warning due to missing handling leg of
unsupported L3 protocol type in the hns3_get_l4_protocol() function.

Fixes: 76ad4f0ee747 ("net: hns3: Add support of HNS3 Ethernet Driver for
hip08 SoC")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index b12730a..e731f87 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -436,8 +436,8 @@ static int hns3_set_tso(struct sk_buff *skb, u32 *paylen,
 	return 0;
 }
 
-static void hns3_get_l4_protocol(struct sk_buff *skb, u8 *ol4_proto,
-				 u8 *il4_proto)
+static int hns3_get_l4_protocol(struct sk_buff *skb, u8 *ol4_proto,
+				u8 *il4_proto)
 {
 	union {
 		struct iphdr *v4;
@@ -461,6 +461,8 @@ static void hns3_get_l4_protocol(struct sk_buff *skb, u8 *ol4_proto,
 					 &l4_proto_tmp, &frag_off);
 	} else if (skb->protocol == htons(ETH_P_IP)) {
 		l4_proto_tmp = l3.v4->protocol;
+	} else {
+		return -EINVAL;
 	}
 
 	*ol4_proto = l4_proto_tmp;
@@ -468,7 +470,7 @@ static void hns3_get_l4_protocol(struct sk_buff *skb, u8 *ol4_proto,
 	/* tunnel packet */
 	if (!skb->encapsulation) {
 		*il4_proto = 0;
-		return;
+		return 0;
 	}
 
 	/* find inner header point */
@@ -486,6 +488,8 @@ static void hns3_get_l4_protocol(struct sk_buff *skb, u8 *ol4_proto,
 	}
 
 	*il4_proto = l4_proto_tmp;
+
+	return 0;
 }
 
 static void hns3_set_l2l3l4_len(struct sk_buff *skb, u8 ol4_proto,
@@ -757,7 +761,9 @@ static int hns3_fill_desc(struct hns3_enet_ring *ring, void *priv,
 				protocol = vlan_get_protocol(skb);
 				skb->protocol = protocol;
 			}
-			hns3_get_l4_protocol(skb, &ol4_proto, &il4_proto);
+			ret = hns3_get_l4_protocol(skb, &ol4_proto, &il4_proto);
+			if (ret)
+				return ret;
 			hns3_set_l2l3l4_len(skb, ol4_proto, il4_proto,
 					    &type_cs_vlan_tso,
 					    &ol_type_vlan_len_msec);
-- 
2.7.4
