From: arno@natisbad.org (Arnaud Ebalard)
Subject: [PATCH net-next-2.6 5/5] XFRM,IPv6: Add IRO remapping capability via socket ancillary data path
Date: Fri, 24 Sep 2010 21:26:58 +0200
Message-ID: <87mxr7q6wt.fsf@small.ssi.corp>
References: <87bp7nrlvy.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:55497 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757628Ab0IXT01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Sep 2010 15:26:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This provides the ability to remap src/dst address using IRO
via ancillary data passed to sockets. This is the IRO equivalent
of what is done for RH2/HAO (i.e. IPV6_RTHDR/IPV6_DSTOPTS).
This is used by UMIP during BA emission when acting as a Home
Agent.

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 include/net/ipv6.h       |    4 ++++
 net/ipv6/datagram.c      |   20 ++++++++++++++++++++
 net/ipv6/exthdrs.c       |   19 +++++++++++++------
 net/ipv6/ip6_flowlabel.c |    7 +++++++
 net/ipv6/ip6_output.c    |   22 ++++++++++++++++++++++
 net/ipv6/raw.c           |    3 ++-
 6 files changed, 68 insertions(+), 7 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 1f84124..9dbc4f7 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -188,6 +188,10 @@ struct ipv6_txoptions {
 	struct ipv6_rt_hdr	*srcrt;	/* Routing Header */
 	struct ipv6_opt_hdr	*dst1opt;
 
+	/* XXX protect those via some ifdef e.g. CONFIG_XFRM_SUB_POLICY ? */
+	struct in6_addr         *iro_src;
+	struct in6_addr         *iro_dst;
+
 	/* Option buffer, as read by IPV6_PKTOPTIONS, starts here. */
 };
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 2952c9e..0ac7adf 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -757,6 +757,26 @@ int datagram_send_ctl(struct net *net,
 			}
 			break;
 
+#ifdef CONFIG_XFRM_SUB_POLICY
+		case IPV6_IROSRC:
+		case IPV6_IRODST:
+			if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct in6_addr))) {
+				err = -EINVAL;
+				goto exit_f;
+			}
+
+			if (!capable(CAP_NET_RAW)) {
+				err = -EPERM;
+				goto exit_f;
+			}
+
+			if (cmsg->cmsg_type == IPV6_IROSRC)
+				opt->iro_src = (struct in6_addr *)CMSG_DATA(cmsg);
+			else
+				opt->iro_dst = (struct in6_addr *)CMSG_DATA(cmsg);
+			break;
+#endif
+
 		case IPV6_2292RTHDR:
 		case IPV6_RTHDR:
 			if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct ipv6_rt_hdr))) {
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 262f105..e480b06 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -750,6 +750,10 @@ ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt)
 			*((char**)&opt2->dst1opt) += dif;
 		if (opt2->srcrt)
 			*((char**)&opt2->srcrt) += dif;
+		if (opt2->iro_src)
+			*((char**)&opt2->iro_src) += dif;
+		if (opt2->iro_dst)
+			*((char**)&opt2->iro_dst) += dif;
 	}
 	return opt2;
 }
@@ -874,24 +878,27 @@ struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
 
 /**
  * fl6_update_dst - update flowi destination address with info given
- *                  by srcrt option, if any.
+ *                  by srcrt/iro_dst option, if any.
  *
  * @fl: flowi for which fl6_dst is to be updated
- * @opt: struct ipv6_txoptions in which to look for srcrt opt
+ * @opt: struct ipv6_txoptions in which to look for srcrt/iro_dst opt
  * @orig: copy of original fl6_dst address if modified
  *
- * Returns NULL if no txoptions or no srcrt, otherwise returns orig
- * and initial value of fl->fl6_dst set in orig
+ * Returns NULL if no txoptions or no options to change flowi destination
+ * (srcrt or IRO destination remapping rule), otherwise returns orig and
+ * initial value of fl->fl6_dst set in orig
  */
 struct in6_addr *fl6_update_dst(struct flowi *fl,
 				const struct ipv6_txoptions *opt,
 				struct in6_addr *orig)
 {
-	if (!opt || !opt->srcrt)
+	if (!opt || (!opt->srcrt && !opt->iro_dst))
 		return NULL;
 
 	ipv6_addr_copy(orig, &fl->fl6_dst);
-	ipv6_addr_copy(&fl->fl6_dst, ((struct rt0_hdr *)opt->srcrt)->addr);
+	ipv6_addr_copy(&fl->fl6_dst,
+		       opt->iro_dst ?: ((struct rt0_hdr *)opt->srcrt)->addr);
+
 	return orig;
 }
 
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 1365468..dbf9c29 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -280,6 +280,9 @@ struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions * opt_space,
 		opt_space->hopopt = fl_opt->hopopt;
 		opt_space->dst0opt = fl_opt->dst0opt;
 		opt_space->srcrt = fl_opt->srcrt;
