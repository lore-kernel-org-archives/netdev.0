From: Jens Osterkamp <jens@de.ibm.com>
Subject: [PATCH] spidernet : fix memory leak in spider_net_stop
Date: Thu, 1 Feb 2007 12:07:47 +0100
Message-ID: <200702011207.47421.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linas Vepstas <linas@austin.ibm.com>,
	James K Lewis <jim@jklewis.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, jgarzik@pobox.com, cbe-oss-dev@ozlabs.org,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:46112 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbXBALHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 06:07:50 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id l11B7nXV064254
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 11:07:49 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l11B7mdR1429538
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 12:07:48 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l11B7l1n015813
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 12:07:48 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We forget to call spider_net_free_rx_chain_contents which does the
actual dev_kfree_skb. New skbs are allocated from skbuff_head_cache
on each "ifconfig up" letting the cache grow infinitely.

This patch fixes it.

Signed-off-by: Jens Osterkamp <jens@de.ibm.com>

Index: linux-2.6.20-rc6/drivers/net/spider_net.c
===================================================================
--- linux-2.6.20-rc6.orig/drivers/net/spider_net.c
+++ linux-2.6.20-rc6/drivers/net/spider_net.c
@@ -1925,6 +1925,8 @@ spider_net_stop(struct net_device *netde
 	/* release chains */
 	spider_net_release_tx_chain(card, 1);
 
+	spider_net_free_rx_chain_contents(card);
+
 	spider_net_free_chain(card, &card->tx_chain);
 	spider_net_free_chain(card, &card->rx_chain);
 
