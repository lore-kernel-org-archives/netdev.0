From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH, TAKE 2] [IPV6] XFRM: extract xfrm_lookup() from
 ip6_dst_lookup() (is Re: [PATCH][IPv6] separation xfrm_lookup from
 ip6_dst_lookup)
Date: Sat, 28 Aug 2004 01:49:35 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040828.014935.131415609.yoshfuji@linux-ipv6.org>
References: <20040730171205.114f22ba.kazunori@miyazawa.org>
	<20040801195135.16734846.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org, kazunori@miyazawa.org,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040801195135.16734846.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <20040801195135.16734846.davem@redhat.com> (at Sun, 1 Aug 2004 19:51:35 -0700), "David S. Miller" <davem@redhat.com> says:

> On Fri, 30 Jul 2004 17:12:05 +0900
> Kazunori Miyazawa <kazunori@miyazawa.org> wrote:
> 
> > I consider copying flowi(fl_rt) uses too much stack at the moment.
> > I'll re-send the fixed patch again.
> 
> I agree, and let's defer this patch until we
> resolve that.
> 
> It is simple to fix, I think.

Here's the updated patch.

From: Kazunori Miyazawa <kazunori@miyazawa.org>

(Because Miyazawa-san is very busy now, 
I'm sending this patch as the proxy of him.)

Please pull from <bk://bk.skbuff.net:20609/linux-2.6-xfrm/>

Thank you.

DIFFSTAT
--------
 datagram.c   |   13 +++++++++++-
 ip6_output.c |    4 ---
 raw.c        |   11 +++++++++-
 tcp_ipv6.c   |   62 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 udp.c        |   11 +++++++++-
 5 files changed, 91 insertions(+), 10 deletions(-)

CHANGESET
---------
ChangeSet@1.1841, 2004-08-28 01:35:09+09:00, kazunori@miyazawa.org
  [IPV6] XFRM: extract xfrm_lookup() from ip6_dst_lookup() to support source routing appropriately.
  
  This patch extracts xfrm_lookup() from ip6_dst_lookup()
  to support source routing appropriately.
  
  This is because xfrm_lookup() should be performed with the final
  destination while ip6_dst_lookup() is called with the next-hop.
  
  Signed-off-by: Kazunori Miyazawa <kazunori@miyazawa.org>
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/datagram.c b/net/ipv6/datagram.c
--- a/net/ipv6/datagram.c	2004-08-28 01:36:43 +09:00
+++ b/net/ipv6/datagram.c	2004-08-28 01:36:43 +09:00
@@ -38,7 +38,7 @@
 	struct sockaddr_in6	*usin = (struct sockaddr_in6 *) uaddr;
 	struct inet_opt      	*inet = inet_sk(sk);
 	struct ipv6_pinfo      	*np = inet6_sk(sk);
-	struct in6_addr		*daddr;
+	struct in6_addr		*daddr, *final_p = NULL, final;
 	struct dst_entry	*dst;
 	struct flowi		fl;
 	struct ip6_flowlabel	*flowlabel = NULL;
@@ -157,16 +157,27 @@
 	if (flowlabel) {
 		if (flowlabel->opt && flowlabel->opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) flowlabel->opt->srcrt;
+			ipv6_addr_copy(&final, &fl.fl6_dst);
 			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+			final_p = &final;
 		}
 	} else if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
+		ipv6_addr_copy(&final, &fl.fl6_dst);
 		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		final_p = &final;
 	}
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
 		goto out;
+	if (final_p)
+		ipv6_addr_copy(&fl.fl6_dst, final_p);
+
+	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+		dst_release(dst);
+		goto out;
+	}
 
 	/* source address lookup done in ip6_dst_lookup */
 
diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	2004-08-28 01:36:43 +09:00
+++ b/net/ipv6/ip6_output.c	2004-08-28 01:36:43 +09:00
@@ -796,10 +796,6 @@
 			goto out_err_release;
 		}
 	}
-	if ((err = xfrm_lookup(dst, fl, sk, 0)) < 0) {
-		err = -ENETUNREACH;
-		goto out_err_release;
-        }
 
 	return 0;
 
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	2004-08-28 01:36:43 +09:00
+++ b/net/ipv6/raw.c	2004-08-28 01:36:43 +09:00
@@ -606,7 +606,7 @@
 {
 	struct ipv6_txoptions opt_space;
 	struct sockaddr_in6 * sin6 = (struct sockaddr_in6 *) msg->msg_name;
-	struct in6_addr *daddr;
+	struct in6_addr *daddr, *final_p = NULL, final;
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct raw6_opt *raw_opt = raw6_sk(sk);
@@ -729,7 +729,9 @@
 	/* merge ip6_build_xmit from ip6_output */
 	if (opt && opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
+		ipv6_addr_copy(&final, &fl.fl6_dst);
 		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		final_p = &final;
 	}
 
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
@@ -738,6 +740,13 @@
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
 		goto out;
+	if (final_p)
+		ipv6_addr_copy(&fl.fl6_dst, final_p);
+
+	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+		dst_release(dst);
+		goto out;
+	}
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2004-08-28 01:36:43 +09:00
+++ b/net/ipv6/tcp_ipv6.c	2004-08-28 01:36:43 +09:00
@@ -549,7 +549,7 @@
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_opt *tp = tcp_sk(sk);
-	struct in6_addr *saddr = NULL;
+	struct in6_addr *saddr = NULL, *final_p = NULL, final;
 	struct flowi fl;
 	struct dst_entry *dst;
 	int addr_type;
