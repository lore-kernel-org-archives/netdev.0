From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 5/9] net: fddi/defxx: avoid warning about uninitialized variable use
Date: Wed, 27 Jan 2016 15:04:55 +0100
Message-ID: <1453903507-3427225-6-git-send-email-arnd@arndb.de>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The defxx driver can be configured for different kinds of buses,
and appears to be handling this correctly, but the compiler cannot
see how it always initializes the bar_start and bar_length
fields it uses depending on the configured bus, so we get a warning
with recent gcc versions:

fddi/defxx.c: In function 'dfx_pci_unregister':
fddi/defxx.c:3726:3: warning: 'bar_len' may be used uninitialized in this function [-Wmaybe-uninitialized]
   release_mem_region(bar_start[0], bar_len[0]);
fddi/defxx.c:3701:18: note: 'bar_len' was declared here
  resource_size_t bar_len[3];  /* resource lengths */
fddi/defxx.c:3726:3: warning: 'bar_start' may be used uninitialized in this function [-Wmaybe-uninitialized]
   release_mem_region(bar_start[0], bar_len[0]);
fddi/defxx.c:3700:18: note: 'bar_start' was declared here
  resource_size_t bar_start[3];  /* pointers to ports */
                  ^
fddi/defxx.c: In function 'dfx_pci_register':
fddi/defxx.c:617:18: warning: 'bar_len' may be used uninitialized in this function [-Wmaybe-uninitialized]
   bp->base.mem = ioremap_nocache(bar_start[0], bar_len[0]);
fddi/defxx.c:537:18: note: 'bar_len' was declared here
  resource_size_t bar_len[3];  /* resource length */
fddi/defxx.c:1125:2: warning: 'bar_start' may be used uninitialized in this function [-Wmaybe-uninitialized]
  pr_info("%s: %s at %s addr = 0x%llx, IRQ = %d, Hardware addr = %pMF\n",
fddi/defxx.c:536:18: note: 'bar_start' was declared here
  resource_size_t bar_start[3];  /* pointers to ports */

This adds code to ensure that the BAR values are initialized
even in the impossible case when a device gets probed that
does not belong to any bus. This shuts up the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/fddi/defxx.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 7f975a2c8990..e7cdd1226d39 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -484,6 +484,11 @@ static void dfx_get_bars(struct device *bdev,
 		bar_start[2] = bar_start[1] = 0;
 		bar_len[2] = bar_len[1] = 0;
 	}
+	if (!(dfx_bus_pci || dfx_bus_eisa || dfx_bus_tc)) {
+		dev_err(bdev, "invalid bus configuration\n");
+		bar_start[2] = bar_start[1] = bar_start[0] = 0;
+		bar_len[2] = bar_len[1] = bar_len[0] = 0;
+	}
 }
 
 static const struct net_device_ops dfx_netdev_ops = {
-- 
2.7.0
