From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] phy: IRQ cannot be shared
Date: Fri, 20 Dec 2013 22:09:04 +0300
Message-ID: <201312202209.04333.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:42946 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab3LTSIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 13:08:55 -0500
Received: by mail-la0-f50.google.com with SMTP id el20so1242022lab.37
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 10:08:54 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-82-46.pppoe.mtu-net.ru. [91.76.82.46])
        by mx.google.com with ESMTPSA id r10sm6697452lag.7.2013.12.20.10.08.53
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Dec 2013 10:08:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the way PHY IRQ handler is implemented (all real handling being pushed to
the workqueue and returning IRQ_HANDLED all the time PHY is active), we cannot
really claim that PHY IRQ can be shared when calling request_irq().  

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net.git' repo.
I recommend pushing it to the stable kernels as well.

 drivers/net/phy/phy.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

Index: net/drivers/net/phy/phy.c
===================================================================
--- net.orig/drivers/net/phy/phy.c
+++ net/drivers/net/phy/phy.c
@@ -565,10 +565,8 @@ int phy_start_interrupts(struct phy_devi
 	int err = 0;
 
 	atomic_set(&phydev->irq_disable, 0);
-	if (request_irq(phydev->irq, phy_interrupt,
-				IRQF_SHARED,
-				"phy_interrupt",
-				phydev) < 0) {
+	if (request_irq(phydev->irq, phy_interrupt, 0, "phy_interrupt",
+			phydev) < 0) {
 		pr_warn("%s: Can't get IRQ %d (PHY)\n",
 			phydev->bus->name, phydev->irq);
 		phydev->irq = PHY_POLL;
