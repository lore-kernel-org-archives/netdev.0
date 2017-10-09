From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40e/i40evf: bump tail only in multiples of 8
Date: Mon,  9 Oct 2017 15:38:34 -0700
Message-ID: <20171009223841.2557-8-jeffrey.t.kirsher@intel.com>
References: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36096 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755507AbdJIWjG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 18:39:06 -0400
In-Reply-To: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Hardware only fetches descriptors on cachelines of 8, essentially
ignoring the lower 3 bits of the tail register. Thus, it is pointless to
bump tail by an unaligned access as the hardware will ignore some of the
new descriptors we allocated. Thus, it's ideal if we can ensure tail
writes are always aligned to 8.

At first, it seems like we'd already do this, since we allocate
descriptors in batches which are a multiple of 8. Since we'd always
increment by a multiple of 8, it seems like the value should always be
aligned.

However, this ignores allocation failures. If we fail to allocate
a buffer, our tail register will become unaligned. Once it has become
unaligned it will essentially be stuck unaligned until a buffer
allocation happens to fail at the exact amount necessary to re-align it.

We can do better, by simply rounding down the number of buffers we're
about to allocate (cleaned_count) such that "next_to_clean
+ cleaned_count" is rounded to the nearest multiple of 8.

We do this by calculating how far off that value is and subtracting it
from the cleaned_count. This essentially defers allocation of buffers if
they're going to be ignored by hardware anyways, and re-aligns our
next_to_use and tail values after a failure to allocate a descriptor.

This calculation ensures that we always align the tail writes in a way
the hardware expects and don't unnecessarily allocate buffers which
won't be fetched immediately.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 9 +++++++++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 9 +++++++++
 2 files changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 616abf79253e..a23306f04e00 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1372,6 +1372,15 @@ bool i40e_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 	union i40e_rx_desc *rx_desc;
 	struct i40e_rx_buffer *bi;
 
+	/* Hardware only fetches new descriptors in cache lines of 8,
+	 * essentially ignoring the lower 3 bits of the tail register. We want
+	 * to ensure our tail writes are aligned to avoid unnecessary work. We
+	 * can't simply round down the cleaned count, since we might fail to
+	 * allocate some buffers. What we really want is to ensure that
+	 * next_to_used + cleaned_count produces an aligned value.
+	 */
+	cleaned_count -= (ntu + cleaned_count) & 0x7;
+
 	/* do nothing if no valid netdev defined */
 	if (!rx_ring->netdev || !cleaned_count)
 		return false;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index fe817e2b6fef..6806ada11490 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -711,6 +711,15 @@ bool i40evf_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 	union i40e_rx_desc *rx_desc;
 	struct i40e_rx_buffer *bi;
 
+	/* Hardware only fetches new descriptors in cache lines of 8,
+	 * essentially ignoring the lower 3 bits of the tail register. We want
+	 * to ensure our tail writes are aligned to avoid unnecessary work. We
+	 * can't simply round down the cleaned count, since we might fail to
+	 * allocate some buffers. What we really want is to ensure that
+	 * next_to_used + cleaned_count produces an aligned value.
+	 */
+	cleaned_count -= (ntu + cleaned_count) & 0x7;
+
 	/* do nothing if no valid netdev defined */
 	if (!rx_ring->netdev || !cleaned_count)
 		return false;
-- 
2.14.2
