From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
	2.6.27
Date: Fri, 9 Jan 2009 22:55:15 +1100
Message-ID: <20090109115515.GA12486@gondor.apana.org.au>
References: <e7c4531f0901081558n429f7275w717774dbe9ccd895@mail.gmail.com> <20090109031408.GB11336@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Speedster <speedster@haveacry.com>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45976 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752763AbZAILzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 06:55:25 -0500
Content-Disposition: inline
In-Reply-To: <20090109031408.GB11336@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

It turns out that even though we have sysctl's that's supposed
to control pppoe/vlan processing, they don't actually work.

This patch should make them work.

bridge: Fix handling of non-IP packets in FORWARD/POST_ROUTING

Currently the bridge FORWARD/POST_ROUTING chains treats all
non-IPv4 packets as IPv6.  This packet fixes that by returning
NF_ACCEPT on non-IP packets instead, just as is done in PRE_ROUTING.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index a65e43a..9a1cd75 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -686,8 +686,11 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 	if (skb->protocol == htons(ETH_P_IP) || IS_VLAN_IP(skb) ||
 	    IS_PPPOE_IP(skb))
 		pf = PF_INET;
-	else
+	else if (skb->protocol == htons(ETH_P_IPV6) || IS_VLAN_IPV6(skb) ||
+		 IS_PPPOE_IPV6(skb))
 		pf = PF_INET6;
+	else
+		return NF_ACCEPT;
 
 	nf_bridge_pull_encap_header(skb);
 
@@ -828,8 +831,11 @@ static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 	if (skb->protocol == htons(ETH_P_IP) || IS_VLAN_IP(skb) ||
 	    IS_PPPOE_IP(skb))
 		pf = PF_INET;
-	else
+	else if (skb->protocol == htons(ETH_P_IPV6) || IS_VLAN_IPV6(skb) ||
+		 IS_PPPOE_IPV6(skb))
 		pf = PF_INET6;
+	else
+		return NF_ACCEPT;
 
 #ifdef CONFIG_NETFILTER_DEBUG
 	if (skb->dst == NULL) {

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
