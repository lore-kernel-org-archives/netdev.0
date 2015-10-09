From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] packet: fix match_fanout_group()
Date: Fri, 09 Oct 2015 11:29:32 -0700
Message-ID: <1444415372.27760.74.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Eric Leblond <eric@regit.org>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35677 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758717AbbJIS3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 14:29:33 -0400
Received: by pabve7 with SMTP id ve7so34783322pab.2
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 11:29:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Recent TCP listener patches exposed a prior af_packet bug :
match_fanout_group() blindly assumes it is always safe
to cast sk to a packet socket to compare fanout with af_packet_priv

But SYNACK packets can be sent while attached to request_sock, which
are smaller than a "struct sock".

We can read non existent memory and crash.

Fixes: c0de08d04215 ("af_packet: don't emit packet on orig fanout group")
Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Eric Leblond <eric@regit.org>
---
 net/packet/af_packet.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 81c900fbc4a4..ccd1d4e9b151 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1519,10 +1519,10 @@ static void __fanout_unlink(struct sock *sk, struct packet_sock *po)
 
 static bool match_fanout_group(struct packet_type *ptype, struct sock *sk)
 {
-	if (ptype->af_packet_priv == (void *)((struct packet_sock *)sk)->fanout)
-		return true;
+	if (sk->sk_family != PF_PACKET)
+		return false;
 
-	return false;
+	return ptype->af_packet_priv == pkt_sk(sk)->fanout;
 }
 
 static void fanout_init_data(struct packet_fanout *f)
