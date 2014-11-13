From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 3/3] fm10k/igb/ixgbe: Use load_acquire on Rx descriptor
Date: Thu, 13 Nov 2014 11:27:47 -0800
Message-ID: <20141113192746.12579.91054.stgit@ahduyck-server>
References: <20141113191250.12579.19694.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mikey@neuling.org, tony.luck@intel.com,
	mathieu.desnoyers@polymtl.ca, donald.c.skidmore@intel.com,
	peterz@infradead.org, benh@kernel.crashing.org,
	heiko.carstens@de.ibm.com, oleg@redhat.com, will.deacon@arm.com,
	davem@davemloft.net, michael@ellerman.id.au,
	matthew.vick@intel.com, nic_swsd@realtek.com, geert@linux-m68k.org,
	jeffrey.t.kirsher@intel.com, fweisbec@gmail.com,
	schwidefsky@de.ibm.com, linux@arm.linux.org.uk,
	paulmck@linux.vnet.ibm.com, torvalds@linux-foundation.org,
	mingo@kernel.org
To: linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141113191250.12579.19694.stgit@ahduyck-server>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change makes it so that load_acquire is used when reading the Rx
descriptor.  The advantage of load_acquire is that it allows for a much
lower cost barrier on x86, ia64, powerpc, arm64, and s390 architectures
than a traditional memory barrier when dealing with reads that only have
to synchronize to system memory.

In addition I have updated the code so that it just checks to see if any
bits have been set instead of just the DD bit since the DD bit will always
be set as a part of a descriptor write-back so we just need to check for a
non-zero value being present at that memory location rather than just
checking for any specific bit.  This allows the code itself to appear much
cleaner and allows the compiler more room to optimize.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |    8 +++-----
 drivers/net/ethernet/intel/igb/igb_main.c     |    8 +++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   11 ++++-------
 3 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index e645af4..2d4923c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -620,14 +620,12 @@ static bool fm10k_clean_rx_irq(struct fm10k_q_vector *q_vector,
 
 		rx_desc = FM10K_RX_DESC(rx_ring, rx_ring->next_to_clean);
 
-		if (!fm10k_test_staterr(rx_desc, FM10K_RXD_STATUS_DD))
-			break;
-
 		/* This memory barrier is needed to keep us from reading
 		 * any other fields out of the rx_desc until we know the
-		 * RXD_STATUS_DD bit is set
+		 * descriptor has been written back
 		 */
-		rmb();
+		if (!load_acquire(&rx_desc->d.staterr))
+			break;
 
 		/* retrieve a buffer from the ring */
 		skb = fm10k_fetch_rx_buffer(rx_ring, rx_desc, skb);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a2d72a8..a55cd54 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6918,14 +6918,12 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
 
 		rx_desc = IGB_RX_DESC(rx_ring, rx_ring->next_to_clean);
 
-		if (!igb_test_staterr(rx_desc, E1000_RXD_STAT_DD))
-			break;
-
 		/* This memory barrier is needed to keep us from reading
 		 * any other fields out of the rx_desc until we know the
-		 * RXD_STAT_DD bit is set
+		 * descriptor has been written back
 		 */
-		rmb();
+		if (!load_acquire(&rx_desc->wb.upper.status_error))
+			break;
 
 		/* retrieve a buffer from the ring */
 		skb = igb_fetch_rx_buffer(rx_ring, rx_desc, skb);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d2df4e3..007f174 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2003,15 +2003,12 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 
 		rx_desc = IXGBE_RX_DESC(rx_ring, rx_ring->next_to_clean);
 
-		if (!ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_DD))
-			break;
-
-		/*
-		 * This memory barrier is needed to keep us from reading
+		/* This memory barrier is needed to keep us from reading
 		 * any other fields out of the rx_desc until we know the
-		 * RXD_STAT_DD bit is set
+		 * descriptor has been written back
 		 */
-		rmb();
+		if (!load_acquire(&rx_desc->wb.upper.status_error))
+			break;
 
 		/* retrieve a buffer from the ring */
 		skb = ixgbe_fetch_rx_buffer(rx_ring, rx_desc);
