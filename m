From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: [PATCH][IPV6] fix clearing in ah6 input
Date: Wed, 6 Aug 2003 16:28:08 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030806162808.4edf9eeb.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi@linux-ipv6.org, latten@austin.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

This patch fixes zero-clear in ah6_input.
If calling pskb_expand_head, the kernel clears wrong memory.

This patch is against linux-2.6.0-test2

Best regards,

diff -ruN a/net/ipv6/ah6.c b/net/ipv6/ah6.c
--- a/net/ipv6/ah6.c	2003-07-28 02:05:05.000000000 +0900
+++ b/net/ipv6/ah6.c	2003-08-06 12:57:19.000000000 +0900
@@ -262,13 +262,12 @@
 	 * There is offset of AH before IPv6 header after the process.
 	 */
 
-	struct ipv6hdr *iph = skb->nh.ipv6h;
 	struct ipv6_auth_hdr *ah;
 	struct ah_data *ahp;
 	unsigned char *tmp_hdr = NULL;
-	u16 hdr_len = skb->data - skb->nh.raw;
+	u16 hdr_len;
 	u16 ah_hlen;
-	u16 cleared_hlen = hdr_len;
+	u16 cleared_hlen;
 	u16 nh_offset = 0;
 	u8 nexthdr = 0;
 	u8 *prevhdr;
@@ -276,6 +275,14 @@
 	if (!pskb_may_pull(skb, sizeof(struct ip_auth_hdr)))
 		goto out;
 
+	/* We are going to _remove_ AH header to keep sockets happy,
+	 * so... Later this can change. */
+	if (skb_cloned(skb) &&
+	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+		goto out;
+
+	hdr_len = skb->data - skb->nh.raw;
+	cleared_hlen = hdr_len;
 	ah = (struct ipv6_auth_hdr*)skb->data;
 	ahp = x->data;
 	nexthdr = ah->nexthdr;
@@ -294,27 +301,22 @@
 	if (!pskb_may_pull(skb, ah_hlen))
 		goto out;
 
-	/* We are going to _remove_ AH header to keep sockets happy,
-	 * so... Later this can change. */
-	if (skb_cloned(skb) &&
-	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
-		goto out;
-
 	tmp_hdr = kmalloc(cleared_hlen, GFP_ATOMIC);
 	if (!tmp_hdr)
 		goto out;
 	memcpy(tmp_hdr, skb->nh.raw, cleared_hlen);
 	ipv6_clear_mutable_options(skb, &nh_offset, XFRM_POLICY_IN);
-	iph->priority    = 0;
-	iph->flow_lbl[0] = 0;
-	iph->flow_lbl[1] = 0;
-	iph->flow_lbl[2] = 0;
-	iph->hop_limit   = 0;
+	skb->nh.ipv6h->priority    = 0;
+	skb->nh.ipv6h->flow_lbl[0] = 0;
+	skb->nh.ipv6h->flow_lbl[1] = 0;
+	skb->nh.ipv6h->flow_lbl[2] = 0;
+	skb->nh.ipv6h->hop_limit   = 0;
 
         {
 		u8 auth_data[ahp->icv_trunc_len];
 
 		memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
+		memset(ah->auth_data, 0, ahp->icv_trunc_len);
 		skb_push(skb, skb->data - skb->nh.raw);
 		ahp->icv(ahp, skb, ah->auth_data);
 		if (memcmp(ah->auth_data, auth_data, ahp->icv_trunc_len)) {
