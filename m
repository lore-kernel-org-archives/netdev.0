From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2] block/drbd: use nla_put_u64_64bit()
Date: Tue,  3 May 2016 11:39:18 +0200
Message-ID: <1462268358-19044-1-git-send-email-nicolas.dichtel@6wind.com>
References: <57286F49.8050107@6wind.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	philipp.reisner@linbit.com, drbd-dev@lists.linbit.com,
	linux-kernel@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: lars.ellenberg@linbit.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57286F49.8050107@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two new handlers have been defined in genl_magic_ headers:
 - __field2: the corresponding nla_put() function (nla_put_flag()) takes
             only two args
 - __field4: the corresponding nla_put() function (nla_put_u64_64bit())
             takes four args

__field2 allows us to define __unspec_field for padding attribute.
__field4 allows us to update the definition of __u64_field: the pad
attribute should now be specified.

Note that this patch is only compile-tested.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v1 -> v2:
 rework the patch to handle all cases

 drivers/block/drbd/drbd_nl.c      | 40 +++++++++++++++++--------
 include/linux/drbd_genl.h         | 62 +++++++++++++++++++++------------------
 include/linux/genl_magic_func.h   | 41 ++++++++++++++++++++++++++
 include/linux/genl_magic_struct.h | 45 ++++++++++++++++++++++++++--
 4 files changed, 145 insertions(+), 43 deletions(-)

diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
index 1fd1dccebb6b..93d873532195 100644
--- a/drivers/block/drbd/drbd_nl.c
+++ b/drivers/block/drbd/drbd_nl.c
@@ -3633,14 +3633,23 @@ static int nla_put_status_info(struct sk_buff *skb, struct drbd_device *device,
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
+	    nla_put_u64_64bit(skb, T_ed_uuid, device->ed_uuid,
+			      T_state_info_pad) ||
+	    nla_put_u64_64bit(skb, T_capacity,
+			      drbd_get_capacity(device->this_bdev),
+			      T_state_info_pad) ||
+	    nla_put_u64_64bit(skb, T_send_cnt, device->send_cnt,
+			      T_state_info_pad) ||
+	    nla_put_u64_64bit(skb, T_recv_cnt, device->recv_cnt,
+			      T_state_info_pad) ||
+	    nla_put_u64_64bit(skb, T_read_cnt, device->read_cnt,
+			      T_state_info_pad) ||
+	    nla_put_u64_64bit(skb, T_writ_cnt, device->writ_cnt,
+			      T_state_info_pad) ||
+	    nla_put_u64_64bit(skb, T_al_writ_cnt, device->al_writ_cnt,
+			      T_state_info_pad) ||
+	    nla_put_u64_64bit(skb, T_bm_writ_cnt, device->bm_writ_cnt,
+			      T_state_info_pad) ||
 	    nla_put_u32(skb, T_ap_bio_cnt, atomic_read(&device->ap_bio_cnt)) ||
 	    nla_put_u32(skb, T_ap_pending_cnt, atomic_read(&device->ap_pending_cnt)) ||
 	    nla_put_u32(skb, T_rs_pending_cnt, atomic_read(&device->rs_pending_cnt)))
@@ -3657,13 +3666,20 @@ static int nla_put_status_info(struct sk_buff *skb, struct drbd_device *device,
 			goto nla_put_failure;
 
 		if (nla_put_u32(skb, T_disk_flags, device->ldev->md.flags) ||
-		    nla_put_u64(skb, T_bits_total, drbd_bm_bits(device)) ||
-		    nla_put_u64(skb, T_bits_oos, drbd_bm_total_weight(device)))
+		    nla_put_u64_64bit(skb, T_bits_total, drbd_bm_bits(device),
+				      T_state_info_pad) ||
+		    nla_put_u64_64bit(skb, T_bits_oos,
+				      drbd_bm_total_weight(device),
+				      T_state_info_pad))
 			goto nla_put_failure;
 		if (C_SYNC_SOURCE <= device->state.conn &&
 		    C_PAUSED_SYNC_T >= device->state.conn) {
-			if (nla_put_u64(skb, T_bits_rs_total, device->rs_total) ||
-			    nla_put_u64(skb, T_bits_rs_failed, device->rs_failed))
+			if (nla_put_u64_64bit(skb, T_bits_rs_total,
+					      device->rs_total,
+					      T_state_info_pad) ||
+			    nla_put_u64_64bit(skb, T_bits_rs_failed,
+					      device->rs_failed,
+					      T_state_info_pad))
 				goto nla_put_failure;
 		}
 	}
