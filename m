From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 2/2] cxgb4i : Call into recently added cxgb4 ipv6 api
Date: Tue, 13 Jan 2015 18:28:36 -0800
Message-ID: <1421202516-13862-3-git-send-email-anish@chelsio.com>
References: <1421202516-13862-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, kxie@chelsio.com,
	deepak.s@chelsio.com, Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27159 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752186AbbANC2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 21:28:48 -0500
In-Reply-To: <1421202516-13862-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get a reference on every ipv6 address we offload to hardware so that it cannot
be prematurely cleared out before cleanup or when still in use.

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 37d7191a3c38..dd00e5fe4a5e 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -28,6 +28,7 @@
 #include "t4fw_api.h"
 #include "l2t.h"
 #include "cxgb4i.h"
+#include "clip_tbl.h"
 
 static unsigned int dbg_level;
 
@@ -1322,6 +1323,9 @@ static inline void l2t_put(struct cxgbi_sock *csk)
 static void release_offload_resources(struct cxgbi_sock *csk)
 {
 	struct cxgb4_lld_info *lldi;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct net_device *ndev = csk->cdev->ports[csk->port_id];
+#endif
 
 	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
 		"csk 0x%p,%u,0x%lx,%u.\n",
@@ -1334,6 +1338,12 @@ static void release_offload_resources(struct cxgbi_sock *csk)
 	}
 
 	l2t_put(csk);
+#if IS_ENABLED(CONFIG_IPV6)
+	if (csk->csk_family == AF_INET6)
+		cxgb4_clip_release(ndev,
+				   (const u32 *)&csk->saddr6.sin6_addr, 1);
+#endif
+
 	if (cxgbi_sock_flag(csk, CTPF_HAS_ATID))
 		free_atid(csk);
 	else if (cxgbi_sock_flag(csk, CTPF_HAS_TID)) {
@@ -1391,10 +1401,15 @@ static int init_act_open(struct cxgbi_sock *csk)
 	csk->l2t = cxgb4_l2t_get(lldi->l2t, n, ndev, 0);
 	if (!csk->l2t) {
 		pr_err("%s, cannot alloc l2t.\n", ndev->name);
-		goto rel_resource;
+		goto rel_resource_without_clip;
 	}
 	cxgbi_sock_get(csk);
 
+#if IS_ENABLED(CONFIG_IPV6)
+	if (csk->csk_family == AF_INET6)
+		cxgb4_clip_get(ndev, (const u32 *)&csk->saddr6.sin6_addr, 1);
+#endif
+
 	if (t4) {
 		size = sizeof(struct cpl_act_open_req);
 		size6 = sizeof(struct cpl_act_open_req6);
@@ -1451,6 +1466,12 @@ static int init_act_open(struct cxgbi_sock *csk)
 	return 0;
 
 rel_resource:
+#if IS_ENABLED(CONFIG_IPV6)
+	if (csk->csk_family == AF_INET6)
+		cxgb4_clip_release(ndev,
+				   (const u32 *)&csk->saddr6.sin6_addr, 1);
+#endif
+rel_resource_without_clip:
 	if (n)
 		neigh_release(n);
 	if (skb)
-- 
2.2.1
