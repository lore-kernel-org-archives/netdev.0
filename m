From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x prism54 fixes
Date: Tue, 27 Jul 2004 15:52:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040727195219.GA29777@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/wireless/prism54/isl_ioctl.c      |   16 +++++++++-------
 drivers/net/wireless/prism54/islpci_hotplug.c |   17 ++++++++++-------
 drivers/net/wireless/prism54/islpci_mgt.c     |    2 ++
 drivers/net/wireless/prism54/oid_mgt.c        |    6 ++++--
 4 files changed, 25 insertions(+), 16 deletions(-)

through these ChangeSets:

<margitsw@t-online.de> (04/07/27 1.1932)
   [PATCH] prism54 Fix null pointer reference (Bug 100)
   
   * prism54_get/set_debug_oid are missing checks for a null pointer.
     Reported in Bugzilla number 100.

<margitsw@t-online.de> (04/07/27 1.1931)
   [PATCH] prism54 Fix initialization with older firmware
   
   * In the card initialization routine, we try to set the
     output power. For firmware < 1.0.4.3, this leads to a
     worrying "mgt_commit has failed .." in the log although
     the device continues to react normally.
     Fix is simple, do not try to configure output power.
     (which I believe we should not be doing anyway as it is
      probably against local country regulations)

<margitsw@t-online.de> (04/07/27 1.1930)
   [PATCH] prism54 Refix TRDY/RETRY_TIMEOUT
   
   * Reintroduce pushing 0 into the TRDY_TIMEOUT and RETRY_TIMEOUT
     registers. Make this configurable with module parameter
     init_pcitm.
   
   * We now have the ludicrous situation that some hardware setups
     require this (not even pushing 0xFF helps), whilst others
     don't care either way (the majority), and yet others bork
     if anything is pushed into these regs.
     If anybody can explain this (including Conexant :-) ), my ears
     are open.

<margitsw@t-online.de> (04/07/27 1.1929)
   [PATCH] prism54 Fix reference to uninitialized pointer
   
   * oid_mgt.c is calling islpci_mgt_transaction passing the address
     of a pointer to the management frame. This is not being
     initialized by the caller. The callee only updates this
     pointer when successful. When not, boom.
   
   * Being ultracautious again, not only initialize in the caller,
     also null out the pointer unconditionally in the callee.

diff -Nru a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
--- a/drivers/net/wireless/prism54/isl_ioctl.c	2004-07-27 15:51:18 -04:00
+++ b/drivers/net/wireless/prism54/isl_ioctl.c	2004-07-27 15:51:18 -04:00
@@ -1942,7 +1942,7 @@
 {
 	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_mgmtframe *response = NULL;
-	int ret = -EIO, response_op = PIMFOR_OP_ERROR;
+	int ret = -EIO;
 
 	printk("%s: get_oid 0x%08X\n", ndev->name, priv->priv_oid);
 	data->length = 0;
@@ -1952,9 +1952,7 @@
 		    islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
 					   priv->priv_oid, extra, 256,
 					   &response);
-		response_op = response->header->operation;
 		printk("%s: ret: %i\n", ndev->name, ret);
-		printk("%s: response_op: %i\n", ndev->name, response_op);
 		if (ret || !response
 		    || response->header->operation == PIMFOR_OP_ERROR) {
 			if (response) {
@@ -1991,15 +1989,19 @@
 					   priv->priv_oid, extra, data->length,
 					   &response);
 		printk("%s: ret: %i\n", ndev->name, ret);
+		if (ret || !response
+		    || response->header->operation == PIMFOR_OP_ERROR) {
+			if (response) {
+				islpci_mgt_release(response);
+			}
+			printk("%s: EIO\n", ndev->name);
+			ret = -EIO;
+		}
 		if (!ret) {
 			response_op = response->header->operation;
 			printk("%s: response_op: %i\n", ndev->name,
 			       response_op);
 			islpci_mgt_release(response);
-		}
-		if (ret || response_op == PIMFOR_OP_ERROR) {
-			printk("%s: EIO\n", ndev->name);
-			ret = -EIO;
 		}
 	}
 
diff -Nru a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
--- a/drivers/net/wireless/prism54/islpci_hotplug.c	2004-07-27 15:51:18 -04:00
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c	2004-07-27 15:51:18 -04:00
@@ -36,6 +36,9 @@
 MODULE_DESCRIPTION("The Prism54 802.11 Wireless LAN adapter");
 MODULE_LICENSE("GPL");
 
+static int	init_pcitm = 0;
+module_param(init_pcitm, int, 0);
+
 /* In this order: vendor, device, subvendor, subdevice, class, class_mask,
  * driver_data 
  * If you have an update for this please contact prism54-devel@prism54.org 
@@ -292,14 +295,14 @@
 	 *
 	 * 	Writing zero to both these two registers will disable both timeouts and
 	 * 	*can* solve problems caused by devices that are slow to respond.
+	 *	Make this configurable - MSW
 	 */
-	/*	I am taking these out, we should not be poking around in the
-	 *	programmable timers - MSW
-	*/
-/*	Do not zero the programmable timers
-	pci_write_config_byte(pdev, 0x40, 0);
-	pci_write_config_byte(pdev, 0x41, 0);
-*/
+	if ( init_pcitm >= 0 ) {
+		pci_write_config_byte(pdev, 0x40, (u8)init_pcitm);
+		pci_write_config_byte(pdev, 0x41, (u8)init_pcitm);
+	} else {
+		printk(KERN_INFO "PCI TRDY/RETRY unchanged\n");
+	}
 
 	/* request the pci device I/O regions */
 	rvalue = pci_request_regions(pdev, DRV_NAME);
diff -Nru a/drivers/net/wireless/prism54/islpci_mgt.c b/drivers/net/wireless/prism54/islpci_mgt.c
--- a/drivers/net/wireless/prism54/islpci_mgt.c	2004-07-27 15:51:18 -04:00
+++ b/drivers/net/wireless/prism54/islpci_mgt.c	2004-07-27 15:51:18 -04:00
@@ -458,6 +458,8 @@
 	int err;
 	DEFINE_WAIT(wait);
 
+	*recvframe = NULL;
+
 	if (down_interruptible(&priv->mgmt_sem))
 		return -ERESTARTSYS;
 
diff -Nru a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/prism54/oid_mgt.c
--- a/drivers/net/wireless/prism54/oid_mgt.c	2004-07-27 15:51:18 -04:00
+++ b/drivers/net/wireless/prism54/oid_mgt.c	2004-07-27 15:51:18 -04:00
@@ -408,7 +408,7 @@
 mgt_set_request(islpci_private *priv, enum oid_num_t n, int extra, void *data)
 {
 	int ret = 0;
-	struct islpci_mgmtframe *response;
+	struct islpci_mgmtframe *response = NULL;
 	int response_op = PIMFOR_OP_ERROR;
 	int dlen;
 	void *cache, *_data = data;
@@ -613,14 +613,16 @@
 	DOT11_OID_DEFKEYID,
 	DOT11_OID_DOT1XENABLE,
 	OID_INL_DOT11D_CONFORMANCE,
+	/* Do not initialize this - fw < 1.0.4.3 rejects it
 	OID_INL_OUTPUTPOWER,
+	*/
 };
 
 /* update the MAC addr. */
 static int
 mgt_update_addr(islpci_private *priv)
 {
-	struct islpci_mgmtframe *res;
+	struct islpci_mgmtframe *res = NULL;
 	int ret;
 
 	ret = islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
