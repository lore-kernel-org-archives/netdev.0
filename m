From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2] mlx4: add missed recycle opportunity for XDP_TX
 on TX failure
Date: Mon, 19 Sep 2016 17:46:38 +0200
Message-ID: <20160919154556.10965.75722.stgit@firesoul>
References: <1474295315.22679.85.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, tom@herbertland.com,
        bblanco@plumgrid.com, Jesper Dangaard Brouer <brouer@redhat.com>,
        rana.shahot@gmail.com, "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47800 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752189AbcISPql (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 11:46:41 -0400
In-Reply-To: <1474295315.22679.85.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct drop handling for XDP_TX on TX failure, were recently added in
commit 95357907ae73 ("mlx4: fix XDP_TX is acting like XDP_PASS on TX
ring full").

The change missed an opportunity for recycling the RX page, instead of
going through the page allocator, like the regular XDP_DROP action does.
This patch cease the opportunity, by going through the XDP_DROP case.

Fixes: 95357907ae73 ("mlx4: fix XDP_TX is acting like XDP_PASS on TX ring full")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
V2: adjust indention according to Eric

 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c80073e4947f..c46355bce613 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -906,11 +906,12 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 							length, tx_index,
 							&doorbell_pending))
 					goto consumed;
-				goto next; /* Drop on xmit failure */
+				goto xdp_drop; /* Drop on xmit failure */
 			default:
 				bpf_warn_invalid_xdp_action(act);
 			case XDP_ABORTED:
 			case XDP_DROP:
+xdp_drop:
 				if (mlx4_en_rx_recycle(ring, frags))
 					goto consumed;
 				goto next;