+		/* XXX protect those via some ifdef - see net/ipv6.h */
+		opt_space->iro_src = fl_opt->iro_src;
+		opt_space->iro_dst = fl_opt->iro_dst;
 		opt_space->opt_nflen = fl_opt->opt_nflen;
 	} else {
 		if (fopt->opt_nflen == 0)
@@ -287,6 +290,9 @@ struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions * opt_space,
 		opt_space->hopopt = NULL;
 		opt_space->dst0opt = NULL;
 		opt_space->srcrt = NULL;
+		/* XXX protect those via some ifdef - see net/ipv6.h */
+		opt_space->iro_src = NULL;
+		opt_space->iro_dst = NULL;
 		opt_space->opt_nflen = 0;
 	}
 	opt_space->dst1opt = fopt->dst1opt;
@@ -456,6 +462,7 @@ static int ipv6_opt_cmp(struct ipv6_txoptions *o1, struct ipv6_txoptions *o2)
 		return 1;
 	if (ipv6_hdr_cmp((struct ipv6_opt_hdr *)o1->srcrt, (struct ipv6_opt_hdr *)o2->srcrt))
 		return 1;
+
 	return 0;
 }
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d40b330..2fbe583 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -222,6 +222,8 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 			ipv6_push_frag_opts(skb, opt, &proto);
 		if (opt->opt_nflen)
 			ipv6_push_nfrag_opts(skb, opt, &proto, &first_hop);
+		if (opt->iro_dst)
+			first_hop = opt->iro_dst;
 	}
 
 	skb_push(skb, sizeof(struct ipv6hdr));
@@ -1098,6 +1100,12 @@ static inline struct ipv6_rt_hdr *ip6_rthdr_dup(struct ipv6_rt_hdr *src,
 	return src ? kmemdup(src, (src->hdrlen + 1) * 8, gfp) : NULL;
 }
 
+static inline struct in6_addr *ip6_iro_addr_dup(struct in6_addr *addr,
+						gfp_t gfp)
+{
+	return addr ? kmemdup(addr, sizeof(struct in6_addr), gfp) : NULL;
+}
+
 int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	int offset, int len, int odd, struct sk_buff *skb),
 	void *from, int length, int transhdrlen,
@@ -1154,6 +1162,16 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 			if (opt->srcrt && !np->cork.opt->srcrt)
 				return -ENOBUFS;
 
+			np->cork.opt->iro_src = ip6_iro_addr_dup(opt->iro_src,
+								 sk->sk_allocation);
+			if (opt->iro_src && !np->cork.opt->iro_src)
+				return -ENOBUFS;
+
+			np->cork.opt->iro_dst = ip6_iro_addr_dup(opt->iro_dst,
+								 sk->sk_allocation);
+			if (opt->iro_dst && !np->cork.opt->iro_dst)
+				return -ENOBUFS;
+
 			/* need source address above miyazawa*/
 		}
 		dst_hold(&rt->dst);
@@ -1432,6 +1450,8 @@ static void ip6_cork_release(struct inet_sock *inet, struct ipv6_pinfo *np)
 		kfree(np->cork.opt->dst1opt);
 		kfree(np->cork.opt->hopopt);
 		kfree(np->cork.opt->srcrt);
+		kfree(np->cork.opt->iro_src);
+		kfree(np->cork.opt->iro_dst);
 		kfree(np->cork.opt);
 		np->cork.opt = NULL;
 	}
@@ -1487,6 +1507,8 @@ int ip6_push_pending_frames(struct sock *sk)
 		ipv6_push_frag_opts(skb, opt, &proto);
 	if (opt && opt->opt_nflen)
 		ipv6_push_nfrag_opts(skb, opt, &proto, &final_dst);
+	if (opt && opt->iro_dst)
+		final_dst = opt->iro_dst;
 
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index e677937..e817d04 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -828,7 +828,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 			if (flowlabel == NULL)
 				return -EINVAL;
 		}
-		if (!(opt->opt_nflen|opt->opt_flen))
+		if (!(opt->opt_nflen|opt->opt_flen) &&
+		    (!opt->iro_src && !opt->iro_dst))
 			opt = NULL;
 	}
 	if (opt == NULL)
-- 
1.7.1


