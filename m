From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net PATCH] mlx4: fix XDP_TX is acting like XDP_PASS on TX ring full
Date: Fri, 16 Sep 2016 21:47:05 +0200
Message-ID: <20160916194645.13201.70408.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, bblanco@plumgrid.com, rana.shahot@gmail.com,
        "David S. Miller" <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36920 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964829AbcIPTrI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 15:47:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The XDP_TX action can fail transmitting the frame in case the TX ring
is full or port is down.  In case of TX failure it should drop the
frame, and not as now call 'break' which is the same as XDP_PASS.

Fixes: 9ecc2d86171a ("net/mlx4_en: add xdp forwarding and data write support")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
Note, this fix have nothing to do with the page-refcnt bug I just reported.

 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 2040dad8611d..d414c67dfd12 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -906,6 +906,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 							length, tx_index,
 							&doorbell_pending))
 					goto consumed;
+				goto next;
 				break;
 			default:
 				bpf_warn_invalid_xdp_action(act);
