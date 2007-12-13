From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Make callers of xfrm_lookup to use XFRM_LOOKUP_WAIT
Date: Thu, 13 Dec 2007 09:46:23 +0800
Message-ID: <20071213014623.GB32308@gondor.apana.org.au>
References: <20071212012552.GA20618@gondor.apana.org.au> <E1J2GrH-0005SK-00@gondolin.me.apana.org.au> <20071212.104342.206132994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4990 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751718AbXLMBq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 20:46:26 -0500
Content-Disposition: inline
In-Reply-To: <20071212.104342.206132994.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 12, 2007 at 10:43:42AM -0800, David Miller wrote:
>
> Begrudgingly, I've applied this, but only to make the merging of your
> work easier.  I think this flag is totally wrong and you need to
> fix this up.

Well I did do a grep to make sure it's safe.  But yeah relying
on ip_route_connect to pass the right value through isn't nice.

[IPSEC]: Make callers of xfrm_lookup to use XFRM_LOOKUP_WAIT

This patch converts all callers of xfrm_lookup that used an
explicit value of 1 to indiciate blocking to use the new flag
XFRM_LOOKUP_WAIT.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 87c98fb..a08e2cb 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -994,7 +994,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	err = __xfrm_lookup(&dst, &fl, sk, 1);
+	err = __xfrm_lookup(&dst, &fl, sk, XFRM_LOOKUP_WAIT);
 	if (err < 0) {
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, &fl);
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index eb07df9..62f3ae7 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1196,7 +1196,8 @@ int dn_route_output_sock(struct dst_entry **pprt, struct flowi *fl, struct sock
 
 	err = __dn_route_output_key(pprt, fl, flags & MSG_TRYHARD);
 	if (err == 0 && fl->proto) {
-		err = xfrm_lookup(pprt, fl, sk, !(flags & MSG_DONTWAIT));
+		err = xfrm_lookup(pprt, fl, sk, (flags & MSG_DONTWAIT) ?
+						XFRM_LOOKUP_WAIT : 0);
 	}
 	return err;
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 245f5cf..f00edae 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2536,7 +2536,8 @@ int ip_route_output_flow(struct rtable **rp, struct flowi *flp, struct sock *sk,
 			flp->fl4_src = (*rp)->rt_src;
 		if (!flp->fl4_dst)
 			flp->fl4_dst = (*rp)->rt_dst;
-		err = __xfrm_lookup((struct dst_entry **)rp, flp, sk, flags);
+		err = __xfrm_lookup((struct dst_entry **)rp, flp, sk,
+				    flags ? XFRM_LOOKUP_WAIT : 0);
 		if (err == -EREMOTE)
 			err = ipv4_dst_blackhole(rp, flp, sk);
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 2ed689a..707ba45 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -177,7 +177,7 @@ ipv4_connected:
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = __xfrm_lookup(&dst, &fl, sk, 1)) < 0) {
+	if ((err = __xfrm_lookup(&dst, &fl, sk, XFRM_LOOKUP_WAIT)) < 0) {
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, &fl);
 		if (err < 0)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 850b83e..2663fd1 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -871,7 +871,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = __xfrm_lookup(&dst, &fl, sk, 1)) < 0) {
+	if ((err = __xfrm_lookup(&dst, &fl, sk, XFRM_LOOKUP_WAIT)) < 0) {
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, &fl);
 		if (err < 0)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0604d9d..d576833 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -265,7 +265,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = __xfrm_lookup(&dst, &fl, sk, 1)) < 0) {
+	if ((err = __xfrm_lookup(&dst, &fl, sk, XFRM_LOOKUP_WAIT)) < 0) {
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, &fl);
 		if (err < 0)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1e3bd39..8cbdcc9 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -757,7 +757,7 @@ do_udp_sendmsg:
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = __xfrm_lookup(&dst, &fl, sk, 1)) < 0) {
+	if ((err = __xfrm_lookup(&dst, &fl, sk, XFRM_LOOKUP_WAIT)) < 0) {
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, &fl);
 		if (err < 0)
