From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Thu, 27 Aug 2009 16:23:24 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908271621260.28029@gentwo.org>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>  <alpine.DEB.1.10.0908251514190.17963@gentwo.org>  <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908261223210.9933@gentwo.org>
 <1251309040.10599.34.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908261506590.9933@gentwo.org> <1251324666.10599.72.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908271139450.14277@gentwo.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:46464 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752230AbZH0Udv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 16:33:51 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A05B682C6E2
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2009 16:25:09 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id FEDPcXC-l1dJ for <netdev@vger.kernel.org>;
	Thu, 27 Aug 2009 16:25:09 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C46FF82CB18
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2009 16:24:55 -0400 (EDT)
In-Reply-To: <alpine.DEB.1.10.0908271139450.14277@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ip_local_out returns NET_XMIT_DROP but the qdisc increment does not
trigger...

[  219.098552] ip_local_out failed with 1
[  219.098798] ip_local_out failed with 1
[  219.099091] ip_local_out failed with 1
[  219.099158] ip_local_out failed with 1
[  219.099399] ip_local_out failed with 1
[  219.099466] ip_local_out failed with 1
[  219.099530] ip_local_out failed with 1
[  219.099688] ip_local_out failed with 1
[  219.099751] ip_local_out failed with 1
[  219.099818] ip_local_out failed with 1

---
 net/core/dev.c       |    2 ++
 net/ipv4/ip_output.c |    2 ++
 2 files changed, 4 insertions(+)

Index: linux-2.6.31-rc7/net/core/dev.c
===================================================================
--- linux-2.6.31-rc7.orig/net/core/dev.c	2009-08-27 19:46:44.000000000 +0000
+++ linux-2.6.31-rc7/net/core/dev.c	2009-08-27 19:51:54.000000000 +0000
@@ -1865,6 +1865,8 @@ gso:

 		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
 			rc = qdisc_drop(skb, q);
+			if (net_ratelimit())
+				printk(KERN_CRIT "Qdisc not active. NIC overrun\n");
 		} else {
 			rc = qdisc_enqueue_root(skb, q);
 			qdisc_run(q);
Index: linux-2.6.31-rc7/net/ipv4/ip_output.c
===================================================================
--- linux-2.6.31-rc7.orig/net/ipv4/ip_output.c	2009-08-27 19:48:17.000000000 +0000
+++ linux-2.6.31-rc7/net/ipv4/ip_output.c	2009-08-27 19:51:30.000000000 +0000
@@ -1301,6 +1301,8 @@ int ip_push_pending_frames(struct sock *
 	/* Netfilter gets whole the not fragmented skb. */
 	err = ip_local_out(skb);
 	if (err) {
+		if (net_ratelimit())
+			printk(KERN_CRIT "ip_local_out failed with %d\n", err);
 		if (err > 0)
 			err = net_xmit_errno(err);
 		if (err)
