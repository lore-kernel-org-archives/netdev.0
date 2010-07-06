From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] gre: propagate ipv6 transport class
Date: Tue, 6 Jul 2010 10:58:21 -0700
Message-ID: <20100706105821.7b0e2538@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57589 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752907Ab0GFR6Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jul 2010 13:58:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes IPV6 over IPv4 GRE tunnel propagate the transport
class field from the underlying IPV6 header to the IPV4 Type Of Service
field. Without the patch, all IPV6 packets in tunnel look the same to QoS.

This assumes that IPV6 transport class is exactly the same
as IPv4 TOS. Not sure if that is always the case?  Maybe need
to mask off some bits.

The mask and shift to get tclass is copied from ipv6/datagram.c

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/ip_gre.c	2010-07-06 08:52:03.702096234 -0700
+++ b/net/ipv4/ip_gre.c	2010-07-06 08:59:18.416738831 -0700
@@ -731,6 +731,8 @@ static netdev_tx_t ipgre_tunnel_xmit(str
 		tos = 0;
 		if (skb->protocol == htons(ETH_P_IP))
 			tos = old_iph->tos;
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			tos = (ntohl(*(__be32 *)ipv6_hdr(skb)) >> 20) & 0xff;
 	}
 
 	{
