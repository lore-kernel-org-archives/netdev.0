From: David Miller <davem@davemloft.net>
Subject: Re: when having to acquire an SA, ipsec drops the packet
Date: Mon, 05 Feb 2007 13:07:43 -0800 (PST)
Message-ID: <20070205.130743.11598998.davem@davemloft.net>
References: <20070204.205315.10325007.davem@davemloft.net>
	<Pine.LNX.4.64.0702051133050.32533@d.namei>
	<Pine.LNX.4.64.0702051532560.3565@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com, netdev@vger.kernel.org, paul.moore@hp.com,
	vyekkirala@TrustedCS.com, herbert@gondor.apana.org.au
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47885
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933444AbXBEVHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 16:07:45 -0500
In-Reply-To: <Pine.LNX.4.64.0702051532560.3565@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Mon, 5 Feb 2007 15:34:39 -0500 (EST)

> On Mon, 5 Feb 2007, James Morris wrote:
> 
> > On Sun, 4 Feb 2007, David Miller wrote:
> > 
> > > Something like this (untested) on the ipv4 side, for example:
> > 
> > Looks like it should work.  Will do some testing.
> 
> Appears to work well, with a slight delay on the first packet as expected.  
> Tested with tcp, udp & icmp.

Thanks for testing James.

Last night I put an updated version of my patch into the net-2.6.21
tree, taking care of the ipv6 bits as well.  I attach it below
for completeness.

commit cbc77956da98305f0525c0b40257608f0c02a357
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Sun Feb 4 21:21:59 2007 -0800

    [IPV4/IPV6]: Always wait for IPSEC SA resolution in socket contexts.
    
    Do this even for non-blocking sockets.  This avoids the silly -EAGAIN
    that applications can see now, even for non-blocking sockets in some
    cases (f.e. connect()).
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/route.h b/include/net/route.h
index 486e37a..a8af632 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -146,7 +146,8 @@ static inline char rt_tos2priority(u8 tos)
 
 static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 				   __be32 src, u32 tos, int oif, u8 protocol,
-				   __be16 sport, __be16 dport, struct sock *sk)
+				   __be16 sport, __be16 dport, struct sock *sk,
+				   int flags)
 {
 	struct flowi fl = { .oif = oif,
 			    .nl_u = { .ip4_u = { .daddr = dst,
@@ -168,7 +169,7 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 		*rp = NULL;
 	}
 	security_sk_classify_flow(sk, &fl);
-	return ip_route_output_flow(rp, &fl, sk, 0);
+	return ip_route_output_flow(rp, &fl, sk, 1);
 }
 
 static inline int ip_route_newports(struct rtable **rp, u8 protocol,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 90c74b4..fa2c982 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -72,7 +72,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	tmp = ip_route_connect(&rt, nexthop, inet->saddr,
 			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			       IPPROTO_DCCP,
-			       inet->sport, usin->sin_port, sk);
+			       inet->sport, usin->sin_port, sk, 1);
 	if (tmp < 0)
 		return tmp;
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 6b91a9d..79140b3 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1041,7 +1041,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	err = xfrm_lookup(&dst, &fl, sk, 0);
+	err = xfrm_lookup(&dst, &fl, sk, 1);
 	if (err < 0)
 		goto failure;
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8640096..5750a2b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1007,7 +1007,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 			       RT_CONN_FLAGS(sk),
 			       sk->sk_bound_dev_if,
 			       sk->sk_protocol,
-			       inet->sport, inet->dport, sk);
+			       inet->sport, inet->dport, sk, 0);
 	if (err)
 		return err;
 
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 7b068a8..0072d79 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -49,7 +49,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	err = ip_route_connect(&rt, usin->sin_addr.s_addr, saddr,
 			       RT_CONN_FLAGS(sk), oif,
 			       sk->sk_protocol,
-			       inet->sport, usin->sin_port, sk);
+			       inet->sport, usin->sin_port, sk, 1);
 	if (err)
 		return err;
 	if ((rt->rt_flags & RTCF_BROADCAST) && !sock_flag(sk, SOCK_BROADCAST)) {
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index a6c63bb..fed6a1e 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -489,7 +489,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		}
 
 		security_sk_classify_flow(sk, &fl);
-		err = ip_route_output_flow(&rt, &fl, sk, !(msg->msg_flags&MSG_DONTWAIT));
+		err = ip_route_output_flow(&rt, &fl, sk, 1);
 	}
 	if (err)
 		goto done;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f061ec5..383e4b5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -191,7 +191,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	tmp = ip_route_connect(&rt, nexthop, inet->saddr,
 			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			       IPPROTO_TCP,
-			       inet->sport, usin->sin_port, sk);
+			       inet->sport, usin->sin_port, sk, 1);
 	if (tmp < 0)
 		return tmp;
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cfff930..8b54c68 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -629,7 +629,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 					       { .sport = inet->sport,
 						 .dport = dport } } };
 		security_sk_classify_flow(sk, &fl);
-		err = ip_route_output_flow(&rt, &fl, sk, !(msg->msg_flags&MSG_DONTWAIT));
+		err = ip_route_output_flow(&rt, &fl, sk, 1);
 		if (err)
 			goto out;
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 5c94fea..ecde301 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -178,7 +178,7 @@ ipv4_connected:
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+	if ((err = xfrm_lookup(&dst, &fl, sk, 1)) < 0)
 		goto out;
 
 	/* source address lookup done in ip6_dst_lookup */
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 4ae1b19..f2e883c 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -815,7 +815,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+	if ((err = xfrm_lookup(&dst, &fl, sk, 1)) < 0)
 		goto out;
 
 	if (hlimit < 0) {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c25e930..dcb7b00 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -265,7 +265,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+	if ((err = xfrm_lookup(&dst, &fl, sk, 1)) < 0)
 		goto failure;
 
 	if (saddr == NULL) {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f52a5c3..15e5195 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -736,7 +736,7 @@ do_udp_sendmsg:
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+	if ((err = xfrm_lookup(&dst, &fl, sk, 1)) < 0)
 		goto out;
 
 	if (hlimit < 0) {
