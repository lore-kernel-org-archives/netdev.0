From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/8] netfilter: nf_nat_snmp: Fix panic when snmp_trap_helper fails to register
Date: Wed, 29 Mar 2017 14:14:09 +0200
Message-ID: <1490789650-7294-8-git-send-email-pablo@netfilter.org>
References: <1490789650-7294-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43966 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756039AbdC2MPm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 08:15:42 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BDAB9EBAD8
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 14:15:38 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 71186DA848
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 14:15:38 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C9A92DA91B
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 14:15:31 +0200 (CEST)
In-Reply-To: <1490789650-7294-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

In the commit 93557f53e1fb ("netfilter: nf_conntrack: nf_conntrack snmp
helper"), the snmp_helper is replaced by nf_nat_snmp_hook. So the
snmp_helper is never registered. But it still tries to unregister the
snmp_helper, it could cause the panic.

Now remove the useless snmp_helper and the unregister call in the
error handler.

Fixes: 93557f53e1fb ("netfilter: nf_conntrack: nf_conntrack snmp helper")
Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_nat_snmp_basic.c | 19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 5a8f7c360887..53e49f5011d3 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -1260,16 +1260,6 @@ static const struct nf_conntrack_expect_policy snmp_exp_policy = {
 	.timeout	= 180,
 };
 
-static struct nf_conntrack_helper snmp_helper __read_mostly = {
-	.me			= THIS_MODULE,
-	.help			= help,
-	.expect_policy		= &snmp_exp_policy,
-	.name			= "snmp",
-	.tuple.src.l3num	= AF_INET,
-	.tuple.src.u.udp.port	= cpu_to_be16(SNMP_PORT),
-	.tuple.dst.protonum	= IPPROTO_UDP,
-};
-
 static struct nf_conntrack_helper snmp_trap_helper __read_mostly = {
 	.me			= THIS_MODULE,
 	.help			= help,
@@ -1288,17 +1278,10 @@ static struct nf_conntrack_helper snmp_trap_helper __read_mostly = {
 
 static int __init nf_nat_snmp_basic_init(void)
 {
-	int ret = 0;
-
 	BUG_ON(nf_nat_snmp_hook != NULL);
 	RCU_INIT_POINTER(nf_nat_snmp_hook, help);
 
-	ret = nf_conntrack_helper_register(&snmp_trap_helper);
-	if (ret < 0) {
-		nf_conntrack_helper_unregister(&snmp_helper);
-		return ret;
-	}
-	return ret;
+	return nf_conntrack_helper_register(&snmp_trap_helper);
 }
 
 static void __exit nf_nat_snmp_basic_fini(void)
-- 
2.1.4
