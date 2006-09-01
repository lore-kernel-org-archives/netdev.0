From: jamal <hadi@cyberus.ca>
Subject: [IPSEC]: output mode to take an xfrm state as input param
Date: Thu, 31 Aug 2006 20:01:12 -0400
Message-ID: <1157068872.5057.17.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-V7w+4MK2qA89IIvE5dyL"
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:60103 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932494AbWIAABQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 20:01:16 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GIwTJ-0008CP-Cz
	for netdev@vger.kernel.org; Thu, 31 Aug 2006 20:01:21 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-V7w+4MK2qA89IIvE5dyL
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Against net-2.6.19

cheers,
jamal

--=-V7w+4MK2qA89IIvE5dyL
Content-Disposition: attachment; filename=ipsec-mode-p1
Content-Type: text/plain; name=ipsec-mode-p1; charset=UTF-8
Content-Transfer-Encoding: 7bit

  Expose IPSEC modes output path to take an xfrm state as input param.
  This makes it consistent with the input mode processing (which already
  takes the xfrm state as a param).

---
commit 0169ac1c2a64f04deeff3dae704f34e22ae59cb7
tree 8ae315bf21444eec3f845538ac06a080a184a534
parent 28df617d024ac4eaeb51123eea9eda2932466684
author Jamal Hadi Salim <hadi@znyx.com> Thu, 31 Aug 2006 19:55:17 -0400
committer Jamal Hadi Salim <hadi@jzny2.(none)> Thu, 31 Aug 2006 19:55:17 -0400

 include/net/xfrm.h              |    2 +-
 net/ipv4/xfrm4_mode_transport.c |    4 +---
 net/ipv4/xfrm4_mode_tunnel.c    |    3 +--
 net/ipv4/xfrm4_output.c         |    2 +-
 net/ipv6/xfrm6_mode_ro.c        |    3 +--
 net/ipv6/xfrm6_mode_transport.c |    3 +--
 net/ipv6/xfrm6_mode_tunnel.c    |    3 +--
 net/ipv6/xfrm6_output.c         |    2 +-
 8 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 9d366a2..bf8e2df 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -286,7 +286,7 @@ extern void xfrm_put_type(struct xfrm_ty
 
 struct xfrm_mode {
 	int (*input)(struct xfrm_state *x, struct sk_buff *skb);
-	int (*output)(struct sk_buff *skb);
+	int (*output)(struct xfrm_state *x,struct sk_buff *skb);
 
 	struct module *owner;
 	unsigned int encap;
diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
index a9e6b3d..92676b7 100644
--- a/net/ipv4/xfrm4_mode_transport.c
+++ b/net/ipv4/xfrm4_mode_transport.c
@@ -21,9 +21,8 @@ #include <net/xfrm.h>
  * On exit, skb->h will be set to the start of the payload to be processed
  * by x->type->output and skb->nh will be set to the top IP header.
  */
-static int xfrm4_transport_output(struct sk_buff *skb)
+static int xfrm4_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct xfrm_state *x;
 	struct iphdr *iph;
 	int ihl;
 
@@ -33,7 +32,6 @@ static int xfrm4_transport_output(struct
 	ihl = iph->ihl * 4;
 	skb->h.raw += ihl;
 
-	x = skb->dst->xfrm;
 	skb->nh.raw = memmove(skb_push(skb, x->props.header_len), iph, ihl);
 	return 0;
 }
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 13cafbe..e23c21d 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -33,10 +33,9 @@ static inline void ipip_ecn_decapsulate(
  * On exit, skb->h will be set to the start of the payload to be processed
  * by x->type->output and skb->nh will be set to the top IP header.
  */
-static int xfrm4_tunnel_output(struct sk_buff *skb)
+static int xfrm4_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x = dst->xfrm;
 	struct iphdr *iph, *top_iph;
 	int flags;
 
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 5fd115f..04403fb 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -66,7 +66,7 @@ static int xfrm4_output_one(struct sk_bu
 		if (err)
 			goto error;
 
-		err = x->mode->output(skb);
+		err = x->mode->output(x, skb);
 		if (err)
 			goto error;
 
diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
index c11c335..6031c16 100644
--- a/net/ipv6/xfrm6_mode_ro.c
+++ b/net/ipv6/xfrm6_mode_ro.c
@@ -43,9 +43,8 @@ #include <net/xfrm.h>
  * its absence, that of the top IP header.  The value of skb->data will always
  * point to the top IP header.
  */
-static int xfrm6_ro_output(struct sk_buff *skb)
+static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct xfrm_state *x = skb->dst->xfrm;
 	struct ipv6hdr *iph;
 	u8 *prevhdr;
 	int hdr_len;
diff --git a/net/ipv6/xfrm6_mode_transport.c b/net/ipv6/xfrm6_mode_transport.c
index a5dce21..3a4b39b 100644
--- a/net/ipv6/xfrm6_mode_transport.c
+++ b/net/ipv6/xfrm6_mode_transport.c
@@ -25,9 +25,8 @@ #include <net/xfrm.h>
  * its absence, that of the top IP header.  The value of skb->data will always
  * point to the top IP header.
  */
-static int xfrm6_transport_output(struct sk_buff *skb)
+static int xfrm6_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct xfrm_state *x = skb->dst->xfrm;
 	struct ipv6hdr *iph;
 	u8 *prevhdr;
 	int hdr_len;
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 8af79be..5e7d8a7 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -37,10 +37,9 @@ static inline void ipip6_ecn_decapsulate
  * its absence, that of the top IP header.  The value of skb->data will always
  * point to the top IP header.
  */
-static int xfrm6_tunnel_output(struct sk_buff *skb)
+static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x = dst->xfrm;
 	struct ipv6hdr *iph, *top_iph;
 	int dsfield;
 
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index db58104..c260ea1 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -65,7 +65,7 @@ static int xfrm6_output_one(struct sk_bu
 		if (err)
 			goto error;
 
-		err = x->mode->output(skb);
+		err = x->mode->output(x, skb);
 		if (err)
 			goto error;
 

--=-V7w+4MK2qA89IIvE5dyL--

