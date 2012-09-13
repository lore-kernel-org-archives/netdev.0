From: pablo@netfilter.org
Subject: [PATCH 4/4] netfilter: log: Fix log-level processing
Date: Thu, 13 Sep 2012 12:54:08 +0200
Message-ID: <1347533648-3451-5-git-send-email-pablo@netfilter.org>
References: <1347533648-3451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1347533648-3451-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>

auto75914331@hushmail.com reports that iptables does not correctly
output the KERN_<level>.

$IPTABLES -A RULE_0_in  -j LOG  --log-level notice --log-prefix "DENY  in: "

result with linux 3.6-rc5
Sep 12 06:37:29 xxxxx kernel: <5>DENY  in: IN=eth0 OUT= MAC=.......

result with linux 3.5.3 and older:
Sep  9 10:43:01 xxxxx kernel: DENY  in: IN=eth0 OUT= MAC......

commit 04d2c8c83d0
("printk: convert the format for KERN_<LEVEL> to a 2 byte pattern")
updated the syslog header style but did not update netfilter uses.

Do so.

Use KERN_SOH and string concatenation instead of "%c" KERN_SOH_ASCII
as suggested by Eric Dumazet.

Signed-off-by: Joe Perches <joe@perches.com>
cc: auto75914331@hushmail.com
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_log.c |    2 +-
 net/netfilter/xt_LOG.c         |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index f88ee53..92de5e5 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -80,7 +80,7 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
 	unsigned int bitmask;
 
 	spin_lock_bh(&ebt_log_lock);
-	printk("<%c>%s IN=%s OUT=%s MAC source = %pM MAC dest = %pM proto = 0x%04x",
+	printk(KERN_SOH "%c%s IN=%s OUT=%s MAC source = %pM MAC dest = %pM proto = 0x%04x",
 	       '0' + loginfo->u.log.level, prefix,
 	       in ? in->name : "", out ? out->name : "",
 	       eth_hdr(skb)->h_source, eth_hdr(skb)->h_dest,
diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index 2a4f969..91e9af4 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -443,8 +443,8 @@ log_packet_common(struct sbuff *m,
 		  const struct nf_loginfo *loginfo,
 		  const char *prefix)
 {
-	sb_add(m, "<%d>%sIN=%s OUT=%s ", loginfo->u.log.level,
-	       prefix,
+	sb_add(m, KERN_SOH "%c%sIN=%s OUT=%s ",
+	       '0' + loginfo->u.log.level, prefix,
 	       in ? in->name : "",
 	       out ? out->name : "");
 #ifdef CONFIG_BRIDGE_NETFILTER
-- 
1.7.10.4

