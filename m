From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [stable] [PATCH 2/3] sky2: fix VLAN receive processing
Date: Fri, 28 Sep 2007 12:20:44 -0700
Message-ID: <20070928192044.GH3906@sequoia.sous-sol.org>
References: <20070928164811.387831540@linux-foundation.org> <20070928164858.539587428@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Oledzki <olel@ans.pl>, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org, stable@kernel.org,
	Pierre-Yves Ritschard <pyr@spootnik.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:51710 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751534AbXI1TVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 15:21:22 -0400
Content-Disposition: inline
In-Reply-To: <20070928164858.539587428@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Stephen Hemminger (shemminger@linux-foundation.org) wrote:
> The length check for truncated frames was not correctly handling
> the case where VLAN acceleration had already read the tag.
> Also, the Yukon EX has some features that use high bit of status
> as security tag.

Did you leave out the GMR_FS_LEN change on purpose?  AFAICT, w/out
that you miss the Yukon EX high bit usage.  The upstream patch applies,
can we simply use that one (below rediffed for stable)?

thanks,
-chris
--

>From d6532232cd3de79c852685823a9c52f723816d0a Mon Sep 17 00:00:00 2001
From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 19 Sep 2007 15:36:42 -0700
Subject: sky2: fix VLAN receive processing (resend)

The length check for truncated frames was not correctly handling
the case where VLAN acceleration had already read the tag.
Also, the Yukon EX has some features that use high bit of status
as security tag.

Signed-off-by: Pierre-Yves Ritschard <pyr@spootnik.org>
Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Jeff Garzik <jeff@garzik.org>
---
 drivers/net/sky2.c |   14 +++++++++++++-
 drivers/net/sky2.h |    2 +-
 2 files changed, 14 insertions(+), 2 deletions(-)

--- linux-2.6.22.9.orig/drivers/net/sky2.c
+++ linux-2.6.22.9/drivers/net/sky2.c
@@ -2049,6 +2049,13 @@ static struct sk_buff *sky2_receive(stru
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
@@ -2063,7 +2070,8 @@ static struct sk_buff *sky2_receive(stru
 	if (!(status & GMR_FS_RX_OK))
 		goto resubmit;
 
-	if (status >> 16 != length)
+	/* if length reported by DMA does not match PHY, packet was truncated */
+	if (length != count)
 		goto len_mismatch;
 
 	if (length < copybreak)
@@ -2079,6 +2087,10 @@ len_mismatch:
 	/* Truncation of overlength packets
 	   causes PHY length to not match MAC length */
 	++sky2->net_stats.rx_length_errors;
+	if (netif_msg_rx_err(sky2) && net_ratelimit())
+		pr_info(PFX "%s: rx length mismatch: length %d status %#x\n",
+			dev->name, length, status);
+	goto resubmit;
 
 error:
 	++sky2->net_stats.rx_errors;
--- linux-2.6.22.9.orig/drivers/net/sky2.h
+++ linux-2.6.22.9/drivers/net/sky2.h
@@ -1579,7 +1579,7 @@ enum {
 
 /* Receive Frame Status Encoding */
 enum {
-	GMR_FS_LEN	= 0xffff<<16, /* Bit 31..16:	Rx Frame Length */
+	GMR_FS_LEN	= 0x7fff<<16, /* Bit 30..16:	Rx Frame Length */
 	GMR_FS_VLAN	= 1<<13, /* VLAN Packet */
 	GMR_FS_JABBER	= 1<<12, /* Jabber Packet */
 	GMR_FS_UN_SIZE	= 1<<11, /* Undersize Packet */