@@ -666,13 +666,21 @@
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
+		ipv6_addr_copy(&final, &fl.fl6_dst);
 		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		final_p = &final;
 	}
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
-
 	if (err)
 		goto failure;
+	if (final_p)
+		ipv6_addr_copy(&fl.fl6_dst, final_p);
+
+	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+		dst_release(dst);
+		goto failure;
+	}
 
 	if (saddr == NULL) {
 		saddr = &fl.fl6_src;
@@ -793,6 +801,12 @@
 				sk->sk_err_soft = -err;
 				goto out;
 			}
+
+			if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+				sk->sk_err_soft = -err;
+				goto out;
+			}
+
 		} else
 			dst_hold(dst);
 
@@ -863,6 +877,7 @@
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff * skb;
 	struct ipv6_txoptions *opt = NULL;
+	struct in6_addr * final_p = NULL, final;
 	struct flowi fl;
 	int err = -1;
 
@@ -888,12 +903,18 @@
 
 		if (opt && opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
+			ipv6_addr_copy(&final, &fl.fl6_dst);
 			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+			final_p = &final;
 		}
 
 		err = ip6_dst_lookup(sk, &dst, &fl);
 		if (err)
 			goto done;
+		if (final_p)
+			ipv6_addr_copy(&fl.fl6_dst, final_p);
+		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+			goto done;
 	}
 
 	skb = tcp_make_synack(sk, dst, req);
@@ -1021,6 +1042,12 @@
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
 	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
+
+		if ((xfrm_lookup(&buff->dst, &fl, NULL, 0)) < 0) {
+			dst_release(buff->dst);
+			return;
+		}
+
 		ip6_xmit(NULL, buff, &fl, NULL, 0);
 		TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 		TCP_INC_STATS_BH(TCP_MIB_OUTRSTS);
@@ -1082,6 +1109,10 @@
 	fl.fl_ip_sport = t1->source;
 
 	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
+		if ((xfrm_lookup(&buff->dst, &fl, NULL, 0)) < 0) {
+			dst_release(buff->dst);
+			return;
+		}
 		ip6_xmit(NULL, buff, &fl, NULL, 0);
 		TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 		return;
@@ -1313,6 +1344,7 @@
 	}
 
 	if (dst == NULL) {
+		struct in6_addr *final_p = NULL, final;
 		struct flowi fl;
 
 		memset(&fl, 0, sizeof(fl));
@@ -1320,7 +1352,9 @@
 		ipv6_addr_copy(&fl.fl6_dst, &req->af.v6_req.rmt_addr);
 		if (opt && opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
+			ipv6_addr_copy(&final, &fl.fl6_dst);
 			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+			final_p = &final;
 		}
 		ipv6_addr_copy(&fl.fl6_src, &req->af.v6_req.loc_addr);
 		fl.oif = sk->sk_bound_dev_if;
@@ -1329,6 +1363,12 @@
 
 		if (ip6_dst_lookup(sk, &dst, &fl))
 			goto out;
+
+		if (final_p)
+			ipv6_addr_copy(&fl.fl6_dst, final_p);
+
+		if ((xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+			goto out;
 	} 
 
 	newsk = tcp_create_openreq_child(sk, req, skb);
@@ -1710,6 +1750,7 @@
 
 	if (dst == NULL) {
 		struct inet_opt *inet = inet_sk(sk);
+		struct in6_addr *final_p = NULL, final;
 		struct flowi fl;
 
 		memset(&fl, 0, sizeof(fl));
@@ -1723,15 +1764,24 @@
 
 		if (np->opt && np->opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
+			ipv6_addr_copy(&final, &fl.fl6_dst);
 			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+			final_p = &final;
 		}
 
 		err = ip6_dst_lookup(sk, &dst, &fl);
-
 		if (err) {
 			sk->sk_route_caps = 0;
 			return err;
 		}
+		if (final_p)
+			ipv6_addr_copy(&fl.fl6_dst, final_p);
+
+		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+			sk->sk_err_soft = -err;
+			dst_release(dst);
+			return err;
+		}
 
 		ip6_dst_store(sk, dst, NULL);
 		sk->sk_route_caps = dst->dev->features &
@@ -1772,6 +1822,12 @@
 
 		if (err) {
 			sk->sk_err_soft = -err;
+			return err;
+		}
+
+		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+			sk->sk_route_caps = 0;
+			dst_release(dst);
 			return err;
 		}
 
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	2004-08-28 01:36:43 +09:00
+++ b/net/ipv6/udp.c	2004-08-28 01:36:43 +09:00
@@ -627,7 +627,7 @@
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) msg->msg_name;
-	struct in6_addr *daddr;
+	struct in6_addr *daddr, *final_p = NULL, final;
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
 	struct flowi *fl = &inet->cork.fl;
@@ -783,7 +783,9 @@
 	/* merge ip6_build_xmit from ip6_output */
 	if (opt && opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
+		ipv6_addr_copy(&final, &fl->fl6_dst);
 		ipv6_addr_copy(&fl->fl6_dst, rt0->addr);
+		final_p = &final;
 	}
 
 	if (!fl->oif && ipv6_addr_is_multicast(&fl->fl6_dst))
@@ -792,6 +794,13 @@
 	err = ip6_dst_lookup(sk, &dst, fl);
 	if (err)
 		goto out;
+	if (final_p)
+		ipv6_addr_copy(&fl->fl6_dst, final_p);
+
+	if ((err = xfrm_lookup(&dst, fl, sk, 0)) < 0) {
+		dst_release(dst);
+		goto out;
+	}
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl->fl6_dst))



-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
