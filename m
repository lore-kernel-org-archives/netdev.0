From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC v2 10/12] raw: enable sendmsg zerocopy with IP_HDRINCL
Date: Wed, 22 Feb 2017 11:38:59 -0500
Message-ID: <20170222163901.90834-11-willemdebruijn.kernel@gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33609 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932364AbdBVQjd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 11:39:33 -0500
Received: by mail-qk0-f194.google.com with SMTP id x71so1187408qkb.0
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 08:39:27 -0800 (PST)
In-Reply-To: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Tested:
  raw loopback test snd_zerocopy_lo -r -z produces:

  without zerocopy (-r):
    rx=97632 (6092 MB) tx=97632 txc=0
    rx=208194 (12992 MB) tx=208194 txc=0
    rx=318714 (19889 MB) tx=318714 txc=0
    rx=429126 (26779 MB) tx=429126 txc=0

  with zerocopy (-r -z):
    rx=326160 (20353 MB) tx=326160 txc=326144
    rx=689244 (43012 MB) tx=689244 txc=689220
    rx=1049352 (65484 MB) tx=1049352 txc=1049320
    rx=1408782 (87914 MB) tx=1408782 txc=1408744

  raw hdrincl loopback test snd_zerocopy_lo -R -z produces:

  without zerocopy (-R):
    rx=167328 (10442 MB) tx=167328 txc=0
    rx=354942 (22150 MB) tx=354942 txc=0
    rx=542400 (33848 MB) tx=542400 txc=0
    rx=716442 (44709 MB) tx=716442 txc=0

  with zerocopy (-R -z):
    rx=340116 (21224 MB) tx=340116 txc=340102
    rx=712746 (44478 MB) tx=712746 txc=712726
    rx=1083732 (67629 MB) tx=1083732 txc=1083704
    rx=1457856 (90976 MB) tx=1457856 txc=1457820

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/raw.c | 27 +++++++++++++++++++++++----
 1 file changed, 23 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 8119e1f66e03..d21279b2f69e 100644
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
@@ -363,8 +363,14 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
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
@@ -377,7 +383,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	skb_reset_network_header(skb);
 	iph = ip_hdr(skb);
-	skb_put(skb, length);
+	skb_put(skb, linear);
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -388,7 +394,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	skb->transport_header = skb->network_header;
 	err = -EFAULT;
-	if (memcpy_from_msg(iph, msg, length))
+	if (memcpy_from_msg(iph, msg, linear))
 		goto error_free;
 
 	iphlen = iph->ihl * 4;
@@ -404,6 +410,17 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
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
@@ -430,6 +447,8 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 out:
 	return 0;
 
+error_zcopy:
+	sock_zerocopy_put_abort(skb_zcopy(skb));
 error_free:
 	kfree_skb(skb);
 error:
-- 
2.11.0.483.g087da7b7c-goog
