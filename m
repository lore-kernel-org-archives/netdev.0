From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: reduce out_of_order memory use
Date: Sun, 18 Mar 2012 06:37:34 -0700
Message-ID: <1332077854.3722.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:45528 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991Ab2CRNhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 09:37:37 -0400
Received: by dajr28 with SMTP id r28so8565327daj.19
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 06:37:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With increasing receive window sizes, but speed of light not improved
that much, out of order queue can contain a huge number of skbs, waitin=
g
to be moved to receive_queue when missing packets can fill the holes.

Some devices happen to use fat skbs (truesize of 4096 + sizeof(struct
sk_buff)) to store regular (MTU <=3D 1500) frames. This makes highly
probable sk_rmem_alloc hits sk_rcvbuf limit, which can be 4Mbytes in
many cases.

When limit is hit, tcp stack calls tcp_collapse_ofo_queue(), a true
latency killer and cpu cache blower.

Doing the coalescing attempt each time we add a frame in ofo queue
permits to keep memory use tight and in many cases avoid the
tcp_collapse() thing later.

Tested on various wireless setups (b43, ath9k, ...) known to use big sk=
b
truesize, this patch removed the "packets collapsed in receive queue du=
e
to low socket buffer" I had before.

This also reduced average memory used by tcp sockets.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: H.K. Jerry Chu <hkchu@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/snmp.h |    1 +
 net/ipv4/proc.c      |    1 +
 net/ipv4/tcp_input.c |   19 +++++++++++++++++--
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 8ee8af4..2e68f5b 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -233,6 +233,7 @@ enum
 	LINUX_MIB_TCPREQQFULLDOCOOKIES,		/* TCPReqQFullDoCookies */
 	LINUX_MIB_TCPREQQFULLDROP,		/* TCPReqQFullDrop */
 	LINUX_MIB_TCPRETRANSFAIL,		/* TCPRetransFail */
+	LINUX_MIB_TCPRCVCOALESCE,			/* TCPRcvCoalesce */
 	__LINUX_MIB_MAX
 };
=20
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 02d6107..8af0d44 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -257,6 +257,7 @@ static const struct snmp_mib snmp4_net_list[] =3D {
 	SNMP_MIB_ITEM("TCPReqQFullDoCookies", LINUX_MIB_TCPREQQFULLDOCOOKIES)=
,
 	SNMP_MIB_ITEM("TCPReqQFullDrop", LINUX_MIB_TCPREQQFULLDROP),
 	SNMP_MIB_ITEM("TCPRetransFail", LINUX_MIB_TCPRETRANSFAIL),
+	SNMP_MIB_ITEM("TCPRcvCoalesce", LINUX_MIB_TCPRCVCOALESCE),
 	SNMP_MIB_SENTINEL
 };
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 68d4057..51fe686 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4590,8 +4590,23 @@ drop:
 		u32 end_seq =3D TCP_SKB_CB(skb)->end_seq;
=20
 		if (seq =3D=3D TCP_SKB_CB(skb1)->end_seq) {
-			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
-
+			/* Packets in ofo can stay in queue a long time.
+			 * Better try to coalesce them right now
+			 * to avoid future tcp_collapse_ofo_queue(),
+			 * probably the most expensive function in tcp stack.
+			 */
+			if (skb->len <=3D skb_tailroom(skb1) && !th->fin) {
+				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
+				BUG_ON(skb_copy_bits(skb, 0,
+						     skb_put(skb1, skb->len),
+						     skb->len));
+				TCP_SKB_CB(skb1)->end_seq =3D end_seq;
+				TCP_SKB_CB(skb1)->ack_seq =3D TCP_SKB_CB(skb)->ack_seq;
+				__kfree_skb(skb);
+				skb =3D NULL;
+			} else {
+				__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
+			}
 			if (!tp->rx_opt.num_sacks ||
 			    tp->selective_acks[0].end_seq !=3D seq)
 				goto add_sack;
