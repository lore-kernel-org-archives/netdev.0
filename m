From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/23] netfilter: labels: don't emit ct event if labels were not changed
Date: Fri, 22 Apr 2016 15:39:51 +0200
Message-ID: <1461332394-3994-21-git-send-email-pablo@netfilter.org>
References: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45273 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753947AbcDVNkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 09:40:24 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 006D56DFC9
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id D690DA827A
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:22 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2BCEB8E553
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:20 +0200 (CEST)
In-Reply-To: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

make the replace function only send a ctnetlink event if the contents
of the new set is different.

Otherwise 'ct label set ct label | bar'

will cause netlink event storm since we "replace" labels for each packet.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_labels.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_conntrack_labels.c b/net/netfilter/nf_conntrack_labels.c
index 3a30900..bd7f26b 100644
--- a/net/netfilter/nf_conntrack_labels.c
+++ b/net/netfilter/nf_conntrack_labels.c
@@ -33,14 +33,18 @@ int nf_connlabel_set(struct nf_conn *ct, u16 bit)
 }
 EXPORT_SYMBOL_GPL(nf_connlabel_set);
 
-static void replace_u32(u32 *address, u32 mask, u32 new)
+static int replace_u32(u32 *address, u32 mask, u32 new)
 {
 	u32 old, tmp;
 
 	do {
 		old = *address;
 		tmp = (old & mask) ^ new;
+		if (old == tmp)
+			return 0;
 	} while (cmpxchg(address, old, tmp) != old);
+
+	return 1;
 }
 
 int nf_connlabels_replace(struct nf_conn *ct,
@@ -49,6 +53,7 @@ int nf_connlabels_replace(struct nf_conn *ct,
 {
 	struct nf_conn_labels *labels;
 	unsigned int size, i;
+	int changed = 0;
 	u32 *dst;
 
 	labels = nf_ct_labels_find(ct);
@@ -60,16 +65,15 @@ int nf_connlabels_replace(struct nf_conn *ct,
 		words32 = size / sizeof(u32);
 
 	dst = (u32 *) labels->bits;
-	if (words32) {
-		for (i = 0; i < words32; i++)
-			replace_u32(&dst[i], mask ? ~mask[i] : 0, data[i]);
-	}
+	for (i = 0; i < words32; i++)
+		changed |= replace_u32(&dst[i], mask ? ~mask[i] : 0, data[i]);
 
 	size /= sizeof(u32);
 	for (i = words32; i < size; i++) /* pad */
 		replace_u32(&dst[i], 0, 0);
 
-	nf_conntrack_event_cache(IPCT_LABEL, ct);
+	if (changed)
+		nf_conntrack_event_cache(IPCT_LABEL, ct);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nf_connlabels_replace);
-- 
2.1.4
