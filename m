From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: Fix tunnel encapsulation limit in ip6_tunnel.c
Date: Mon, 18 Aug 2003 14:50:51 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308181423250.19167-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I reread RFC 2473 and noticed the tunnel encapsulation limit handling was
off by one. This patch fixes the bug. Please apply!

Thanks,
Ville

--- linux-2.5.OLD/net/ipv6/ip6_tunnel.c	2003-08-18 10:04:23.000000000 +0300
+++ linux-2.5/net/ipv6/ip6_tunnel.c	2003-08-15 18:45:36.000000000 +0300
@@ -423,7 +423,7 @@

 		if (teli && teli == info - 2) {
 			tel = (struct ipv6_tlv_tnl_enc_lim *) &skb->data[teli];
-			if (tel->encap_limit <= 1) {
+			if (tel->encap_limit == 0) {
 				if (net_ratelimit())
 					printk(KERN_WARNING
 					       "%s: Too small encapsulation "
@@ -669,7 +669,7 @@
 	struct ipv6hdr *ipv6h = skb->nh.ipv6h;
 	struct ipv6_txoptions *orig_opt = NULL;
 	struct ipv6_txoptions *opt = NULL;
-	__u8 encap_limit = 0;
+	int encap_limit = -1;
 	__u16 offset;
 	struct flowi fl;
 	struct ip6_flowlabel *fl_lbl = NULL;
@@ -692,7 +692,7 @@
 	if ((offset = parse_tlv_tnl_enc_lim(skb, skb->nh.raw)) > 0) {
 		struct ipv6_tlv_tnl_enc_lim *tel;
 		tel = (struct ipv6_tlv_tnl_enc_lim *) &skb->nh.raw[offset];
-		if (tel->encap_limit <= 1) {
+		if (tel->encap_limit == 0) {
 			icmpv6_send(skb, ICMPV6_PARAMPROB,
 				    ICMPV6_HDR_FIELD, offset + 2, skb->dev);
 			goto tx_err;
@@ -715,7 +715,7 @@
 		if (fl_lbl)
 			orig_opt = fl_lbl->opt;
 	}
-	if (encap_limit > 0) {
+	if (encap_limit >= 0) {
 		if (!(opt = merge_options(sk, encap_limit, orig_opt))) {
 			goto tx_err_free_fl_lbl;
 		}


--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
