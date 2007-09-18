From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: fix VLAN receive processing
Date: Mon, 17 Sep 2007 22:08:04 -0700
Message-ID: <20070917220804.6c6e2502@freepuppy.rosehill.hemminger.net>
References: <200709151157.10042.l@lwithers.me.uk>
	<20070916215814.1cbd917a@oldman.hemminger.net>
	<200709162129.53978.l@lwithers.me.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Laurence Withers <l@lwithers.me.uk>,
	Jeff Garzik <jgarzik@pobox.com>,
	Pierre-Yves Ritschard <pyr@spootnik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50983 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751092AbXIRFIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 01:08:40 -0400
In-Reply-To: <200709162129.53978.l@lwithers.me.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The length check for truncated frames was not correctly handling
the case where VLAN acceleration had already read the tag.
Also, the Yukon EX has some features that use high bit of status
as security tag.

Original patch by Pierre-Yves Ritschard but with additions.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-09-17 16:51:53.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-17 17:03:25.000000000 -0700
@@ -2103,6 +2103,13 @@ static struct sk_buff *sky2_receive(stru
  	struct sky2_port *sky2 = netdev_priv(dev);
 	struct rx_ring_info *re = sky2->rx_ring + sky2->rx_next;
 	struct sk_buff *skb = NULL;
+	u16 count = (status & GMR_FS_LEN) >> 16;
+
+#ifdef SKY2_VLAN_TAG_USED
+	/* Account for vlan tag */
+	if (sky2->vlgrp && (status & GMR_FS_VLAN))
+		count -= VLAN_HLEN;
+#endif
 
 	if (unlikely(netif_msg_rx_status(sky2)))
 		printk(KERN_DEBUG PFX "%s: rx slot %u status 0x%x len %d\n",
@@ -2117,7 +2124,8 @@ static struct sk_buff *sky2_receive(stru
 	if (!(status & GMR_FS_RX_OK))
 		goto resubmit;
 
-	if (status >> 16 != length)
+	/* if length reported by DMA does not match PHY, packet was truncated */
+	if (length != count)
 		goto len_mismatch;
 
 	if (length < copybreak)
@@ -2133,6 +2141,10 @@ len_mismatch:
 	/* Truncation of overlength packets
 	   causes PHY length to not match MAC length */
 	++sky2->net_stats.rx_length_errors;
+	if (netif_msg_rx_err(sky2) && net_ratelimit())
+		pr_info(PFX "%s: rx length mismatch: length %d status %#x\n",
+			dev->name, length, status);
+	goto resubmit;
 
 error:
 	++sky2->net_stats.rx_errors;
--- a/drivers/net/sky2.h	2007-09-17 16:51:53.000000000 -0700
+++ b/drivers/net/sky2.h	2007-09-17 16:53:25.000000000 -0700
@@ -1668,7 +1668,7 @@ enum {
 
 /* Receive Frame Status Encoding */
 enum {
-	GMR_FS_LEN	= 0xffff<<16, /* Bit 31..16:	Rx Frame Length */
+	GMR_FS_LEN	= 0x7fff<<16, /* Bit 30..16:	Rx Frame Length */
 	GMR_FS_VLAN	= 1<<13, /* VLAN Packet */
 	GMR_FS_JABBER	= 1<<12, /* Jabber Packet */
 	GMR_FS_UN_SIZE	= 1<<11, /* Undersize Packet */
