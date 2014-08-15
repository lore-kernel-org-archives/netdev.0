From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v1 net] packet: handle too big packets for PACKET_V3
Date: Fri, 15 Aug 2014 09:16:04 -0700
Message-ID: <1408119364.6804.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>
	 <1408064099.6804.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1408064641.867439.152913861.09367C24@webmail.messagingengine.com>
	 <1408068085.6804.75.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0B7AA838-0FC7-4B0C-881E-17FC71748140@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev <netdev@vger.kernel.org>, Guy Harris <guy@alum.mit.edu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:40868 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbaHOQQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 12:16:08 -0400
Received: by mail-pd0-f176.google.com with SMTP id y10so3543749pdj.7
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 09:16:07 -0700 (PDT)
In-Reply-To: <0B7AA838-0FC7-4B0C-881E-17FC71748140@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

af_packet can currently overwrite kernel memory by out of bound
accesses, because it assumed a [new] block can always hold one frame.

This is not generally the case, even if most existing tools do it right.

This patch clamps too long frames as API permits, and issue a one time
error on syslog.

[  394.357639] tpacket_rcv: packet too big, clamped from 5042 to 3966. macoff=82

In this example, packet header tp_snaplen was set to 3966,
and tp_len was set to 5042 (skb->len)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: f6fb8f100b80 ("af-packet: TPACKET_V3 flexible buffer implementation.")
---
 net/packet/af_packet.c |   17 +++++++++++++++++
 net/packet/internal.h  |    1 +
 2 files changed, 18 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8d9f8042705a..93896d2092f6 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -632,6 +632,7 @@ static void init_prb_bdqc(struct packet_sock *po,
 	p1->tov_in_jiffies = msecs_to_jiffies(p1->retire_blk_tov);
 	p1->blk_sizeof_priv = req_u->req3.tp_sizeof_priv;
 
+	p1->max_frame_len = p1->kblk_size - BLK_PLUS_PRIV(p1->blk_sizeof_priv);
 	prb_init_ft_ops(p1, req_u);
 	prb_setup_retire_blk_timer(po, tx_ring);
 	prb_open_block(p1, pbd);
@@ -1942,6 +1943,18 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 			if ((int)snaplen < 0)
 				snaplen = 0;
 		}
+	} else if (unlikely(macoff + snaplen >
+			    GET_PBDQC_FROM_RB(&po->rx_ring)->max_frame_len)) {
+		u32 nval;
+
+		nval = GET_PBDQC_FROM_RB(&po->rx_ring)->max_frame_len - macoff;
+		pr_err_once("tpacket_rcv: packet too big, clamped from %u to %u. macoff=%u\n",
+			    snaplen, nval, macoff);
+		snaplen = nval;
+		if (unlikely((int)snaplen < 0)) {
+			snaplen = 0;
+			macoff = GET_PBDQC_FROM_RB(&po->rx_ring)->max_frame_len;
+		}
 	}
 	spin_lock(&sk->sk_receive_queue.lock);
 	h.raw = packet_current_rx_frame(po, skb,
@@ -3783,6 +3796,10 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 			goto out;
 		if (unlikely(req->tp_block_size & (PAGE_SIZE - 1)))
 			goto out;
+		if (po->tp_version >= TPACKET_V3 &&
+		    (int)(req->tp_block_size -
+			  BLK_PLUS_PRIV(req_u->req3.tp_sizeof_priv)) <= 0)
+			goto out;
 		if (unlikely(req->tp_frame_size < po->tp_hdrlen +
 					po->tp_reserve))
 			goto out;
diff --git a/net/packet/internal.h b/net/packet/internal.h
index eb9580a6b25f..cdddf6a30399 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -29,6 +29,7 @@ struct tpacket_kbdq_core {
 	char		*pkblk_start;
 	char		*pkblk_end;
 	int		kblk_size;
+	unsigned int	max_frame_len;
 	unsigned int	knum_blocks;
 	uint64_t	knxt_seq_num;
 	char		*prev;
