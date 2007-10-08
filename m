From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/7] [IPSEC]: Move output replay code into xfrm_output
Date: Mon, 08 Oct 2007 19:29:42 +0800
Message-ID: <E1Ieqnu-0000oF-00@gondolin.me.apana.org.au>
References: <20071008112818.GA3010@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1737 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753145AbXJHL3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 07:29:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move output replay code into xfrm_output

The replay counter is one of only two remaining things in the output code
that requires a lock on the xfrm state (the other being the crypto).  This
patch moves it into the generic xfrm_output so we can remove the lock from
the transforms themselves.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h     |   20 +++++++++++++++++++-
 net/ipv4/ah4.c         |    4 ++--
 net/ipv4/esp4.c        |    4 ++--
 net/ipv6/ah6.c         |    4 ++--
 net/ipv6/esp6.c        |    4 ++--
 net/xfrm/xfrm_output.c |    5 +++++
 6 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bb91934..a267725 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -2,7 +2,6 @@
 #define _NET_XFRM_H
 
 #include <linux/compiler.h>
-#include <linux/in.h>
 #include <linux/xfrm.h>
 #include <linux/spinlock.h>
 #include <linux/list.h>
@@ -16,6 +15,7 @@
 
 #include <net/sock.h>
 #include <net/dst.h>
+#include <net/ip.h>
 #include <net/route.h>
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
@@ -279,6 +279,7 @@ struct xfrm_type
 	__u8			proto;
 	__u8			flags;
 #define XFRM_TYPE_NON_FRAGMENT	1
+#define XFRM_TYPE_REPLAY_PROT	2
 
 	int			(*init_state)(struct xfrm_state *x);
 	void			(*destructor)(struct xfrm_state *);
@@ -419,6 +420,23 @@ extern int xfrm_unregister_km(struct xfrm_mgr *km);
 
 extern unsigned int xfrm_policy_count[XFRM_POLICY_MAX*2];
 
+/*
+ * This structure is used for the duration where packets are being
+ * transformed by IPsec.  As soon as the packet leaves IPsec the
+ * area beyond the generic IP part may be overwritten.
+ */
+struct xfrm_skb_cb {
+	union {
+		struct inet_skb_parm h4;
+		struct inet6_skb_parm h6;
+        } header;
+
+        /* Sequence number for replay protection. */
+        u64 seq;
+};
+
+#define XFRM_SKB_CB(__skb) ((struct xfrm_skb_cb *)&((__skb)->cb[0]))
+
 /* Audit Information */
 struct xfrm_audit
 {
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index dc1d8e8..58af298 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -96,8 +96,7 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
-	ah->seq_no = htonl(++x->replay.oseq);
-	xfrm_aevent_doreplay(x);
+	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq);
 	err = ah_mac_digest(ahp, skb, ah->auth_data);
 	if (err)
 		goto error;
@@ -297,6 +296,7 @@ static struct xfrm_type ah_type =
 	.description	= "AH4",
 	.owner		= THIS_MODULE,
 	.proto	     	= IPPROTO_AH,
+	.flags		= XFRM_TYPE_REPLAY_PROT,
 	.init_state	= ah_init_state,
 	.destructor	= ah_destroy,
 	.input		= ah_input,
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index d233e2e..0f62af9 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -95,8 +95,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 		top_iph->protocol = IPPROTO_ESP;
 
 	esph->spi = x->id.spi;
-	esph->seq_no = htonl(++x->replay.oseq);
-	xfrm_aevent_doreplay(x);
+	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq);
 
 	if (esp->conf.ivlen) {
 		if (unlikely(!esp->conf.ivinitted)) {
@@ -437,6 +436,7 @@ static struct xfrm_type esp_type =
 	.description	= "ESP4",
 	.owner		= THIS_MODULE,
 	.proto	     	= IPPROTO_ESP,
+	.flags		= XFRM_TYPE_REPLAY_PROT,
 	.init_state	= esp_init_state,
 	.destructor	= esp_destroy,
 	.get_mtu	= esp4_get_mtu,
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 69a2030..ae68a90 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -283,8 +283,7 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
-	ah->seq_no = htonl(++x->replay.oseq);
-	xfrm_aevent_doreplay(x);
+	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq);
 	err = ah_mac_digest(ahp, skb, ah->auth_data);
 	if (err)
 		goto error_free_iph;
@@ -506,6 +505,7 @@ static struct xfrm_type ah6_type =
 	.description	= "AH6",
 	.owner		= THIS_MODULE,
 	.proto	     	= IPPROTO_AH,
+	.flags		= XFRM_TYPE_REPLAY_PROT,
 	.init_state	= ah6_init_state,
 	.destructor	= ah6_destroy,
 	.input		= ah6_input,
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 7728106..0c5fb81 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -95,8 +95,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	*skb_network_header(skb) = IPPROTO_ESP;
 
 	esph->spi = x->id.spi;
-	esph->seq_no = htonl(++x->replay.oseq);
-	xfrm_aevent_doreplay(x);
+	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq);
 
 	if (esp->conf.ivlen) {
 		if (unlikely(!esp->conf.ivinitted)) {
@@ -373,6 +372,7 @@ static struct xfrm_type esp6_type =
 	.description	= "ESP6",
 	.owner	     	= THIS_MODULE,
 	.proto	     	= IPPROTO_ESP,
+	.flags		= XFRM_TYPE_REPLAY_PROT,
 	.init_state	= esp6_init_state,
 	.destructor	= esp6_destroy,
 	.get_mtu	= esp6_get_mtu,
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 5b1c978..20e789d 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -58,6 +58,11 @@ int xfrm_output(struct sk_buff *skb)
 		if (err)
 			goto error;
 
+		if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
+			XFRM_SKB_CB(skb)->seq = ++x->replay.oseq;
+			xfrm_aevent_doreplay(x);
+		}
+
 		err = x->mode->output(x, skb);
 		if (err)
 			goto error;
