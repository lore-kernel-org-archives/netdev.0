From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Convert pppoe to new style protocol
Date: Wed, 18 Jun 2003 00:04:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617220420.GA1169@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mostrows@speakeasy.net, paulus@au.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Convert pppoe to a new style protocol, otherwise it is unusable 
on SMP compiled kernels because of the printk in deliver*old_ones.
It works fine here, but only tested on a UP box.

I checked with paulus and he confirmed that ppp_input is safe
to be called with the new softirq semantics. The PPP path also 
appears to work with shared skbs (never modify skb data, 
not 100% audited however) but not with non linear skbs.

The pppoe code itself is safe because it never uses timers
or does anything complicated.

If someone knows a place in ppp_input that modifies the data 
area then please contain now so that a skb_copy can be added.
 
-Andi

diff -u linux-2.5.72-work/drivers/net/pppoe.c-o linux-2.5.72-work/drivers/net/pppoe.c
--- linux-2.5.72-work/drivers/net/pppoe.c-o	2003-06-14 23:42:51.000000000 +0200
+++ linux-2.5.72-work/drivers/net/pppoe.c	2003-06-17 23:15:11.000000000 +0200
@@ -348,6 +348,9 @@
 	struct pppox_opt *po = pppox_sk(sk);
 	struct pppox_opt *relay_po = NULL;
 
+	if (skb_is_nonlinear(skb) && skb_linearize(skb, GFP_ATOMIC))
+		goto abort_kfree;
+
 	if (sk->sk_state & PPPOX_BOUND) {
 		skb_pull(skb, sizeof(struct pppoe_hdr));
 		ppp_input(&po->chan, skb);
@@ -463,11 +466,13 @@
 struct packet_type pppoes_ptype = {
 	.type	= __constant_htons(ETH_P_PPP_SES),
 	.func	= pppoe_rcv,
+	.data =	(void*) 1,
 };
 
 struct packet_type pppoed_ptype = {
 	.type	= __constant_htons(ETH_P_PPP_DISC),
 	.func	= pppoe_disc_rcv,
+	.data =	(void*) 1,
 };
 
 /***********************************************************************
