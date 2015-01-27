From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 01/11] net/mlx4_core: Add bad-cable event support
Date: Tue, 27 Jan 2015 15:57:59 +0200
Message-ID: <1422367089-13419-2-git-send-email-amirv@mellanox.com>
References: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46344 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757937AbbA0N7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 08:59:14 -0500
In-Reply-To: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

If the firmware can detect a bad cable, allow it to generate an
event, and print the problem in the log.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c | 22 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.c |  9 ++++++++-
 include/linux/mlx4/device.h             | 14 +++++++++++++-
 3 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 2f2e606..4df006d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -88,6 +88,8 @@ static u64 get_async_ev_mask(struct mlx4_dev *dev)
 	u64 async_ev_mask = MLX4_ASYNC_EVENT_MASK;
 	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_PORT_MNG_CHG_EV)
 		async_ev_mask |= (1ull << MLX4_EVENT_TYPE_PORT_MNG_CHG_EVENT);
+	if (dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RECOVERABLE_ERROR_EVENT)
+		async_ev_mask |= (1ull << MLX4_EVENT_TYPE_RECOVERABLE_ERROR_EVENT);
 
 	return async_ev_mask;
 }
@@ -736,6 +738,26 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 					    (unsigned long) eqe);
 			break;
 
+		case MLX4_EVENT_TYPE_RECOVERABLE_ERROR_EVENT:
+			switch (eqe->subtype) {
+			case MLX4_RECOVERABLE_ERROR_EVENT_SUBTYPE_BAD_CABLE:
+				mlx4_warn(dev, "Bad cable detected on port %u\n",
+					  eqe->event.bad_cable.port);
+				break;
+			case MLX4_RECOVERABLE_ERROR_EVENT_SUBTYPE_UNSUPPORTED_CABLE:
+				mlx4_warn(dev, "Unsupported cable detected\n");
+				break;
+			default:
+				mlx4_dbg(dev,
+					 "Unhandled recoverable error event detected: %02x(%02x) on EQ %d at index %u. owner=%x, nent=0x%x, ownership=%s\n",
+					 eqe->type, eqe->subtype, eq->eqn,
+					 eq->cons_index, eqe->owner, eq->nent,
+					 !!(eqe->owner & 0x80) ^
+					 !!(eq->cons_index & eq->nent) ? "HW" : "SW");
+				break;
+			}
+			break;
+
 		case MLX4_EVENT_TYPE_EEC_CATAS_ERROR:
 		case MLX4_EVENT_TYPE_ECC_DETECT:
 		default:
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 982861d..2eadc28 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -145,7 +145,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[16] = "CONFIG DEV support",
 		[17] = "Asymmetric EQs support",
 		[18] = "More than 80 VFs support",
-		[19] = "Performance optimized for limited rule configuration flow steering support"
+		[19] = "Performance optimized for limited rule configuration flow steering support",
+		[20] = "Recoverable error events support"
 	};
 	int i;
 
@@ -859,6 +860,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	MLX4_GET(field32, outbox, QUERY_DEV_CAP_ETH_BACKPL_OFFSET);
 	if (field32 & (1 << 0))
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_ETH_BACKPL_AN_REP;
+	if (field32 & (1 << 7))
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_RECOVERABLE_ERROR_EVENT;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_FW_REASSIGN_MAC);
 	if (field & 1<<6)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_REASSIGN_MAC_EN;
@@ -1562,6 +1565,7 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 #define INIT_HCA_VXLAN_OFFSET		 0x0c
 #define INIT_HCA_CACHELINE_SZ_OFFSET	 0x0e
 #define INIT_HCA_FLAGS_OFFSET		 0x014
+#define INIT_HCA_RECOVERABLE_ERROR_EVENT_OFFSET 0x018
 #define INIT_HCA_QPC_OFFSET		 0x020
 #define	 INIT_HCA_QPC_BASE_OFFSET	 (INIT_HCA_QPC_OFFSET + 0x10)
 #define	 INIT_HCA_LOG_QP_OFFSET		 (INIT_HCA_QPC_OFFSET + 0x17)
@@ -1668,6 +1672,9 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 		dev->caps.userspace_caps |= MLX4_USER_DEV_CAP_LARGE_CQE;
 	}
 
+	if (dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RECOVERABLE_ERROR_EVENT)
+		*(inbox + INIT_HCA_RECOVERABLE_ERROR_EVENT_OFFSET / 4) |= cpu_to_be32(1 << 31);
+
 	/* QPC/EEC/CQC/EQC/RDMARC attributes */
 
 	MLX4_PUT(inbox, param->qpc_base,      INIT_HCA_QPC_BASE_OFFSET);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 5ef54e1..c95d659 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -200,7 +200,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_CONFIG_DEV		= 1LL <<  16,
 	MLX4_DEV_CAP_FLAG2_SYS_EQS		= 1LL <<  17,
 	MLX4_DEV_CAP_FLAG2_80_VFS		= 1LL <<  18,
-	MLX4_DEV_CAP_FLAG2_FS_A0		= 1LL <<  19
+	MLX4_DEV_CAP_FLAG2_FS_A0		= 1LL <<  19,
+	MLX4_DEV_CAP_FLAG2_RECOVERABLE_ERROR_EVENT = 1LL << 20
 };
 
 enum {
@@ -280,6 +281,7 @@ enum mlx4_event {
 	MLX4_EVENT_TYPE_FATAL_WARNING	   = 0x1b,
 	MLX4_EVENT_TYPE_FLR_EVENT	   = 0x1c,
 	MLX4_EVENT_TYPE_PORT_MNG_CHG_EVENT = 0x1d,
+	MLX4_EVENT_TYPE_RECOVERABLE_ERROR_EVENT  = 0x3e,
 	MLX4_EVENT_TYPE_NONE		   = 0xff,
 };
 
@@ -289,6 +291,11 @@ enum {
 };
 
 enum {
+	MLX4_RECOVERABLE_ERROR_EVENT_SUBTYPE_BAD_CABLE		= 1,
+	MLX4_RECOVERABLE_ERROR_EVENT_SUBTYPE_UNSUPPORTED_CABLE	= 2,
+};
+
+enum {
 	MLX4_FATAL_WARNING_SUBTYPE_WARMING = 0,
 };
 
@@ -860,6 +867,11 @@ struct mlx4_eqe {
 				} __packed tbl_change_info;
 			} params;
 		} __packed port_mgmt_change;
+		struct {
+			u8 reserved[3];
+			u8 port;
+			u32 reserved1[5];
+		} __packed bad_cable;
 	}			event;
 	u8			slave_id;
 	u8			reserved3[2];
-- 
1.9.3
