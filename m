From: Ben McKeegan <ben@netservers.co.uk>
Subject: Re: [PATCH] ppp: fix BUG on non-linear SKB (multilink receive)
Date: Mon, 16 Nov 2009 13:44:25 +0000 (GMT)
Message-ID: <Pine.LNX.4.58.0911161334240.15274@benxen>
References: <Pine.LNX.4.58.0911121144380.25398@benxen>
 <20091113.194650.214404898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: paulus@samba.org, netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20091113.194650.214404898.davem@davemloft.net>
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
protocol header could safely be read.

Signed-off-by: Ben McKeegan <ben@netservers.co.uk>
---
diff -uprN linux-2.6.31.6/drivers/net/ppp_generic.c linux-2.6.31.6-ppp-non-linear-skb/drivers/net/ppp_generic.c
--- linux-2.6.31.6/drivers/net/ppp_generic.c	2009-11-10 00:32:31.000000000 +0000
+++ linux-2.6.31.6-ppp-non-linear-skb/drivers/net/ppp_generic.c	2009-11-16 13:14:22.000000000 +0000
@@ -1943,8 +1943,15 @@ ppp_receive_mp_frame(struct ppp *ppp, st
 	}

 	/* Pull completed packets off the queue and receive them. */
-	while ((skb = ppp_mp_reconstruct(ppp)))
-		ppp_receive_nonmp_frame(ppp, skb);
+	while ((skb = ppp_mp_reconstruct(ppp))) {
+	  	if (pskb_may_pull(skb, 2))
+			ppp_receive_nonmp_frame(ppp, skb);
+		else {
+			++ppp->dev->stats.rx_length_errors;
+			kfree_skb(skb);
+			ppp_receive_error(ppp);
+		}
+	}

 	return;

