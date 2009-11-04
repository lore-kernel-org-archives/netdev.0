From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 06/13] wimax/i2400m: change the bcf_len to exclude the extended header size
Date: Wed,  4 Nov 2009 13:40:01 -0800
Message-ID: <28cff50d99ce9a1db65b7d4dcdcc0f1f8d9f9309.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:17987 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932756AbZKDVmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:12 -0500
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

The actual fw->size may not equal to the bcf size indicated in
the bcf header if the extended bcf debug header is added in the tail.

To reflect the actual fw size that will be downloaded to the device,
it is now retrived from from the size field indicated in the bcf header.

All of the headers (if there are extended headers) should indicate same
value for the size field since only one set of firmware chunks is downloaded

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
---
 drivers/net/wimax/i2400m/fw.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 97ea784..fda54bf 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -1388,15 +1388,16 @@ const struct i2400m_bcf_hdr *i2400m_bcf_hdr_find(struct i2400m *i2400m)
  */
 static
 int i2400m_fw_dnload(struct i2400m *i2400m, const struct i2400m_bcf_hdr *bcf,
-		     size_t bcf_size, enum i2400m_bri flags)
+		     size_t fw_size, enum i2400m_bri flags)
 {
 	int ret = 0;
 	struct device *dev = i2400m_dev(i2400m);
 	int count = i2400m->bus_bm_retries;
 	const struct i2400m_bcf_hdr *bcf_hdr;
+	size_t bcf_size;
 
-	d_fnstart(5, dev, "(i2400m %p bcf %p size %zu)\n",
-		  i2400m, bcf, bcf_size);
+	d_fnstart(5, dev, "(i2400m %p bcf %p fw size %zu)\n",
+		  i2400m, bcf, fw_size);
 	i2400m->boot_mode = 1;
 	wmb();		/* Make sure other readers see it */
 hw_reboot:
@@ -1434,6 +1435,12 @@ hw_reboot:
 	if (ret < 0)
 		goto error_dnload_init;
 
+	/*
+	 * bcf_size refers to one header size plus the fw sections size
+	 * indicated by the header,ie. if there are other extended headers
+	 * at the tail, they are not counted
+	 */
+	bcf_size = sizeof(u32) * le32_to_cpu(bcf_hdr->size);
 	ret = i2400m_dnload_bcf(i2400m, bcf, bcf_size);
 	if (ret == -ERESTARTSYS)
 		goto error_dev_rebooted;
@@ -1464,7 +1471,7 @@ error_bcf_hdr_find:
 error_bootrom_init:
 error_too_many_reboots:
 	d_fnend(5, dev, "(i2400m %p bcf %p size %zu) = %d\n",
-		i2400m, bcf, bcf_size, ret);
+		i2400m, bcf, fw_size, ret);
 	return ret;
 
 error_dev_rebooted:
-- 
1.6.2.5

