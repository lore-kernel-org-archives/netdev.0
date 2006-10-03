From: cagri coltekin <cagri@ripe.net>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Tue, 3 Oct 2006 16:57:31 +0200
Message-ID: <20061003145731.GC25063@ripe.net>
References: <20060829082828.GA8625@gondor.apana.org.au> <20060831151243.GJ3590@ripe.net> <20060901070557.GA15731@gondor.apana.org.au> <20060901162248.GI19284@ripe.net> <20060925121530.GC18667@gondor.apana.org.au> <20060926112122.GU22330@ripe.net> <20060928003829.GA8952@gondor.apana.org.au> <20060928084018.GA15141@ripe.net> <20061003054935.GA23963@gondor.apana.org.au> <20061003062820.GA24217@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from x10.ripe.net ([193.0.1.10]:5833 "EHLO x10.ripe.net")
	by vger.kernel.org with ESMTP id S964799AbWJCO5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 10:57:33 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20061003062820.GA24217@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2006 at 04:28:20PM +1000, Herbert Xu wrote:
> On Tue, Oct 03, 2006 at 03:49:35PM +1000, Herbert Xu wrote:
> >
> > OK, I think I've got the right bug this time.
> 
> Here is the patch for the other bug that I found along the way:
> 
> [UDP6]: Fix MSG_PROBE crash
> 

This one fixes. Thanks!

The patch does not cleanly apply to 2.6.18, needed some manual
tweaking (the patch that applies cleanly to vanilla 2.6.18 is
below in case it has any use).

Cheers,
-- 
cagri


--- linux-2.6.18/net/ipv6/udp.c	2006-09-20 05:42:06.000000000 +0200
+++ linux-2.6.18-p4/net/ipv6/udp.c	2006-10-03 08:57:31.000000000 +0200
@@ -613,7 +613,7 @@
 	struct in6_addr *daddr, *final_p = NULL, final;
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
-	struct flowi *fl = &inet->cork.fl;
+	struct flowi fl;
 	struct dst_entry *dst;
 	int addr_len = msg->msg_namelen;
 	int ulen = len;
@@ -693,19 +693,19 @@
 	}
 	ulen += sizeof(struct udphdr);
 
-	memset(fl, 0, sizeof(*fl));
+	memset(&fl, 0, sizeof(fl));
 
 	if (sin6) {
 		if (sin6->sin6_port == 0)
 			return -EINVAL;
 
-		fl->fl_ip_dport = sin6->sin6_port;
+		fl.fl_ip_dport = sin6->sin6_port;
 		daddr = &sin6->sin6_addr;
 
 		if (np->sndflow) {
-			fl->fl6_flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
-			if (fl->fl6_flowlabel&IPV6_FLOWLABEL_MASK) {
-				flowlabel = fl6_sock_lookup(sk, fl->fl6_flowlabel);
+			fl.fl6_flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
+			if (fl.fl6_flowlabel&IPV6_FLOWLABEL_MASK) {
+				flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
 				if (flowlabel == NULL)
 					return -EINVAL;
 				daddr = &flowlabel->dst;
@@ -723,32 +723,32 @@
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    sin6->sin6_scope_id &&
 		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
-			fl->oif = sin6->sin6_scope_id;
+			fl.oif = sin6->sin6_scope_id;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
 
-		fl->fl_ip_dport = inet->dport;
+		fl.fl_ip_dport = inet->dport;
 		daddr = &np->daddr;
-		fl->fl6_flowlabel = np->flow_label;
+		fl.fl6_flowlabel = np->flow_label;
 		connected = 1;
 	}
 
-	if (!fl->oif)
-		fl->oif = sk->sk_bound_dev_if;
+	if (!fl.oif)
+		fl.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
 		opt = &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(*opt);
 
-		err = datagram_send_ctl(msg, fl, opt, &hlimit, &tclass);
+		err = datagram_send_ctl(msg, &fl, opt, &hlimit, &tclass);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
 		}
-		if ((fl->fl6_flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
-			flowlabel = fl6_sock_lookup(sk, fl->fl6_flowlabel);
+		if ((fl.fl6_flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
+			flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
 		}
@@ -762,37 +762,37 @@
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 	opt = ipv6_fixup_options(&opt_space, opt);
 
-	fl->proto = IPPROTO_UDP;
-	ipv6_addr_copy(&fl->fl6_dst, daddr);
-	if (ipv6_addr_any(&fl->fl6_src) && !ipv6_addr_any(&np->saddr))
-		ipv6_addr_copy(&fl->fl6_src, &np->saddr);
-	fl->fl_ip_sport = inet->sport;
+	fl.proto = IPPROTO_UDP;
+	ipv6_addr_copy(&fl.fl6_dst, daddr);
+	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
+		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
+	fl.fl_ip_sport = inet->sport;
 	
 	/* merge ip6_build_xmit from ip6_output */
 	if (opt && opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-		ipv6_addr_copy(&final, &fl->fl6_dst);
-		ipv6_addr_copy(&fl->fl6_dst, rt0->addr);
+		ipv6_addr_copy(&final, &fl.fl6_dst);
+		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 		final_p = &final;
 		connected = 0;
 	}
 
-	if (!fl->oif && ipv6_addr_is_multicast(&fl->fl6_dst)) {
-		fl->oif = np->mcast_oif;
+	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst)) {
+		fl.oif = np->mcast_oif;
 		connected = 0;
 	}
 
-	err = ip6_sk_dst_lookup(sk, &dst, fl);
+	err = ip6_sk_dst_lookup(sk, &dst, &fl);
 	if (err)
 		goto out;
 	if (final_p)
-		ipv6_addr_copy(&fl->fl6_dst, final_p);
+		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, fl, sk, 0)) < 0)
+	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
 		goto out;
 
 	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(&fl->fl6_dst))
+		if (ipv6_addr_is_multicast(&fl.fl6_dst))
 			hlimit = np->mcast_hops;
 		else
 			hlimit = np->hop_limit;
@@ -828,18 +828,20 @@
 do_append_data:
 	up->len += ulen;
 	err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov, ulen,
-		sizeof(struct udphdr), hlimit, tclass, opt, fl,
+		sizeof(struct udphdr), hlimit, tclass, opt, &fl,
 		(struct rt6_info*)dst,
 		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
 	if (err)
 		udp_v6_flush_pending_frames(sk);
 	else if (!corkreq)
 		err = udp_v6_push_pending_frames(sk, up);
+	else if (unlikely(skb_queue_empty(&sk->sk_write_queue)))
+		up->pending = 0;
 
 	if (dst) {
 		if (connected) {
 			ip6_dst_store(sk, dst,
-				      ipv6_addr_equal(&fl->fl6_dst, &np->daddr) ?
+				      ipv6_addr_equal(&fl.fl6_dst, &np->daddr) ?
 				      &np->daddr : NULL);
 		} else {
 			dst_release(dst);