diff --git a/include/linux/drbd_genl.h b/include/linux/drbd_genl.h
index 2d0e5ad5de9d..f3b810089142 100644
--- a/include/linux/drbd_genl.h
+++ b/include/linux/drbd_genl.h
@@ -107,7 +107,7 @@ GENL_struct(DRBD_NLA_DISK_CONF, 3, disk_conf,
 	__s32_field(3, DRBD_F_REQUIRED | DRBD_F_INVARIANT,	meta_dev_idx)
 
 	/* use the resize command to try and change the disk_size */
-	__u64_field(4, DRBD_GENLA_F_MANDATORY | DRBD_F_INVARIANT,	disk_size)
+	__u64_field(4, DRBD_GENLA_F_MANDATORY | DRBD_F_INVARIANT,	disk_size, 24)
 	/* we could change the max_bio_bvecs,
 	 * but it won't propagate through the stack */
 	__u32_field(5, DRBD_GENLA_F_MANDATORY | DRBD_F_INVARIANT,	max_bio_bvecs)
@@ -132,6 +132,7 @@ GENL_struct(DRBD_NLA_DISK_CONF, 3, disk_conf,
 	__u32_field_def(21,	0 /* OPTIONAL */,       read_balancing, DRBD_READ_BALANCING_DEF)
 	/* 9: __u32_field_def(22,	DRBD_GENLA_F_MANDATORY,	unplug_watermark, DRBD_UNPLUG_WATERMARK_DEF) */
 	__flg_field_def(23,     0 /* OPTIONAL */,	al_updates, DRBD_AL_UPDATES_DEF)
+	__unspec_field(24,	0		,	disk_conf_pad)
 )
 
 GENL_struct(DRBD_NLA_RESOURCE_OPTS, 4, res_opts,
@@ -182,11 +183,12 @@ GENL_struct(DRBD_NLA_SET_ROLE_PARMS, 6, set_role_parms,
 )
 
 GENL_struct(DRBD_NLA_RESIZE_PARMS, 7, resize_parms,
-	__u64_field(1, DRBD_GENLA_F_MANDATORY,	resize_size)
+	__u64_field(1, DRBD_GENLA_F_MANDATORY,	resize_size, 6)
 	__flg_field(2, DRBD_GENLA_F_MANDATORY,	resize_force)
 	__flg_field(3, DRBD_GENLA_F_MANDATORY,	no_resync)
 	__u32_field_def(4, 0 /* OPTIONAL */, al_stripes, DRBD_AL_STRIPES_DEF)
 	__u32_field_def(5, 0 /* OPTIONAL */, al_stripe_size, DRBD_AL_STRIPE_SIZE_DEF)
+	__unspec_field(6, 0, resize_parms_pad)
 )
 
 GENL_struct(DRBD_NLA_STATE_INFO, 8, state_info,
@@ -194,8 +196,8 @@ GENL_struct(DRBD_NLA_STATE_INFO, 8, state_info,
 	 * if this is an event triggered broadcast. */
 	__u32_field(1, DRBD_GENLA_F_MANDATORY,	sib_reason)
 	__u32_field(2, DRBD_F_REQUIRED,	current_state)
-	__u64_field(3, DRBD_GENLA_F_MANDATORY,	capacity)
-	__u64_field(4, DRBD_GENLA_F_MANDATORY,	ed_uuid)
+	__u64_field(3, DRBD_GENLA_F_MANDATORY,	capacity, 24)
+	__u64_field(4, DRBD_GENLA_F_MANDATORY,	ed_uuid, 24)
 
 	/* These are for broadcast from after state change work.
 	 * prev_state and new_state are from the moment the state change took
@@ -208,30 +210,32 @@ GENL_struct(DRBD_NLA_STATE_INFO, 8, state_info,
 	/* if we have a local disk: */
 	__bin_field(7, DRBD_GENLA_F_MANDATORY,	uuids, (UI_SIZE*sizeof(__u64)))
 	__u32_field(8, DRBD_GENLA_F_MANDATORY,	disk_flags)
-	__u64_field(9, DRBD_GENLA_F_MANDATORY,	bits_total)
-	__u64_field(10, DRBD_GENLA_F_MANDATORY,	bits_oos)
+	__u64_field(9, DRBD_GENLA_F_MANDATORY,	bits_total, 24)
+	__u64_field(10, DRBD_GENLA_F_MANDATORY,	bits_oos, 24)
 	/* and in case resync or online verify is active */
-	__u64_field(11, DRBD_GENLA_F_MANDATORY,	bits_rs_total)
-	__u64_field(12, DRBD_GENLA_F_MANDATORY,	bits_rs_failed)
+	__u64_field(11, DRBD_GENLA_F_MANDATORY,	bits_rs_total, 24)
+	__u64_field(12, DRBD_GENLA_F_MANDATORY,	bits_rs_failed, 24)
 
 	/* for pre and post notifications of helper execution */
 	__str_field(13, DRBD_GENLA_F_MANDATORY,	helper, 32)
 	__u32_field(14, DRBD_GENLA_F_MANDATORY,	helper_exit_code)
 
-	__u64_field(15,                      0, send_cnt)
-	__u64_field(16,                      0, recv_cnt)
-	__u64_field(17,                      0, read_cnt)
-	__u64_field(18,                      0, writ_cnt)
-	__u64_field(19,                      0, al_writ_cnt)
-	__u64_field(20,                      0, bm_writ_cnt)
+	__u64_field(15,                      0, send_cnt, 24)
+	__u64_field(16,                      0, recv_cnt, 24)
+	__u64_field(17,                      0, read_cnt, 24)
+	__u64_field(18,                      0, writ_cnt, 24)
+	__u64_field(19,                      0, al_writ_cnt, 24)
+	__u64_field(20,                      0, bm_writ_cnt, 24)
 	__u32_field(21,                      0, ap_bio_cnt)
 	__u32_field(22,                      0, ap_pending_cnt)
 	__u32_field(23,                      0, rs_pending_cnt)
+	__unspec_field(24,                   0, state_info_pad)
 )
 
 GENL_struct(DRBD_NLA_START_OV_PARMS, 9, start_ov_parms,
-	__u64_field(1, DRBD_GENLA_F_MANDATORY,	ov_start_sector)
-	__u64_field(2, DRBD_GENLA_F_MANDATORY,	ov_stop_sector)
+	__u64_field(1, DRBD_GENLA_F_MANDATORY,	ov_start_sector, 3)
+	__u64_field(2, DRBD_GENLA_F_MANDATORY,	ov_stop_sector, 3)
+	__unspec_field(3, 0, ov_pad)
 )
 
 GENL_struct(DRBD_NLA_NEW_C_UUID_PARMS, 10, new_c_uuid_parms,
@@ -280,20 +284,21 @@ GENL_struct(DRBD_NLA_RESOURCE_STATISTICS, 19, resource_statistics,
 )
 
 GENL_struct(DRBD_NLA_DEVICE_STATISTICS, 20, device_statistics,
-	__u64_field(1, 0, dev_size)  /* (sectors) */
-	__u64_field(2, 0, dev_read)  /* (sectors) */
-	__u64_field(3, 0, dev_write)  /* (sectors) */
-	__u64_field(4, 0, dev_al_writes)  /* activity log writes (count) */
-	__u64_field(5, 0, dev_bm_writes)  /*  bitmap writes  (count) */
+	__u64_field(1, 0, dev_size, 15)  /* (sectors) */
+	__u64_field(2, 0, dev_read, 15)  /* (sectors) */
+	__u64_field(3, 0, dev_write, 15)  /* (sectors) */
+	__u64_field(4, 0, dev_al_writes, 15)  /* activity log writes (count) */
+	__u64_field(5, 0, dev_bm_writes, 15)  /*  bitmap writes  (count) */
 	__u32_field(6, 0, dev_upper_pending)  /* application requests in progress */
 	__u32_field(7, 0, dev_lower_pending)  /* backing device requests in progress */
 	__flg_field(8, 0, dev_upper_blocked)
 	__flg_field(9, 0, dev_lower_blocked)
 	__flg_field(10, 0, dev_al_suspended)  /* activity log suspended */
-	__u64_field(11, 0, dev_exposed_data_uuid)
-	__u64_field(12, 0, dev_current_uuid)
+	__u64_field(11, 0, dev_exposed_data_uuid, 15)
+	__u64_field(12, 0, dev_current_uuid, 15)
 	__u32_field(13, 0, dev_disk_flags)
 	__bin_field(14, 0, history_uuids, HISTORY_UUIDS * sizeof(__u64))
+	__unspec_field(15, 0, dev_pad)
 )
 
 GENL_struct(DRBD_NLA_CONNECTION_STATISTICS, 21, connection_statistics,
@@ -301,14 +306,15 @@ GENL_struct(DRBD_NLA_CONNECTION_STATISTICS, 21, connection_statistics,
 )
 
 GENL_struct(DRBD_NLA_PEER_DEVICE_STATISTICS, 22, peer_device_statistics,
-	__u64_field(1, 0, peer_dev_received)  /* sectors */
-	__u64_field(2, 0, peer_dev_sent)  /* sectors */
+	__u64_field(1, 0, peer_dev_received, 10)  /* sectors */
+	__u64_field(2, 0, peer_dev_sent, 10)  /* sectors */
 	__u32_field(3, 0, peer_dev_pending)  /* number of requests */
 	__u32_field(4, 0, peer_dev_unacked)  /* number of requests */
-	__u64_field(5, 0, peer_dev_out_of_sync)  /* sectors */
-	__u64_field(6, 0, peer_dev_resync_failed)  /* sectors */
-	__u64_field(7, 0, peer_dev_bitmap_uuid)
+	__u64_field(5, 0, peer_dev_out_of_sync, 10)  /* sectors */
+	__u64_field(6, 0, peer_dev_resync_failed, 10)  /* sectors */
+	__u64_field(7, 0, peer_dev_bitmap_uuid, 10)
 	__u32_field(9, 0, peer_dev_flags)
+	__unspec_field(10, 0, peer_dev_pad)
 )
 
 GENL_struct(DRBD_NLA_NOTIFICATION_HEADER, 23, drbd_notification_header,
diff --git a/include/linux/genl_magic_func.h b/include/linux/genl_magic_func.h
index 667c31101b8b..34b12f0836a5 100644
--- a/include/linux/genl_magic_func.h
+++ b/include/linux/genl_magic_func.h
@@ -35,6 +35,15 @@ static struct nla_policy s_name ## _nl_policy[] __read_mostly =		\
 		 __put, __is_signed)					\
 	[attr_nr] = { .type = nla_type },
 
+#undef __field2
+#define __field2 __field
+
+#undef __field4
+#define __field4(attr_nr, attr_flag, name, nla_type, _type, __get,	\
+		 __put, __is_signed, padattr)				\
+	__field(attr_nr, attr_flag, name, nla_type, _type, __get,       \
+		__put, __is_signed)
+
 #undef __array
 #define __array(attr_nr, attr_flag, name, nla_type, _type, maxlen,	\
 		__get, __put, __is_signed)				\
@@ -199,6 +208,15 @@ static int s_name ## _from_attrs_for_change(struct s_name *s,		\
 				s->name = __get(nla);			\
 			DPRINT_FIELD("<<", nla_type, name, s, nla))
 
+#undef __field2
+#define __field2 __field
+
+#undef __field4
+#define __field4(attr_nr, attr_flag, name, nla_type, _type, __get,	\
+		 __put, __is_signed, padattr)				\
+	__field(attr_nr, attr_flag, name, nla_type, _type, __get,       \
+		__put, __is_signed)
+
 /* validate_nla() already checked nla_len <= maxlen appropriately. */
 #undef __array
 #define __array(attr_nr, attr_flag, name, nla_type, type, maxlen,	\
@@ -362,6 +380,24 @@ static inline int s_name ## _to_unpriv_skb(struct sk_buff *skb,		\
 			goto nla_put_failure;				\
 	}
 
