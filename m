From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT] tehuti: napi fix
Date: Wed, 12 Dec 2007 13:58:52 -0800
Message-ID: <20071212135852.3369c820@freepuppy.rosehill>
References: <002901c83c73$b089b6e0$9c94fea9@jason>
	<20071212.071832.07747779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: joonwpark81@gmail.com, netdev@vger.kernel.org, jgarzik@pobox.com,
	baum@tehutinetworks.net, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37344 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756434AbXLLWBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 17:01:31 -0500
In-Reply-To: <20071212.071832.07747779.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should fix the tehuti napi fence post problems by getting
rid of priv->napi_stop, and setting weight to 32 (like other 10G).

Also, used the wierd entry/exit macro's like rest of driver.

--- a/drivers/net/tehuti.c	2007-11-13 22:19:14.000000000 -0800
+++ b/drivers/net/tehuti.c	2007-12-12 13:37:01.000000000 -0800
@@ -295,18 +295,12 @@ static int bdx_poll(struct napi_struct *
 	ENTER;
 	bdx_tx_cleanup(priv);
 	work_done = bdx_rx_receive(priv, &priv->rxd_fifo0, budget);
-	if ((work_done < budget) ||
-	    (priv->napi_stop++ >= 30)) {
+	if (work_done < budget) {
 		DBG("rx poll is done. backing to isr-driven\n");
-
-		/* from time to time we exit to let NAPI layer release
-		 * device lock and allow waiting tasks (eg rmmod) to advance) */
-		priv->napi_stop = 0;
-
 		netif_rx_complete(dev, napi);
 		bdx_enable_interrupts(priv);
 	}
-	return work_done;
+	RET(work_done);
 }
 
 /* bdx_fw_load - loads firmware to NIC
@@ -2022,7 +2016,7 @@ bdx_probe(struct pci_dev *pdev, const st
 		priv->nic = nic;
 		priv->msg_enable = BDX_DEF_MSG_ENABLE;
 
-		netif_napi_add(ndev, &priv->napi, bdx_poll, 64);
+		netif_napi_add(ndev, &priv->napi, bdx_poll, 32);
 
 		if ((readl(nic->regs + FPGA_VER) & 0xFFF) == 308) {
 			DBG("HW statistics not supported\n");
--- a/drivers/net/tehuti.h	2007-10-16 16:48:17.000000000 -0700
+++ b/drivers/net/tehuti.h	2007-12-12 13:25:25.000000000 -0800
@@ -257,7 +257,6 @@ struct bdx_priv {
 	struct rxd_fifo rxd_fifo0;
 	struct rxf_fifo rxf_fifo0;
 	struct rxdb *rxdb;	/* rx dbs to store skb pointers */
-	int napi_stop;
 	struct vlan_group *vlgrp;
 
 	/* Tx FIFOs: 1 for data desc, 1 for empty (acks) desc */
