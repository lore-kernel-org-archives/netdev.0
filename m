From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] i40e/i40evf: Revert "i40e/i40evf: bump tail only in multiples of 8"
Date: Tue, 31 Oct 2017 11:40:06 -0700
Message-ID: <20171031184012.29690-4-jeffrey.t.kirsher@intel.com>
References: <20171031184012.29690-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4615 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932605AbdJaSkg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 14:40:36 -0400
In-Reply-To: <20171031184012.29690-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This reverts commit 11f29003d6376fb123b7c3779dba49bb56fb0815.

I am reverting this as I am fairly certain this can result in a memory leak
when combined with the current page recycling scheme. Specifically we end
up attempting to allocate fewer buffers than we recycled and this results
in us rewinding the next to alloc pointer which leads to leaks when we
overwrite the rx_buffer_info when processing the next frame.

Fixes: 11f29003d637 ("i40e/i40evf: bump tail only in multiples of 8")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 9 ---------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 9 ---------
 2 files changed, 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index c5cd233c8fee..d6d352a6e6ea 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1407,15 +1407,6 @@ bool i40e_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 	union i40e_rx_desc *rx_desc;
 	struct i40e_rx_buffer *bi;
 
-	/* Hardware only fetches new descriptors in cache lines of 8,
-	 * essentially ignoring the lower 3 bits of the tail register. We want
-	 * to ensure our tail writes are aligned to avoid unnecessary work. We
-	 * can't simply round down the cleaned count, since we might fail to
-	 * allocate some buffers. What we really want is to ensure that
-	 * next_to_used + cleaned_count produces an aligned value.
-	 */
-	cleaned_count -= (ntu + cleaned_count) & 0x7;
-
 	/* do nothing if no valid netdev defined */
 	if (!rx_ring->netdev || !cleaned_count)
 		return false;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 6806ada11490..fe817e2b6fef 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -711,15 +711,6 @@ bool i40evf_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 	union i40e_rx_desc *rx_desc;
 	struct i40e_rx_buffer *bi;
 
-	/* Hardware only fetches new descriptors in cache lines of 8,
-	 * essentially ignoring the lower 3 bits of the tail register. We want
-	 * to ensure our tail writes are aligned to avoid unnecessary work. We
-	 * can't simply round down the cleaned count, since we might fail to
-	 * allocate some buffers. What we really want is to ensure that
-	 * next_to_used + cleaned_count produces an aligned value.
-	 */
-	cleaned_count -= (ntu + cleaned_count) & 0x7;
-
 	/* do nothing if no valid netdev defined */
 	if (!rx_ring->netdev || !cleaned_count)
 		return false;
-- 
2.14.2
