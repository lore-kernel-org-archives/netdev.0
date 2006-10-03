From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Tue, 3 Oct 2006 15:49:35 +1000
Message-ID: <20061003054935.GA23963@gondor.apana.org.au>
References: <E1GHUoC-0007Tn-00@gondolin.me.apana.org.au> <20060828004906.GC20092@ripe.net> <20060829082828.GA8625@gondor.apana.org.au> <20060831151243.GJ3590@ripe.net> <20060901070557.GA15731@gondor.apana.org.au> <20060901162248.GI19284@ripe.net> <20060925121530.GC18667@gondor.apana.org.au> <20060926112122.GU22330@ripe.net> <20060928003829.GA8952@gondor.apana.org.au> <20060928084018.GA15141@ripe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:17423 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965262AbWJCFtv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 01:49:51 -0400
To: cagri coltekin <cagri@ripe.net>
Content-Disposition: inline
In-Reply-To: <20060928084018.GA15141@ripe.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2006 at 10:40:18AM +0200, cagri coltekin wrote:
>
> No. Bug is the first after boot:

OK, I think I've got the right bug this time.

[UDP6]: Fix flowi clobbering

The udp6_sendmsg function uses a shared buffer to store the
flow without taking any locks.  This leads to races with SMP.
This patch moves the flowi object onto the stack.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This bug is pretty old so we need the fix for 2.6.18 too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -546,7 +546,7 @@ static int udpv6_sendmsg(struct kiocb *i
 	struct in6_addr *daddr, *final_p = NULL, final;
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
-	struct flowi *fl = &inet->cork.fl;
+	struct flowi fl;
 	struct dst_entry *dst;
 	int addr_len = msg->msg_namelen;
 	int ulen = len;
@@ -626,19 +626,19 @@ do_udp_sendmsg:
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
@@ -656,32 +656,32 @@ do_udp_sendmsg:
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
@@ -695,39 +695,39 @@ do_udp_sendmsg:
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
 
-	security_sk_classify_flow(sk, fl);
+	security_sk_classify_flow(sk, &fl);
 
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
@@ -763,7 +763,7 @@ back_from_confirm:
 do_append_data:
 	up->len += ulen;
 	err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov, ulen,
-		sizeof(struct udphdr), hlimit, tclass, opt, fl,
+		sizeof(struct udphdr), hlimit, tclass, opt, &fl,
 		(struct rt6_info*)dst,
 		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
 	if (err)
@@ -774,10 +774,10 @@ do_append_data:
 	if (dst) {
 		if (connected) {
 			ip6_dst_store(sk, dst,
-				      ipv6_addr_equal(&fl->fl6_dst, &np->daddr) ?
+				      ipv6_addr_equal(&fl.fl6_dst, &np->daddr) ?
 				      &np->daddr : NULL,
 #ifdef CONFIG_IPV6_SUBTREES
-				      ipv6_addr_equal(&fl->fl6_src, &np->saddr) ?
+				      ipv6_addr_equal(&fl.fl6_src, &np->saddr) ?
 				      &np->saddr :
 #endif
 				      NULL);
