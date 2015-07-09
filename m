From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] neterion: s2io: Use module_pci_driver
Date: Thu, 9 Jul 2015 10:25:39 +0530
Message-ID: <20150709045539.GA7052@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jon Mason <jdmason@kudzu.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use module_pci_driver for drivers whose init and exit functions
only register and unregister, respectively.

A simplified version of the Coccinelle semantic patch that performs
this transformation is as follows:

@a@
identifier f, x;
@@
-static f(...) { return pci_register_driver(&x); }

@b depends on a@
identifier e, a.x;
statement S;
@@
-static e(...) {
-pci_unregister_driver(&x);
-DBG_PRINT(INIT_DBG,"S");
- }

@c depends on a && b@
identifier a.f;
declarer name module_init;
@@
-module_init(f);

@d depends on a && b && c@
identifier b.e, a.x;
declarer name module_exit;
declarer name module_pci_driver;
@@
-module_exit(e);
+module_pci_driver(x);

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 drivers/net/ethernet/neterion/s2io.c | 26 +-------------------------
 drivers/net/ethernet/neterion/s2io.h |  2 --
 2 files changed, 1 insertion(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index c281117..2d1b942 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -8226,31 +8226,7 @@ static void s2io_rem_nic(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-/**
- * s2io_starter - Entry point for the driver
- * Description: This function is the entry point for the driver. It verifies
- * the module loadable parameters and initializes PCI configuration space.
- */
-
-static int __init s2io_starter(void)
-{
-	return pci_register_driver(&s2io_driver);
-}
-
-/**
- * s2io_closer - Cleanup routine for the driver
- * Description: This function is the cleanup routine for the driver. It
- * unregisters the driver.
- */
-
-static __exit void s2io_closer(void)
-{
-	pci_unregister_driver(&s2io_driver);
-	DBG_PRINT(INIT_DBG, "cleanup done\n");
-}
-
-module_init(s2io_starter);
-module_exit(s2io_closer);
+module_pci_driver(s2io_driver);
 
 static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
 				struct tcphdr **tcp, struct RxD_t *rxdp,
diff --git a/drivers/net/ethernet/neterion/s2io.h b/drivers/net/ethernet/neterion/s2io.h
index d89b6ed..6c5997d 100644
--- a/drivers/net/ethernet/neterion/s2io.h
+++ b/drivers/net/ethernet/neterion/s2io.h
@@ -1085,8 +1085,6 @@ static void s2io_txpic_intr_handle(struct s2io_nic *sp);
 static void tx_intr_handler(struct fifo_info *fifo_data);
 static void s2io_handle_errors(void * dev_id);
 
-static int s2io_starter(void);
-static void s2io_closer(void);
 static void s2io_tx_watchdog(struct net_device *dev);
 static void s2io_set_multicast(struct net_device *dev);
 static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp);
-- 
1.9.1
