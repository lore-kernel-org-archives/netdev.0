From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/3] mlxsw: spectrum: Fix memory leak at skb reallocation
Date: Thu, 12 Jan 2017 09:10:37 +0100
Message-ID: <1484208639-1890-2-git-send-email-jiri@resnulli.us>
References: <1484208639-1890-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32870 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbdALIKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 03:10:43 -0500
Received: by mail-wm0-f67.google.com with SMTP id r144so1965011wme.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 00:10:42 -0800 (PST)
In-Reply-To: <1484208639-1890-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

During transmission the skb is checked for headroom in order to
add vendor specific header. In case the skb needs to be re-allocated,
skb_realloc_headroom() is called to make a private copy of the original,
but doesn't release it. Current code assumes that the original skb is
released during reallocation and only releases it at the error path
which causes a memory leak.

Fix this by adding the original skb release to the main path.

Fixes: 56ade8fe3fe1 ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index d768c7b..003093a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -684,6 +684,7 @@ static netdev_tx_t mlxsw_sp_port_xmit(struct sk_buff *skb,
 			dev_kfree_skb_any(skb_orig);
 			return NETDEV_TX_OK;
 		}
+		dev_consume_skb_any(skb_orig);
 	}
 
 	if (eth_skb_pad(skb)) {
-- 
2.7.4
