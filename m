From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT] netpoll: fully initialize skb
Date: Wed, 18 Oct 2006 20:04:21 -0700
Message-ID: <20061018200421.79877ced@localhost.localdomain>
References: <Pine.LNX.4.64.0610152043060.3962@g5.osdl.org>
	<20061017170147.08edc149@freekitty>
	<Pine.LNX.4.64.0610171712050.3962@g5.osdl.org>
	<20061017190321.0414fb38@dads-laptop>
	<Pine.LNX.4.64.0610172129320.3962@g5.osdl.org>
	<20061017214830.07cb89bb@dads-laptop>
	<Pine.LNX.4.64.0610180932500.3962@g5.osdl.org>
	<Pine.LNX.4.64.0610181002390.3962@g5.osdl.org>
	<Pine.LNX.4.64.0610181014230.3962@g5.osdl.org>
	<20061018125629.5f480ff7@dxpl.pdx.osdl.net>
	<Pine.LNX.4.64.0610181310040.3962@g5.osdl.org>
	<20061018144553.6a40e0a4@dxpl.pdx.osdl.net>
	<Pine.LNX.4.64.0610181501490.3962@g5.osdl.org>
	<20061018154915.324900d6@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:62650 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030293AbWJSDFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 23:05:01 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061018154915.324900d6@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This stops the 
	protocol 0000 is buggy, dev eth0
messages from occurring when netpoll decides to queue packets.
It fully initializes the protocol fields.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

If you want to wait on including it, I intend to rollup all the netpoll
patches into a patchbomb tomorrow.

--- netpoll.orig/net/core/netpoll.c
+++ netpoll/net/core/netpoll.c
@@ -335,13 +335,13 @@ void netpoll_send_udp(struct netpoll *np
 	memcpy(skb->data, msg, len);
 	skb->len += len;
 
-	udph = (struct udphdr *) skb_push(skb, sizeof(*udph));
+	skb->h.uh = udph = (struct udphdr *) skb_push(skb, sizeof(*udph));
 	udph->source = htons(np->local_port);
 	udph->dest = htons(np->remote_port);
 	udph->len = htons(udp_len);
 	udph->check = 0;
 
-	iph = (struct iphdr *)skb_push(skb, sizeof(*iph));
+	skb->nh.iph = iph = (struct iphdr *)skb_push(skb, sizeof(*iph));
 
 	/* iph->version = 4; iph->ihl = 5; */
 	put_unaligned(0x45, (unsigned char *)iph);
@@ -357,8 +357,8 @@ void netpoll_send_udp(struct netpoll *np
 	iph->check    = ip_fast_csum((unsigned char *)iph, iph->ihl);
 
 	eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
-
-	eth->h_proto = htons(ETH_P_IP);
+	skb->mac.raw = skb->data;
+	skb->protocol = eth->h_proto = htons(ETH_P_IP);
 	memcpy(eth->h_source, np->local_mac, 6);
 	memcpy(eth->h_dest, np->remote_mac, 6);
 
