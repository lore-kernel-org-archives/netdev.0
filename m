From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 06/17] bnxt: Move GENEVE support from hard-coded
 port to using port notifier
Date: Thu, 16 Jun 2016 12:21:36 -0700
Message-ID: <20160616192136.20872.49824.stgit@localhost.localdomain>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, eugenia@mellanox.com,
	jbenc@redhat.com, alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com,
	davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34973 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543AbcFPTVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 15:21:39 -0400
Received: by mail-pa0-f43.google.com with SMTP id hl6so20712960pac.2
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 12:21:38 -0700 (PDT)
In-Reply-To: <20160616191851.20872.67154.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The port number for GENEVE is hard coded into the bnxt driver.  This is the
kind of thing we want to avoid going forward.  For now I will integrate
this back into the port notifier so that we can change the GENEVE port
number if we need to in the future.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c |   36 ++++++++++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |    3 ++
 2 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 03a5d84198ee..673f4d62e73e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5253,13 +5253,8 @@ static int __bnxt_open_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 			netdev_warn(bp->dev, "failed to update phy settings\n");
 	}
 
-	if (irq_re_init) {
+	if (irq_re_init)
 		udp_tunnel_get_rx_info(bp->dev);
-		if (!bnxt_hwrm_tunnel_dst_port_alloc(
-				bp, htons(0x17c1),
-				TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_GENEVE))
-			bp->nge_port_cnt = 1;
-	}
 
 	set_bit(BNXT_STATE_OPEN, &bp->state);
 	bnxt_enable_int(bp);
@@ -5877,6 +5872,15 @@ static void bnxt_sp_task(struct work_struct *work)
 		bnxt_hwrm_tunnel_dst_port_free(
 			bp, TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_VXLAN);
 	}
+	if (test_and_clear_bit(BNXT_GENEVE_ADD_PORT_SP_EVENT, &bp->sp_event)) {
+		bnxt_hwrm_tunnel_dst_port_alloc(
+			bp, bp->nge_port,
+			TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_GENEVE);
+	}
+	if (test_and_clear_bit(BNXT_GENEVE_DEL_PORT_SP_EVENT, &bp->sp_event)) {
+		bnxt_hwrm_tunnel_dst_port_free(
+			bp, TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_GENEVE);
+	}
 	if (test_and_clear_bit(BNXT_RESET_TASK_SP_EVENT, &bp->sp_event))
 		bnxt_reset(bp, false);
 
@@ -6269,6 +6273,16 @@ static void bnxt_udp_tunnel_add(struct net_device *dev,
 			schedule_work(&bp->sp_task);
 		}
 		break;
+	case UDP_TUNNEL_TYPE_GENEVE:
+		if (bp->nge_port_cnt && bp->nge_port != ti->port)
+			return;
+
+		bp->nge_port_cnt++;
+		if (bp->nge_port_cnt == 1) {
+			bp->nge_port = ti->port;
+			set_bit(BNXT_GENEVE_ADD_PORT_SP_EVENT, &bp->sp_event);
+		}
+		break;
 	default:
 		return;
 	}
@@ -6298,6 +6312,16 @@ static void bnxt_udp_tunnel_del(struct net_device *dev,
 
 		set_bit(BNXT_VXLAN_DEL_PORT_SP_EVENT, &bp->sp_event);
 		break;
+	case UDP_TUNNEL_TYPE_GENEVE:
+		if (!bp->nge_port_cnt || bp->nge_port != ti->port)
+			return;
+		bp->nge_port_cnt--;
+
+		if (bp->nge_port_cnt != 0)
+			return;
+
+		set_bit(BNXT_GENEVE_DEL_PORT_SP_EVENT, &bp->sp_event);
+		break;
 	default:
 		return;
 	}
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 04cc69bb9e6a..927ece9c408a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1049,6 +1049,7 @@ struct bnxt {
 	__be16			vxlan_port;
 	u8			vxlan_port_cnt;
 	__le16			vxlan_fw_dst_port_id;
+	__be16			nge_port;
 	u8			nge_port_cnt;
 	__le16			nge_fw_dst_port_id;
 	u8			port_partition_type;
@@ -1078,6 +1079,8 @@ struct bnxt {
 #define BNXT_PERIODIC_STATS_SP_EVENT	9
 #define BNXT_HWRM_PORT_MODULE_SP_EVENT	10
 #define BNXT_RESET_TASK_SILENT_SP_EVENT	11
+#define BNXT_GENEVE_ADD_PORT_SP_EVENT	12
+#define BNXT_GENEVE_DEL_PORT_SP_EVENT	13
 
 	struct bnxt_pf_info	pf;
 #ifdef CONFIG_BNXT_SRIOV
