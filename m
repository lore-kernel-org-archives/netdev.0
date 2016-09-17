From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net PATCH V3] mlx4: fix XDP_TX is acting like XDP_PASS on TX ring
 full
Date: Sat, 17 Sep 2016 17:48:00 +0200
Message-ID: <20160917154753.3130.16986.stgit@firesoul>
References: <20160917164650.53e68314@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, bblanco@plumgrid.com, rana.shahot@gmail.com,
        "David S. Miller" <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34500 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752257AbcIQPsD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 11:48:03 -0400
In-Reply-To: <20160917164650.53e68314@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The XDP_TX action can fail transmitting the frame in case the TX ring
is full or port is down.  In case of TX failure it should drop the
frame, and not as now call 'break' which is the same as XDP_PASS.

Fixes: 9ecc2d86171a ("net/mlx4_en: add xdp forwarding and data write support")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
Is this goto lable inside a switch case too ugly?
Note, this fix have nothing to do with the page-refcnt bug I reported.

 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 2040dad8611d..9eadda431965 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -906,11 +906,12 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 							length, tx_index,
 							&doorbell_pending))
 					goto consumed;
-				break;
+				goto xdp_drop; /* Drop on xmit failure */
 			default:
 				bpf_warn_invalid_xdp_action(act);
 			case XDP_ABORTED:
 			case XDP_DROP:
+			xdp_drop:
 				if (mlx4_en_rx_recycle(ring, frags))
 					goto consumed;
 				goto next;
