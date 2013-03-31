From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] sh_eth: fix handling of no LINK signal
Date: Sun, 31 Mar 2013 23:50:07 +0400
Message-ID: <201303312350.08153.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:58662 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755535Ab3CaTva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Mar 2013 15:51:30 -0400
Received: by mail-la0-f52.google.com with SMTP id fs12so1638949lab.39
        for <netdev@vger.kernel.org>; Sun, 31 Mar 2013 12:51:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code handling the absent LINK signal (or the absent PSR register -- which
reflects the state of this signal) is quite naive and has probably never really
worked.  It's probably enough to say that this code is executed only on the LINK
change interrupt (sic!) but even if we actually have the signal and choose to
ignore it (it might be connected to PHY's link/activity LED output as on the
Renesas BOCK-W board), sh_eth_adjust_link() on which this code relies to update
'mdp->link' gets executed later than the LINK change interrupt where it is
checked, and so RX/TX never get enabled via ECMR register.

So, ignore the LINK changed interrupt iff LINK signal is absent (or just chosen
not to be used) or PSR register is absent, and enable/disable RX/TX directly in
sh_eth_adjust_link() in this case. 

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the David Miller's 'net.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1216,10 +1216,7 @@ static void sh_eth_error(struct net_devi
 		if (felic_stat & ECSR_LCHNG) {
 			/* Link Changed */
 			if (mdp->cd->no_psr || mdp->no_ether_link) {
-				if (mdp->link == PHY_DOWN)
-					link_stat = 0;
-				else
-					link_stat = PHY_ST_LINK;
+				goto ignore_link;
 			} else {
 				link_stat = (sh_eth_read(ndev, PSR));
 				if (mdp->ether_link_active_low)
@@ -1242,6 +1239,7 @@ static void sh_eth_error(struct net_devi
 		}
 	}
 
+ignore_link:
 	if (intr_status & EESR_TWB) {
 		/* Write buck end. unused write back interrupt */
 		if (intr_status & EESR_TABT)	/* Transmit Abort int */
@@ -1392,12 +1390,16 @@ static void sh_eth_adjust_link(struct ne
 				(sh_eth_read(ndev, ECMR) & ~ECMR_TXF), ECMR);
 			new_state = 1;
 			mdp->link = phydev->link;
+			if (mdp->cd->no_psr || mdp->no_ether_link)
+				sh_eth_rcv_snd_enable(ndev);
 		}
 	} else if (mdp->link) {
 		new_state = 1;
 		mdp->link = PHY_DOWN;
 		mdp->speed = 0;
 		mdp->duplex = -1;
+		if (mdp->cd->no_psr || mdp->no_ether_link)
+			sh_eth_rcv_snd_disable(ndev);
 	}
 
 	if (new_state && netif_msg_link(mdp))
