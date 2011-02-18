From: Phil Oester <kernel@linuxace.com>
Subject: [PATCH] bonding: bond_select_queue off by one
Date: Thu, 17 Feb 2011 18:07:13 -0800
Message-ID: <20110218020713.GA9696@linuxace.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0F1p//8PRICkK4MW"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63922 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665Ab1BRCHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 21:07:18 -0500
Received: by iyj8 with SMTP id 8so3027559iyj.19
        for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 18:07:17 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The bonding driver's bond_select_queue function simply returns
skb->queue_mapping.  However queue_mapping could be == 16
for queue #16.  This causes the following message to be flooded
to syslog:

kernel: bondx selects TX queue 16, but real number of TX queues is 16

ndo_select_queue wants a zero-based number, so bonding driver needs
to subtract one to return the proper queue number.  Also fix grammar in
a comment while in the vicinity.

Phil Oester

Signed-off-by: Phil Oester <kernel@linuxace.com>



--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch-bond-txq

--- linux-2.6/drivers/net/bonding/bond_main.c.orig	2011-01-30 09:15:09.813843817 -0800
+++ linux-2.6/drivers/net/bonding/bond_main.c	2011-02-17 18:02:46.919050909 -0800
@@ -4537,11 +4537,11 @@
 {
 	/*
 	 * This helper function exists to help dev_pick_tx get the correct
-	 * destination queue.  Using a helper function skips the a call to
+	 * destination queue.  Using a helper function skips a call to
 	 * skb_tx_hash and will put the skbs in the queue we expect on their
 	 * way down to the bonding driver.
 	 */
-	return skb->queue_mapping;
+	return skb->queue_mapping ? skb->queue_mapping - 1 : 0;
 }
 
 static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)

--0F1p//8PRICkK4MW--
