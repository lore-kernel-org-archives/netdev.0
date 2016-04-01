From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 11/11] tcp: rate limit ACK sent by SYN_RECV request sockets
Date: Fri,  1 Apr 2016 08:52:22 -0700
Message-ID: <1459525942-30399-12-git-send-email-edumazet@google.com>
References: <1459525942-30399-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35768 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758966AbcDAPwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:52:51 -0400
Received: by mail-pa0-f52.google.com with SMTP id td3so93538649pab.2
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:52:51 -0700 (PDT)
In-Reply-To: <1459525942-30399-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Attackers like to use SYNFLOOD targeting one 5-tuple, as they
hit a single RX queue (and cpu) on the victim.

If they use random sequence numbers in their SYN, we detect
they do not match the expected window and send back an ACK.

This patch adds a rate limitation, so that the effect of such
attacks is limited to ingress only.

We roughly double our ability to absorb such attacks.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/ipv4/tcp_minisocks.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index acb366dd61e6..4c53e7c86586 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -704,7 +704,10 @@ struct sock *tcp_check_req(struct sock *sk, struct=
 sk_buff *skb,
 	if (paws_reject || !tcp_in_window(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(sk=
b)->end_seq,
 					  tcp_rsk(req)->rcv_nxt, tcp_rsk(req)->rcv_nxt + req->rsk_rcv_wnd=
)) {
 		/* Out of window: send ACK and drop. */
-		if (!(flg & TCP_FLAG_RST))
+		if (!(flg & TCP_FLAG_RST) &&
+		    !tcp_oow_rate_limited(sock_net(sk), skb,
+					  LINUX_MIB_TCPACKSKIPPEDSYNRECV,
+					  &tcp_rsk(req)->last_oow_ack_time))
 			req->rsk_ops->send_ack(sk, skb, req);
 		if (paws_reject)
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
--=20
2.8.0.rc3.226.g39d4020
