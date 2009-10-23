From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] e100: Fix to allow systems with FW based cards
	to resume from STD
Date: Thu, 22 Oct 2009 19:59:29 -0700
Message-ID: <20091023025904.7057.58001.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	David Graham <david.graham@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:37092
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751120AbZJWDCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 23:02:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Graham <david.graham@intel.com>

Devices with loadable firmware must have their firmware reloaded
after the system resumes from sleep, but the request_firmare()
API is not available at this point in the resume flow because
tasks are not yet running, and the system will hang if it is
called. Work around this issue by only calling request_firmware()
for a device's first firmware load, and cache a copy of the pointer
to the firmware blob for that device, so that we may reload firmware
images even during resume.

Signed-off-by: David Graham <david.graham@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e100.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index ff83efd..f428c5f 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -621,6 +621,7 @@ struct nic {
 	u16 eeprom_wc;
 	__le16 eeprom[256];
 	spinlock_t mdio_lock;
+	const struct firmware *fw;
 };
 
 static inline void e100_write_flush(struct nic *nic)
@@ -1222,9 +1223,9 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 static const struct firmware *e100_request_firmware(struct nic *nic)
 {
 	const char *fw_name;
-	const struct firmware *fw;
+	const struct firmware *fw = nic->fw;
 	u8 timer, bundle, min_size;
-	int err;
+	int err = 0;
 
 	/* do not load u-code for ICH devices */
 	if (nic->flags & ich)
@@ -1240,12 +1241,20 @@ static const struct firmware *e100_request_firmware(struct nic *nic)
 	else /* No ucode on other devices */
 		return NULL;
 
-	err = request_firmware(&fw, fw_name, &nic->pdev->dev);
+	/* If the firmware has not previously been loaded, request a pointer
+	 * to it. If it was previously loaded, we are reinitializing the
+	 * adapter, possibly in a resume from hibernate, in which case
+	 * request_firmware() cannot be used.
+	 */
+	if (!fw)
+		err = request_firmware(&fw, fw_name, &nic->pdev->dev);
+
 	if (err) {
 		DPRINTK(PROBE, ERR, "Failed to load firmware \"%s\": %d\n",
 			fw_name, err);
 		return ERR_PTR(err);
 	}
+
 	/* Firmware should be precisely UCODE_SIZE (words) plus three bytes
 	   indicating the offsets for BUNDLESMALL, BUNDLEMAX, INTDELAY */
 	if (fw->size != UCODE_SIZE * 4 + 3) {
@@ -1268,7 +1277,10 @@ static const struct firmware *e100_request_firmware(struct nic *nic)
 		release_firmware(fw);
 		return ERR_PTR(-EINVAL);
 	}
-	/* OK, firmware is validated and ready to use... */
+
+	/* OK, firmware is validated and ready to use. Save a pointer
+	 * to it in the nic */
+	nic->fw = fw;
 	return fw;
 }
 

