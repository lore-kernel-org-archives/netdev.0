From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] MTU discovery not working over GRE
Date: Fri, 4 May 2012 14:04:53 -0700
Message-ID: <20120504140453.452794c4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57903 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932644Ab2EDVE5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 17:04:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using gretap, I am seeing that Path MTU discovery is not
working for packets going out over the tunnel interface. What happens
is that the driver correctly identifies the DF bit, and see IPv4
but since skb_dst(skb) is NULL, the icmp_send() ends up doing nothing.

The following fixes the problem but does not seem like the correct general
solution. IPv6 almost certainly has the same problem.
Perhaps we should just set the skb_dst() earlier (before the
MTU checks).

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 1017460..da57bb0 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -838,8 +838,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 
 		if ((old_iph->frag_off&htons(IP_DF)) &&
 		    mtu < ntohs(old_iph->tot_len)) {
+			skb_dst_drop(skb);
+			skb_dst_set(skb, &rt->dst);
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
-			ip_rt_put(rt);
 			goto tx_error;
 		}
 	}
