From: Lars Ellenberg <lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v2] block/drbd: use
	nla_put_u64_64bit()
Date: Tue, 3 May 2016 12:06:44 +0200
Message-ID: <20160503100644.GE16459@soda.linbit>
References: <57286F49.8050107@6wind.com>
	<1462268358-19044-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org
To: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Return-path: <drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1462268358-19044-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://lists.linbit.com/mailman/options/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linbit.com/pipermail/drbd-dev>
List-Post: <mailto:drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
List-Help: <mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=help>
List-Subscribe: <http://lists.linbit.com/mailman/listinfo/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=subscribe>
Sender: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
Errors-To: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 03, 2016 at 11:39:18AM +0200, Nicolas Dichtel wrote:
> Two new handlers have been defined in genl_magic_ headers:
>  - __field2: the corresponding nla_put() function (nla_put_flag()) takes
>              only two args
>  - __field4: the corresponding nla_put() function (nla_put_u64_64bit())
>              takes four args
> 
> __field2 allows us to define __unspec_field for padding attribute.
> __field4 allows us to update the definition of __u64_field: the pad
> attribute should now be specified.

Please just NOT use an additional "field",
but always use 0 to pad.

Patch is much shorter as well, see below.

Attribute type "0" is not used,
and will never be of semantic value,
but always be ignored in the DRBD netlink family.

Whereas using some arbitrary value will be wrong,
and will needlessly break userland.

Thanks,

    Lars Ellenberg

diff --git a/include/linux/genl_magic_struct.h b/include/linux/genl_magic_struct.h
index eecd19b..6270a56 100644
--- a/include/linux/genl_magic_struct.h
+++ b/include/linux/genl_magic_struct.h
@@ -62,6 +62,11 @@ extern void CONCAT_(GENL_MAGIC_FAMILY, _genl_unregister)(void);
 
 /* MAGIC helpers							{{{2 */
 
+static inline int nla_put_u64_0pad(struct sk_buff *skb, int attrtype, u64 value)
+{
+	return nla_put_64bit(skb, attrtype, sizeof(u64), &value, 0);
+}
+
 /* possible field types */
 #define __flg_field(attr_nr, attr_flag, name) \
 	__field(attr_nr, attr_flag, name, NLA_U8, char, \
@@ -80,7 +85,7 @@ extern void CONCAT_(GENL_MAGIC_FAMILY, _genl_unregister)(void);
 			nla_get_u32, nla_put_u32, true)
 #define __u64_field(attr_nr, attr_flag, name)	\
 	__field(attr_nr, attr_flag, name, NLA_U64, __u64, \
-			nla_get_u64, nla_put_u64, false)
+			nla_get_u64, nla_put_u64_0pad, false)
 #define __str_field(attr_nr, attr_flag, name, maxlen) \
 	__array(attr_nr, attr_flag, name, NLA_NUL_STRING, char, maxlen, \
 			nla_strlcpy, nla_put, false)
diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
index 1fd1dcc..206cc76 100644
--- a/drivers/block/drbd/drbd_nl.c
+++ b/drivers/block/drbd/drbd_nl.c
@@ -3633,14 +3633,14 @@ static int nla_put_status_info(struct sk_buff *skb, struct drbd_device *device,
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
+	    nla_put_u64_0pad(skb, T_ed_uuid, device->ed_uuid) ||
+	    nla_put_u64_0pad(skb, T_capacity, drbd_get_capacity(device->this_bdev)) ||
+	    nla_put_u64_0pad(skb, T_send_cnt, device->send_cnt) ||
+	    nla_put_u64_0pad(skb, T_recv_cnt, device->recv_cnt) ||
+	    nla_put_u64_0pad(skb, T_read_cnt, device->read_cnt) ||
+	    nla_put_u64_0pad(skb, T_writ_cnt, device->writ_cnt) ||
+	    nla_put_u64_0pad(skb, T_al_writ_cnt, device->al_writ_cnt) ||
+	    nla_put_u64_0pad(skb, T_bm_writ_cnt, device->bm_writ_cnt) ||
 	    nla_put_u32(skb, T_ap_bio_cnt, atomic_read(&device->ap_bio_cnt)) ||
 	    nla_put_u32(skb, T_ap_pending_cnt, atomic_read(&device->ap_pending_cnt)) ||
 	    nla_put_u32(skb, T_rs_pending_cnt, atomic_read(&device->rs_pending_cnt)))
@@ -3657,13 +3657,13 @@ static int nla_put_status_info(struct sk_buff *skb, struct drbd_device *device,
 			goto nla_put_failure;
 
 		if (nla_put_u32(skb, T_disk_flags, device->ldev->md.flags) ||
-		    nla_put_u64(skb, T_bits_total, drbd_bm_bits(device)) ||
-		    nla_put_u64(skb, T_bits_oos, drbd_bm_total_weight(device)))
+		    nla_put_u64_0pad(skb, T_bits_total, drbd_bm_bits(device)) ||
+		    nla_put_u64_0pad(skb, T_bits_oos, drbd_bm_total_weight(device)))
 			goto nla_put_failure;
 		if (C_SYNC_SOURCE <= device->state.conn &&
 		    C_PAUSED_SYNC_T >= device->state.conn) {
-			if (nla_put_u64(skb, T_bits_rs_total, device->rs_total) ||
-			    nla_put_u64(skb, T_bits_rs_failed, device->rs_failed))
+			if (nla_put_u64_0pad(skb, T_bits_rs_total, device->rs_total) ||
+			    nla_put_u64_0pad(skb, T_bits_rs_failed, device->rs_failed))
 				goto nla_put_failure;
 		}
 	}
