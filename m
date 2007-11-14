From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Fix ip_local_out when NETFILTER is off
Date: Wed, 14 Nov 2007 15:34:25 +0800
Message-ID: <20071114073425.GA11815@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3482 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751193AbXKNHe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 02:34:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[IPSEC]: Fix ip_local_out when NETFILTER is off

Thanks for testing with NETFILTER off because I obviously didn't :)
The code for ip_local_out/ip6_local_out is completely broken in
that case.

This patch fixes and also makes the IPsec path use the correct
local_out function so that the loop executes properly and we
don't end up nesting too deep and overrun the stack.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/ip.h b/include/net/ip.h
index dc60ea4..83fb9f1 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -103,11 +103,7 @@ extern int		ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 extern int		ip_do_nat(struct sk_buff *skb);
 extern void		ip_send_check(struct iphdr *ip);
 extern int		__ip_local_out(struct sk_buff *skb);
-#ifdef CONFIG_NETFILTER
 extern int		ip_local_out(struct sk_buff *skb);
-#else
-#define ip_local_out	__ip_local_out
-#endif
 extern int		ip_queue_xmit(struct sk_buff *skb, int ipfragok);
 extern void		ip_init(void);
 extern int		ip_append_data(struct sock *sk,
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 5078605..e90f962 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -510,11 +510,7 @@ extern int			ip6_input(struct sk_buff *skb);
 extern int			ip6_mc_input(struct sk_buff *skb);
 
 extern int			__ip6_local_out(struct sk_buff *skb);
-#ifdef CONFIG_NETFILTER
 extern int			ip6_local_out(struct sk_buff *skb);
-#else
-#define ip6_local_out		__ip6_local_out
-#endif
 
 /*
  *	Extension header (options) processing
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c652ddb..ad8106c 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -101,7 +101,6 @@ int __ip_local_out(struct sk_buff *skb)
 		       dst_output);
 }
 
-#ifdef CONFIG_NETFILTER
 int ip_local_out(struct sk_buff *skb)
 {
 	int err;
@@ -112,7 +111,6 @@ int ip_local_out(struct sk_buff *skb)
 
 	return err;
 }
-#endif
 EXPORT_SYMBOL_GPL(ip_local_out);
 
 /* dev_loopback_xmit for use with netfilter. */
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index d6232df..b4948c1 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -237,7 +237,7 @@ static struct dst_ops xfrm4_dst_ops = {
 	.update_pmtu =		xfrm4_update_pmtu,
 	.destroy =		xfrm4_dst_destroy,
 	.ifdown =		xfrm4_dst_ifdown,
-	.local_out =		ip_local_out,
+	.local_out =		__ip_local_out,
 	.gc_thresh =		1024,
 	.entry_size =		sizeof(struct xfrm_dst),
 };
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a0a366f..45a0f39 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -83,7 +83,6 @@ int __ip6_local_out(struct sk_buff *skb)
 		       dst_output);
 }
 
-#ifdef CONFIG_NETFILTER
 int ip6_local_out(struct sk_buff *skb)
 {
 	int err;
@@ -94,7 +93,6 @@ int ip6_local_out(struct sk_buff *skb)
 
 	return err;
 }
-#endif
 EXPORT_SYMBOL_GPL(ip6_local_out);
 
 static int ip6_output_finish(struct sk_buff *skb)
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 6ee0de1..31456c7 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -253,7 +253,7 @@ static struct dst_ops xfrm6_dst_ops = {
 	.update_pmtu =		xfrm6_update_pmtu,
 	.destroy =		xfrm6_dst_destroy,
 	.ifdown =		xfrm6_dst_ifdown,
-	.local_out =		ip6_local_out,
+	.local_out =		__ip6_local_out,
 	.gc_thresh =		1024,
 	.entry_size =		sizeof(struct xfrm_dst),
 };
