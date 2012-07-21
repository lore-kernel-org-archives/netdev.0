From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] ixgbe: Reduce Rx header size to what is actually used
Date: Sat, 21 Jul 2012 16:08:56 -0700
Message-ID: <1342912142-11130-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:22894 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751975Ab2GUXJK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 19:09:10 -0400
In-Reply-To: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The recent changes to netdev_alloc_skb actually make it so that the size of
the buffer now actually has a more direct input on the truesize.  So in
order to make best use of the piece of a page we are allocated I am
reducing the IXGBE_RX_HDR_SIZE to 256 so that our truesize will be reduced
by 256 bytes as well.

This should result in performance improvements since the number of uses per
page should increase from 4 to 6 in the case of a 4K page.  In addition we
should see socket performance improvements due to the truesize dropping
to less than 1K for buffers less than 256 bytes.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   15 ++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index eb59282..b9623e9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -77,17 +77,18 @@
 #define IXGBE_MAX_FCPAUSE		 0xFFFF
 
 /* Supported Rx Buffer Sizes */
-#define IXGBE_RXBUFFER_512   512    /* Used for packet split */
+#define IXGBE_RXBUFFER_256    256  /* Used for skb receive header */
 #define IXGBE_MAX_RXBUFFER  16384  /* largest size for a single descriptor */
 
 /*
- * NOTE: netdev_alloc_skb reserves up to 64 bytes, NET_IP_ALIGN mans we
- * reserve 2 more, and skb_shared_info adds an additional 384 bytes more,
- * this adds up to 512 bytes of extra data meaning the smallest allocation
- * we could have is 1K.
- * i.e. RXBUFFER_512 --> size-1024 slab
+ * NOTE: netdev_alloc_skb reserves up to 64 bytes, NET_IP_ALIGN means we
+ * reserve 64 more, and skb_shared_info adds an additional 320 bytes more,
+ * this adds up to 448 bytes of extra data.
+ *
+ * Since netdev_alloc_skb now allocates a page fragment we can use a value
+ * of 256 and the resultant skb will have a truesize of 960 or less.
  */
-#define IXGBE_RX_HDR_SIZE IXGBE_RXBUFFER_512
+#define IXGBE_RX_HDR_SIZE IXGBE_RXBUFFER_256
 
 #define MAXIMUM_ETHERNET_VLAN_SIZE (ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7be3504..b376926 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1517,8 +1517,8 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring *rx_ring,
 	 * 60 bytes if the skb->len is less than 60 for skb_pad.
 	 */
 	pull_len = skb_frag_size(frag);
-	if (pull_len > 256)
-		pull_len = ixgbe_get_headlen(va, pull_len);
+	if (pull_len > IXGBE_RX_HDR_SIZE)
+		pull_len = ixgbe_get_headlen(va, IXGBE_RX_HDR_SIZE);
 
 	/* align pull length to size of long to optimize memcpy performance */
 	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
-- 
1.7.10.4
