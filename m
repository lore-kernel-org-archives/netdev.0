From: Ilya Matveychikov <matvejchikov@gmail.com>
Subject: [PATCH] tcp_input: move out condition check from tcp_data_queue()
Date: Sun, 6 Aug 2017 13:51:17 +0400
Message-ID: <674DB789-9B28-4A9C-A0BF-D91023CB86F3@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36081 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbdHFJvW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 05:51:22 -0400
Received: by mail-wm0-f66.google.com with SMTP id d40so10480390wma.3
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 02:51:22 -0700 (PDT)
Received: from [10.1.0.103] (bba193486.alshamil.net.ae. [217.165.96.192])
        by smtp.gmail.com with ESMTPSA id w134sm2269082wmd.7.2017.08.06.02.51.20
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Aug 2017 02:51:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As tcp_data_queue() function is used just only twice it's better
to move out the first check and wrap it with inline. It saves a
single call in case the condition evaluated as true.

Signed-off-by: Ilya V. Matveychikov <matvejchikov@gmail.com>
---
 net/ipv4/tcp_input.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2920e0c..141a722 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4585,16 +4585,12 @@ int tcp_send_rcvq(struct sock *sk, struct msghdr =
*msg, size_t size)
=20
 }
=20
-static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
+static void __tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	bool fragstolen =3D false;
 	int eaten =3D -1;
=20
-	if (TCP_SKB_CB(skb)->seq =3D=3D TCP_SKB_CB(skb)->end_seq) {
-		__kfree_skb(skb);
-		return;
-	}
 	skb_dst_drop(skb);
 	__skb_pull(skb, tcp_hdr(skb)->doff * 4);
=20
@@ -4703,6 +4699,14 @@ static void tcp_data_queue(struct sock *sk, =
struct sk_buff *skb)
 	tcp_data_queue_ofo(sk, skb);
 }
=20
+static inline void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
+{
+	if (TCP_SKB_CB(skb)->seq =3D=3D TCP_SKB_CB(skb)->end_seq)
+		__kfree_skb(skb);
+	else
+		__tcp_data_queue(sk, skb);
+}
+
 static struct sk_buff *tcp_skb_next(struct sk_buff *skb, struct =
sk_buff_head *list)
 {
 	if (list)
--=20
2.7.4
