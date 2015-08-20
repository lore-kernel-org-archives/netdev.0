From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 07/10] raw: enable sendmsg zerocopy with hdrincl
Date: Thu, 20 Aug 2015 10:36:46 -0400
Message-ID: <1440081408-12302-8-git-send-email-willemb@google.com>
References: <1440081408-12302-1-git-send-email-willemb@google.com>
Cc: mst@redhat.com, jasowang@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:35193 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750AbbHTOg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 10:36:57 -0400
Received: by qkbm65 with SMTP id m65so16086809qkb.2
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 07:36:57 -0700 (PDT)
In-Reply-To: <1440081408-12302-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add MSG_ZEROCOPY support to inet/raw when passing IP_HDRINCL

Tested:
  raw loopback test //net/socket:snd_zerocopy_lo -r -z passes:

  without zerocopy (-r):
    rx=69348 (4327 MB) tx=69348 txc=0
    rx=145590 (9085 MB) tx=145590 txc=0
    rx=219210 (13679 MB) tx=219210 txc=0
    rx=293688 (18327 MB) tx=293688 txc=0

  with zerocopy (-r -z):
    rx=258132 (16108 MB) tx=258132 txc=258122
    rx=541266 (33777 MB) tx=541266 txc=541256
    rx=822606 (51334 MB) tx=822606 txc=822596
    rx=1105776 (69005 MB) tx=1105776 txc=1105766

  raw hdrincl loopback test //net/socket:snd_zerocopy_lo -R -z passes:

  without zerocopy (-R):
    rx=101904 (6359 MB) tx=101904 txc=0
    rx=215256 (13432 MB) tx=215256 txc=0
    rx=328584 (20505 MB) tx=328584 txc=0
    rx=442008 (27583 MB) tx=442008 txc=0

  with zerocopy (-R -z):
    rx=265398 (16562 MB) tx=265398 txc=265392
    rx=558744 (34868 MB) tx=558744 txc=558738
    rx=853308 (53250 MB) tx=853308 txc=853302
    rx=1148142 (71649 MB) tx=1148142 txc=1148136

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/raw.c | 28 +++++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 561cd4b..c4fa57d 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -347,7 +347,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 	unsigned int iphlen;
 	int err;
 	struct rtable *rt = *rtp;
-	int hlen, tlen;
+	int hlen, tlen, linear;
 
 	if (length > rt->dst.dev->mtu) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
@@ -359,8 +359,14 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	hlen = LL_RESERVED_SPACE(rt->dst.dev);
 	tlen = rt->dst.dev->needed_tailroom;
+	linear = length;
+
+	if (flags & MSG_ZEROCOPY && length &&
+	    sock_can_zerocopy(sk, rt, CHECKSUM_UNNECESSARY))
+		linear = min_t(int, length, MAX_HEADER);
+
 	skb = sock_alloc_send_skb(sk,
-				  length + hlen + tlen + 15,
+				  linear + hlen + tlen + 15,
 				  flags & MSG_DONTWAIT, &err);
 	if (!skb)
 		goto error;
@@ -373,15 +379,14 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	skb_reset_network_header(skb);
 	iph = ip_hdr(skb);
-	skb_put(skb, length);
+	skb_put(skb, linear);
 
 	skb->ip_summed = CHECKSUM_NONE;
 
 	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
-
 	skb->transport_header = skb->network_header;
 	err = -EFAULT;
-	if (memcpy_from_msg(iph, msg, length))
+	if (memcpy_from_msg(iph, msg, linear))
 		goto error_free;
 
 	iphlen = iph->ihl * 4;
@@ -397,6 +402,17 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 	if (iphlen > length)
 		goto error_free;
 
+	if (length != linear) {
+		size_t datalen = length - linear;
+
+		if (!skb_zerocopy_alloc(skb, datalen))
+			goto error_zcopy;
+		err = skb_zerocopy_add_frags_iter(sk, skb, &msg->msg_iter,
+						  datalen, skb_uarg(skb));
+		if (err != datalen)
+			goto error_zcopy;
+	}
+
 	if (iphlen >= sizeof(*iph)) {
 		if (!iph->saddr)
 			iph->saddr = fl4->saddr;
@@ -420,6 +436,8 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 out:
 	return 0;
 
+error_zcopy:
+	sock_zerocopy_put_abort(skb_zcopy(skb));
 error_free:
 	kfree_skb(skb);
 error:
-- 
2.5.0.276.gf5e568e