+#undef __field2
+#define __field2(attr_nr, attr_flag, name, nla_type, type, __get, __put,\
+		 __is_signed)						\
+	if (!exclude_sensitive || !((attr_flag) & DRBD_F_SENSITIVE)) {	\
+		DPRINT_FIELD(">>", nla_type, name, s, NULL);		\
+		if (__put(skb, attr_nr))				\
+			goto nla_put_failure;				\
+	}
+
+#undef __field4
+#define __field4(attr_nr, attr_flag, name, nla_type, type, __get, __put,\
+		 __is_signed, padattr)					\
+	if (!exclude_sensitive || !((attr_flag) & DRBD_F_SENSITIVE)) {	\
+		DPRINT_FIELD(">>", nla_type, name, s, NULL);		\
+		if (__put(skb, attr_nr, s->name, padattr))		\
+			goto nla_put_failure;				\
+	}
+
 #undef __array
 #define __array(attr_nr, attr_flag, name, nla_type, type, maxlen,	\
 		__get, __put, __is_signed)				\
@@ -381,6 +417,11 @@ static inline int s_name ## _to_unpriv_skb(struct sk_buff *skb,		\
 #undef __field
 #define __field(attr_nr, attr_flag, name, nla_type, type, __get, __put,	\
 		__is_signed)
