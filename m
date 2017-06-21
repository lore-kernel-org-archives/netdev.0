From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v2 11/13] raw: enable MSG_ZEROCOPY with IP_HDRINCL
Date: Wed, 21 Jun 2017 16:36:50 -0400
Message-ID: <20170621203652.15306-12-willemdebruijn.kernel@gmail.com>
References: <20170621203652.15306-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-api@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34086 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751999AbdFUUhG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 16:37:06 -0400
In-Reply-To: <20170621203652.15306-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Zerocopy support for udp also enables it for some raw sockets. Only
raw sockets that have hdrinc set take a different path. Add zerocopy
support for this variant.

Tested:
  msg_zerocopy.sh 4 raw_hdrincl:

  without zerocopy
    tx=150438 (9390 MB) txc=0 zc=n
    rx=150438 (9387 MB)

  with zerocopy
    tx=292454 (18255 MB) txc=292454 zc=y
    rx=292454 (18250 MB)

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/raw.c | 23 +++++++++++++++++++----
 net/ipv6/raw.c | 20 +++++++++++++++++---
 2 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index bdffad875691..0a5a3f2ce81b 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -351,7 +351,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 	unsigned int iphlen;
 	int err;
 	struct rtable *rt = *rtp;
-	int hlen, tlen;
+	int hlen, tlen, linear;
 
 	if (length > rt->dst.dev->mtu) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
@@ -366,8 +366,14 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	hlen = LL_RESERVED_SPACE(rt->dst.dev);
 	tlen = rt->dst.dev->needed_tailroom;
+	linear = length;
+
+	if (flags & MSG_ZEROCOPY &&
+	    rt->dst.dev->features & NETIF_F_SG)
+		linear = min_t(int, linear, MAX_HEADER);
+
 	skb = sock_alloc_send_skb(sk,
-				  length + hlen + tlen + 15,
+				  linear + hlen + tlen + 15,
 				  flags & MSG_DONTWAIT, &err);
 	if (!skb)
 		goto error;
@@ -380,7 +386,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	skb_reset_network_header(skb);
 	iph = ip_hdr(skb);
-	skb_put(skb, length);
+	skb_put(skb, linear);
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -391,7 +397,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	skb->transport_header = skb->network_header;
 	err = -EFAULT;
-	if (memcpy_from_msg(iph, msg, length))
+	if (memcpy_from_msg(iph, msg, linear))
 		goto error_free;
 
 	iphlen = iph->ihl * 4;
@@ -423,6 +429,13 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 				skb_transport_header(skb))->type);
 	}
 
+	if (flags & MSG_ZEROCOPY) {
+		err = skb_zerocopy_iter_alloc(skb, (void *)&msg,
+					      length - linear);
+		if (err)
+			goto error_zcopy;
+	}
+
 	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT,
 		      net, sk, skb, NULL, rt->dst.dev,
 		      dst_output);
@@ -433,6 +446,8 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 out:
 	return 0;
 
+error_zcopy:
+	skb_zcopy_abort(skb);
 error_free:
 	kfree_skb(skb);
 error:
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 60be012fe708..206cca2d9b29 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -627,6 +627,7 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 	struct rt6_info *rt = (struct rt6_info *)*dstp;
 	int hlen = LL_RESERVED_SPACE(rt->dst.dev);
 	int tlen = rt->dst.dev->needed_tailroom;
+	int linear = length;
 
 	if (length > rt->dst.dev->mtu) {
 		ipv6_local_error(sk, EMSGSIZE, fl6, rt->dst.dev->mtu);
@@ -637,8 +638,12 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 	if (flags&MSG_PROBE)
 		goto out;
 
+	if (flags & MSG_ZEROCOPY &&
+	    rt->dst.dev->features & NETIF_F_SG)
+		linear = min_t(int, length, MAX_HEADER);
+
 	skb = sock_alloc_send_skb(sk,
-				  length + hlen + tlen + 15,
+				  linear + hlen + tlen + 15,
 				  flags & MSG_DONTWAIT, &err);
 	if (!skb)
 		goto error;
@@ -650,7 +655,7 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 	skb_dst_set(skb, &rt->dst);
 	*dstp = NULL;
 
-	skb_put(skb, length);
+	skb_put(skb, linear);
 	skb_reset_network_header(skb);
 	iph = ipv6_hdr(skb);
 
@@ -660,10 +665,17 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 		skb_set_dst_pending_confirm(skb, 1);
 
 	skb->transport_header = skb->network_header;
-	err = memcpy_from_msg(iph, msg, length);
+	err = memcpy_from_msg(iph, msg, linear);
 	if (err)
 		goto error_fault;
 
+	if (flags & MSG_ZEROCOPY) {
+		err = skb_zerocopy_iter_alloc(skb, (void *)&msg,
+					      length - linear);
+		if (err)
+			goto error_zcopy;
+	}
+
 	/* if egress device is enslaved to an L3 master device pass the
 	 * skb to its handler for processing
 	 */
@@ -681,6 +693,8 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 out:
 	return 0;
 
+error_zcopy:
+	skb_zcopy_abort(skb);
 error_fault:
 	err = -EFAULT;
 	kfree_skb(skb);
-- 
2.13.1.611.g7e3b11ae1-goog
