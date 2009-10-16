From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] af_packet: Avoid cache line dirtying
Date: Fri, 16 Oct 2009 16:02:20 +0200
Message-ID: <4AD87CEC.4020407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Luca Deri <deri@ntop.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59275 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702AbZJPODV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 10:03:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While doing multiple captures, I found af_packet was dirtying cache line
containing its prot_hook.

This slow down machines where several cpus are necessary to handle capture
traffic, as each prot_hook is traversed for each packet coming in or out
the host.

This patches moves "struct packet_type prot_hook" to the end of 
packet_sock, and uses a ____cacheline_aligned_in_smp to make sure
this remains shared by all cpus.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index bf3a295..dac775e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -188,7 +188,6 @@ struct packet_sock {
 	struct packet_ring_buffer	tx_ring;
 	int			copy_thresh;
 #endif
-	struct packet_type	prot_hook;
 	spinlock_t		bind_lock;
 	struct mutex		pg_vec_lock;
 	unsigned int		running:1,	/* prot_hook is attached*/
@@ -204,6 +203,7 @@ struct packet_sock {
 	unsigned int		tp_reserve;
 	unsigned int		tp_loss:1;
 #endif
+	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
 };
 
 struct packet_skb_cb {
