From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: git-net, git-netdev-all and everything else on g5
Date: Fri, 29 Jun 2007 03:18:31 +0800
Message-ID: <20070628191831.GA25497@gondor.apana.org.au>
References: <20070628021338.0d37f95a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1569 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1765318AbXF1TiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 15:38:03 -0400
Content-Disposition: inline
In-Reply-To: <20070628021338.0d37f95a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 28, 2007 at 09:13:38AM +0000, Andrew Morton wrote:
> 
> With the full -mm lineup, my tg3-using powerpc g5 spits lots of these:
> 
> windfarm: Drive bay control loop started.
> audit(1183017094.732:2): audit_pid=2117 old=0 by auid=4294967295
> ------------[ cut here ]------------
> Badness at net/core/dev.c:1303

Hmm, we really should come up with a better way for checking
checksum support.

[NET]: Fix TX checksum feature check

This patch fixes a boolean error in the new TX checksum check
that causes bogus TSO packets to be generated.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1509,11 +1509,11 @@ int dev_queue_xmit(struct sk_buff *skb)
 		skb_set_transport_header(skb, skb->csum_start -
 					      skb_headroom(skb));
 
-		if (!(dev->features & NETIF_F_GEN_CSUM)
-		    || ((dev->features & NETIF_F_IP_CSUM)
-			&& skb->protocol == htons(ETH_P_IP))
-		    || ((dev->features & NETIF_F_IPV6_CSUM)
-			&& skb->protocol == htons(ETH_P_IPV6)))
+		if (!(dev->features & NETIF_F_GEN_CSUM) &&
+		    !((dev->features & NETIF_F_IP_CSUM) &&
+		      skb->protocol == htons(ETH_P_IP)) &&
+		    !((dev->features & NETIF_F_IPV6_CSUM) &&
+		      skb->protocol == htons(ETH_P_IPV6)))
 			if (skb_checksum_help(skb))
 				goto out_kfree_skb;
 	}
