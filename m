From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH] liquidio: stop using huge static buffer, save 4096k in .data
Date: Mon, 19 Jun 2017 21:50:52 +0200
Message-ID: <20170619195052.13176-1-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
        Felix Manlunas <felix.manlunas@cavium.com>,
        Prasad Kanneganti <prasad.kanneganti@cavium.com>,
        Derek Chickles <derek.chickles@cavium.com>,
        David Miller <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only compile-tested - I don't have the hardware.

>From code inspection, octeon_pci_write_core_mem() appears to be safe wrt
unaligned source. In any case, u8 fbuf[] was not guaranteed to be aligned
anyway.

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: Felix Manlunas <felix.manlunas@cavium.com>
CC: Prasad Kanneganti <prasad.kanneganti@cavium.com>
CC: Derek Chickles <derek.chickles@cavium.com>
CC: David Miller <davem@davemloft.net>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/cavium/liquidio/octeon_console.c | 6 +-----
 drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c | 4 ++--
 drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h | 2 +-
 3 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index 53f38d0..e08f760 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -724,13 +724,11 @@ static int octeon_console_read(struct octeon_device *oct, u32 console_num,
 }
 
 #define FBUF_SIZE	(4 * 1024 * 1024)
-u8 fbuf[FBUF_SIZE];
 
 int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 			     size_t size)
 {
 	int ret = 0;
-	u8 *p = fbuf;
 	u32 crc32_result;
 	u64 load_addr;
 	u32 image_len;
@@ -805,10 +803,8 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 			else
 				size = FBUF_SIZE;
 
-			memcpy(p, data, size);
-
 			/* download the image */
-			octeon_pci_write_core_mem(oct, load_addr, p, (u32)size);
+			octeon_pci_write_core_mem(oct, load_addr, data, (u32)size);
 
 			data += size;
 			rem -= (u32)size;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
index 5cd96e7..4c85ae6 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
@@ -167,10 +167,10 @@ octeon_pci_read_core_mem(struct octeon_device *oct,
 void
 octeon_pci_write_core_mem(struct octeon_device *oct,
 			  u64 coreaddr,
-			  u8 *buf,
+			  const u8 *buf,
 			  u32 len)
 {
-	__octeon_pci_rw_core_mem(oct, coreaddr, buf, len, 0);
+	__octeon_pci_rw_core_mem(oct, coreaddr, (u8 *)buf, len, 0);
 }
 
 u64 octeon_read_device_mem64(struct octeon_device *oct, u64 coreaddr)
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h
index bae2fdd..47a3ff5 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h
@@ -66,7 +66,7 @@ octeon_pci_read_core_mem(struct octeon_device *oct,
 void
 octeon_pci_write_core_mem(struct octeon_device *oct,
 			  u64 coreaddr,
-			  u8 *buf,
+			  const u8 *buf,
 			  u32 len);
 
 #endif
-- 
2.9.2
