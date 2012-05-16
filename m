From: pablo@netfilter.org
Subject: [PATCH 5/7] netfilter: ipset: fix timeout value overflow bug
Date: Thu, 17 May 2012 01:06:42 +0200
Message-ID: <1337209604-3412-6-git-send-email-pablo@netfilter.org>
References: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Large timeout parameters could result wrong timeout values due to
an overflow at msec to jiffies conversion (reported by Andreas Herz)

[ This patch was mangled by Pablo Neira Ayuso since David Laight and
  Eric Dumazet noticed that we were using hardcoded 1000 instead of
  MSEC_PER_SEC to calculate the timeout ]

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set_timeout.h |    4 ++++
 net/netfilter/xt_set.c                         |   15 +++++++++++++--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_timeout.h b/include/linux/netfilter/ipset/ip_set_timeout.h
index 4792320..41d9cfa 100644
--- a/include/linux/netfilter/ipset/ip_set_timeout.h
+++ b/include/linux/netfilter/ipset/ip_set_timeout.h
@@ -30,6 +30,10 @@ ip_set_timeout_uget(struct nlattr *tb)
 {
 	unsigned int timeout = ip_set_get_h32(tb);
 
+	/* Normalize to fit into jiffies */
+	if (timeout > UINT_MAX/MSEC_PER_SEC)
+		timeout = UINT_MAX/MSEC_PER_SEC;
+
 	/* Userspace supplied TIMEOUT parameter: adjust crazy size */
 	return timeout == IPSET_NO_TIMEOUT ? IPSET_NO_TIMEOUT - 1 : timeout;
 }
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 0ec8138..035960e 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -44,6 +44,14 @@ const struct ip_set_adt_opt n = {	\
 	.cmdflags = cfs,		\
 	.timeout = t,			\
 }
+#define ADT_MOPT(n, f, d, fs, cfs, t)	\
+struct ip_set_adt_opt n = {		\
+	.family	= f,			\
+	.dim = d,			\
+	.flags = fs,			\
+	.cmdflags = cfs,		\
+	.timeout = t,			\
+}
 
 /* Revision 0 interface: backward compatible with netfilter/iptables */
 
@@ -296,11 +304,14 @@ static unsigned int
 set_target_v2(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_set_info_target_v2 *info = par->targinfo;
-	ADT_OPT(add_opt, par->family, info->add_set.dim,
-		info->add_set.flags, info->flags, info->timeout);
+	ADT_MOPT(add_opt, par->family, info->add_set.dim,
+		 info->add_set.flags, info->flags, info->timeout);
 	ADT_OPT(del_opt, par->family, info->del_set.dim,
 		info->del_set.flags, 0, UINT_MAX);
 
+	/* Normalize to fit into jiffies */
+	if (add_opt.timeout > UINT_MAX/MSEC_PER_SEC)
+		add_opt.timeout = UINT_MAX/MSEC_PER_SEC;
 	if (info->add_set.index != IPSET_INVALID_ID)
 		ip_set_add(info->add_set.index, skb, par, &add_opt);
 	if (info->del_set.index != IPSET_INVALID_ID)
-- 
1.7.10

