From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/4] netfilter: nf_log: don't zap all loggers on unregister
Date: Fri, 18 Sep 2015 11:17:53 +0200
Message-ID: <1442567876-4046-2-git-send-email-pablo@netfilter.org>
References: <1442567876-4046-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1442567876-4046-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

like nf_log_unset, nf_log_unregister must not reset the list of loggers.
Otherwise, a call to nf_log_unregister() will render loggers of other nf
protocols unusable:

iptables -A INPUT -j LOG
modprobe nf_log_arp ; rmmod nf_log_arp
iptables -A INPUT -j LOG
iptables: No chain/target/match by that name

Fixes: 30e0c6a6be ("netfilter: nf_log: prepare net namespace support for loggers")
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_log.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 675d12c..a5ebd7d 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -107,11 +107,15 @@ EXPORT_SYMBOL(nf_log_register);
 
 void nf_log_unregister(struct nf_logger *logger)
 {
+	const struct nf_logger *log;
 	int i;
 
 	mutex_lock(&nf_log_mutex);
-	for (i = 0; i < NFPROTO_NUMPROTO; i++)
-		RCU_INIT_POINTER(loggers[i][logger->type], NULL);
+	for (i = 0; i < NFPROTO_NUMPROTO; i++) {
+		log = nft_log_dereference(loggers[i][logger->type]);
+		if (log == logger)
+			RCU_INIT_POINTER(loggers[i][logger->type], NULL);
+	}
 	mutex_unlock(&nf_log_mutex);
 }
 EXPORT_SYMBOL(nf_log_unregister);
-- 
1.7.10.4

