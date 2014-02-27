From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 06/12] ip_tunnel: Make vti work with i_key set
Date: Thu, 27 Feb 2014 09:00:34 +0100
Message-ID: <1393488040-22005-7-git-send-email-steffen.klassert@secunet.com>
References: <1393488040-22005-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59024 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751309AbaB0IA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 03:00:56 -0500
In-Reply-To: <1393488040-22005-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vti uses the o_key to mark packets that were transmitted or received
by a vti interface. Unfortunately we can't apply different marks
to in and outbound packets with only one key availabe. Vti interfaces
typically use wildcard selectors for vti IPsec policies. On forwarding,
the same output policy will match for both directions. This generates
a loop between the IPsec gateways until the ttl of the packet is
exceeded.

The gre i_key/o_key are usually there to find the right gre tunnel
during a lookup. When vti uses the i_key to mark packets, the tunnel
lookup does not work any more because vti does not use the gre keys
as a hash key for the lookup.

This patch workarounds this my not including the i_key when comupting
the hash for the tunnel lookup in case of vti tunnels.

With this we have separate keys available for the transmitting and
receiving side of the vti interface.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_tunnel.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 6d430ff..4fff644 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -280,13 +280,17 @@ static struct hlist_head *ip_bucket(struct ip_tunnel_net *itn,
 {
 	unsigned int h;
 	__be32 remote;
+	__be32 i_key = parms->i_key;
 
 	if (parms->iph.daddr && !ipv4_is_multicast(parms->iph.daddr))
 		remote = parms->iph.daddr;
 	else
 		remote = 0;
 
-	h = ip_tunnel_hash(parms->i_key, remote);
+	if (!(parms->i_flags & TUNNEL_KEY) && (parms->i_flags & VTI_ISVTI))
+		i_key = 0;
+
+	h = ip_tunnel_hash(i_key, remote);
 	return &itn->tunnels[h];
 }
 
-- 
1.7.9.5
