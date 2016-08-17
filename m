From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH v2 2/2] kaweth: fix oops upon failed memory allocation
Date: Wed, 17 Aug 2016 15:51:56 +0200
Message-ID: <1471441916-19656-3-git-send-email-oneukum@suse.com>
References: <1471441916-19656-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: linux-usb@vger.kernel.org, stern@rowland.harvard.edu,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49939 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993AbcHQNyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 09:54:45 -0400
In-Reply-To: <1471441916-19656-1-git-send-email-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just return an error upon failure.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/kaweth.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 37bf715..528b9c9 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -1009,6 +1009,7 @@ static int kaweth_probe(
 	struct net_device *netdev;
 	const eth_addr_t bcast_addr = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
 	int result = 0;
+	int rv = -EIO;
 
 	dev_dbg(dev,
 		"Kawasaki Device Probe (Device number:%d): 0x%4.4x:0x%4.4x:0x%4.4x\n",
@@ -1049,6 +1050,10 @@ static int kaweth_probe(
 		/* Download the firmware */
 		dev_info(dev, "Downloading firmware...\n");
 		kaweth->firmware_buf = (__u8 *)__get_free_page(GFP_KERNEL);
+		if (!kaweth->firmware_buf) {
+			rv = -ENOMEM;
+			goto err_free_netdev;
+		}
 		if ((result = kaweth_download_firmware(kaweth,
 						      "kaweth/new_code.bin",
 						      100,
@@ -1203,7 +1208,7 @@ err_only_tx:
 err_free_netdev:
 	free_netdev(netdev);
 
-	return -EIO;
+	return rv;
 }
 
 /****************************************************************
-- 
2.1.4
