From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] block/drbd: use nla_put_u64_64bit()
Date: Tue,  3 May 2016 10:50:35 +0200
Message-ID: <1462265435-15141-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20160426121850.GC20950@soda.linbit>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	philipp.reisner@linbit.com, drbd-dev@lists.linbit.com,
	linux-kernel@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: lars.ellenberg@linbit.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160426121850.GC20950@soda.linbit>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I had to define an intermediate function (nla_magic_put_flag()) because
handlers in genl_magic_struct.h expect a function with three arguments.

Note that this patch is only compile-tested.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/block/drbd/drbd_nl.c      | 29 +++++++++++++++++------------
 include/linux/drbd_genl.h         |  1 +
 include/linux/genl_magic_struct.h |  4 ++++
 3 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
index 1fd1dccebb6b..22ec2ede4110 100644
--- a/drivers/block/drbd/drbd_nl.c
+++ b/drivers/block/drbd/drbd_nl.c
@@ -3633,14 +3633,15 @@ static int nla_put_status_info(struct sk_buff *skb, struct drbd_device *device,
 		goto nla_put_failure;
 	if (nla_put_u32(skb, T_sib_reason, sib ? sib->sib_reason : SIB_GET_STATUS_REPLY) ||
 	    nla_put_u32(skb, T_current_state, device->state.i) ||
-	    nla_put_u64(skb, T_ed_uuid, device->ed_uuid) ||
-	    nla_put_u64(skb, T_capacity, drbd_get_capacity(device->this_bdev)) ||
-	    nla_put_u64(skb, T_send_cnt, device->send_cnt) ||
-	    nla_put_u64(skb, T_recv_cnt, device->recv_cnt) ||
-	    nla_put_u64(skb, T_read_cnt, device->read_cnt) ||
-	    nla_put_u64(skb, T_writ_cnt, device->writ_cnt) ||
-	    nla_put_u64(skb, T_al_writ_cnt, device->al_writ_cnt) ||
-	    nla_put_u64(skb, T_bm_writ_cnt, device->bm_writ_cnt) ||
+	    nla_put_u64_64bit(skb, T_ed_uuid, device->ed_uuid, T_pad) ||
+	    nla_put_u64_64bit(skb, T_capacity,
+			      drbd_get_capacity(device->this_bdev), T_pad) ||
+	    nla_put_u64_64bit(skb, T_send_cnt, device->send_cnt, T_pad) ||
+	    nla_put_u64_64bit(skb, T_recv_cnt, device->recv_cnt, T_pad) ||
+	    nla_put_u64_64bit(skb, T_read_cnt, device->read_cnt, T_pad) ||
+	    nla_put_u64_64bit(skb, T_writ_cnt, device->writ_cnt, T_pad) ||
+	    nla_put_u64_64bit(skb, T_al_writ_cnt, device->al_writ_cnt, T_pad) ||
+	    nla_put_u64_64bit(skb, T_bm_writ_cnt, device->bm_writ_cnt, T_pad) ||
 	    nla_put_u32(skb, T_ap_bio_cnt, atomic_read(&device->ap_bio_cnt)) ||
 	    nla_put_u32(skb, T_ap_pending_cnt, atomic_read(&device->ap_pending_cnt)) ||
 	    nla_put_u32(skb, T_rs_pending_cnt, atomic_read(&device->rs_pending_cnt)))
@@ -3657,13 +3658,17 @@ static int nla_put_status_info(struct sk_buff *skb, struct drbd_device *device,
 			goto nla_put_failure;
 
 		if (nla_put_u32(skb, T_disk_flags, device->ldev->md.flags) ||
-		    nla_put_u64(skb, T_bits_total, drbd_bm_bits(device)) ||
-		    nla_put_u64(skb, T_bits_oos, drbd_bm_total_weight(device)))
+		    nla_put_u64_64bit(skb, T_bits_total, drbd_bm_bits(device),
+				      T_pad) ||
+		    nla_put_u64_64bit(skb, T_bits_oos,
+				      drbd_bm_total_weight(device), T_pad))
 			goto nla_put_failure;
 		if (C_SYNC_SOURCE <= device->state.conn &&
 		    C_PAUSED_SYNC_T >= device->state.conn) {
-			if (nla_put_u64(skb, T_bits_rs_total, device->rs_total) ||
-			    nla_put_u64(skb, T_bits_rs_failed, device->rs_failed))
+			if (nla_put_u64_64bit(skb, T_bits_rs_total,
+					      device->rs_total, T_pad) ||
+			    nla_put_u64_64bit(skb, T_bits_rs_failed,
+					      device->rs_failed, T_pad))
 				goto nla_put_failure;
 		}
 	}
diff --git a/include/linux/drbd_genl.h b/include/linux/drbd_genl.h
index 2d0e5ad5de9d..8d327d8fbbc2 100644
--- a/include/linux/drbd_genl.h
+++ b/include/linux/drbd_genl.h
@@ -227,6 +227,7 @@ GENL_struct(DRBD_NLA_STATE_INFO, 8, state_info,
 	__u32_field(21,                      0, ap_bio_cnt)
 	__u32_field(22,                      0, ap_pending_cnt)
 	__u32_field(23,                      0, rs_pending_cnt)
+	__unspec_field(24,                   0, pad)
 )
 
 GENL_struct(DRBD_NLA_START_OV_PARMS, 9, start_ov_parms,
diff --git a/include/linux/genl_magic_struct.h b/include/linux/genl_magic_struct.h
index eecd19b37001..fde46be8fc40 100644
--- a/include/linux/genl_magic_struct.h
+++ b/include/linux/genl_magic_struct.h
@@ -61,11 +61,15 @@ extern void CONCAT_(GENL_MAGIC_FAMILY, _genl_unregister)(void);
  */
 
 /* MAGIC helpers							{{{2 */
+#define nla_magic_put_flag(skb, attr, val) nla_put_flag(skb, attr)
 
 /* possible field types */
 #define __flg_field(attr_nr, attr_flag, name) \
 	__field(attr_nr, attr_flag, name, NLA_U8, char, \
 			nla_get_u8, nla_put_u8, false)
+#define __unspec_field(attr_nr, attr_flag, name)	\
+	__field(attr_nr, attr_flag, name, NLA_UNSPEC, unsigned char, \
+			nla_get_flag, nla_magic_put_flag, false)
 #define __u8_field(attr_nr, attr_flag, name)	\
 	__field(attr_nr, attr_flag, name, NLA_U8, unsigned char, \
 			nla_get_u8, nla_put_u8, false)
-- 
2.8.1
