From: Paul Bolle <pebolle@tiscali.nl>
Subject: [i4l] do not print a warning when shutting down an i4l ppp
 interface
Date: Mon, 12 Jan 2009 13:43:17 +0100
Message-ID: <1231764197.7132.12.camel@test.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.tiscali.nl ([195.241.79.178]:45684 "EHLO
	smtp-out3.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbZALMnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 07:43:20 -0500
Received: from [212.123.169.34] (helo=[192.168.1.42])
	by smtp-out3.tiscali.nl with esmtp
	id 1LMM8U-0006Dk-Ct
	for <netdev@vger.kernel.org>; Mon, 12 Jan 2009 13:43:18 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an i4l ppp interface is shut down (e.g. with /sbin/ifdown ippp0) a
scary warning is logged:
    
    isdn_free_channel: called with invalid drv(-1) or channel(-1)
    
This warning is caused by isdn_net_unbind_channel(), which always calls
isdn_free_channel() even if isdn_net_local->isdn_device and
isdn_net_local->isdn_channel are (still) in a perfectly acceptable
default state, so let's not do that.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Sent only to netdev@vger.kernel.org (and not also to
isdn4linux@listserv.isdn4linux.de) because an earlier ISDN patch I wrote
only got a response from this list (and this patch is NETWORKING related
anyway).
---
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index ecc92c8..cb8943d 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -292,7 +292,9 @@ isdn_net_unbind_channel(isdn_net_local * lp)
 	lp->dialstate = 0;
 	dev->rx_netdev[isdn_dc2minor(lp->isdn_device, lp->isdn_channel)] = NULL;
 	dev->st_netdev[isdn_dc2minor(lp->isdn_device, lp->isdn_channel)] = NULL;
-	isdn_free_channel(lp->isdn_device, lp->isdn_channel, ISDN_USAGE_NET);
+	if (lp->isdn_device != -1 && lp->isdn_channel != -1)
+		isdn_free_channel(lp->isdn_device, lp->isdn_channel,
+				  ISDN_USAGE_NET);
 	lp->flags &= ~ISDN_NET_CONNECTED;
 	lp->isdn_device = -1;
 	lp->isdn_channel = -1;


