From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [10/*] [TCP] Get rid of dst_ptmu/ext2_header_len
Date: Mon, 7 Mar 2005 22:45:33 +1100
Message-ID: <20050307114533.GA11190@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050216103744.GA476@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050216103744.GA476@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Here is a patch that replaces all occurrences of dst_pmtu in the TCP
stack.  As a result we no longer need ext2_header_len.

This has a nice synergetic effect with Arnaldo's latest change to
linux/tcp.h :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I'll be removing other users of dst->path/dst_pmtu next.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-10

===== include/linux/tcp.h 1.35 vs edited =====
--- 1.35/include/linux/tcp.h	2005-02-23 05:45:31 +11:00
+++ edited/include/linux/tcp.h	2005-03-07 22:41:00 +11:00
@@ -284,10 +284,13 @@
 	__u32	mss_cache;	/* Cached effective mss, not including SACKS */
 	__u16	mss_cache_std;	/* Like mss_cache, but without TSO */
 	__u16	ext_header_len;	/* Network protocol overhead (IP/IPv6 options) */
-	__u16	ext2_header_len;/* Options depending on route */
 	__u8	ca_state;	/* State of fast-retransmit machine 	*/
 	__u8	retransmits;	/* Number of unrecovered RTO timeouts.	*/
 
+	__u16	advmss;		/* Advertised MSS			*/
+	__u32	window_clamp;	/* Maximal window to advertise		*/
+	__u32	rcv_ssthresh;	/* Current window clamp			*/
+
 	__u32	frto_highmark;	/* snd_nxt when RTO occurred */
 	__u8	reordering;	/* Packet reordering metric.		*/
 	__u8	frto_counter;	/* Number of new acks after RTO */
@@ -345,14 +348,9 @@
 	struct tcp_sack_block duplicate_sack[1]; /* D-SACK block */
 	struct tcp_sack_block selective_acks[4]; /* The SACKS themselves*/
 
-	__u32	window_clamp;	/* Maximal window to advertise		*/
-	__u32	rcv_ssthresh;	/* Current window clamp			*/
-	__u16	advmss;		/* Advertised MSS			*/
-
 	__u8	syn_retries;	/* num of allowed syn retries */
 	__u8	ecn_flags;	/* ECN status bits.			*/
 	__u16	prior_ssthresh; /* ssthresh saved at recovery start	*/
-	__u16	__pad1;
 	__u32	lost_out;	/* Lost packets			*/
 	__u32	sacked_out;	/* SACK'd packets			*/
 	__u32	fackets_out;	/* FACK'd packets			*/
===== net/ipv4/tcp_ipv4.c 1.110 vs edited =====
--- 1.110/net/ipv4/tcp_ipv4.c	2005-02-23 14:23:09 +11:00
+++ edited/net/ipv4/tcp_ipv4.c	2005-03-07 22:02:37 +11:00
@@ -831,7 +831,6 @@
 	/* OK, now commit destination to socket.  */
 	__sk_dst_set(sk, &rt->u.dst);
 	tcp_v4_setup_caps(sk, &rt->u.dst);
-	tp->ext2_header_len = rt->u.dst.header_len;
 
 	if (!tp->write_seq)
 		tp->write_seq = secure_tcp_sequence_number(inet->saddr,
@@ -941,10 +940,10 @@
 	/* Something is about to be wrong... Remember soft error
 	 * for the case, if this connection will not able to recover.
 	 */
-	if (mtu < dst_pmtu(dst) && ip_dont_fragment(sk, dst))
+	if (mtu < dst_mtu(dst) && ip_dont_fragment(sk, dst))
 		sk->sk_err_soft = EMSGSIZE;
 
-	mtu = dst_pmtu(dst);
+	mtu = dst_mtu(dst);
 
 	if (inet->pmtudisc != IP_PMTUDISC_DONT &&
 	    tp->pmtu_cookie > mtu) {
@@ -1578,10 +1577,9 @@
 	newtp->ext_header_len = 0;
 	if (newinet->opt)
 		newtp->ext_header_len = newinet->opt->optlen;
-	newtp->ext2_header_len = dst->header_len;
 	newinet->id = newtp->write_seq ^ jiffies;
 
-	tcp_sync_mss(newsk, dst_pmtu(dst));
+	tcp_sync_mss(newsk, dst_mtu(dst));
 	newtp->advmss = dst_metric(dst, RTAX_ADVMSS);
 	tcp_initialize_rcv_mss(newsk);
 
@@ -1877,7 +1875,6 @@
 
 	__sk_dst_set(sk, &rt->u.dst);
 	tcp_v4_setup_caps(sk, &rt->u.dst);
-	tcp_sk(sk)->ext2_header_len = rt->u.dst.header_len;
 
 	new_saddr = rt->rt_src;
 
@@ -1937,7 +1934,6 @@
 	if (!err) {
 		__sk_dst_set(sk, &rt->u.dst);
 		tcp_v4_setup_caps(sk, &rt->u.dst);
-		tcp_sk(sk)->ext2_header_len = rt->u.dst.header_len;
 		return 0;
 	}
 
===== net/ipv4/tcp_output.c 1.80 vs edited =====
--- 1.80/net/ipv4/tcp_output.c	2005-02-24 14:16:59 +11:00
+++ edited/net/ipv4/tcp_output.c	2005-03-07 22:11:07 +11:00
@@ -632,12 +632,8 @@
 unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
 	int mss_now;
 
-	if (dst && dst->ops->get_mss)
-		pmtu = dst->ops->get_mss(dst, pmtu);
-
 	/* Calculate base mss without TCP options:
 	   It is MMS_S - sizeof(tcphdr) of rfc1122
 	 */
@@ -648,7 +644,7 @@
 		mss_now = tp->rx_opt.mss_clamp;
 
 	/* Now subtract optional transport overhead */
-	mss_now -= tp->ext_header_len + tp->ext2_header_len;
+	mss_now -= tp->ext_header_len;
 
 	/* Then reserve room for full set of TCP options and 8 bytes of data */
 	if (mss_now < 48)
@@ -684,9 +680,8 @@
 
 	mss_now = tp->mss_cache_std;
 	if (dst) {
-		u32 mtu = dst_pmtu(dst);
-		if (mtu != tp->pmtu_cookie ||
-		    tp->ext2_header_len != dst->header_len)
+		u32 mtu = dst_mtu(dst);
+		if (mtu != tp->pmtu_cookie)
 			mss_now = tcp_sync_mss(sk, mtu);
 	}
 
@@ -698,8 +693,7 @@
 		unsigned int large_mss, factor, limit;
 
 		large_mss = 65535 - tp->af_specific->net_header_len -
-			tp->ext_header_len - tp->ext2_header_len -
-			tp->tcp_header_len;
+			tp->ext_header_len - tp->tcp_header_len;
 
 		if (tp->max_window && large_mss > (tp->max_window>>1))
 			large_mss = max((tp->max_window>>1),
@@ -1444,7 +1438,7 @@
 	if (tp->rx_opt.user_mss)
 		tp->rx_opt.mss_clamp = tp->rx_opt.user_mss;
 	tp->max_window = 0;
-	tcp_sync_mss(sk, dst_pmtu(dst));
+	tcp_sync_mss(sk, dst_mtu(dst));
 
 	if (!tp->window_clamp)
 		tp->window_clamp = dst_metric(dst, RTAX_WINDOW);
===== net/ipv6/tcp_ipv6.c 1.106 vs edited =====
--- 1.106/net/ipv6/tcp_ipv6.c	2005-02-23 14:23:09 +11:00
+++ edited/net/ipv6/tcp_ipv6.c	2005-03-07 22:02:38 +11:00
@@ -782,7 +782,6 @@
 	tp->ext_header_len = 0;
 	if (np->opt)
 		tp->ext_header_len = np->opt->opt_flen + np->opt->opt_nflen;
-	tp->ext2_header_len = dst->header_len;
 
 	tp->rx_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 
@@ -894,8 +893,8 @@
 		} else
 			dst_hold(dst);
 
-		if (tp->pmtu_cookie > dst_pmtu(dst)) {
-			tcp_sync_mss(sk, dst_pmtu(dst));
+		if (tp->pmtu_cookie > dst_mtu(dst)) {
+			tcp_sync_mss(sk, dst_mtu(dst));
 			tcp_simple_retransmit(sk);
 		} /* else let the usual retransmit timer handle it */
 		dst_release(dst);
@@ -1524,9 +1523,8 @@
 	if (newnp->opt)
 		newtp->ext_header_len = newnp->opt->opt_nflen +
 					newnp->opt->opt_flen;
-	newtp->ext2_header_len = dst->header_len;
 
-	tcp_sync_mss(newsk, dst_pmtu(dst));
+	tcp_sync_mss(newsk, dst_mtu(dst));
 	newtp->advmss = dst_metric(dst, RTAX_ADVMSS);
 	tcp_initialize_rcv_mss(newsk);
 
@@ -1873,7 +1871,6 @@
 		ip6_dst_store(sk, dst, NULL);
 		sk->sk_route_caps = dst->dev->features &
 			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
-		tcp_sk(sk)->ext2_header_len = dst->header_len;
 	}
 
 	return 0;
@@ -1927,7 +1924,6 @@
 		ip6_dst_store(sk, dst, NULL);
 		sk->sk_route_caps = dst->dev->features &
 			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
-		tcp_sk(sk)->ext2_header_len = dst->header_len;
 	}
 
 	skb->dst = dst_clone(dst);

--HlL+5n6rz5pIUxbD--