+#undef __field2
+#define __field2 __field
+#undef __field4
+#define __field4(attr_nr, attr_flag, name, nla_type, type, __get, __put,\
+		__is_signed, padattr)
 #undef __array
 #define __array(attr_nr, attr_flag, name, nla_type, type, maxlen,	\
 		__get, __put, __is_signed)
diff --git a/include/linux/genl_magic_struct.h b/include/linux/genl_magic_struct.h
index eecd19b37001..768e63406540 100644
--- a/include/linux/genl_magic_struct.h
+++ b/include/linux/genl_magic_struct.h
@@ -66,6 +66,9 @@ extern void CONCAT_(GENL_MAGIC_FAMILY, _genl_unregister)(void);
 #define __flg_field(attr_nr, attr_flag, name) \
 	__field(attr_nr, attr_flag, name, NLA_U8, char, \
 			nla_get_u8, nla_put_u8, false)
+#define __unspec_field(attr_nr, attr_flag, name)	\
+	__field2(attr_nr, attr_flag, name, NLA_UNSPEC, unsigned char, \
+			nla_get_flag, nla_put_flag, false)
 #define __u8_field(attr_nr, attr_flag, name)	\
 	__field(attr_nr, attr_flag, name, NLA_U8, unsigned char, \
 			nla_get_u8, nla_put_u8, false)
