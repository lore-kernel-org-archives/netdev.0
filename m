From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net-next 1/6] ipv6: pull cork initialization into its own function.
Date: Sat, 31 Jan 2015 10:40:13 -0500
Message-ID: <1422718818-21093-2-git-send-email-vyasevic@redhat.com>
References: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Cc: herbert@gondor.apana.org.au, hannes@stressinduktion.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:42788 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbbAaPk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 10:40:27 -0500
Received: by mail-qa0-f43.google.com with SMTP id v10so23909656qac.2
        for <netdev@vger.kernel.org>; Sat, 31 Jan 2015 07:40:26 -0800 (PST)
In-Reply-To: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pull IPv6 cork initialization into its own function that
can be re-used.  IPv6 specific cork data did not have an
explicit data structure.  This patch creats eone so that
just ipv6 cork data can be as arguemts.  Also, since
IPv6 tries to save the flow label into inet_cork_full
tructure, pass the full cork.

Adjust ip6_cork_release() to take cork data structures.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/linux/ipv6.h  |  12 ++--
 net/ipv6/ip6_output.c | 158 ++++++++++++++++++++++++++++----------------------
 2 files changed, 96 insertions(+), 74 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 2805062..4d5169f 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -125,6 +125,12 @@ struct ipv6_mc_socklist;
 struct ipv6_ac_socklist;
 struct ipv6_fl_socklist;
 
+struct inet6_cork {
+	struct ipv6_txoptions *opt;
+	u8 hop_limit;
+	u8 tclass;
+};
+
 /**
  * struct ipv6_pinfo - ipv6 private area
  *
@@ -217,11 +223,7 @@ struct ipv6_pinfo {
 	struct ipv6_txoptions	*opt;
 	struct sk_buff		*pktoptions;
 	struct sk_buff		*rxpmtu;
-	struct {
-		struct ipv6_txoptions *opt;
-		u8 hop_limit;
-		u8 tclass;
-	} cork;
+	struct inet6_cork	cork;
 };
 
 /* WARNING: don't change the layout of the members in {raw,udp,tcp}6_sock! */
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index ce69a12..f9f08c4 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1135,6 +1135,74 @@ static void ip6_append_data_mtu(unsigned int *mtu,
 	}
 }
 
+static int ip6_setup_cork(struct sock *sk, struct inet_cork_full *cork,
+			  struct inet6_cork *v6_cork,
+			  int hlimit, int tclass, struct ipv6_txoptions *opt,
+			  struct rt6_info *rt, struct flowi6 *fl6)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	unsigned int mtu;
+
+	/*
+	 * setup for corking
+	 */
+	if (opt) {
+		if (WARN_ON(v6_cork->opt))
+			return -EINVAL;
+
+		v6_cork->opt = kzalloc(opt->tot_len, sk->sk_allocation);
+		if (unlikely(v6_cork->opt == NULL))
+			return -ENOBUFS;
+
+		v6_cork->opt->tot_len = opt->tot_len;
+		v6_cork->opt->opt_flen = opt->opt_flen;
+		v6_cork->opt->opt_nflen = opt->opt_nflen;
+
+		v6_cork->opt->dst0opt = ip6_opt_dup(opt->dst0opt,
+						    sk->sk_allocation);
+		if (opt->dst0opt && !v6_cork->opt->dst0opt)
+			return -ENOBUFS;
+
+		v6_cork->opt->dst1opt = ip6_opt_dup(opt->dst1opt,
+						    sk->sk_allocation);
+		if (opt->dst1opt && !v6_cork->opt->dst1opt)
+			return -ENOBUFS;
+
+		v6_cork->opt->hopopt = ip6_opt_dup(opt->hopopt,
+						   sk->sk_allocation);
+		if (opt->hopopt && !v6_cork->opt->hopopt)
+			return -ENOBUFS;
+
+		v6_cork->opt->srcrt = ip6_rthdr_dup(opt->srcrt,
+						    sk->sk_allocation);
+		if (opt->srcrt && !v6_cork->opt->srcrt)
+			return -ENOBUFS;
+
+		/* need source address above miyazawa*/
+	}
+	dst_hold(&rt->dst);
+	cork->base.dst = &rt->dst;
+	cork->fl.u.ip6 = *fl6;
+	v6_cork->hop_limit = hlimit;
+	v6_cork->tclass = tclass;
+	if (rt->dst.flags & DST_XFRM_TUNNEL)
+		mtu = np->pmtudisc >= IPV6_PMTUDISC_PROBE ?
+		      rt->dst.dev->mtu : dst_mtu(&rt->dst);
+	else
+		mtu = np->pmtudisc >= IPV6_PMTUDISC_PROBE ?
+		      rt->dst.dev->mtu : dst_mtu(rt->dst.path);
+	if (np->frag_size < mtu) {
+		if (np->frag_size)
+			mtu = np->frag_size;
+	}
+	cork->base.fragsize = mtu;
+	if (dst_allfrag(rt->dst.path))
+		cork->base.flags |= IPCORK_ALLFRAG;
+	cork->base.length = 0;
+
+	return 0;
+}
+
 int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	int offset, int len, int odd, struct sk_buff *skb),
 	void *from, int length, int transhdrlen,
@@ -1162,59 +1230,10 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		/*
 		 * setup for corking
 		 */
