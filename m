From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2-net-3.8 1/3] ixgbe: fix gso type
Date: Thu, 7 Feb 2013 15:13:05 +0200
Message-ID: <e1e4fe6d356c2766cd6a962a3ef6439bfd94a985.1360236441.git.mst@redhat.com>
References: <cover.1360236441.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, e1000-devel@lists.sourceforge.net,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Sony Chacko <sony.chacko@qlogic.com>, linux-driver@qlogic.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <cover.1360236441.git.mst@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

ixgbe set gso_size but not gso_type. This leads to
crashes in macvtap.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 20a5af6..e1b2d22 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1401,6 +1401,10 @@ static void ixgbe_set_rsc_gso_size(struct ixgbe_ring *ring,
 	/* set gso_size to avoid messing up TCP MSS */
 	skb_shinfo(skb)->gso_size = DIV_ROUND_UP((skb->len - hdr_len),
 						 IXGBE_CB(skb)->append_cnt);
+	if (skb->protocol == __constant_htons(ETH_P_IPV6))
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+	else
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
 }
 
 static void ixgbe_update_rsc_stats(struct ixgbe_ring *rx_ring,
@@ -1435,6 +1439,8 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 {
 	struct net_device *dev = rx_ring->netdev;
 
+	skb->protocol = eth_type_trans(skb, dev);
+
 	ixgbe_update_rsc_stats(rx_ring, skb);
 
 	ixgbe_rx_hash(rx_ring, rx_desc, skb);
@@ -1450,8 +1456,6 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 	}
 
 	skb_record_rx_queue(skb, rx_ring->queue_index);
-
-	skb->protocol = eth_type_trans(skb, dev);
 }
 
 static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
-- 
MST


------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
