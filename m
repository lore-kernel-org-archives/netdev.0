From: fgao@ikuai8.com
Subject: [PATCH nf v2 1/1] netfilter: snmp: Fix one possible panic when snmp_trap_helper fail to register
Date: Mon, 20 Mar 2017 17:55:28 +0800
Message-ID: <1490003728-33866-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, davem@davemloft.net, jolsa@redhat.com,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        gfree.wind@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

In the commit <93557f53e1fb> ("netfilter: nf_conntrack: nf_conntrack snmp
helper"), the snmp_helper is replaced by nf_nat_snmp_hook. So the
snmp_helper is never registered. But it still tries to unregister the
snmp_helper, it could cause the panic.

Now remove the useless snmp_helper and the unregister call in the
error handler.

Fixes: 93557f53e1fb ("netfilter: nf_conntrack: nf_conntrack snmp helper")

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v2: Add the SHA1 ID in the description, per Sergei
 v1: Initial version

 net/ipv4/netfilter/nf_nat_snmp_basic.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index c9b52c3..5787364 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -1260,16 +1260,6 @@ static int help(struct sk_buff *skb, unsigned int protoff,
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
@@ -1294,10 +1284,8 @@ static int __init nf_nat_snmp_basic_init(void)
 	RCU_INIT_POINTER(nf_nat_snmp_hook, help);
 
 	ret = nf_conntrack_helper_register(&snmp_trap_helper);
-	if (ret < 0) {
-		nf_conntrack_helper_unregister(&snmp_helper);
+	if (ret < 0)
 		return ret;
-	}
 	return ret;
 }
 
-- 
1.9.1


