From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 17:57:21 +1000
Message-ID: <20100519075721.GA23926@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Graf <tgraf@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:51683 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754042Ab0ESH5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 03:57:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

tun: Use netif_receive_skb instead of netif_rx

First a bit of history as I recall, Dave can correct me where
he recalls differently :)

1) There was netif_rx and everyone had to use that.
2) Everyone had to use that, including drivers/net/tun.c.
3) NAPI brings us netif_receive_skb.
4) About the same time people noticed that tun.c can cause wild
   fluctuations in latency because of its use of netif_rx with IRQs
   enabled.
5) netif_rx_ni was added to address this.

However, netif_rx_ni was really a bit of a roundabout way of
injecting a packet if you think about it.  What ends up happening
is that we always queue the packet into the backlog, and then
immediately process it.  Which is what would happen if we simply
called netif_receive_skb directly.

So this patch just does the obvious thing and makes tun.c call
netif_receive_skb, albeit through the netif_receive_skb_ni wrapper
which does the necessary things for calling it in process context.

Now apart from potential performance gains from eliminating
unnecessary steps in the process, this has the benefit of keeping
the process context for the packet processing.  This is needed
by cgroups to shape network traffic based on the original process.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4326520..0eed49f 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -667,7 +667,7 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
 		skb_shinfo(skb)->gso_segs = 0;
 	}
 
-	netif_rx_ni(skb);
+	netif_receive_skb_ni(skb);
 
 	tun->dev->stats.rx_packets++;
 	tun->dev->stats.rx_bytes += len;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fa8b476..34bb405 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1562,6 +1562,18 @@ extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
+
+static inline int netif_receive_skb_ni(struct sk_buff *skb)
+{
+	int err;
+
+	local_bh_disable();
+	err = netif_receive_skb(skb);
+	local_bh_enable();
+
+	return err;
+}
+
 extern gro_result_t	dev_gro_receive(struct napi_struct *napi,
 					struct sk_buff *skb);
 extern gro_result_t	napi_skb_finish(gro_result_t ret, struct sk_buff *skb);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
