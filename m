From: "David S. Miller" <davem@davemloft.net>
Subject: Re: BUG: dst underflow (again)
Date: Thu, 4 Nov 2004 23:16:18 -0800
Message-ID: <20041104231618.1d584a6f.davem@davemloft.net>
References: <20041022075947.GA15795@xi.wantstofly.org>
	<1099577717.1039.155.camel@jzny.localdomain>
	<20041104221801.584c8f11.davem@davemloft.net>
	<20041105.155355.110780816.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: hadi@cyberus.ca, buytenh@wantstofly.org, jgarzik@pobox.com,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20041105.155355.110780816.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 05 Nov 2004 15:53:55 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <20041104221801.584c8f11.davem@davemloft.net> (at Thu, 4 Nov 2004 22:18:01 -0800), "David S. Miller" <davem@davemloft.net> says:
> 
> > > > 	00012c0d <udpv6_sendmsg>	(god, that's one big function btw)
> > 
> > The last one is the most interesting.  The only dst_release() call
> > that occurs in udpv6_sendmsg() is when xfrm_lookup() returns
> > an error.  The semantics of that function are a complete mess
> > (when it errors, it sometimes releases the DST, sometimes does not)
> > and I'll fix that up.
> 
> Oh,yes, something like this?

Something, but not quite.  :-)  This change you propose
adds a leak, you have to modify xfrm_lookup() as well.

I'm mid-way through such changes, but it looks something
like this (BTW, note the addrconf.c leak I noticed today
as well):

===== net/ipv6/addrconf.c 1.115 vs edited =====
--- 1.115/net/ipv6/addrconf.c	2004-10-25 21:11:35 -07:00
+++ edited/net/ipv6/addrconf.c	2004-11-04 13:10:26 -08:00
@@ -509,6 +509,7 @@
 	rt = addrconf_dst_alloc(idev, addr, 0);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
+		rt = NULL;
 		goto out;
 	}
 
@@ -572,6 +573,8 @@
 	if (unlikely(err == 0))
 		notifier_call_chain(&inet6addr_chain, NETDEV_UP, ifa);
 	else {
+		if (rt)
+			dst_free(&rt->u.dst);
 		kfree(ifa);
 		ifa = ERR_PTR(err);
 	}
===== net/ipv6/datagram.c 1.19 vs edited =====
--- 1.19/net/ipv6/datagram.c	2004-08-27 09:35:00 -07:00
+++ edited/net/ipv6/datagram.c	2004-11-04 16:43:24 -08:00
@@ -174,10 +174,8 @@
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
-		dst_release(dst);
+	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
 		goto out;
-	}
 
 	/* source address lookup done in ip6_dst_lookup */
 
===== net/ipv6/icmp.c 1.59 vs edited =====
--- 1.59/net/ipv6/icmp.c	2004-09-14 22:32:09 -07:00
+++ edited/net/ipv6/icmp.c	2004-11-04 16:44:01 -08:00
@@ -373,7 +373,7 @@
 	if (err)
 		goto out;
 	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
-		goto out_dst_release;
+		goto out;
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
@@ -461,7 +461,7 @@
 	if (err)
 		goto out;
 	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
-		goto out_dst_release;
+		goto out;
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
===== net/ipv6/ip6_tunnel.c 1.25 vs edited =====
--- 1.25/net/ipv6/ip6_tunnel.c	2004-09-13 13:03:39 -07:00
+++ edited/net/ipv6/ip6_tunnel.c	2004-11-04 16:49:24 -08:00
@@ -759,9 +759,14 @@
 
 	t->recursion--;
 	return 0;
+
 tx_err_link_failure:
 	stats->tx_carrier_errors++;
 	dst_link_failure(skb);
+	if (opt)
+		kfree(opt);
+	goto tx_err;
+
 tx_err_dst_release:
 	dst_release(dst);
 	if (opt)
===== net/ipv6/ndisc.c 1.104 vs edited =====
--- 1.104/net/ipv6/ndisc.c	2004-11-03 11:56:07 -08:00
+++ edited/net/ipv6/ndisc.c	2004-11-04 16:49:48 -08:00
@@ -408,10 +408,8 @@
 		return;
 
 	err = xfrm_lookup(&dst, &fl, NULL, 0);
