From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: RT patches expose netdev race [was Re: [RFC] [patch 2/2] powerpc 2.6.21-rt1: fix kernel hang and/or panic
Date: Thu, 17 May 2007 18:52:47 -0500
Message-ID: <20070517235247.GJ4325@austin.ibm.com>
References: <yyiirau5v8g.wl@toshiba.co.jp> <1179223742.32247.184.camel@localhost.localdomain> <20070517001801.GB4325@austin.ibm.com> <20070516.174101.45179259.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benh@kernel.crashing.org, tsutomu.owa@toshiba.co.jp,
	linuxppc-dev@ozlabs.org, mingo@elte.hu, tglx@linutronix.de,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:49299 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755649AbXEQXwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 19:52:53 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4HNqr3H030352
	for <netdev@vger.kernel.org>; Thu, 17 May 2007 19:52:53 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4HNqq4L210330
	for <netdev@vger.kernel.org>; Thu, 17 May 2007 17:52:52 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4HNqpsu001679
	for <netdev@vger.kernel.org>; Thu, 17 May 2007 17:52:52 -0600
Content-Disposition: inline
In-Reply-To: <20070516.174101.45179259.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2007 at 05:41:01PM -0700, David Miller wrote:
> From: linas@austin.ibm.com (Linas Vepstas)
> Date: Wed, 16 May 2007 19:18:02 -0500
> 
> > Since this is a long email; let me put a summary up front:
> > I think the RT/premption patches are exposing some sort
> > of race in the ip header handling code. The rest of the 
> > note is forensics pointing to this.
> 
> skb->head should never ever be NULL.

The stack trace from Owa-san showed a null pointer deref at 
ip_hdr(skb)->protocol for an skb passed in via hard_start_xmit()

I dunno, memory corruption?

Tsutomu, can you reproduce this with something similr to the following
patch?

--linas

 drivers/net/spider_net.c |   16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-05-17 18:31:40.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-05-17 18:51:49.000000000 -0500
@@ -720,7 +720,19 @@ spider_net_prepare_tx_descr(struct spide
 			SPIDER_NET_DESCR_CARDOWNED | SPIDER_NET_DMAC_NOCS;
 	spin_unlock_irqrestore(&chain->lock, flags);
 
-	if (skb->protocol == htons(ETH_P_IP) && skb->ip_summed == CHECKSUM_PARTIAL)
+	if (skb->protocol == htons(ETH_P_IP) && skb->ip_summed == CHECKSUM_PARTIAL) {
+		struct iphdr *hp=ip_hdr(skb);
+		if (((unsigned long) hp < 0x100000) || 
+		    ((unsigned long)hp > 0xffff000000000000UL)) {
+			printk(KERN_ERROR "spidernet: bad ip header! "
+				"skb=%p ip_hdr=%p head=%p data=%p net=%x\n", skb, hp,
+				skb->head, skb->data, skb->network_header);
+			int i;
+			unsinged long *s=(unsigned long*) skb;
+			for (i=0; i<20; i++) {
+				printk("%d %lx %lx\n", i, s[2*i],s[2*i+1]);
+			}
+		} else {
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_TCP:
 			hwdescr->dmac_cmd_status |= SPIDER_NET_DMAC_TCP;
@@ -728,6 +740,8 @@ spider_net_prepare_tx_descr(struct spide
 		case IPPROTO_UDP:
 			hwdescr->dmac_cmd_status |= SPIDER_NET_DMAC_UDP;
 			break;
+		}
+		}
 	}
 
 	/* Chain the bus address, so that the DMA engine finds this descr. */
