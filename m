From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] vmxnet3: prevent building with 64K pages
Date: Fri, 17 Feb 2017 16:08:30 +0100
Message-ID: <20170217150847.2505538-1-arnd@arndb.de>
Cc: Shrikrishna Khare <skhare@vmware.com>,
        "VMware Inc ." <pv-drivers@vmware.com>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I got a warning about broken code on ARM64 with 64K pages:

drivers/net/vmxnet3/vmxnet3_drv.c: In function 'vmxnet3_rq_init':
drivers/net/vmxnet3/vmxnet3_drv.c:1679:29: error: large integer implicitly truncated to unsigned type [-Werror=overflow]
    rq->buf_info[0][i].len = PAGE_SIZE;

'len' here is a 16-bit integer, so this clearly won't work. I don't think
this driver is used much on anything other than x86, so there is no need
to fix this properly and we can work around it with a Kconfig dependency
to forbid known-broken configurations. qemu in theory supports it on
other architectures too, but presumably only for compatibility with x86
guests that also run on vmware.

CONFIG_PAGE_SIZE_64KB is used on hexagon, mips, sh and tile, the other
symbols are architecture-specific names for the same thing.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/Kconfig | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4c07a067df1d..8a49fedb80ef 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -458,6 +458,9 @@ config XEN_NETDEV_BACKEND
 config VMXNET3
 	tristate "VMware VMXNET3 ethernet driver"
 	depends on PCI && INET
+	depends on !(PAGE_SIZE_64KB || ARM64_64K_PAGES || \
+		     IA64_PAGE_SIZE_64KB || MICROBLAZE_64K_PAGES || \
+		     PARISC_PAGE_SIZE_64KB || PPC_64K_PAGES)
 	help
 	  This driver supports VMware's vmxnet3 virtual ethernet NIC.
 	  To compile this driver as a module, choose M here: the
-- 
2.9.0
