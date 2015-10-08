From: Edward Hyunkoo Jee <edjee@google.com>
Subject: [PATCH net-next 2/2] packet: support per-packet fwmark for af_packet sendmsg
Date: Thu,  8 Oct 2015 14:56:49 -0700
Message-ID: <1444341409-28729-2-git-send-email-edjee@google.com>
References: <1444341409-28729-1-git-send-email-edjee@google.com>
Cc: edumazet@google.com, willemb@google.com,
	Edward Hyunkoo Jee <edjee@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34504 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758884AbbJHV6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 17:58:35 -0400
Received: by padhy16 with SMTP id hy16so65757293pad.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 14:58:34 -0700 (PDT)
In-Reply-To: <1444341409-28729-1-git-send-email-edjee@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Hyunkoo Jee <edjee@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 81c900f..9d8c7fa 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2630,6 +2630,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	__be16 proto;
 	unsigned char *addr;
 	int err, reserve = 0;
+	struct sockcm_cookie sockc;
 	struct virtio_net_hdr vnet_hdr = { 0 };
 	int offset = 0;
 	int vnet_hdr_len;
@@ -2665,6 +2666,13 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	if (unlikely(!(dev->flags & IFF_UP)))
 		goto out_unlock;
 
+	sockc.mark = sk->sk_mark;
+	if (msg->msg_controllen) {
+		err = sock_cmsg_send(sk, msg, &sockc);
+		if (unlikely(err))
+			goto out_unlock;
+	}
+
 	if (sock->type == SOCK_RAW)
 		reserve = dev->hard_header_len;
 	if (po->has_vnet_hdr) {
@@ -2774,7 +2782,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	skb->protocol = proto;
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
-	skb->mark = sk->sk_mark;
+	skb->mark = sockc.mark;
 
 	packet_pick_tx_queue(dev, skb);
 
-- 
2.6.0.rc2.230.g3dd15c0
