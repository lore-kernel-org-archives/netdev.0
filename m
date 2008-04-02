From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sky2: fix suspend/resume races
Date: Wed, 2 Apr 2008 10:16:45 -0700
Message-ID: <20080402101645.39427b7b@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:60085 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755902AbYDBRQt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 13:16:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are a couple of possible races on suspend/resume reported by Dell.
First the driver needs to block new packets from being queued for Tx.
The other less likely problem is the watchdog timer going off
during resume.

Note: there is no need to explicitly restart the watchdog timer
since it gets restarted by link up on resume.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2008-04-01 11:42:56.000000000 -0700
+++ b/drivers/net/sky2.c	2008-04-01 12:29:17.000000000 -0700
@@ -4329,10 +4329,14 @@ static int sky2_suspend(struct pci_dev *
 	if (!hw)
 		return 0;
 
+	del_timer_sync(&hw->watchdog_timer);
+	cancel_work_sync(&hw->restart_work);
+
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 		struct sky2_port *sky2 = netdev_priv(dev);
 
+		netif_device_detach(dev);
 		if (netif_running(dev))
 			sky2_down(dev);
 
@@ -4383,6 +4387,8 @@ static int sky2_resume(struct pci_dev *p
 
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
+
+		netif_device_attach(dev);
 		if (netif_running(dev)) {
 			err = sky2_up(dev);
 			if (err) {
