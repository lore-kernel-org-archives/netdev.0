From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH] netfilter/nflog: nflog-range does not truncate packets
Date: Wed, 1 Jun 2016 20:23:54 -0400
Message-ID: <20160602002354.GG1644@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: coreteam@netfilter.org, johunt@akamai.com, netdev@vger.kernel.org,
	pai.vishwain@gmail.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:37596 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750960AbcFBAXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 20:23:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netfilter/nflog: nflog-range does not truncate packets

The --nflog-range parameter from userspace is ignored in the kernel and
the entire packet is sent to the userspace. The per-instance parameter
copy_range still works, with this change --nflog-range will have
preference over copy_range.

Signed-off-by: Vishwanath Pai <vpai@akamai.com>
Reviewed-by: Joshua Hunt <johunt@akamai.com>

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 4ef1fae..f40ddba 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -680,7 +680,6 @@ nfulnl_log_packet(struct net *net,
 		if (qthreshold > li->u.ulog.qthreshold)
 			qthreshold = li->u.ulog.qthreshold;
 
-
 	switch (inst->copy_mode) {
 	case NFULNL_COPY_META:
 	case NFULNL_COPY_NONE:
@@ -688,10 +687,12 @@ nfulnl_log_packet(struct net *net,
 		break;
 
 	case NFULNL_COPY_PACKET:
-		if (inst->copy_range > skb->len)
+		data_len = inst->copy_range;
+		if (li->u.ulog.copy_len < data_len)
+			data_len = li->u.ulog.copy_len;
+
+		if (data_len > skb->len)
 			data_len = skb->len;
-		else
-			data_len = inst->copy_range;
 
 		size += nla_total_size(data_len);
 		break;
