From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] ppp: Don't stop and restart queue on every TX packet
Date: Mon, 26 Mar 2012 11:03:42 +0100
Message-ID: <1332756222.2379.66.camel@shinybook.infradead.org>
References: <1332450218.32446.79.camel@shinybook.infradead.org>
	 <20120322.230331.1623101647193498167.davem@davemloft.net>
	 <1332672230.32446.160.camel@shinybook.infradead.org>
	 <20120325.173635.1909319488008466320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:49660 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756743Ab2CZKDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 06:03:53 -0400
In-Reply-To: <20120325.173635.1909319488008466320.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46or every transmitted packet, ppp_start_xmit() will stop the netdev
queue and then, if appropriate, restart it. This causes the TX softirq
to run, entirely gratuitously.

This is "only" a waste of CPU time in the normal case, but it's activel=
y
harmful when the PPP device is a TEQL slave =E2=80=94 the wakeup will c=
ause the
offending device to receive the next TX packet from the TEQL queue, whe=
n
it *should* have gone to the next slave in the list. We end up seeing
large bursts of packets on just *one* slave device, rather than using
the full available bandwidth over all slaves.

This patch fixes the problem by *not* unconditionally stopping the queu=
e
in ppp_start_xmit(). It adds a return value from ppp_xmit_process()
which indicates whether the queue should be stopped or not.

It *doesn't* remove the call to netif_wake_queue() from
ppp_xmit_process(), because other code paths (especially from
ppp_output_wakeup()) need it there and it's messy to push it out to the
other callers to do it based on the return value. So we leave it in
place =E2=80=94 it's a no-op in the case where the queue wasn't stopped=
, so it's
harmless in the TX path.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

--- drivers/net/ppp/ppp_generic.c~	2012-01-26 00:39:32.000000000 +0000
+++ drivers/net/ppp/ppp_generic.c	2012-03-26 10:32:31.286744147 +0100
@@ -235,7 +235,7 @@ struct ppp_net {
 /* Prototypes. */
 static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
 			struct file *file, unsigned int cmd, unsigned long arg);
-static void ppp_xmit_process(struct ppp *ppp);
+static int ppp_xmit_process(struct ppp *ppp);
 static void ppp_send_frame(struct ppp *ppp, struct sk_buff *skb);
 static void ppp_push(struct ppp *ppp);
 static void ppp_channel_push(struct channel *pch);
@@ -968,9 +968,9 @@ ppp_start_xmit(struct sk_buff *skb, stru
 	proto =3D npindex_to_proto[npi];
 	put_unaligned_be16(proto, pp);
=20
-	netif_stop_queue(dev);
 	skb_queue_tail(&ppp->file.xq, skb);
-	ppp_xmit_process(ppp);
+	if (!ppp_xmit_process(ppp))
+		netif_stop_queue(dev);
 	return NETDEV_TX_OK;
=20
  outf:
@@ -1048,10 +1048,11 @@ static void ppp_setup(struct net_device
  * Called to do any work queued up on the transmit side
  * that can now be done.
  */
-static void
+static int
 ppp_xmit_process(struct ppp *ppp)
 {
 	struct sk_buff *skb;
+	int ret =3D 0;
=20
 	ppp_xmit_lock(ppp);
 	if (!ppp->closing) {
@@ -1061,10 +1062,13 @@ ppp_xmit_process(struct ppp *ppp)
 			ppp_send_frame(ppp, skb);
 		/* If there's no work left to do, tell the core net
 		   code that we can accept some more. */
-		if (!ppp->xmit_pending && !skb_peek(&ppp->file.xq))
+		if (!ppp->xmit_pending && !skb_peek(&ppp->file.xq)) {
 			netif_wake_queue(ppp->dev);
+			ret =3D 1;
+		}
 	}
 	ppp_xmit_unlock(ppp);
+	return ret;
 }
=20
 static inline struct sk_buff *

--=20
David Woodhouse                            Open Source Technology Centr=
e
David.Woodhouse@intel.com                              Intel Corporatio=
n
