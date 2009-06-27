From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 13627] New: Tunnel device ignores TCP/UDP
	traffic
Date: Sat, 27 Jun 2009 10:04:03 +0800
Message-ID: <20090627020403.GB19639@gondor.apana.org.au>
References: <bug-13627-10286@http.bugzilla.kernel.org/> <20090626124444.c24d9b38.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <olver@hartkopp.net>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pm@debian.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47899 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755227AbZF0CEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 22:04:04 -0400
Content-Disposition: inline
In-Reply-To: <20090626124444.c24d9b38.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 12:44:44PM -0700, Andrew Morton wrote:
>
> It's a post-2.6.30 regression which Paul has bisected down to
> 
>   commit d55d87fdff8252d0e2f7c28c2d443aee17e9d70f
>   Author:     Herbert Xu <herbert@gondor.apana.org.au>
>   AuthorDate: Mon Jun 22 02:25:25 2009 +0000
>   Commit:     David S. Miller <davem@davemloft.net>
>   CommitDate: Tue Jun 23 16:36:25 2009 -0700
> 
>       net: Move rx skb_orphan call to where needed
> 
> (thanks for doing the bisection!)

Doh, I'd forgotten about transparent proxying.

inet: Call skb_orphan before tproxy activates

As transparent proxying looks up the socket early and assigns
it to the skb for later processing, we must drop any existing
socket ownership prior to that in order to distinguish between
the case where tproxy is active and where it is not.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 490ce20..db46b4b 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -440,6 +440,9 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	/* Remove any debris in the socket control block */
 	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
 
+	/* Must drop socket now because of tproxy. */
+	skb_orphan(skb);
+
 	return NF_HOOK(PF_INET, NF_INET_PRE_ROUTING, skb, dev, NULL,
 		       ip_rcv_finish);
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index c3a07d7..6d6a427 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -139,6 +139,9 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 
 	rcu_read_unlock();
 
+	/* Must drop socket now because of tproxy. */
+	skb_orphan(skb);
+
 	return NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, skb, dev, NULL,
 		       ip6_rcv_finish);
 err:

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