-		if (opt) {
-			if (WARN_ON(np->cork.opt))
-				return -EINVAL;
-
-			np->cork.opt = kzalloc(opt->tot_len, sk->sk_allocation);
-			if (unlikely(np->cork.opt == NULL))
-				return -ENOBUFS;
-
-			np->cork.opt->tot_len = opt->tot_len;
-			np->cork.opt->opt_flen = opt->opt_flen;
-			np->cork.opt->opt_nflen = opt->opt_nflen;
-
-			np->cork.opt->dst0opt = ip6_opt_dup(opt->dst0opt,
-							    sk->sk_allocation);
-			if (opt->dst0opt && !np->cork.opt->dst0opt)
-				return -ENOBUFS;
-
-			np->cork.opt->dst1opt = ip6_opt_dup(opt->dst1opt,
-							    sk->sk_allocation);
-			if (opt->dst1opt && !np->cork.opt->dst1opt)
-				return -ENOBUFS;
-
-			np->cork.opt->hopopt = ip6_opt_dup(opt->hopopt,
-							   sk->sk_allocation);
-			if (opt->hopopt && !np->cork.opt->hopopt)
-				return -ENOBUFS;
-
-			np->cork.opt->srcrt = ip6_rthdr_dup(opt->srcrt,
-							    sk->sk_allocation);
-			if (opt->srcrt && !np->cork.opt->srcrt)
-				return -ENOBUFS;
-
-			/* need source address above miyazawa*/
-		}
-		dst_hold(&rt->dst);
-		cork->dst = &rt->dst;
-		inet->cork.fl.u.ip6 = *fl6;
-		np->cork.hop_limit = hlimit;
-		np->cork.tclass = tclass;
-		if (rt->dst.flags & DST_XFRM_TUNNEL)
-			mtu = np->pmtudisc >= IPV6_PMTUDISC_PROBE ?
-			      rt->dst.dev->mtu : dst_mtu(&rt->dst);
-		else
-			mtu = np->pmtudisc >= IPV6_PMTUDISC_PROBE ?
-			      rt->dst.dev->mtu : dst_mtu(rt->dst.path);
-		if (np->frag_size < mtu) {
-			if (np->frag_size)
-				mtu = np->frag_size;
-		}
-		cork->fragsize = mtu;
-		if (dst_allfrag(rt->dst.path))
-			cork->flags |= IPCORK_ALLFRAG;
-		cork->length = 0;
+		err = ip6_setup_cork(sk, &inet->cork, &np->cork, hlimit,
+				     tclass, opt, rt, fl6);
+		if (err)
+			return err;
 		exthdrlen = (opt ? opt->opt_flen : 0);
 		length += exthdrlen;
 		transhdrlen += exthdrlen;
@@ -1226,8 +1245,8 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		transhdrlen = 0;
 		exthdrlen = 0;
 		dst_exthdrlen = 0;
-		mtu = cork->fragsize;
 	}
+	mtu = cork->fragsize;
 	orig_mtu = mtu;
 
 	hh_len = LL_RESERVED_SPACE(rt->dst.dev);
@@ -1503,23 +1522,24 @@ error:
 }
 EXPORT_SYMBOL_GPL(ip6_append_data);
 
-static void ip6_cork_release(struct inet_sock *inet, struct ipv6_pinfo *np)
+static void ip6_cork_release(struct inet_cork_full *cork,
+			     struct inet6_cork *v6_cork)
 {
-	if (np->cork.opt) {
-		kfree(np->cork.opt->dst0opt);
-		kfree(np->cork.opt->dst1opt);
-		kfree(np->cork.opt->hopopt);
-		kfree(np->cork.opt->srcrt);
-		kfree(np->cork.opt);
-		np->cork.opt = NULL;
+	if (v6_cork->opt) {
+		kfree(v6_cork->opt->dst0opt);
+		kfree(v6_cork->opt->dst1opt);
+		kfree(v6_cork->opt->hopopt);
+		kfree(v6_cork->opt->srcrt);
+		kfree(v6_cork->opt);
+		v6_cork->opt = NULL;
 	}
 
-	if (inet->cork.base.dst) {
-		dst_release(inet->cork.base.dst);
-		inet->cork.base.dst = NULL;
-		inet->cork.base.flags &= ~IPCORK_ALLFRAG;
+	if (cork->base.dst) {
+		dst_release(cork->base.dst);
+		cork->base.dst = NULL;
+		cork->base.flags &= ~IPCORK_ALLFRAG;
 	}
-	memset(&inet->cork.fl, 0, sizeof(inet->cork.fl));
+	memset(&cork->fl, 0, sizeof(cork->fl));
 }
 
 int ip6_push_pending_frames(struct sock *sk)
@@ -1599,7 +1619,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	}
 
 out:
-	ip6_cork_release(inet, np);
+	ip6_cork_release(&inet->cork, &np->cork);
 	return err;
 error:
 	IP6_INC_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
@@ -1618,6 +1638,6 @@ void ip6_flush_pending_frames(struct sock *sk)
 		kfree_skb(skb);
 	}
 
-	ip6_cork_release(inet_sk(sk), inet6_sk(sk));
+	ip6_cork_release(&inet_sk(sk)->cork, &inet6_sk(sk)->cork);
 }
 EXPORT_SYMBOL_GPL(ip6_flush_pending_frames);
-- 
1.9.3
