From: sfeldma@gmail.com
Subject: [PATCH net-next 1/3] rocker: fix non-portable err return codes
Date: Wed, 25 Feb 2015 20:15:36 -0800
Message-ID: <1424924138-15928-2-git-send-email-sfeldma@gmail.com>
References: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:42109 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084AbbBZEPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 23:15:13 -0500
Received: by pdbfp1 with SMTP id fp1so9942150pdb.9
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 20:15:13 -0800 (PST)
In-Reply-To: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

The rocker device returns error codes if something goes wrong with descriptor
processing.  Originally the device used standard errno codes for different
errors, but since those errno codes aren't portable across ARCHs, the device
now returns hard-coded error codes that stay constant across diff ARCHs.  Fix
driver to use those same hard-coded values.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   25 ++++++++++++++++++++++++-
 drivers/net/ethernet/rocker/rocker.h |   13 +++++++++++++
 2 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 34389b6a..61f2ef4 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -789,7 +789,30 @@ static u32 __pos_inc(u32 pos, size_t limit)
 
 static int rocker_desc_err(struct rocker_desc_info *desc_info)
 {
-	return -(desc_info->desc->comp_err & ~ROCKER_DMA_DESC_COMP_ERR_GEN);
+	int err = desc_info->desc->comp_err & ~ROCKER_DMA_DESC_COMP_ERR_GEN;
+
+	switch (err) {
+	case ROCKER_OK:
+		return 0;
+	case -ROCKER_ENOENT:
+		return -ENOENT;
+	case -ROCKER_ENXIO:
+		return -ENXIO;
+	case -ROCKER_ENOMEM:
+		return -ENOMEM;
+	case -ROCKER_EEXIST:
+		return -EEXIST;
+	case -ROCKER_EINVAL:
+		return -EINVAL;
+	case -ROCKER_EMSGSIZE:
+		return -EMSGSIZE;
+	case -ROCKER_ENOTSUP:
+		return -EOPNOTSUPP;
+	case -ROCKER_ENOBUFS:
+		return -ENOBUFS;
+	}
+
+	return -EINVAL;
 }
 
 static void rocker_desc_gen_clear(struct rocker_desc_info *desc_info)
diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index a5bc432..76e79ed 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -14,6 +14,19 @@
 
 #include <linux/types.h>
 
+/* Return codes */
+enum {
+	ROCKER_OK = 0,
+	ROCKER_ENOENT = 2,
+	ROCKER_ENXIO = 6,
+	ROCKER_ENOMEM = 12,
+	ROCKER_EEXIST = 17,
+	ROCKER_EINVAL = 22,
+	ROCKER_EMSGSIZE = 90,
+	ROCKER_ENOTSUP = 95,
+	ROCKER_ENOBUFS = 105,
+};
+
 #define PCI_VENDOR_ID_REDHAT		0x1b36
 #define PCI_DEVICE_ID_REDHAT_ROCKER	0x0006
 
-- 
1.7.10.4
