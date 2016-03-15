From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/18] netfilter: ipset: Check IPSET_ATTR_ETHER netlink attribute length
Date: Tue, 15 Mar 2016 02:27:51 +0100
Message-ID: <1458005282-24665-8-git-send-email-pablo@netfilter.org>
References: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33234 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933317AbcCOB2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 21:28:31 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id B85EB114F51
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:27 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A8401DA391
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:27 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 33558DA38E
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 02:28:25 +0100 (CET)
In-Reply-To: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Julia Lawall pointed out that IPSET_ATTR_ETHER netlink attribute length
was not checked explicitly, just for the maximum possible size. Malicious
netlink clients could send shorter attribute and thus resulting a kernel
read after the buffer.

The patch adds the explicit length checkings.

Reported-by: Julia Lawall <julia.lawall@lip6.fr>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_bitmap_ipmac.c | 2 ++
 net/netfilter/ipset/ip_set_hash_mac.c     | 3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 29dde20..9a065f6 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -267,6 +267,8 @@ bitmap_ipmac_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	e.id = ip_to_id(map, ip);
 	if (tb[IPSET_ATTR_ETHER]) {
+		if (nla_len(tb[IPSET_ATTR_ETHER]) != ETH_ALEN)
+			return -IPSET_ERR_PROTOCOL;
 		memcpy(e.ether, nla_data(tb[IPSET_ATTR_ETHER]), ETH_ALEN);
 		e.add_mac = 1;
 	}
diff --git a/net/netfilter/ipset/ip_set_hash_mac.c b/net/netfilter/ipset/ip_set_hash_mac.c
index f1e7d2c..8f004ed 100644
--- a/net/netfilter/ipset/ip_set_hash_mac.c
+++ b/net/netfilter/ipset/ip_set_hash_mac.c
@@ -110,7 +110,8 @@ hash_mac4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	if (unlikely(!tb[IPSET_ATTR_ETHER]))
+	if (unlikely(!tb[IPSET_ATTR_ETHER] ||
+		     nla_len(tb[IPSET_ATTR_ETHER]) != ETH_ALEN))
 		return -IPSET_ERR_PROTOCOL;
 
 	ret = ip_set_get_extensions(set, tb, &ext);
-- 
2.1.4
