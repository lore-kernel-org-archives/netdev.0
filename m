From: Daode Huang <huangdaode@hisilicon.com>
Subject: [PATCH V2 net 1/6] net: hns: bug fix about the overflow of mss
Date: Fri, 11 Mar 2016 17:10:41 +0800
Message-ID: <1457687446-109867-2-git-send-email-huangdaode@hisilicon.com>
References: <1457687446-109867-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lisheng011@huawei.com, salil.mehta@huawei.com, yankejian@huawei.com,
 kenneth-lee-2012@foxmail.com, liguozhu@hisilicon.com, linuxarm@huawei.com,
 xuwei5@hisilicon.com, linux-kernel@vger.kernel.org, huangdaode@hisilicon.com,
 netdev@vger.kernel.org, Yisen.Zhuang@huawei.com,
 linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1457687446-109867-1-git-send-email-huangdaode@hisilicon.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

When set MTU to the minimum value 68, there are increasing number
of error packets occur, which is caused by the overflowed value of
mss. This patch fix the bug.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 3f77ff7..9d46d57 100644
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
@@ -90,13 +89,13 @@ static void fill_v2_desc(struct hnae_ring *ring, void *priv,
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
@@ -104,13 +103,13 @@ static void fill_v2_desc(struct hnae_ring *ring, void *priv,
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
