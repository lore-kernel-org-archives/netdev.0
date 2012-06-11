From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] inet: Hide route peer accesses behind helpers.
Date: Mon, 11 Jun 2012 04:19:10 -0700 (PDT)
Message-ID: <20120611.041910.1087693152444897262.davem@davemloft.net>
References: <20120611.022908.953732817435232845.davem@davemloft.net>
	<1339411862.6001.2015.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204Ab2FKLTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 07:19:13 -0400
In-Reply-To: <1339411862.6001.2015.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Jun 2012 12:51:02 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> On Mon, 2012-06-11 at 02:29 -0700, David Miller wrote:
>> +static inline bool inetpeer_ptr_set_peer(unsigned long *ptr, struct inet_peer *peer)
>> +{
>> +	unsigned long val = (unsigned long) peer;
>> +	unsigned long orig = *ptr;
>> +
>> +	if (!(orig & INETPEER_BASE_BIT) || !val ||
>> +	    cmpxchg(ptr, orig, val) != orig)
>> +		return false;
>> +	return true;
>> +}
> 
> If peer is NULL here, we return false;

Good catch.

--------------------
inet: Avoid potential NULL peer dereference.

We handle NULL in rt{,6}_set_peer but then our caller will try to pass
that NULL pointer into inet_putpeer() which isn't ready for it.

Fix this by moving the NULL check one level up, and then remove the
now unnecessary NULL check from inetpeer_ptr_set_peer().

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h |    2 +-
 net/ipv4/route.c       |   11 ++++++-----
 net/ipv6/route.c       |   10 ++++++----
 3 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index e15c086..c27c8f1 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -104,7 +104,7 @@ static inline bool inetpeer_ptr_set_peer(unsigned long *ptr, struct inet_peer *p
 	unsigned long val = (unsigned long) peer;
 	unsigned long orig = *ptr;
 
-	if (!(orig & INETPEER_BASE_BIT) || !val ||
+	if (!(orig & INETPEER_BASE_BIT) ||
 	    cmpxchg(ptr, orig, val) != orig)
 		return false;
 	return true;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4c33ce3..842510d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1333,11 +1333,12 @@ void rt_bind_peer(struct rtable *rt, __be32 daddr, int create)
 		return;
 
 	peer = inet_getpeer_v4(base, daddr, create);
-
-	if (!rt_set_peer(rt, peer))
-		inet_putpeer(peer);
-	else
-		rt->rt_peer_genid = rt_peer_genid();
+	if (peer) {
+		if (!rt_set_peer(rt, peer))
+			inet_putpeer(peer);
+		else
+			rt->rt_peer_genid = rt_peer_genid();
+	}
 }
 
 /*
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d9ba480..58a3ec2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -313,10 +313,12 @@ void rt6_bind_peer(struct rt6_info *rt, int create)
 		return;
 
 	peer = inet_getpeer_v6(base, &rt->rt6i_dst.addr, create);
-	if (!rt6_set_peer(rt, peer))
-		inet_putpeer(peer);
-	else
-		rt->rt6i_peer_genid = rt6_peer_genid();
+	if (peer) {
+		if (!rt6_set_peer(rt, peer))
+			inet_putpeer(peer);
+		else
+			rt->rt6i_peer_genid = rt6_peer_genid();
+	}
 }
 
 static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
-- 
1.7.10
