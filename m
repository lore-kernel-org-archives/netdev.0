From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ipip: Fix handling of DF packets when pmtudisc is OFF
Date: Fri, 6 Nov 2009 15:37:41 -0500
Message-ID: <20091106203741.GA19736@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55454 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759717AbZKFUhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 15:37:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

It appears that our tunnels are pretty much broken when pmtudisc
is turned off.  It's never really showed up in the past as for
pure IP tunnels using pmtudisc is usually a better choice.  But
now that we have raw Ethernet GRE tunnels that are incapable of
doing PMTU within the tunnel, people are running into these bugs
as they have to turn pmtudisc off.

I've got a number of patches that tries to address this but here
is a first to kick things off.

ipip: Fix handling of DF packets when pmtudisc is OFF

RFC 2003 requires the outer header to have DF set if DF is set
on the inner header, even when PMTU discovery is off for the
tunnel.  Our implementation does exactly that.

For this to work properly the IPIP gateway also needs to engate
in PMTU when the inner DF bit is set.  As otherwise the original
host would not be able to carry out its PMTU successfully since
part of the path is only visible to the gateway.

Unfortunately when the tunnel PMTU discovery setting is off, we
do not collect the necessary soft state, resulting in blackholes
when the original host tries to perform PMTU discovery.

This problem is not reproducible on the IPIP gateway itself as
the inner packet usually has skb->local_df set.  This is not
correctly cleared (an unrelated bug) when the packet passes
through the tunnel, which allows fragmentation to occur.  For
hosts behind the IPIP gateway it is readily visible with a simple
ping.

This patch fixes the problem by performing PMTU discovery for
all packets with the inner DF bit set, regardless of the PMTU
discovery setting on the tunnel itself.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 08ccd34..ae40ed1 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -438,25 +438,27 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_error;
 	}
 
-	if (tiph->frag_off)
+	df |= old_iph->frag_off & htons(IP_DF);
+
+	if (df) {
 		mtu = dst_mtu(&rt->u.dst) - sizeof(struct iphdr);
-	else
-		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
 
-	if (mtu < 68) {
-		stats->collisions++;
-		ip_rt_put(rt);
-		goto tx_error;
-	}
-	if (skb_dst(skb))
-		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
+		if (mtu < 68) {
+			stats->collisions++;
+			ip_rt_put(rt);
+			goto tx_error;
+		}
 
-	df |= (old_iph->frag_off&htons(IP_DF));
+		if (skb_dst(skb))
+			skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
 
-	if ((old_iph->frag_off&htons(IP_DF)) && mtu < ntohs(old_iph->tot_len)) {
-		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
-		ip_rt_put(rt);
-		goto tx_error;
+		if ((old_iph->frag_off & htons(IP_DF)) &&
+		    mtu < ntohs(old_iph->tot_len)) {
+			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
+				  htonl(mtu));
+			ip_rt_put(rt);
+			goto tx_error;
+		}
 	}
 
 	if (tunnel->err_count > 0) {

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
