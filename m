From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] [PPP] L2TP: Fix skb handling in pppol2tp_xmit
Date: Wed, 19 Sep 2007 09:30:18 +0800
Message-ID: <20070919013018.GB15046@gondor.apana.org.au>
References: <20070918120438.GA9121@gondor.apana.org.au> <E1IXbqs-0002Od-00@gondolin.me.apana.org.au> <46F032D5.7020806@katalix.com> <20070918.133240.35800852.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jchapman@katalix.com, mostrows@speakeasy.net, paulus@samba.org,
	toralf.foerster@gmx.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3138 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750758AbXISBah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 21:30:37 -0400
Content-Disposition: inline
In-Reply-To: <20070918.133240.35800852.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 18, 2007 at 01:32:40PM -0700, David Miller wrote:
> 
> I'll make sure not to push this until we figure out what's
> wrong, thanks for checking James.

I think it was because of a double-free that I created after
transmitting the packet.  In fact I had the same bug in PPPOE
too.

[PPP] pppoe: Fix double-free on skb after transmit failure

When I got rid of the second packet in __pppoe_xmit I created
a double-free on the skb because of the goto abort on failure.
This patch removes that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 0d7f570..9b30cd6 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -879,8 +879,7 @@ static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 	dev->hard_header(skb, dev, ETH_P_PPP_SES,
 			 po->pppoe_pa.remote, NULL, data_len);
 
-	if (dev_queue_xmit(skb) < 0)
-		goto abort;
+	dev_queue_xmit(skb);
 
 	return 1;
 
