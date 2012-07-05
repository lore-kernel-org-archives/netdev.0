From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next v2] ipv4: defer fib_compute_spec_dst() call
Date: Thu, 05 Jul 2012 10:30:09 +0200
Message-ID: <1341477009.2583.3406.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41269 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458Ab2GEIaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 04:30:15 -0400
Received: by eaak11 with SMTP id k11so3129050eaa.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 01:30:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ip_options_compile() can avoid calling fib_compute_spec_dst()
by default, and perform the call only if needed.

David suggested to add a helper to make the call only once.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_options.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 1f02251..a19d647 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -242,6 +242,15 @@ void ip_options_fragment(struct sk_buff *skb)
 	opt->ts_needtime = 0;
 }
 
+/* helper used by ip_options_compile() to call fib_compute_spec_dst()
+ * at most one time.
+ */
+static void spec_dst_fill(__be32 *spec_dst, struct sk_buff *skb)
+{
+	if (*spec_dst == htonl(INADDR_ANY))
+		*spec_dst = fib_compute_spec_dst(skb);
+}
+
 /*
  * Verify options and fill pointers in struct options.
  * Caller should clear *opt, and set opt->data.
@@ -251,7 +260,7 @@ void ip_options_fragment(struct sk_buff *skb)
 int ip_options_compile(struct net *net,
 		       struct ip_options *opt, struct sk_buff *skb)
 {
-	__be32 spec_dst = (__force __be32) 0;
+	__be32 spec_dst = htonl(INADDR_ANY);
 	unsigned char *pp_ptr = NULL;
 	struct rtable *rt = NULL;
 	unsigned char *optptr;
@@ -260,8 +269,6 @@ int ip_options_compile(struct net *net,
 
 	if (skb != NULL) {
 		rt = skb_rtable(skb);
-		if (rt)
-			spec_dst = fib_compute_spec_dst(skb);
 		optptr = (unsigned char *)&(ip_hdr(skb)[1]);
 	} else
 		optptr = opt->__data;
@@ -334,6 +341,7 @@ int ip_options_compile(struct net *net,
 					goto error;
 				}
 				if (rt) {
+					spec_dst_fill(&spec_dst, skb);
 					memcpy(&optptr[optptr[2]-1], &spec_dst, 4);
 					opt->is_changed = 1;
 				}
@@ -376,6 +384,7 @@ int ip_options_compile(struct net *net,
 					}
 					opt->ts = optptr - iph;
 					if (rt)  {
+						spec_dst_fill(&spec_dst, skb);
 						memcpy(&optptr[optptr[2]-1], &spec_dst, 4);
 						timeptr = &optptr[optptr[2]+3];
 					}
