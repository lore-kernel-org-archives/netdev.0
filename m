From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/4] netfilter: conntrack: fix false CRC32c mismatch using paged skb
Date: Mon, 29 May 2017 13:34:29 +0200
Message-ID: <1496057672-6751-2-git-send-email-pablo@netfilter.org>
References: <1496057672-6751-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53076 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751103AbdE2Les (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 07:34:48 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7DE7D303D0A
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 13:34:39 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 691F1100A4E
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 13:34:39 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7632C100790
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 13:34:37 +0200 (CEST)
In-Reply-To: <1496057672-6751-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Caratti <dcaratti@redhat.com>

sctp_compute_cksum() implementation assumes that at least the SCTP header
is in the linear part of skb: modify conntrack error callback to avoid
false CRC32c mismatch, if the transport header is partially/entirely paged.

Fixes: cf6e007eef83 ("netfilter: conntrack: validate SCTP crc32c in PREROUTING")
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_sctp.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 13875d599a85..1c5b14a6cab3 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -512,16 +512,19 @@ static int sctp_error(struct net *net, struct nf_conn *tpl, struct sk_buff *skb,
 		      u8 pf, unsigned int hooknum)
 {
 	const struct sctphdr *sh;
-	struct sctphdr _sctph;
 	const char *logmsg;
 
-	sh = skb_header_pointer(skb, dataoff, sizeof(_sctph), &_sctph);
-	if (!sh) {
+	if (skb->len < dataoff + sizeof(struct sctphdr)) {
 		logmsg = "nf_ct_sctp: short packet ";
 		goto out_invalid;
 	}
 	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    skb->ip_summed == CHECKSUM_NONE) {
+		if (!skb_make_writable(skb, dataoff + sizeof(struct sctphdr))) {
+			logmsg = "nf_ct_sctp: failed to read header ";
+			goto out_invalid;
+		}
+		sh = (const struct sctphdr *)(skb->data + dataoff);
 		if (sh->checksum != sctp_compute_cksum(skb, dataoff)) {
 			logmsg = "nf_ct_sctp: bad CRC ";
 			goto out_invalid;
-- 
2.1.4