@@ -78,9 +81,9 @@ extern void CONCAT_(GENL_MAGIC_FAMILY, _genl_unregister)(void);
 #define __s32_field(attr_nr, attr_flag, name)	\
 	__field(attr_nr, attr_flag, name, NLA_U32, __s32, \
 			nla_get_u32, nla_put_u32, true)
-#define __u64_field(attr_nr, attr_flag, name)	\
-	__field(attr_nr, attr_flag, name, NLA_U64, __u64, \
-			nla_get_u64, nla_put_u64, false)
+#define __u64_field(attr_nr, attr_flag, name, padattr)	\
+	__field4(attr_nr, attr_flag, name, NLA_U64, __u64, \
+			nla_get_u64, nla_put_u64_64bit, false, padattr)
 #define __str_field(attr_nr, attr_flag, name, maxlen) \
 	__array(attr_nr, attr_flag, name, NLA_NUL_STRING, char, maxlen, \
 			nla_strlcpy, nla_put, false)
@@ -156,6 +159,15 @@ enum {								\
 		__get, __put, __is_signed)			\
 	T_ ## name = (__u16)(attr_nr | ((attr_flag) & DRBD_GENLA_F_MANDATORY)),
 
+#undef __field2
+#define __field2 __field
+
+#undef __field4
+#define __field4(attr_nr, attr_flag, name, nla_type, _type, __get,	\
+		 __put, __is_signed, padattr)				\
+	__field(attr_nr, attr_flag, name, nla_type, _type, __get,       \
+		__put, __is_signed)
+
 #undef __array
 #define __array(attr_nr, attr_flag, name, nla_type, type,	\
 		maxlen, __get, __put, __is_signed)		\
@@ -222,6 +234,15 @@ static inline void ct_assert_unique_ ## s_name ## _attributes(void)	\
 		__is_signed)						\
 	case attr_nr:
 
+#undef __field2
+#define __field2 __field
+
+#undef __field4
+#define __field4(attr_nr, attr_flag, name, nla_type, _type, __get,	\
+		 __put, __is_signed, padattr)				\
+	__field(attr_nr, attr_flag, name, nla_type, _type, __get,       \
+		__put, __is_signed)
+
 #undef __array
 #define __array(attr_nr, attr_flag, name, nla_type, type, maxlen,	\
 		__get, __put, __is_signed)				\
@@ -246,6 +267,15 @@ struct s_name { s_fields };
 		__is_signed)						\
 	type name;
 
+#undef __field2
+#define __field2 __field
+
+#undef __field4
+#define __field4(attr_nr, attr_flag, name, nla_type, _type, __get,	\
+		 __put, __is_signed, padattr)				\
+	__field(attr_nr, attr_flag, name, nla_type, _type, __get,       \
+		__put, __is_signed)
+
 #undef __array
 #define __array(attr_nr, attr_flag, name, nla_type, type, maxlen,	\
 		__get, __put, __is_signed)				\
@@ -265,6 +295,15 @@ enum {									\
 		is_signed)						\
 	F_ ## name ## _IS_SIGNED = is_signed,
 
+#undef __field2
+#define __field2 __field
+
+#undef __field4
+#define __field4(attr_nr, attr_flag, name, nla_type, _type, __get,	\
+		 __put, __is_signed, padattr)				\
+	__field(attr_nr, attr_flag, name, nla_type, _type, __get,       \
+		__put, __is_signed)
+
 #undef __array
 #define __array(attr_nr, attr_flag, name, nla_type, type, maxlen,	\
 		__get, __put, is_signed)				\
-- 
2.8.1
