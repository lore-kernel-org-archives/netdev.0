From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 11/15] wimax/i2400m: retry loading firmware files in sequence
Date: Wed,  4 Nov 2009 13:39:52 -0800
Message-ID: <ebc5f62b76ad540ff7b3e438506638009e7812a6.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20702 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932717AbZKDVmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:00 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The i2400m firmware loader is given a list of firmware files to try to
load by the probe() function (which can be different based on the
device's model / generation).

Current code didn't attempt to load, check and try to boot with each
file, but just to try to load if off disk. This is limiting in some
cases, where we might want to try to load a firmware and if it fails
to load onto the device, just fall back to another one.

This changes the behaviour so all files are tried for being loaded
from disk, checked and uploaded to the device until one suceeds in
bringing the device up.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c |   35 +++++++++++++++++------------------
 1 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 798564e..55fe011 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -1288,7 +1288,7 @@ error_dev_rebooted:
  */
 int i2400m_dev_bootstrap(struct i2400m *i2400m, enum i2400m_bri flags)
 {
-	int ret = 0, itr = 0;
+	int ret, itr;
 	struct device *dev = i2400m_dev(i2400m);
 	const struct firmware *fw;
 	const struct i2400m_bcf_hdr *bcf;	/* Firmware data */
@@ -1297,32 +1297,31 @@ int i2400m_dev_bootstrap(struct i2400m *i2400m, enum i2400m_bri flags)
 	d_fnstart(5, dev, "(i2400m %p)\n", i2400m);
 
 	/* Load firmware files to memory. */
-	itr = 0;
-	while(1) {
+	for (itr = 0, bcf = NULL, ret = -ENOENT; ; itr++) {
 		fw_name = i2400m->bus_fw_names[itr];
 		if (fw_name == NULL) {
 			dev_err(dev, "Could not find a usable firmware image\n");
 			ret = -ENOENT;
-			goto error_no_fw;
+			break;
 		}
+		d_printf(1, dev, "trying firmware %s (%d)\n", fw_name, itr);
 		ret = request_firmware(&fw, fw_name, dev);
-		if (ret == 0)
-			break;		/* got it */
-		if (ret < 0)
+		if (ret < 0) {
 			dev_err(dev, "fw %s: cannot load file: %d\n",
 				fw_name, ret);
-		itr++;
+			continue;
+		}
+		bcf = (void *) fw->data;
+		i2400m->fw_name = fw_name;
+		ret = i2400m_fw_check(i2400m, bcf, fw->size);
+		if (ret >= 0) {
+			ret = i2400m_fw_dnload(i2400m, bcf, fw->size, flags);
+			if (ret >= 0)
+				break;
+		} else
+			dev_err(dev, "%s: cannot use, skipping\n", fw_name);
+		release_firmware(fw);
 	}
-
-	bcf = (void *) fw->data;
-	i2400m->fw_name = fw_name;
-	ret = i2400m_fw_check(i2400m, bcf, fw->size);
-	if (ret < 0)
-		goto error_fw_bad;
-	ret = i2400m_fw_dnload(i2400m, bcf, fw->size, flags);
-error_fw_bad:
-	release_firmware(fw);
-error_no_fw:
 	d_fnend(5, dev, "(i2400m %p) = %d\n", i2400m, ret);
 	return ret;
 }
-- 
1.6.2.5

