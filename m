From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/3] mlxsw: switchx2: Fix memory leak at skb reallocation
Date: Thu, 12 Jan 2017 09:10:38 +0100
Message-ID: <1484208639-1890-3-git-send-email-jiri@resnulli.us>
References: <1484208639-1890-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34072 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751026AbdALIKo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 03:10:44 -0500
Received: by mail-wm0-f68.google.com with SMTP id c85so1949862wmi.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 00:10:43 -0800 (PST)
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

Fixes: d003462a50de ("mlxsw: Simplify mlxsw_sx_port_xmit function")
Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 150ccf5..2e88115e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -345,6 +345,7 @@ static netdev_tx_t mlxsw_sx_port_xmit(struct sk_buff *skb,
 			dev_kfree_skb_any(skb_orig);
 			return NETDEV_TX_OK;
 		}
+		dev_consume_skb_any(skb_orig);
 	}
 	mlxsw_sx_txhdr_construct(skb, &tx_info);
 	/* TX header is consumed by HW on the way so we shouldn't count its
-- 
2.7.4
