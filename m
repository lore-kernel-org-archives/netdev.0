From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 4/4] ixgbevf: Fix checksum error when
	using stacked vlan
Date: Thu, 29 Jan 2015 20:37:10 +0900
Message-ID: <1422531430-32012-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1422531430-32012-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>, Linux NICS <linux.nics@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1422531430-32012-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When a skb has multiple vlans and it is CHECKSUM_PARTIAL,
ixgbevf_tx_csum() fails to get the network protocol and checksum related
descriptor fields are not configured correctly because skb->protocol
doesn't show the L3 protocol in this case.

Use first->protocol instead of skb->protocol to get the proper network
protocol.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 62a0d8e..38c7a0b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3099,7 +3099,7 @@ static int ixgbevf_tso(struct ixgbevf_ring *tx_ring,
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 	type_tucmd = IXGBE_ADVTXD_TUCMD_L4T_TCP;
 
-	if (skb->protocol == htons(ETH_P_IP)) {
+	if (first->protocol == htons(ETH_P_IP)) {
 		struct iphdr *iph = ip_hdr(skb);
 		iph->tot_len = 0;
 		iph->check = 0;
@@ -3156,7 +3156,7 @@ static void ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u8 l4_hdr = 0;
-		switch (skb->protocol) {
+		switch (first->protocol) {
 		case htons(ETH_P_IP):
 			vlan_macip_lens |= skb_network_header_len(skb);
 			type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
-- 
1.8.1.2



------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
