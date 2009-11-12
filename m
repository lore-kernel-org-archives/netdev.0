From: Ben McKeegan <ben@netservers.co.uk>
Subject: [PATCH] ppp: fix BUG on non-linear SKB (multilink receive)
Date: Thu, 12 Nov 2009 13:09:57 +0000 (GMT)
Message-ID: <Pine.LNX.4.58.0911121144380.25398@benxen>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, paulus@samba.org, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PPP does not correctly call pskb_may_pull() on all necessary receive paths
before reading the PPP protocol, thus causing PPP to report seemingly
random 'unsupported protocols' and eventually trigger BUG_ON(skb->len <
skb->data_len) in skb_pull_rcsum() when receiving multilink protocol in
non-linear skbs.

ppp_receive_nonmp_frame() does not call pskb_may_pull() before reading the
protocol number.  For the non-mp receive path this is not a problem, as
this check is done in ppp_receive_frame().  For the mp receive path,
ppp_mp_reconstruct() usually copies the data into a new linear skb.
However, in the case where the frame is made up of a single mp fragment,
the mp header is pulled and the existing skb used.  This skb was then
passed to ppp_receive_nonmp_frame() without checking if the encapsulated
protocol header can safely be read.

Signed-off-by: Ben McKeegan <ben@netservers.co.uk>
---
This a long standing bug we have observed with PPP over L2TP received on
an e1000e interface, although it may arise with other PPP encapsulations
or devices.

diff -uprN linux-2.6.31.6/drivers/net/ppp_generic.c linux-2.6.31.6-ppp-non-linear-skb/drivers/net/ppp_generic.c
--- linux-2.6.31.6/drivers/net/ppp_generic.c	2009-11-10 00:32:31.000000000 +0000
+++ linux-2.6.31.6-ppp-non-linear-skb/drivers/net/ppp_generic.c	2009-11-12 11:58:40.000000000 +0000
@@ -1944,7 +1944,13 @@ ppp_receive_mp_frame(struct ppp *ppp, st

 	/* Pull completed packets off the queue and receive them. */
 	while ((skb = ppp_mp_reconstruct(ppp)))
-		ppp_receive_nonmp_frame(ppp, skb);
+	  	if (pskb_may_pull(skb, 2))
+			ppp_receive_nonmp_frame(ppp, skb);
+		else {
+			++ppp->dev->stats.rx_length_errors;
+			kfree_skb(skb);
+			ppp_receive_error(ppp);
+		}

 	return;

