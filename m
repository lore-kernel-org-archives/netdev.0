From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 13/14] spidernet: read firmware from the OF device tree
Date: Mon, 05 Dec 2005 22:52:33 -0500
Message-ID: <20051206040645.368270000@localhost>
References: <20051206035220.097737000@localhost>
Cc: linuxppc64-dev@ozlabs.org, netdev@vger.kernel.org,
	Arnd Bergmann <arndb@de.ibm.com>, Jens.Osterkamp@de.ibm.com
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: paulus@samba.org
Content-Disposition: inline; filename=spidernet-fw-from-dt-2.diff
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

request_firmware() is sometimes problematic, especially
in initramfs, reading the firmware from Open Firmware
is much preferrable.

We still try to get the firmware from the file system
first, in order to support old SLOF releases and to allow
updates of the spidernet firmware without reflashing
the system.

From: Jens.Osterkamp@de.ibm.com
Cc: netdev@vger.kernel.org
Signed-off-by: Arnd Bergmann <arndb@de.ibm.com>

Index: linux-2.6.15-rc/drivers/net/spider_net.c
===================================================================
--- linux-2.6.15-rc.orig/drivers/net/spider_net.c
+++ linux-2.6.15-rc/drivers/net/spider_net.c
@@ -1895,16 +1895,27 @@ spider_net_download_firmware(struct spid
 static int
 spider_net_init_firmware(struct spider_net_card *card)
 {
-	const struct firmware *firmware;
+	struct firmware *firmware;
+	struct device_node *dn;
+	u8 *fw_prop;
 	int err = -EIO;
 
-	if (request_firmware(&firmware,
+	if (request_firmware((const struct firmware **)&firmware,
 			     SPIDER_NET_FIRMWARE_NAME, &card->pdev->dev) < 0) {
 		if (netif_msg_probe(card))
 			pr_err("Couldn't read in sequencer data file %s.\n",
 			       SPIDER_NET_FIRMWARE_NAME);
-		firmware = NULL;
-		goto out;
+
+		dn = pci_device_to_OF_node(card->pdev);
+		if (!dn)
+			goto out;
+
+		fw_prop = (u8 *)get_property(dn, "firmware", NULL);
+		if (!fw_prop)
+			goto out;
+
+		memcpy(firmware->data, fw_prop, 6 * SPIDER_NET_FIRMWARE_LEN * sizeof(u32));
+		firmware->size = 6 * SPIDER_NET_FIRMWARE_LEN * sizeof(u32);
 	}
 
 	if (firmware->size != 6 * SPIDER_NET_FIRMWARE_LEN * sizeof(u32)) {

--