-	if (err < 0) {
-		dst_release(dst);
+	if (err < 0)
 		return;
-	}
 
 	if (inc_opt) {
 		if (dev->addr_len)
@@ -499,10 +497,8 @@
 		return;
 
 	err = xfrm_lookup(&dst, &fl, NULL, 0);
-	if (err < 0) {
-		dst_release(dst);
+	if (err < 0)
 		return;
-	}
 
 	len = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
 	send_llinfo = dev->addr_len && !ipv6_addr_any(saddr);
@@ -575,10 +571,8 @@
 		return;
 
 	err = xfrm_lookup(&dst, &fl, NULL, 0);
-	if (err < 0) {
-		dst_release(dst);
+	if (err < 0)
 		return;
-	}
 
 	len = sizeof(struct icmp6hdr);
 	if (dev->addr_len)
@@ -1302,10 +1296,8 @@
 	dst = &rt->u.dst;
 
 	err = xfrm_lookup(&dst, &fl, NULL, 0);
-	if (err) {
-		dst_release(dst);
+	if (err)
 		return;
-	}
 
 	rt = (struct rt6_info *) dst;
 
===== net/ipv6/raw.c 1.73 vs edited =====
--- 1.73/net/ipv6/raw.c	2004-10-25 19:47:26 -07:00
+++ edited/net/ipv6/raw.c	2004-11-04 16:50:05 -08:00
@@ -743,10 +743,8 @@
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
-		dst_release(dst);
+	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
 		goto out;
-	}
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
===== net/ipv6/tcp_ipv6.c 1.100 vs edited =====
--- 1.100/net/ipv6/tcp_ipv6.c	2004-11-01 16:48:28 -08:00
+++ edited/net/ipv6/tcp_ipv6.c	2004-11-04 16:52:43 -08:00
@@ -680,10 +680,8 @@
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
-		dst_release(dst);
+	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
 		goto failure;
-	}
 
 	if (saddr == NULL) {
 		saddr = &fl.fl6_src;
@@ -1047,10 +1045,8 @@
 	/* sk = NULL, but it is safe for now. RST socket required. */
 	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
 
-		if ((xfrm_lookup(&buff->dst, &fl, NULL, 0)) < 0) {
-			dst_release(buff->dst);
+		if ((xfrm_lookup(&buff->dst, &fl, NULL, 0)) < 0)
 			return;
-		}
 
 		ip6_xmit(NULL, buff, &fl, NULL, 0);
 		TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
@@ -1114,10 +1110,9 @@
 	fl.fl_ip_sport = t1->source;
 
 	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
-		if ((xfrm_lookup(&buff->dst, &fl, NULL, 0)) < 0) {
-			dst_release(buff->dst);
+		if ((xfrm_lookup(&buff->dst, &fl, NULL, 0)) < 0)
 			return;
-		}
+
 		ip6_xmit(NULL, buff, &fl, NULL, 0);
 		TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 		return;
@@ -1378,7 +1373,7 @@
 
 	newsk = tcp_create_openreq_child(sk, req, skb);
 	if (newsk == NULL)
-		goto out;
+		goto out_release;
 
 	/* Charge newly allocated IPv6 socket */
 #ifdef INET_REFCNT_DEBUG
@@ -1457,11 +1452,12 @@
 
 out_overflow:
 	NET_INC_STATS_BH(LINUX_MIB_LISTENOVERFLOWS);
+out_release:
+	dst_release(dst);
 out:
 	NET_INC_STATS_BH(LINUX_MIB_LISTENDROPS);
 	if (opt && opt != np->opt)
 		sock_kfree_s(sk, opt, opt->tot_len);
-	dst_release(dst);
 	return NULL;
 }
 
@@ -1784,7 +1780,6 @@
 
 		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
 			sk->sk_err_soft = -err;
-			dst_release(dst);
 			return err;
 		}
 
@@ -1838,7 +1833,6 @@
 
 		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
 			sk->sk_route_caps = 0;
-			dst_release(dst);
 			return err;
 		}
 
===== net/xfrm/xfrm_policy.c 1.57 vs edited =====
--- 1.57/net/xfrm/xfrm_policy.c	2004-10-25 20:23:46 -07:00
+++ edited/net/xfrm/xfrm_policy.c	2004-11-04 16:39:23 -08:00
@@ -745,8 +745,8 @@
 	switch (policy->action) {
 	case XFRM_POLICY_BLOCK:
 		/* Prohibit the flow */
-		xfrm_pol_put(policy);
-		return -EPERM;
+		err = -EPERM;
+		goto error;
 
 	case XFRM_POLICY_ALLOW:
 		if (policy->xfrm_nr == 0) {
@@ -762,8 +762,8 @@
 		 */
 		dst = xfrm_find_bundle(fl, policy, family);
 		if (IS_ERR(dst)) {
-			xfrm_pol_put(policy);
-			return PTR_ERR(dst);
+			err = PTR_ERR(dst);
+			goto error;
 		}
 
 		if (dst)
