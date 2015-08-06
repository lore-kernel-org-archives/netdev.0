From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/7] mlxsw: Fix use-after-free bug in mlxsw_sx_port_xmit
Date: Thu,  6 Aug 2015 16:41:58 +0200
Message-ID: <1438872118-16869-8-git-send-email-jiri@resnulli.us>
References: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:38329 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754755AbbHFOmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 10:42:20 -0400
Received: by wibxm9 with SMTP id xm9so27421228wib.1
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 07:42:19 -0700 (PDT)
In-Reply-To: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Store the length of the skb before transmitting it and use it for stats
instead of skb->len, since skb might have been freed already.

This issue was discovered using the Kernel Address sanitizer (KASan).

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index fce9b45..3e52ee9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -300,6 +300,7 @@ static netdev_tx_t mlxsw_sx_port_xmit(struct sk_buff *skb,
 		.local_port = mlxsw_sx_port->local_port,
 		.is_emad = false,
 	};
+	u64 len;
 	int err;
 
 	if (mlxsw_core_skb_transmit_busy(mlxsw_sx, &tx_info))
@@ -316,6 +317,7 @@ static netdev_tx_t mlxsw_sx_port_xmit(struct sk_buff *skb,
 		}
 	}
 	mlxsw_sx_txhdr_construct(skb, &tx_info);
+	len = skb->len;
 	/* Due to a race we might fail here because of a full queue. In that
 	 * unlikely case we simply drop the packet.
 	 */
@@ -325,7 +327,7 @@ static netdev_tx_t mlxsw_sx_port_xmit(struct sk_buff *skb,
 		pcpu_stats = this_cpu_ptr(mlxsw_sx_port->pcpu_stats);
 		u64_stats_update_begin(&pcpu_stats->syncp);
 		pcpu_stats->tx_packets++;
-		pcpu_stats->tx_bytes += skb->len;
+		pcpu_stats->tx_bytes += len;
 		u64_stats_update_end(&pcpu_stats->syncp);
 	} else {
 		this_cpu_inc(mlxsw_sx_port->pcpu_stats->tx_dropped);
-- 
1.9.3
