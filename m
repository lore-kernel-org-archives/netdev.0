From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v7 resubmit 4/4] fm10k/igb/ixgbe: Use dma_rmb on Rx
 descriptor reads
Date: Thu, 11 Dec 2014 15:02:28 -0800
Message-ID: <20141211230227.25464.647.stgit@ahduyck-server>
References: <20141211225250.25464.30291.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mathieu.desnoyers@polymtl.ca, peterz@infradead.org,
	benh@kernel.crashing.org, heiko.carstens@de.ibm.com,
	mingo@kernel.org, linux-arch@vger.kernel.org, mikey@neuling.org,
	linux@arm.linux.org.uk, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, geert@linux-m68k.org,
	jeffrey.t.kirsher@intel.com, romieu@fr.zoreil.com,
	paulmck@linux.vnet.ibm.com, nic_swsd@realtek.com, arnd@arndb.de,
	will.deacon@arm.com, michael@ellerman.id.au, tony.luck@intel.com,
	torvalds@linux-foundation.org, oleg@redhat.com,
	schwidefsky@de.ibm.com, fweisbec@gmail.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20141211225250.25464.30291.stgit@ahduyck-server>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change makes it so that dma_rmb is used when reading the Rx
descriptor.  The advantage of dma_rmb is that it allows for a much
lower cost barrier on x86, powerpc, arm, and arm64 architectures than a
traditional memory barrier when dealing with reads that only have to
synchronize to coherent memory.

In addition I have updated the code so that it just checks to see if any
bits have been set instead of just the DD bit since the DD bit will always
be set as a part of a descriptor write-back so we just need to check for a
non-zero value being present at that memory location rather than just
checking for any specific bit.  This allows the code itself to appear much
cleaner and allows the compiler more room to optimize.

Cc: Matthew Vick <matthew.vick@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |    6 +++---
 drivers/net/ethernet/intel/igb/igb_main.c     |    6 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    9 ++++-----
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index ee1ecb1..eb088b1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -615,14 +615,14 @@ static bool fm10k_clean_rx_irq(struct fm10k_q_vector *q_vector,
 
 		rx_desc = FM10K_RX_DESC(rx_ring, rx_ring->next_to_clean);
 
-		if (!fm10k_test_staterr(rx_desc, FM10K_RXD_STATUS_DD))
+		if (!rx_desc->d.staterr)
 			break;
 
 		/* This memory barrier is needed to keep us from reading
 		 * any other fields out of the rx_desc until we know the
-		 * RXD_STATUS_DD bit is set
+		 * descriptor has been written back
 		 */
-		rmb();
+		dma_rmb();
 
 		/* retrieve a buffer from the ring */
 		skb = fm10k_fetch_rx_buffer(rx_ring, rx_desc, skb);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 485d2c6..44f1174 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6912,14 +6912,14 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
 
 		rx_desc = IGB_RX_DESC(rx_ring, rx_ring->next_to_clean);
 
-		if (!igb_test_staterr(rx_desc, E1000_RXD_STAT_DD))
+		if (!rx_desc->wb.upper.status_error)
 			break;
 
 		/* This memory barrier is needed to keep us from reading
 		 * any other fields out of the rx_desc until we know the
-		 * RXD_STAT_DD bit is set
+		 * descriptor has been written back
 		 */
-		rmb();
+		dma_rmb();
 
 		/* retrieve a buffer from the ring */
 		skb = igb_fetch_rx_buffer(rx_ring, rx_desc, skb);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 798b055..2ed2c7d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2009,15 +2009,14 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 
 		rx_desc = IXGBE_RX_DESC(rx_ring, rx_ring->next_to_clean);
 
-		if (!ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_DD))
+		if (!rx_desc->wb.upper.status_error)
 			break;
 
-		/*
-		 * This memory barrier is needed to keep us from reading
+		/* This memory barrier is needed to keep us from reading
 		 * any other fields out of the rx_desc until we know the
-		 * RXD_STAT_DD bit is set
+		 * descriptor has been written back
 		 */
-		rmb();
+		dma_rmb();
 
 		/* retrieve a buffer from the ring */
 		skb = ixgbe_fetch_rx_buffer(rx_ring, rx_desc);
