From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH v2 1/2] netfilter/nflog: nflog-range does not truncate packets
Date: Tue, 21 Jun 2016 14:58:46 -0400
Message-ID: <20160621185846.GA6646@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, johunt@akamai.com,
	daviem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pai.vishwain@gmail.com,
	ilubashe@akamai.com, jdollard@akamai.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:60343 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752128AbcFUS6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 14:58:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netfilter/nflog: nflog-range does not truncate packets

li->u.ulog.copy_len is currently ignored by the kernel, we should truncate
the packet to either li->u.ulog.copy_len (if set) or copy_range before
sending it to userspace. 0 is a valid input for copy_len, so add a new
flag to indicate whether this was option was specified by the user or not.

Add two flags to indicate whether nflog-size/copy_len was set or not.
XT_NFLOG_F_COPY_LEN is for XT_NFLOG and NFLOG_F_COPY_LEN for nfnetlink_log

On the userspace side, this was initially represented by the option
nflog-range, this will be replaced by --nflog-size now. --nflog-range would
still exist but does not do anything.

Reported-by: Joe Dollard <jdollard@akamai.com>
Reviewed-by: Josh Hunt <johunt@akamai.com>
Signed-off-by: Vishwanath Pai <vpai@akamai.com>

diff --git a/include/net/netfilter/nf_log.h b/include/net/netfilter/nf_log.h
index 57639fc..83d855b 100644
--- a/include/net/netfilter/nf_log.h
+++ b/include/net/netfilter/nf_log.h
@@ -12,6 +12,9 @@
 #define NF_LOG_UID		0x08	/* Log UID owning local socket */
 #define NF_LOG_MASK		0x0f
 
+/* This flag indicates that copy_len field in nf_loginfo is set */
+#define NF_LOG_F_COPY_LEN	0x1
+
 enum nf_log_type {
 	NF_LOG_TYPE_LOG		= 0,
 	NF_LOG_TYPE_ULOG,
@@ -22,9 +25,13 @@ struct nf_loginfo {
 	u_int8_t type;
 	union {
 		struct {
+			/* copy_len will be used iff you set
+			 * NF_LOG_F_COPY_LEN in flags
+			 */
 			u_int32_t copy_len;
 			u_int16_t group;
 			u_int16_t qthreshold;
+			u_int16_t flags;
 		} ulog;
 		struct {
 			u_int8_t level;
diff --git a/include/uapi/linux/netfilter/xt_NFLOG.h b/include/uapi/linux/netfilter/xt_NFLOG.h
index 87b5831..f330707 100644
--- a/include/uapi/linux/netfilter/xt_NFLOG.h
+++ b/include/uapi/linux/netfilter/xt_NFLOG.h
@@ -6,9 +6,13 @@
 #define XT_NFLOG_DEFAULT_GROUP		0x1
 #define XT_NFLOG_DEFAULT_THRESHOLD	0
 
-#define XT_NFLOG_MASK			0x0
+#define XT_NFLOG_MASK			0x1
+
+/* This flag indicates that 'len' field in xt_nflog_info is set*/
+#define XT_NFLOG_F_COPY_LEN		0x1
 
 struct xt_nflog_info {
+	/* 'len' will be used iff you set XT_NFLOG_F_COPY_LEN in flags */
 	__u32	len;
 	__u16	group;
 	__u16	threshold;
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 11f81c8..cbcfdfb 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -700,10 +700,13 @@ nfulnl_log_packet(struct net *net,
 		break;
 
 	case NFULNL_COPY_PACKET:
-		if (inst->copy_range > skb->len)
+		data_len = inst->copy_range;
+		if ((li->u.ulog.flags & NF_LOG_F_COPY_LEN) &&
+		    (li->u.ulog.copy_len < data_len))
+			data_len = li->u.ulog.copy_len;
+
+		if (data_len > skb->len)
 			data_len = skb->len;
-		else
-			data_len = inst->copy_range;
 
 		size += nla_total_size(data_len);
 		break;
diff --git a/net/netfilter/xt_NFLOG.c b/net/netfilter/xt_NFLOG.c
index a1fa2c8..018eed7 100644
--- a/net/netfilter/xt_NFLOG.c
+++ b/net/netfilter/xt_NFLOG.c
@@ -33,6 +33,9 @@ nflog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	li.u.ulog.group	     = info->group;
 	li.u.ulog.qthreshold = info->threshold;
 
+	if (info->flags & XT_NFLOG_F_COPY_LEN)
+		li.u.ulog.flags |= NF_LOG_F_COPY_LEN;
+
 	nfulnl_log_packet(net, par->family, par->hooknum, skb, par->in,
 			  par->out, &li, info->prefix);
 	return XT_CONTINUE;
