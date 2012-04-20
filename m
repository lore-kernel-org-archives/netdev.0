From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] af_packet: packet_getsockopt() cleanup
Date: Fri, 20 Apr 2012 09:56:11 +0200
Message-ID: <1334908571.2395.228.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60539 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab2DTH4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 03:56:16 -0400
Received: by wejx9 with SMTP id x9so5894664wej.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 00:56:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Factorize code, since most fetched values are int type.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/packet/af_packet.c |   46 ++++++---------------------------------
 1 file changed, 8 insertions(+), 38 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 40053a0..0f66174 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3224,10 +3224,10 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 			     char __user *optval, int __user *optlen)
 {
 	int len;
-	int val;
+	int val, lv = sizeof(val);
 	struct sock *sk = sock->sk;
 	struct packet_sock *po = pkt_sk(sk);
-	void *data;
+	void *data = &val;
 	struct tpacket_stats st;
 	union tpacket_stats_u st_u;
 
@@ -3242,21 +3242,17 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 
 	switch (optname) {
 	case PACKET_STATISTICS:
-		if (po->tp_version == TPACKET_V3) {
-			len = sizeof(struct tpacket_stats_v3);
-		} else {
-			if (len > sizeof(struct tpacket_stats))
-				len = sizeof(struct tpacket_stats);
-		}
 		spin_lock_bh(&sk->sk_receive_queue.lock);
 		if (po->tp_version == TPACKET_V3) {
+			lv = sizeof(struct tpacket_stats_v3);
 			memcpy(&st_u.stats3, &po->stats,
-			sizeof(struct tpacket_stats));
+			       sizeof(struct tpacket_stats));
 			st_u.stats3.tp_freeze_q_cnt =
-			po->stats_u.stats3.tp_freeze_q_cnt;
+					po->stats_u.stats3.tp_freeze_q_cnt;
 			st_u.stats3.tp_packets += po->stats.tp_drops;
 			data = &st_u.stats3;
 		} else {
+			lv = sizeof(struct tpacket_stats);
 			st = po->stats;
 			st.tp_packets += st.tp_drops;
 			data = &st;
@@ -3265,31 +3261,16 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
 		break;
 	case PACKET_AUXDATA:
-		if (len > sizeof(int))
-			len = sizeof(int);
 		val = po->auxdata;
-
-		data = &val;
 		break;
 	case PACKET_ORIGDEV:
-		if (len > sizeof(int))
-			len = sizeof(int);
 		val = po->origdev;
-
-		data = &val;
 		break;
 	case PACKET_VNET_HDR:
-		if (len > sizeof(int))
-			len = sizeof(int);
 		val = po->has_vnet_hdr;
-
-		data = &val;
 		break;
 	case PACKET_VERSION:
-		if (len > sizeof(int))
-			len = sizeof(int);
 		val = po->tp_version;
-		data = &val;
 		break;
 	case PACKET_HDRLEN:
 		if (len > sizeof(int))
@@ -3309,39 +3290,28 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 		default:
 			return -EINVAL;
 		}
-		data = &val;
 		break;
 	case PACKET_RESERVE:
-		if (len > sizeof(unsigned int))
-			len = sizeof(unsigned int);
 		val = po->tp_reserve;
-		data = &val;
 		break;
 	case PACKET_LOSS:
-		if (len > sizeof(unsigned int))
-			len = sizeof(unsigned int);
 		val = po->tp_loss;
-		data = &val;
 		break;
 	case PACKET_TIMESTAMP:
-		if (len > sizeof(int))
-			len = sizeof(int);
 		val = po->tp_tstamp;
-		data = &val;
 		break;
 	case PACKET_FANOUT:
-		if (len > sizeof(int))
-			len = sizeof(int);
 		val = (po->fanout ?
 		       ((u32)po->fanout->id |
 			((u32)po->fanout->type << 16)) :
 		       0);
-		data = &val;
 		break;
 	default:
 		return -ENOPROTOOPT;
 	}
 
+	if (len > lv)
+		len = lv;
 	if (put_user(len, optlen))
 		return -EFAULT;
 	if (copy_to_user(optval, data, len))
