From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: LRO fix needed
Date: Fri, 1 Sep 2006 14:28:25 +1000
Message-ID: <20060901042825.GA10193@gondor.apana.org.au>
References: <20060831.164227.71090271.davem@davemloft.net> <20060831234347.GA7843@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ananda.Raju@neterion.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:20999 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932094AbWIAE2p
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 00:28:45 -0400
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20060831234347.GA7843@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2006 at 09:43:47AM +1000, herbert wrote:
> 
> It might be better to set it to the biggest frag you see rather
> than the first.

I've coded it up.

BTW Ananda, what hardware assistance do your chips currently provide
for LRO? What are the timeouts used before it gives up on aggregating
a session?

[NETDRV] s2io: Set gso_size for LRO to TCP stack

Now that the TCP stack uses gso_size to estimate the receive MSS,
it helps to actually set it :)

Unlike the sending side, there is no single MSS that naturally
pops up for LRO.  However, for our purposes the maximal TCP payload
size is the most appropriate for estimating MSS.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index e72e0e0..3ebc789 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -6522,6 +6522,8 @@ static int rx_osm_handler(ring_info_t *r
 						&tcp_len, &lro, rxdp, sp);
 				switch (ret) {
 					case 3: /* Begin anew */
+						skb_shinfo(skb)->gso_size =
+							tcp_len;
 						lro->parent = skb;
 						goto aggregate;
 					case 1: /* Aggregate */
@@ -7556,6 +7558,8 @@ static void lro_append_pkt(nic_t *sp, lr
 {
 	struct sk_buff *first = lro->parent;
 
+	if (tcp_len > skb_shinfo(first)->gso_size)
+		skb_shinfo(first)->gso_size = tcp_len;
 	first->len += tcp_len;
 	first->data_len = lro->frags_len;
 	skb_pull(skb, (skb->len - tcp_len));
