From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [RFC] Store inner MTU in dst_pmtu for IPsec
Date: Mon, 19 Apr 2004 22:56:29 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040419125629.GA24314@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="uAKRQypu60I7Lcqm"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

WARNING: This patch is completely untested.

Various people have reported that there are issues with TCP MTU handling
with the native IPsec stack.  I found that if your interface/route's MTU
is in a certain range then the xfrm4_tunnel_check_size() function is
guaranteed to fail when given a full-sized packet.

The reason is that it uses trailer_len unconditionally even though
trailer_len is calculated for a packet of a particular size (zero).

For example, in the typical ESP/3DES/IPIP scenario, if the MTU is
congruent to 3/4 modulo 8 then this all works.  But all other values
are doomed to fail.  Luckily, the most common MTUs of 1500/1492 happen
to satisfy this condition.  But the MTU of 1480 (IPIP over Ethernet) fails.

The obvious fix is to use get_mss to calculate the correct size.  However,
since get_mss is rather slow I realised that its value should be cached
rather than recomputed for every outgoing packet.

It soon dawned on me that the entire MTU handling for IPsec is broken.
In particular, we simply ignore ICMP need-to-frag packets for peers
that are across an IPsec tunnel.  This is because the dst_pmtu value
for IPsec dst's comes from the route for the IPsec gateway, not the
route for the peer across the IPsec tunnel.

This patch solves the problem in the obvious way by setting the path
to the peer's route instead of that of the IPsec gateway.

I haven't even compiled this patch so there are bound to be problems
with it.  I have also ignored IPv6 for now.  But I'd like to know
whether I'm completely off my head before proceeding any further :)

Thanks,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: include/linux/tcp.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/include/linux/tcp.h,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 tcp.h
--- a/include/linux/tcp.h	5 Apr 2004 09:49:43 -0000	1.1.1.8
+++ b/include/linux/tcp.h	19 Apr 2004 12:39:44 -0000
@@ -250,7 +250,6 @@
 	__u16	mss_cache_std;	/* Like mss_cache, but without TSO */
 	__u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
 	__u16	ext_header_len;	/* Network protocol overhead (IP/IPv6 options) */
-	__u16	ext2_header_len;/* Options depending on route */
 	__u8	ca_state;	/* State of fast-retransmit machine 	*/
 	__u8	retransmits;	/* Number of unrecovered RTO timeouts.	*/
 
Index: include/net/tcp.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/include/net/tcp.h,v
retrieving revision 1.1.1.13
diff -u -r1.1.1.13 tcp.h
--- a/include/net/tcp.h	11 Mar 2004 02:55:22 -0000	1.1.1.13
+++ b/include/net/tcp.h	19 Apr 2004 12:39:56 -0000
@@ -1030,8 +1030,7 @@
 
 	if (dst) {
 		u32 mtu = dst_pmtu(dst);
-		if (mtu != tp->pmtu_cookie ||
-		    tp->ext2_header_len != dst->header_len)
+		if (mtu != tp->pmtu_cookie)
 			mss_now = tcp_sync_mss(sk, mtu);
 	}
 	if (tp->eff_sacks)
Index: net/core/dst.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/core/dst.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 dst.c
--- a/net/core/dst.c	5 Feb 2004 08:19:57 -0000	1.1.1.8
+++ b/net/core/dst.c	19 Apr 2004 12:11:02 -0000
@@ -170,6 +170,9 @@
 	struct hh_cache *hh;
 
 again:
+	if (dst->path != dst)
+		atomic_dec(&dst->path->__refcnt);
+
 	neigh = dst->neighbour;
 	hh = dst->hh;
 	child = dst->child;
