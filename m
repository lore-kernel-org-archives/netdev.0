From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/26] netfilter: xt_NFLOG: nflog-range does not truncate packets
Date: Wed,  6 Jul 2016 16:23:54 +0200
Message-ID: <1467815048-2240-13-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34235 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754762AbcGFO0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 10:26:46 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 5D02117DB74
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:45 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 36A7A9EBB8
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:45 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 4A93FFAB55
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:41 +0200 (CEST)
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vishwanath Pai <vpai@akamai.com>

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
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_log.h          | 7 +++++++
 include/uapi/linux/netfilter/xt_NFLOG.h | 6 +++++-
 net/netfilter/nfnetlink_log.c           | 9 ++++++---
 net/netfilter/xt_NFLOG.c                | 3 +++
 4 files changed, 21 insertions(+), 4 deletions(-)

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
-- 
2.1.4
