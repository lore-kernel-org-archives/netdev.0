From: akpm@linux-foundation.org
Subject: [patch for 2.6.27? 07/10] ne.c: fix suspend and resume for ISA PnP cards
Date: Mon, 22 Sep 2008 14:10:21 -0700
Message-ID: <200809222110.m8MLALvH029893@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, david@fries.net,
	alan@lxorguk.ukuu.org.uk, anemo@mba.ocn.ne.jp,
	p_gortmaker@yahoo.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39304 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752922AbYIVVQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:16:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Fries <david@fries.net>

A call to pnp_stop_dev and pnp_start_dev now shuts down and initializes
plug and play devices for suspend and resume.

Signed-off-by: David Fries <david@fries.net>
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Cc: Paul Gortmaker <p_gortmaker@yahoo.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ne.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff -puN drivers/net/ne.c~nec-fix-suspend-and-resume-for-isa-pnp-cards drivers/net/ne.c
--- a/drivers/net/ne.c~nec-fix-suspend-and-resume-for-isa-pnp-cards
+++ a/drivers/net/ne.c
@@ -895,8 +895,12 @@ static int ne_drv_suspend(struct platfor
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 
-	if (netif_running(dev))
+	if (netif_running(dev)) {
+		struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
 		netif_device_detach(dev);
+		if (idev)
+			pnp_stop_dev(idev);
+	}
 	return 0;
 }
 
@@ -905,6 +909,9 @@ static int ne_drv_resume(struct platform
 	struct net_device *dev = platform_get_drvdata(pdev);
 
 	if (netif_running(dev)) {
+		struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
+		if (idev)
+			pnp_start_dev(idev);
 		ne_reset_8390(dev);
 		NS8390p_init(dev, 1);
 		netif_device_attach(dev);
_
