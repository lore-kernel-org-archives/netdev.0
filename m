From: Dan Collins <dan@dcollins.co.nz>
Subject: [PATCH] Fixed TPACKET V3 to signal poll when block is closed
 rather than for every packet
Date: Fri, 19 Dec 2014 10:49:16 +1300
Message-ID: <1418939356.3016.9.camel@voodoo.cms.waikato.ac.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender1.zohomail.com ([74.201.84.155]:29464 "EHLO
	sender1.zohomail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbaLRVtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 16:49:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make TPACKET_V3 signal poll when block is closed rather than for every
packet. Side effect is that poll will be signaled when block retire
timer expires which didn't previously happen. Issue was visible when
sending packets at a very low frequency such that all blocks are retired
before packets are received by TPACKET_V3. This caused avoidable packet
loss. The fix ensures that the signal is sent when blocks are closed
which covers the normal path where the block is filled as well as the
path where the timer expires. The case where a block is filled without
moving to the next block (ie. all blocks are full) will still cause poll
to be signaled. 

Signed-off-by: Dan Collins <dan@dcollins.co.nz>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e52a447..14e883d 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -43,6 +43,8 @@
  *             Chetan Loke     :       Implemented TPACKET_V3 block abstraction
  *                                     layer.
  *                                     Copyright (C) 2011, <lokec@ccs.neu.edu>
+ *             Dan Collins : Fixed TPACKET_V3 to wake poll when block is closed
+ *                                     rather than for every packet.
  *
  *
  *             This program is free software; you can redistribute it and/or
@@ -785,6 +787,7 @@ static void prb_close_block(struct tpacket_kbdq_core *pkc1,
 
        struct tpacket3_hdr *last_pkt;
        struct tpacket_hdr_v1 *h1 = &pbd1->hdr.bh1;
+       struct sock *sk = &po->sk;
 
        if (po->stats.stats3.tp_drops)
                status |= TP_STATUS_LOSING;
@@ -809,6 +812,8 @@ static void prb_close_block(struct tpacket_kbdq_core *pkc1,
        /* Flush the block */
        prb_flush_block(pkc1, pbd1, status);
 
+       sk->sk_data_ready(sk);
+
        pkc1->kactive_blk_num = GET_NEXT_PRB_BLK_NUM(pkc1);
 }
 
@@ -2052,12 +2057,12 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
        smp_wmb();
 #endif
 
-       if (po->tp_version <= TPACKET_V2)
+       if (po->tp_version <= TPACKET_V2) {
                __packet_set_status(po, h.raw, status);
-       else
+               sk->sk_data_ready(sk);
+       } else {
                prb_clear_blk_fill_status(&po->rx_ring);
-
-       sk->sk_data_ready(sk);
+       }
 
 drop_n_restore:
        if (skb_head != skb->data && skb_shared(skb)) {
