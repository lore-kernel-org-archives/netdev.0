From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: optimize reads from Octeon PCI console
Date: Thu, 29 Dec 2016 17:04:47 -0800
Message-ID: <20161230010447.GA6015@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0085.outbound.protection.outlook.com ([104.47.42.85]:10912
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750874AbcL3BFq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Dec 2016 20:05:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reads from Octeon PCI console are inefficient because before each read
operation, a dynamic mapping to Octeon DRAM is set up.  This patch replaces
the repeated setup of a dynamic mapping with a one-time setup of a static
mapping.

Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 .../net/ethernet/cavium/liquidio/octeon_config.h    | 10 +++-------
 .../net/ethernet/cavium/liquidio/octeon_console.c   | 10 ++++++++++
 .../net/ethernet/cavium/liquidio/octeon_device.h    |  6 ++++++
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.c   | 21 ++++++++++++++++++++-
 4 files changed, 39 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
index 1cb3514..b3dc2e9 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_config.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
@@ -429,15 +429,11 @@ struct octeon_config {
 
 /* The following config values are fixed and should not be modified. */
 
-/* Maximum address space to be mapped for Octeon's BAR1 index-based access. */
-#define  MAX_BAR1_MAP_INDEX                     2
+#define  BAR1_INDEX_DYNAMIC_MAP          2
+#define  BAR1_INDEX_STATIC_MAP          15
 #define  OCTEON_BAR1_ENTRY_SIZE         (4 * 1024 * 1024)
 
-/* BAR1 Index 0 to (MAX_BAR1_MAP_INDEX - 1) for normal mapped memory access.
- * Bar1 register at MAX_BAR1_MAP_INDEX used by driver for dynamic access.
- */
-#define  MAX_BAR1_IOREMAP_SIZE  ((MAX_BAR1_MAP_INDEX + 1) * \
-				 OCTEON_BAR1_ENTRY_SIZE)
+#define  MAX_BAR1_IOREMAP_SIZE  (16 * OCTEON_BAR1_ENTRY_SIZE)
 
 /* Response lists - 1 ordered, 1 unordered-blocking, 1 unordered-nonblocking
  * NoResponse Lists are now maintained with each IQ. (Dec' 2007).
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index 3265e0b..42b673d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -549,6 +549,16 @@ int octeon_init_consoles(struct octeon_device *oct)
 		return ret;
 	}
 
+	/* Dedicate one of Octeon's BAR1 index registers to create a static
+	 * mapping to a region of Octeon DRAM that contains the PCI console
+	 * named block.
+	 */
+	oct->console_nb_info.bar1_index = BAR1_INDEX_STATIC_MAP;
+	oct->fn_list.bar1_idx_setup(oct, addr, oct->console_nb_info.bar1_index,
+				    true);
+	oct->console_nb_info.dram_region_base = addr
+		& ~(OCTEON_BAR1_ENTRY_SIZE - 1ULL);
+
 	/* num_consoles > 0, is an indication that the consoles
 	 * are accessible
 	 */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 18f6836..c301a38 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -477,6 +477,12 @@ struct octeon_device {
 	/* Console caches */
 	struct octeon_console console[MAX_OCTEON_MAPS];
 
+	/* Console named block info */
+	struct {
+		u64 dram_region_base;
+		int bar1_index;
+	} console_nb_info;
+
 	/* Coprocessor clock rate. */
 	u64 coproc_clock_rate;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
index 13a18c9..5cd96e7 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
@@ -23,7 +23,7 @@
 #include "response_manager.h"
 #include "octeon_device.h"
 
-#define MEMOPS_IDX   MAX_BAR1_MAP_INDEX
+#define MEMOPS_IDX   BAR1_INDEX_DYNAMIC_MAP
 
 #ifdef __BIG_ENDIAN_BITFIELD
 static inline void
@@ -96,6 +96,25 @@ __octeon_pci_rw_core_mem(struct octeon_device *oct, u64 addr,
 	u32 copy_len = 0, index_reg_val = 0;
 	unsigned long flags;
 	u8 __iomem *mapped_addr;
+	u64 static_mapping_base;
+
+	static_mapping_base = oct->console_nb_info.dram_region_base;
+
+	if (static_mapping_base &&
+	    static_mapping_base == (addr & ~(OCTEON_BAR1_ENTRY_SIZE - 1ULL))) {
+		int bar1_index = oct->console_nb_info.bar1_index;
+
+		mapped_addr = oct->mmio[1].hw_addr
+			+ (bar1_index << ilog2(OCTEON_BAR1_ENTRY_SIZE))
+			+ (addr & (OCTEON_BAR1_ENTRY_SIZE - 1ULL));
+
+		if (op)
+			octeon_pci_fastread(oct, mapped_addr, hostbuf, len);
+		else
+			octeon_pci_fastwrite(oct, mapped_addr, hostbuf, len);
+
+		return;
+	}
 
 	spin_lock_irqsave(&oct->mem_access_lock, flags);
 
