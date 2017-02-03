From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/27] netfilter: conntrack: validate SCTP crc32c in PREROUTING
Date: Fri,  3 Feb 2017 13:25:17 +0100
Message-ID: <1486124738-3013-7-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58896 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752872AbdBCM2h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 07:28:37 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 29CEBC0B54
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:35 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 186D5DA846
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:35 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DACFEDA858
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:32 +0100 (CET)
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Caratti <dcaratti@redhat.com>

implement sctp_error to let nf_conntrack_in validate crc32c on the packet
transport header. Assign skb->ip_summed to CHECKSUM_UNNECESSARY and return
NF_ACCEPT in case of successful validation; otherwise, return -NF_ACCEPT to
let netfilter skip connection tracking, like other protocols do.

Besides preventing corrupted packets from matching conntrack entries, this
fixes functionality of REJECT target: it was not generating any ICMP upon
reception of SCTP packets, because it was computing RFC 1624 checksum on
the packet and systematically mismatching crc32c in the SCTP header.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_sctp.c | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index a0efde38da44..44a647418948 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -22,7 +22,9 @@
 #include <linux/seq_file.h>
 #include <linux/spinlock.h>
 #include <linux/interrupt.h>
+#include <net/sctp/checksum.h>
 
+#include <net/netfilter/nf_log.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
@@ -505,6 +507,34 @@ static bool sctp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	return true;
 }
 
+static int sctp_error(struct net *net, struct nf_conn *tpl, struct sk_buff *skb,
+		      unsigned int dataoff, enum ip_conntrack_info *ctinfo,
+		      u8 pf, unsigned int hooknum)
+{
+	const struct sctphdr *sh;
+	struct sctphdr _sctph;
+	const char *logmsg;
+
+	sh = skb_header_pointer(skb, dataoff, sizeof(_sctph), &_sctph);
+	if (!sh) {
+		logmsg = "nf_ct_sctp: short packet ";
+		goto out_invalid;
+	}
+	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
+	    skb->ip_summed == CHECKSUM_NONE) {
+		if (sh->checksum != sctp_compute_cksum(skb, dataoff)) {
+			logmsg = "nf_ct_sctp: bad CRC ";
+			goto out_invalid;
+		}
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
+	return NF_ACCEPT;
+out_invalid:
+	if (LOG_INVALID(net, IPPROTO_SCTP))
+		nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL, "%s", logmsg);
+	return -NF_ACCEPT;
+}
+
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 
 #include <linux/netfilter/nfnetlink.h>
@@ -752,6 +782,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	.packet 		= sctp_packet,
 	.get_timeouts		= sctp_get_timeouts,
 	.new 			= sctp_new,
+	.error			= sctp_error,
 	.me 			= THIS_MODULE,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= sctp_to_nlattr,
@@ -786,6 +817,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	.packet 		= sctp_packet,
 	.get_timeouts		= sctp_get_timeouts,
 	.new 			= sctp_new,
+	.error			= sctp_error,
 	.me 			= THIS_MODULE,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= sctp_to_nlattr,
-- 
2.1.4
