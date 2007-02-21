From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/2] myri10ge: workaround buggy adopted firmwares
Date: Wed, 21 Feb 2007 18:05:17 +0100
Message-ID: <45DC7BCD.1070709@myri.com>
References: <45DC7B8C.9070501@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1811 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1422719AbXBURc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 12:32:28 -0500
In-Reply-To: <45DC7B8C.9070501@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Work around a bug which occurs when adopting firmware versions
1.4.4 though 1.4.11 where broadcasts are filtered as if they
were multicasts.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   27 +++++++++++++++++++++++----
 1 file changed, 23 insertions(+), 4 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-02-21 08:00:31.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-02-21 17:42:22.000000000 +0100
@@ -195,6 +195,10 @@
 	char *fw_name;
 	char eeprom_strings[MYRI10GE_EEPROM_STRINGS_SIZE];
 	char fw_version[128];
+	int fw_ver_major;
+	int fw_ver_minor;
+	int fw_ver_tiny;
+	int adopted_rx_filter_bug;
 	u8 mac_addr[6];		/* eeprom mac address */
 	unsigned long serial_number;
 	int vendor_specific_offset;
@@ -447,7 +451,6 @@
 			   struct mcp_gen_header *hdr)
 {
 	struct device *dev = &mgp->pdev->dev;
-	int major, minor;
 
 	/* check firmware type */
 	if (ntohl(hdr->mcp_type) != MCP_TYPE_ETH) {
@@ -458,9 +461,11 @@
 	/* save firmware version for ethtool */
 	strncpy(mgp->fw_version, hdr->version, sizeof(mgp->fw_version));
 
-	sscanf(mgp->fw_version, "%d.%d", &major, &minor);
+	sscanf(mgp->fw_version, "%d.%d.%d", &mgp->fw_ver_major,
+	       &mgp->fw_ver_minor, &mgp->fw_ver_tiny);
 
-	if (!(major == MXGEFW_VERSION_MAJOR && minor == MXGEFW_VERSION_MINOR)) {
+	if (!(mgp->fw_ver_major == MXGEFW_VERSION_MAJOR
+	      && mgp->fw_ver_minor == MXGEFW_VERSION_MINOR)) {
 		dev_err(dev, "Found firmware version %s\n", mgp->fw_version);
 		dev_err(dev, "Driver needs %d.%d\n", MXGEFW_VERSION_MAJOR,
 			MXGEFW_VERSION_MINOR);
@@ -561,6 +566,18 @@
 	memcpy_fromio(hdr, mgp->sram + hdr_offset, bytes);
 	status = myri10ge_validate_firmware(mgp, hdr);
 	kfree(hdr);
+
+	/* check to see if adopted firmware has bug where adopting
+	 * it will cause broadcasts to be filtered unless the NIC
+	 * is kept in ALLMULTI mode */
+	if (mgp->fw_ver_major == 1 && mgp->fw_ver_minor == 4 &&
+	    mgp->fw_ver_tiny >= 4 && mgp->fw_ver_tiny <= 11) {
+		mgp->adopted_rx_filter_bug = 1;
+		dev_warn(dev, "Adopting fw %d.%d.%d: "
+			 "working around rx filter bug\n",
+			 mgp->fw_ver_major, mgp->fw_ver_minor,
+			 mgp->fw_ver_tiny);
+	}
 	return status;
 }
 
@@ -794,6 +811,8 @@
 	status = myri10ge_update_mac_address(mgp, mgp->dev->dev_addr);
 	myri10ge_change_promisc(mgp, 0, 0);
 	myri10ge_change_pause(mgp, mgp->pause);
+	if (mgp->adopted_rx_filter_bug)
+		(void)myri10ge_send_cmd(mgp, MXGEFW_ENABLE_ALLMULTI, &cmd, 1);
 	return status;
 }
 
@@ -2239,7 +2258,7 @@
 	myri10ge_change_promisc(mgp, dev->flags & IFF_PROMISC, 1);
 
 	/* This firmware is known to not support multicast */
-	if (!mgp->fw_multicast_support)
+	if (!mgp->fw_multicast_support || mgp->adopted_rx_filter_bug)
 		return;
 
 	/* Disable multicast filtering */


