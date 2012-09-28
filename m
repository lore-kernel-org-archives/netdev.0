From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: dont orphan skbs in mlx4_en_xmit()
Date: Fri, 28 Sep 2012 19:53:26 +0200
Message-ID: <1348854806.5093.2686.camel@edumazet-glaptop>
References: <1347866974.26523.53.camel@edumazet-glaptop>
	 <953B660C027164448AE903364AC447D28721B46E@MTLDAG01.mtl.com>
	 <1348056777.26523.750.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50116 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758672Ab2I1Rxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 13:53:31 -0400
Received: by bkcjk13 with SMTP id jk13so3761157bkc.19
        for <netdev@vger.kernel.org>; Fri, 28 Sep 2012 10:53:30 -0700 (PDT)
In-Reply-To: <1348056777.26523.750.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After commit e22979d96a55d (mlx4_en: Moving to Interrupts for TX
completions) we no longer need to orphan skbs in mlx4_en_xmit()
since skb wont stay a long time in TX ring before their release.

Orphaning skbs in ndo_start_xmit() should be avoided as much as
possible, since it breaks TCP Small Queue or other flow control
mechanisms (per socket limits)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 10bba09..c10e3a6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -712,10 +712,6 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (bounce)
 		tx_desc = mlx4_en_bounce_to_desc(priv, ring, index, desc_size);
 
-	/* Run destructor before passing skb to HW */
-	if (likely(!skb_shared(skb)))
-		skb_orphan(skb);
-
 	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce && !vlan_tag) {
 		*(__be32 *) (&tx_desc->ctrl.vlan_tag) |= cpu_to_be32(ring->doorbell_qpn);
 		op_own |= htonl((bf_index & 0xffff) << 8);
