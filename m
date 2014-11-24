From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/17] netfilter: nf_log: Introduce nft_log_dereference() macro
Date: Mon, 24 Nov 2014 14:27:42 +0100
Message-ID: <1416835674-11871-6-git-send-email-pablo@netfilter.org>
References: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44855 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753751AbaKXNZx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 08:25:53 -0500
In-Reply-To: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Leitner <mleitner@redhat.com>

Wrap up a common call pattern in an easier to handle call.

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_log.c |   21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index d719764..5eaf047 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -19,6 +19,9 @@
 static struct nf_logger __rcu *loggers[NFPROTO_NUMPROTO][NF_LOG_TYPE_MAX] __read_mostly;
 static DEFINE_MUTEX(nf_log_mutex);
 
+#define nft_log_dereference(logger) \
+	rcu_dereference_protected(logger, lockdep_is_held(&nf_log_mutex))
+
 static struct nf_logger *__find_logger(int pf, const char *str_logger)
 {
 	struct nf_logger *log;
@@ -28,8 +31,7 @@ static struct nf_logger *__find_logger(int pf, const char *str_logger)
 		if (loggers[pf][i] == NULL)
 			continue;
 
-		log = rcu_dereference_protected(loggers[pf][i],
-						lockdep_is_held(&nf_log_mutex));
+		log = nft_log_dereference(loggers[pf][i]);
 		if (!strncasecmp(str_logger, log->name, strlen(log->name)))
 			return log;
 	}
@@ -45,8 +47,7 @@ void nf_log_set(struct net *net, u_int8_t pf, const struct nf_logger *logger)
 		return;
 
 	mutex_lock(&nf_log_mutex);
-	log = rcu_dereference_protected(net->nf.nf_loggers[pf],
-					lockdep_is_held(&nf_log_mutex));
+	log = nft_log_dereference(net->nf.nf_loggers[pf]);
 	if (log == NULL)
 		rcu_assign_pointer(net->nf.nf_loggers[pf], logger);
 
@@ -61,8 +62,7 @@ void nf_log_unset(struct net *net, const struct nf_logger *logger)
 
 	mutex_lock(&nf_log_mutex);
 	for (i = 0; i < NFPROTO_NUMPROTO; i++) {
-		log = rcu_dereference_protected(net->nf.nf_loggers[i],
-				lockdep_is_held(&nf_log_mutex));
+		log = nft_log_dereference(net->nf.nf_loggers[i]);
 		if (log == logger)
 			RCU_INIT_POINTER(net->nf.nf_loggers[i], NULL);
 	}
@@ -297,8 +297,7 @@ static int seq_show(struct seq_file *s, void *v)
 	int i, ret;
 	struct net *net = seq_file_net(s);
 
-	logger = rcu_dereference_protected(net->nf.nf_loggers[*pos],
-					   lockdep_is_held(&nf_log_mutex));
+	logger = nft_log_dereference(net->nf.nf_loggers[*pos]);
 
 	if (!logger)
 		ret = seq_printf(s, "%2lld NONE (", *pos);
@@ -312,8 +311,7 @@ static int seq_show(struct seq_file *s, void *v)
 		if (loggers[*pos][i] == NULL)
 			continue;
 
-		logger = rcu_dereference_protected(loggers[*pos][i],
-					   lockdep_is_held(&nf_log_mutex));
+		logger = nft_log_dereference(loggers[*pos][i]);
 		ret = seq_printf(s, "%s", logger->name);
 		if (ret < 0)
 			return ret;
@@ -385,8 +383,7 @@ static int nf_log_proc_dostring(struct ctl_table *table, int write,
 		mutex_unlock(&nf_log_mutex);
 	} else {
 		mutex_lock(&nf_log_mutex);
-		logger = rcu_dereference_protected(net->nf.nf_loggers[tindex],
-						   lockdep_is_held(&nf_log_mutex));
+		logger = nft_log_dereference(net->nf.nf_loggers[tindex]);
 		if (!logger)
 			table->data = "NONE";
 		else
-- 
1.7.10.4
