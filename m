From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 08/10] netfilter: nf_log: enable nflog in un-init net namespace
Date: Thu, 7 Feb 2013 15:49:48 +0800
Message-ID: <1360223390-15589-8-git-send-email-gaofeng@cn.fujitsu.com>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: containers@lists.linux-foundation.org, pablo@netfilter.org,
	ebiederm@xmission.com, netdev@vger.kernel.org, lve@guap.ru,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now all nf_loggers are support net namespace, we
can allow all net namespace to enable the nflog.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_log.c | 20 --------------------
 1 file changed, 20 deletions(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index b1e5126..392f64f 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -33,9 +33,6 @@ static struct nf_logger *__find_logger(int pf, const char *str_logger)
 
 void nf_log_set(struct net *net, u_int8_t pf, struct nf_logger *logger)
 {
-	if (!net_eq(net, &init_net))
-		return;
-
 	if (pf != NFPROTO_UNSPEC) {
 		const struct nf_logger *llog;
 		mutex_lock(&nf_log_mutex);
@@ -54,9 +51,6 @@ void nf_log_unset(struct net *net, struct nf_logger *logger)
 	int i;
 	const struct nf_logger *c_logger;
 
-	if (!net_eq(net, &init_net))
-		return;
-
 	mutex_lock(&nf_log_mutex);
 	for (i = 0; i < NFPROTO_NUMPROTO; i++) {
 		c_logger = rcu_dereference_protected(net->ct.nf_loggers[i],
@@ -91,7 +85,6 @@ int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 
 	mutex_unlock(&nf_log_mutex);
 
-	nf_log_set(&init_net, pf, logger);
 	return 0;
 }
 EXPORT_SYMBOL(nf_log_register);
@@ -105,16 +98,12 @@ void nf_log_unregister(struct nf_logger *logger)
 		list_del(&logger->list[i]);
 
 	mutex_unlock(&nf_log_mutex);
-	nf_log_unset(&init_net, logger);
 }
 EXPORT_SYMBOL(nf_log_unregister);
 
 int nf_log_bind_pf(struct net *net, u_int8_t pf,
 		   const struct nf_logger *logger)
 {
-	if (!net_eq(net, &init_net))
-		return 0;
-
 	if (pf >= ARRAY_SIZE(net->ct.nf_loggers))
 		return -EINVAL;
 
@@ -131,9 +120,6 @@ EXPORT_SYMBOL(nf_log_bind_pf);
 
 void nf_log_unbind_pf(struct net *net, u_int8_t pf)
 {
-	if (!net_eq(net, &init_net))
-		return;
-
 	if (pf >= ARRAY_SIZE(net->ct.nf_loggers))
 		return;
 
@@ -156,9 +142,6 @@ void nf_log_packet(struct net *net,
 	char prefix[NF_LOG_PREFIXLEN];
 	const struct nf_logger *logger;
 
-	if (!net_eq(net, &init_net))
-		return;
-
 	rcu_read_lock();
 	logger = rcu_dereference(net->ct.nf_loggers[pf]);
 	if (logger) {
@@ -272,9 +255,6 @@ static int nf_log_proc_dostring(ctl_table *table, int write,
 	struct net *net = current->nsproxy->net_ns;
 
 	if (write) {
-		if (!net_eq(net, &init_net))
-			return -EPERM;
-
 		if (size > sizeof(buf))
 			size = sizeof(buf);
 		if (copy_from_user(buf, buffer, size))
-- 
1.7.11.7

