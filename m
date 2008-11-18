From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: macb phy address bug?
Date: Tue, 18 Nov 2008 16:35:08 +0100
Message-ID: <4922E0AC.6080801@st.com>
References: <20081116.015050.238612963.davem@davemloft.net> <492281C9.6060006@st.com> <gfuad2$907$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040608070807010300080708"
Cc: netdev@vger.kernel.org
To: Giulio Benetti <giulio.benetti@micronovasrl.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:40406 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752179AbYKRPiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 10:38:24 -0500
In-Reply-To: <gfuad2$907$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040608070807010300080708
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Thanks Giulio for your feedback.

So I do think, this is the patch we need.

Peppe

--------------040608070807010300080708
Content-Type: text/x-patch;
 name="phy_dev_uid_detection.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="phy_dev_uid_detection.patch"

Fix phy_id detection also for broken hardware.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

--- a/drivers/net/phy/phy_device.c.orig	2008-11-18 09:25:06.929041000 +0100
+++ a/drivers/net/phy/phy_device.c	2008-11-18 16:34:12.929001000 +0100
@@ -227,8 +227,17 @@ struct phy_device * get_phy_device(struc
 	if (r)
 		return ERR_PTR(r);
 
-	/* If the phy_id is all Fs or all 0s, there is no device there */
-	if ((0xffff == phy_id) || (0x00 == phy_id))
+	/* If the phy_id is mostly Fs, there is no device there */
+	if ((phy_id & 0x1fffffff) == 0x1fffffff)
+		return NULL;
+
+	/*
+	 * Broken hardware is sometimes missing the pull down resistor on the
+	 * MDIO line, which results in reads to non-existent devices returning
+	 * 0 rather than 0xffff. Catch this here and treat 0 as a non-existent
+	 * device as well.
+	 */ 
+	if (phy_id == 0)
 		return NULL;
 
 	dev = phy_device_create(bus, addr, phy_id);

--------------040608070807010300080708--
