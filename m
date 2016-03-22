From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH V2 net 10/10] net: hns: bug fix about the overflow of mss
Date: Tue, 22 Mar 2016 16:06:31 +0800
Message-ID: <1458633991-64313-11-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>, <arnd@arndb.de>,
	<sergei.shtylyov@cogentembedded.com>, <xieqianqian@huawei.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:31778 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127AbcCVHs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 03:48:26 -0400
In-Reply-To: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daode Huang <huangdaode@hisilicon.com>

When set MTU to the minimum value 68, there are increasing number
of error packets occur, which is caused by the overflowed value of
mss. This patch fix the bug.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index ef517af..71aa37b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -48,7 +48,6 @@ static void fill_v2_desc(struct hnae_ring *ring, void *priv,
 	struct iphdr *iphdr;
 	struct ipv6hdr *ipv6hdr;
 	struct sk_buff *skb;
-	int skb_tmp_len;
 	__be16 protocol;
 	u8 bn_pid = 0;
 	u8 rrcfv = 0;
@@ -94,13 +93,13 @@ static void fill_v2_desc(struct hnae_ring *ring, void *priv,
 				hnae_set_bit(rrcfv, HNSV2_TXD_L4CS_B, 1);
 
 				/* check for tcp/udp header */
-				if (iphdr->protocol == IPPROTO_TCP) {
+				if (iphdr->protocol == IPPROTO_TCP &&
+				    skb_is_gso(skb)) {
 					hnae_set_bit(tvsvsn,
 						     HNSV2_TXD_TSE_B, 1);
-					skb_tmp_len = SKB_TMP_LEN(skb);
 					l4_len = tcp_hdrlen(skb);
-					mss = mtu - skb_tmp_len - ETH_FCS_LEN;
-					paylen = skb->len - skb_tmp_len;
+					mss = skb_shinfo(skb)->gso_size;
+					paylen = skb->len - SKB_TMP_LEN(skb);
 				}
 			} else if (skb->protocol == htons(ETH_P_IPV6)) {
 				hnae_set_bit(tvsvsn, HNSV2_TXD_IPV6_B, 1);
@@ -108,13 +107,13 @@ static void fill_v2_desc(struct hnae_ring *ring, void *priv,
 				hnae_set_bit(rrcfv, HNSV2_TXD_L4CS_B, 1);
 
 				/* check for tcp/udp header */
-				if (ipv6hdr->nexthdr == IPPROTO_TCP) {
+				if (ipv6hdr->nexthdr == IPPROTO_TCP &&
+				    skb_is_gso(skb) && skb_is_gso_v6(skb)) {
 					hnae_set_bit(tvsvsn,
 						     HNSV2_TXD_TSE_B, 1);
-					skb_tmp_len = SKB_TMP_LEN(skb);
 					l4_len = tcp_hdrlen(skb);
-					mss = mtu - skb_tmp_len - ETH_FCS_LEN;
-					paylen = skb->len - skb_tmp_len;
+					mss = skb_shinfo(skb)->gso_size;
+					paylen = skb->len - SKB_TMP_LEN(skb);
 				}
 			}
 			desc->tx.ip_offset = ip_offset;
-- 
1.9.1
