From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/14] netfilter: nft_log: restrict the log prefix length to 127
Date: Thu, 26 Jan 2017 17:38:04 +0100
Message-ID: <1485448687-6072-12-git-send-email-pablo@netfilter.org>
References: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

First, log prefix will be truncated to NF_LOG_PREFIXLEN-1, i.e. 127,
at nf_log_packet(), so the extra part is useless.

Second, after adding a log rule with a very very long prefix, we will
fail to dump the nft rules after this _special_ one, but acctually,
they do exist. For example:
  # name_65000=$(printf "%0.sQ" {1..65000})
  # nft add rule filter output log prefix "$name_65000"
  # nft add rule filter output counter
  # nft add rule filter output counter
  # nft list chain filter output
  table ip filter {
      chain output {
          type filter hook output priority 0; policy accept;
      }
  }

So now, restrict the log prefix length to NF_LOG_PREFIXLEN-1.

Fixes: 96518518cc41 ("netfilter: add nftables")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_log.h | 2 ++
 net/netfilter/nf_log.c                | 1 -
 net/netfilter/nft_log.c               | 3 ++-
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_log.h b/include/uapi/linux/netfilter/nf_log.h
index 8be21e02387d..d0b5fa91ff54 100644
--- a/include/uapi/linux/netfilter/nf_log.h
+++ b/include/uapi/linux/netfilter/nf_log.h
@@ -9,4 +9,6 @@
 #define NF_LOG_MACDECODE	0x20	/* Decode MAC header */
 #define NF_LOG_MASK		0x2f
 
+#define NF_LOG_PREFIXLEN	128
+
 #endif /* _NETFILTER_NF_LOG_H */
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 3dca90dc24ad..ffb9e8ada899 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -13,7 +13,6 @@
 /* Internal logging interface, which relies on the real
    LOG target modules */
 
-#define NF_LOG_PREFIXLEN		128
 #define NFLOGGER_NAME_LEN		64
 
 static struct nf_logger __rcu *loggers[NFPROTO_NUMPROTO][NF_LOG_TYPE_MAX] __read_mostly;
diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index 6271e40a3dd6..6f6e64423643 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -39,7 +39,8 @@ static void nft_log_eval(const struct nft_expr *expr,
 
 static const struct nla_policy nft_log_policy[NFTA_LOG_MAX + 1] = {
 	[NFTA_LOG_GROUP]	= { .type = NLA_U16 },
-	[NFTA_LOG_PREFIX]	= { .type = NLA_STRING },
+	[NFTA_LOG_PREFIX]	= { .type = NLA_STRING,
+				    .len = NF_LOG_PREFIXLEN - 1 },
 	[NFTA_LOG_SNAPLEN]	= { .type = NLA_U32 },
 	[NFTA_LOG_QTHRESHOLD]	= { .type = NLA_U16 },
 	[NFTA_LOG_LEVEL]	= { .type = NLA_U32 },
-- 
2.1.4

