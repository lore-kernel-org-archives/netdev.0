From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Fri, 28 Aug 2009 09:53:40 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908280948320.3747@gentwo.org>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>  <alpine.DEB.1.10.0908251514190.17963@gentwo.org>  <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908261223210.9933@gentwo.org>
 <1251309040.10599.34.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908261506590.9933@gentwo.org> <1251324666.10599.72.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908271139450.14277@gentwo.org>
 <alpine.DEB.1.10.0908271621260.28029@gentwo.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:36155 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751570AbZH1NyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 09:54:03 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9221982C83F
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 09:55:10 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id lhs4w35OgnwQ for <netdev@vger.kernel.org>;
	Fri, 28 Aug 2009 09:55:10 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 907A782C86D
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 09:55:03 -0400 (EDT)
In-Reply-To: <alpine.DEB.1.10.0908271621260.28029@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The qdisc drop counter is incremented in pfifo_fast. So Sridhar's patch is
not necessary.

Seems though that the qdisc drop count does not flow into the tx_dropped
counter for the interface. Incrementing the tx_dropped count in the
netdev_queue associated with the outbound qdisc also had no effect (see
the following patch).

Plus I only see one queue for eth0 with "tc -s qdisc show". I think that
what I see there is the queue for receiving packets. tc uses this ugly
netlink interface. Could be a bug in there or in the netlink interface?
Or is there some other trick to display queue statistics for outgoing
packets?

WTH is going on here? Noone was ever interested in making outbound packet
loss account right?


Index: linux-2.6.31-rc7/include/net/sch_generic.h
===================================================================
--- linux-2.6.31-rc7.orig/include/net/sch_generic.h	2009-08-27
21:20:03.000000000 +0000
+++ linux-2.6.31-rc7/include/net/sch_generic.h	2009-08-27
21:26:33.000000000 +0000
@@ -509,6 +509,9 @@ static inline int qdisc_drop(struct sk_b
 	kfree_skb(skb);
 	sch->qstats.drops++;

+	/* device queue statistics */
+	sch->dev_queue->tx_dropped++;
+
 	return NET_XMIT_DROP;
 }




