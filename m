From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 3/9] cxgb4: Include TCP as protocol when creating server filters
Date: Mon, 16 Dec 2013 17:42:12 +0530
Message-ID: <1387195938-3531-4-git-send-email-hariprasad@chelsio.com>
References: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, hariprasad@chelsio.com,
	nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14083 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab3LPMUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 07:20:02 -0500
In-Reply-To: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

We were creating LE Workaround Server Filters without specifying
IPPROTO_TCP (6) in the filters (when F_PROTOCOL is set in TP_VLAN_PRI_MAP).
This meant that UDP packets with matching IP Addresses/Ports would get
caught up in the filter and be delivered to ULDs like iw_cxgb4.
So, include the protocol information in the server filter properly.

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 5 +++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    | 4 ++++
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index f1015ee..2cd7098 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4222,6 +4222,11 @@ int cxgb4_create_server_filter(const struct net_device *dev, unsigned int stid,
 		}
 	}
 
+	if (adap->filter_mode & F_PROTOCOL) {
+		f->fs.val.proto = IPPROTO_TCP;
+		f->fs.mask.proto = ~0;
+	}
+
 	f->fs.dirsteer = 1;
 	f->fs.iq = queue;
 	/* Mark filter as locked */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 0a8205d..d3dd218 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1171,6 +1171,10 @@
 
 #define A_TP_TX_SCHED_PCMD 0x25
 
+#define S_PROTOCOL    5
+#define V_PROTOCOL(x) ((x) << S_PROTOCOL)
+#define F_PROTOCOL    V_PROTOCOL(1U)
+
 #define S_PORT    1
 #define V_PORT(x) ((x) << S_PORT)
 #define F_PORT    V_PORT(1U)
-- 
1.8.0
