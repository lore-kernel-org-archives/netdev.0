From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 1/1] solos-pci: Fix regression introduced by newest firmware
Date: Sun, 20 Mar 2011 16:41:40 -0700
Message-ID: <4D8690B4.7030900@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-atm-general@lists.sourceforge.net"
	<linux-atm-general@lists.sourceforge.net>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:40574 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751832Ab1CTXlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 19:41:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The newest FPGA firmware on the Solos processors correctly signals carrier transitions, bitrate, etc.

The driver previously ignored these messages, and the physical state was always ATM_PHY_SIG_UNKNOWN.

Now that the board reports its state, we expose a bug whereby the transition from UNKNOWN to LOST causes us to release all VC's.  It should not: only transitions from FOUND to LOST or UNKNOWN should do this (actually, it's bears examining if the VC's should be released at all).

So we add a check to the previous state on transitions for leaving FOUND state.

Signed-off-by: Philip A Prindeville <philipp@redfish-solutions.com>
---

--- a/drivers/atm/solos-pci.c	2011-03-20 15:27:40.000000000 -0600
+++ b/drivers/atm/solos-pci.c	2011-03-20 16:32:11.000000000 -0600
@@ -382,8 +382,11 @@ static int process_status(struct solos_c

  	/* Anything but 'Showtime' is down */
  	if (strcmp(state_str, "Showtime")) {
+		char old_signal = card->atmdev[port]->signal;
+
  		atm_dev_signal_change(card->atmdev[port], ATM_PHY_SIG_LOST);
-		atm_dev_release_vccs(card->atmdev[port]);
+		if (old_signal == ATM_PHY_SIG_FOUND)
+			atm_dev_release_vccs(card->atmdev[port]);
  		dev_info(&card->dev->dev, "Port %d: %s\n", port, state_str);
		return 0;
	}