Index: net/ipv4/ip_sockglue.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/ipv4/ip_sockglue.c,v
retrieving revision 1.1.1.7
diff -u -r1.1.1.7 ip_sockglue.c
--- a/net/ipv4/ip_sockglue.c	11 Mar 2004 02:55:24 -0000	1.1.1.7
+++ b/net/ipv4/ip_sockglue.c	19 Apr 2004 12:33:05 -0000
@@ -957,7 +957,7 @@
 			val = 0;
 			dst = sk_dst_get(sk);
 			if (dst) {
-				val = dst_pmtu(dst) - dst->header_len;
+				val = dst_pmtu(dst);
 				dst_release(dst);
 			}
 			if (!val) {
Index: net/ipv4/tcp_ipv4.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/ipv4/tcp_ipv4.c,v
retrieving revision 1.4
diff -u -r1.4 tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	5 Apr 2004 10:54:54 -0000	1.4
+++ b/net/ipv4/tcp_ipv4.c	19 Apr 2004 12:39:00 -0000
@@ -841,7 +841,6 @@
 	/* OK, now commit destination to socket.  */
 	__sk_dst_set(sk, &rt->u.dst);
 	tcp_v4_setup_caps(sk, &rt->u.dst);
-	tp->ext2_header_len = rt->u.dst.header_len;
 
 	if (!tp->write_seq)
 		tp->write_seq = secure_tcp_sequence_number(inet->saddr,
@@ -1592,7 +1591,6 @@
 	newtp->ext_header_len = 0;
 	if (newinet->opt)
 		newtp->ext_header_len = newinet->opt->optlen;
-	newtp->ext2_header_len = dst->header_len;
 	newinet->id = newtp->write_seq ^ jiffies;
 
 	tcp_sync_mss(newsk, dst_pmtu(dst));
@@ -1891,7 +1889,6 @@
 
 	__sk_dst_set(sk, &rt->u.dst);
 	tcp_v4_setup_caps(sk, &rt->u.dst);
-	tcp_sk(sk)->ext2_header_len = rt->u.dst.header_len;
 
 	new_saddr = rt->rt_src;
 
@@ -1951,7 +1948,6 @@
 	if (!err) {
 		__sk_dst_set(sk, &rt->u.dst);
 		tcp_v4_setup_caps(sk, &rt->u.dst);
-		tcp_sk(sk)->ext2_header_len = rt->u.dst.header_len;
 		return 0;
 	}
 
Index: net/ipv4/tcp_output.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/ipv4/tcp_output.c,v
retrieving revision 1.1.1.7
diff -u -r1.1.1.7 tcp_output.c
--- a/net/ipv4/tcp_output.c	8 Oct 2003 19:24:17 -0000	1.1.1.7
+++ b/net/ipv4/tcp_output.c	19 Apr 2004 12:38:37 -0000
@@ -558,9 +558,6 @@
 	struct dst_entry *dst = __sk_dst_get(sk);
 	int mss_now;
 
-	if (dst && dst->ops->get_mss)
-		pmtu = dst->ops->get_mss(dst, pmtu);
-
 	/* Calculate base mss without TCP options:
 	   It is MMS_S - sizeof(tcphdr) of rfc1122
 	 */
@@ -571,7 +568,7 @@
 		mss_now = tp->mss_clamp;
 
 	/* Now subtract optional transport overhead */
-	mss_now -= tp->ext_header_len + tp->ext2_header_len;
+	mss_now -= tp->ext_header_len;
 
 	/* Then reserve room for full set of TCP options and 8 bytes of data */
 	if (mss_now < 48)
@@ -592,7 +589,7 @@
 		int large_mss;
 
 		large_mss = 65535 - tp->af_specific->net_header_len -
-			tp->ext_header_len - tp->ext2_header_len - tp->tcp_header_len;
+			tp->ext_header_len - tp->tcp_header_len;
 
 		if (tp->max_window && large_mss > (tp->max_window>>1))
 			large_mss = max((tp->max_window>>1), 68U - tp->tcp_header_len);
Index: net/ipv4/xfrm4_policy.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/ipv4/xfrm4_policy.c,v
retrieving revision 1.4
diff -u -r1.4 xfrm4_policy.c
--- a/net/ipv4/xfrm4_policy.c	5 Apr 2004 10:54:54 -0000	1.4
+++ b/net/ipv4/xfrm4_policy.c	19 Apr 2004 12:25:13 -0000
@@ -133,7 +133,8 @@
 		dst_prev->header_len	= header_len;
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &rt->u.dst.metrics, sizeof(dst_prev->metrics));
-		dst_prev->path		= &rt->u.dst;
+		dst_hold(&rt0->u.dst);
+		dst_prev->path		= &rt0->u.dst;
 
 		/* Copy neighbout for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
@@ -153,6 +154,10 @@
 		header_len -= x->u.dst.xfrm->props.header_len;
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
+
+	rt0->u.dst.metrics[RTAX_MTU-1] =
+		dst->get_mss(dst, dst_metric(dst, RTAX_MTU)) - dst->header_len;
+
 	*dst_p = dst;
 	return 0;
 
@@ -227,9 +232,6 @@
 {
 	struct dst_entry *path = dst->path;
 
-	if (mtu < 68 + dst->header_len)
-		return;
-
 	path->ops->update_pmtu(path, mtu);
 }
 
Index: net/ipv4/xfrm4_tunnel.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/ipv4/xfrm4_tunnel.c,v
retrieving revision 1.3
diff -u -r1.3 xfrm4_tunnel.c
--- a/net/ipv4/xfrm4_tunnel.c	28 Sep 2003 01:39:20 -0000	1.3
+++ b/net/ipv4/xfrm4_tunnel.c	19 Apr 2004 12:17:05 -0000
@@ -24,7 +24,7 @@
 		goto out;
 
 	dst = skb->dst;
-	mtu = dst_pmtu(dst) - dst->header_len - dst->trailer_len;
+	mtu = dst_pmtu(dst);
 	if (skb->len > mtu) {
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 		ret = -EMSGSIZE;

--uAKRQypu60I7Lcqm--
