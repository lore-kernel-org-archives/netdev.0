From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/4] netfilter: log: netns NULL ptr bug when calling from conntrack
Date: Thu, 16 May 2013 17:55:20 +0200
Message-ID: <1368719721-7470-4-git-send-email-pablo@netfilter.org>
References: <1368719721-7470-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1368719721-7470-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hans Schillstrom <hans@schillstrom.com>

Since (69b34fb netfilter: xt_LOG: add net namespace support
for xt_LOG), we hit this:

[ 4224.708977] BUG: unable to handle kernel NULL pointer dereference at 0000000000000388
[ 4224.709074] IP: [<ffffffff8147f699>] ipt_log_packet+0x29/0x270

when callling log functions from conntrack both in and out
are NULL i.e. the net pointer is invalid.

Adding struct net *net in call to nf_logfn() will secure that
there always is a vaild net ptr.

Reported as netfilter's bugzilla bug 818:
https://bugzilla.netfilter.org/show_bug.cgi?id=818

Reported-by: Ronald <ronald645@gmail.com>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_log.h        |    3 ++-
 include/net/netfilter/nfnetlink_log.h |    3 ++-
 net/bridge/netfilter/ebt_log.c        |   11 +++++------
 net/bridge/netfilter/ebt_ulog.c       |   18 +++++++++++-------
 net/ipv4/netfilter/ipt_ULOG.c         |   13 ++++++++-----
 net/netfilter/nf_log.c                |    2 +-
 net/netfilter/nfnetlink_log.c         |    4 ++--
 net/netfilter/xt_LOG.c                |   13 +++++++------
 net/netfilter/xt_NFLOG.c              |    3 ++-
 9 files changed, 40 insertions(+), 30 deletions(-)

diff --git a/include/net/netfilter/nf_log.h b/include/net/netfilter/nf_log.h
index 31f1fb9..99eac12 100644
--- a/include/net/netfilter/nf_log.h
+++ b/include/net/netfilter/nf_log.h
@@ -30,7 +30,8 @@ struct nf_loginfo {
 	} u;
 };
 
-typedef void nf_logfn(u_int8_t pf,
+typedef void nf_logfn(struct net *net,
+		      u_int8_t pf,
 		      unsigned int hooknum,
 		      const struct sk_buff *skb,
 		      const struct net_device *in,
diff --git a/include/net/netfilter/nfnetlink_log.h b/include/net/netfilter/nfnetlink_log.h
index e2dec42..5ca3f14 100644
--- a/include/net/netfilter/nfnetlink_log.h
+++ b/include/net/netfilter/nfnetlink_log.h
@@ -2,7 +2,8 @@
 #define _KER_NFNETLINK_LOG_H
 
 void
-nfulnl_log_packet(u_int8_t pf,
+nfulnl_log_packet(struct net *net,
+		  u_int8_t pf,
 		  unsigned int hooknum,
 		  const struct sk_buff *skb,
 		  const struct net_device *in,
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 9878eb8..19c37a4 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -72,13 +72,12 @@ print_ports(const struct sk_buff *skb, uint8_t protocol, int offset)
 }
 
 static void
-ebt_log_packet(u_int8_t pf, unsigned int hooknum,
-   const struct sk_buff *skb, const struct net_device *in,
-   const struct net_device *out, const struct nf_loginfo *loginfo,
-   const char *prefix)
+ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
+	       const struct sk_buff *skb, const struct net_device *in,
+	       const struct net_device *out, const struct nf_loginfo *loginfo,
+	       const char *prefix)
 {
 	unsigned int bitmask;
-	struct net *net = dev_net(in ? in : out);
 
 	/* FIXME: Disabled from containers until syslog ns is supported */
 	if (!net_eq(net, &init_net))
@@ -191,7 +190,7 @@ ebt_log_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		nf_log_packet(net, NFPROTO_BRIDGE, par->hooknum, skb,
 			      par->in, par->out, &li, "%s", info->prefix);
 	else
-		ebt_log_packet(NFPROTO_BRIDGE, par->hooknum, skb, par->in,
+		ebt_log_packet(net, NFPROTO_BRIDGE, par->hooknum, skb, par->in,
 			       par->out, &li, info->prefix);
 	return EBT_CONTINUE;
 }
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index fc1905c..df0364a 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -131,14 +131,16 @@ static struct sk_buff *ulog_alloc_skb(unsigned int size)
 	return skb;
 }
 
-static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
-   const struct net_device *in, const struct net_device *out,
-   const struct ebt_ulog_info *uloginfo, const char *prefix)
+static void ebt_ulog_packet(struct net *net, unsigned int hooknr,
+			    const struct sk_buff *skb,
+			    const struct net_device *in,
+			    const struct net_device *out,
+			    const struct ebt_ulog_info *uloginfo,
+			    const char *prefix)
 {
 	ebt_ulog_packet_msg_t *pm;
 	size_t size, copy_len;
 	struct nlmsghdr *nlh;
-	struct net *net = dev_net(in ? in : out);
 	struct ebt_ulog_net *ebt = ebt_ulog_pernet(net);
 	unsigned int group = uloginfo->nlgroup;
 	ebt_ulog_buff_t *ub = &ebt->ulog_buffers[group];
@@ -233,7 +235,7 @@ unlock:
 }
 
 /* this function is registered with the netfilter core */
-static void ebt_log_packet(u_int8_t pf, unsigned int hooknum,
+static void ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
    const struct sk_buff *skb, const struct net_device *in,
    const struct net_device *out, const struct nf_loginfo *li,
    const char *prefix)
@@ -252,13 +254,15 @@ static void ebt_log_packet(u_int8_t pf, unsigned int hooknum,
 		strlcpy(loginfo.prefix, prefix, sizeof(loginfo.prefix));
 	}
 
-	ebt_ulog_packet(hooknum, skb, in, out, &loginfo, prefix);
+	ebt_ulog_packet(net, hooknum, skb, in, out, &loginfo, prefix);
 }
 
 static unsigned int
 ebt_ulog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	ebt_ulog_packet(par->hooknum, skb, par->in, par->out,
+	struct net *net = dev_net(par->in ? par->in : par->out);
+
+	ebt_ulog_packet(net, par->hooknum, skb, par->in, par->out,
 	                par->targinfo, NULL);
 	return EBT_CONTINUE;
 }
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index f8a222cb..cf08218 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -162,7 +162,8 @@ static struct sk_buff *ulog_alloc_skb(unsigned int size)
 	return skb;
 }
 
-static void ipt_ulog_packet(unsigned int hooknum,
+static void ipt_ulog_packet(struct net *net,
+			    unsigned int hooknum,
 			    const struct sk_buff *skb,
 			    const struct net_device *in,
 			    const struct net_device *out,
@@ -174,7 +175,6 @@ static void ipt_ulog_packet(unsigned int hooknum,
 	size_t size, copy_len;
 	struct nlmsghdr *nlh;
 	struct timeval tv;
-	struct net *net = dev_net(in ? in : out);
 	struct ulog_net *ulog = ulog_pernet(net);
 
 	/* ffs == find first bit set, necessary because userspace
@@ -291,12 +291,15 @@ alloc_failure:
 static unsigned int
 ulog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	ipt_ulog_packet(par->hooknum, skb, par->in, par->out,
+	struct net *net = dev_net(par->in ? par->in : par->out);
+
+	ipt_ulog_packet(net, par->hooknum, skb, par->in, par->out,
 	                par->targinfo, NULL);
 	return XT_CONTINUE;
 }
 
-static void ipt_logfn(u_int8_t pf,
+static void ipt_logfn(struct net *net,
+		      u_int8_t pf,
 		      unsigned int hooknum,
 		      const struct sk_buff *skb,
 		      const struct net_device *in,
@@ -318,7 +321,7 @@ static void ipt_logfn(u_int8_t pf,
 		strlcpy(loginfo.prefix, prefix, sizeof(loginfo.prefix));
 	}
 
-	ipt_ulog_packet(hooknum, skb, in, out, &loginfo, prefix);
+	ipt_ulog_packet(net, hooknum, skb, in, out, &loginfo, prefix);
 }
 
 static int ulog_tg_check(const struct xt_tgchk_param *par)
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 757951d..3b18dd1 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -148,7 +148,7 @@ void nf_log_packet(struct net *net,
 		va_start(args, fmt);
 		vsnprintf(prefix, sizeof(prefix), fmt, args);
 		va_end(args);
-		logger->logfn(pf, hooknum, skb, in, out, loginfo, prefix);
+		logger->logfn(net, pf, hooknum, skb, in, out, loginfo, prefix);
 	}
 	rcu_read_unlock();
 }
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index d83d881..962e979 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -602,7 +602,8 @@ static struct nf_loginfo default_loginfo = {
 
 /* log handler for internal netfilter logging api */
 void
-nfulnl_log_packet(u_int8_t pf,
+nfulnl_log_packet(struct net *net,
+		  u_int8_t pf,
 		  unsigned int hooknum,
 		  const struct sk_buff *skb,
 		  const struct net_device *in,
@@ -615,7 +616,6 @@ nfulnl_log_packet(u_int8_t pf,
 	const struct nf_loginfo *li;
 	unsigned int qthreshold;
 	unsigned int plen;
-	struct net *net = dev_net(in ? in : out);
 	struct nfnl_log_net *log = nfnl_log_pernet(net);
 
 	if (li_user && li_user->type == NF_LOG_TYPE_ULOG)
diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index fe573f6..491c7d8 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -466,7 +466,8 @@ log_packet_common(struct sbuff *m,
 
 
 static void
-ipt_log_packet(u_int8_t pf,
+ipt_log_packet(struct net *net,
+	       u_int8_t pf,
 	       unsigned int hooknum,
 	       const struct sk_buff *skb,
 	       const struct net_device *in,
@@ -475,7 +476,6 @@ ipt_log_packet(u_int8_t pf,
 	       const char *prefix)
 {
 	struct sbuff *m;
-	struct net *net = dev_net(in ? in : out);
 
 	/* FIXME: Disabled from containers until syslog ns is supported */
 	if (!net_eq(net, &init_net))
@@ -797,7 +797,8 @@ fallback:
 }
 
 static void
-ip6t_log_packet(u_int8_t pf,
+ip6t_log_packet(struct net *net,
+		u_int8_t pf,
 		unsigned int hooknum,
 		const struct sk_buff *skb,
 		const struct net_device *in,
@@ -806,7 +807,6 @@ ip6t_log_packet(u_int8_t pf,
 		const char *prefix)
 {
 	struct sbuff *m;
-	struct net *net = dev_net(in ? in : out);
 
 	/* FIXME: Disabled from containers until syslog ns is supported */
 	if (!net_eq(net, &init_net))
@@ -833,17 +833,18 @@ log_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_log_info *loginfo = par->targinfo;
 	struct nf_loginfo li;
+	struct net *net = dev_net(par->in ? par->in : par->out);
 
 	li.type = NF_LOG_TYPE_LOG;
 	li.u.log.level = loginfo->level;
 	li.u.log.logflags = loginfo->logflags;
 
 	if (par->family == NFPROTO_IPV4)
-		ipt_log_packet(NFPROTO_IPV4, par->hooknum, skb, par->in,
+		ipt_log_packet(net, NFPROTO_IPV4, par->hooknum, skb, par->in,
 			       par->out, &li, loginfo->prefix);
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	else if (par->family == NFPROTO_IPV6)
-		ip6t_log_packet(NFPROTO_IPV6, par->hooknum, skb, par->in,
+		ip6t_log_packet(net, NFPROTO_IPV6, par->hooknum, skb, par->in,
 				par->out, &li, loginfo->prefix);
 #endif
 	else
diff --git a/net/netfilter/xt_NFLOG.c b/net/netfilter/xt_NFLOG.c
index a17dd0f..fb7497c 100644
--- a/net/netfilter/xt_NFLOG.c
+++ b/net/netfilter/xt_NFLOG.c
@@ -26,13 +26,14 @@ nflog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_nflog_info *info = par->targinfo;
 	struct nf_loginfo li;
+	struct net *net = dev_net(par->in ? par->in : par->out);
 
 	li.type		     = NF_LOG_TYPE_ULOG;
 	li.u.ulog.copy_len   = info->len;
 	li.u.ulog.group	     = info->group;
 	li.u.ulog.qthreshold = info->threshold;
 
-	nfulnl_log_packet(par->family, par->hooknum, skb, par->in,
+	nfulnl_log_packet(net, par->family, par->hooknum, skb, par->in,
 			  par->out, &li, info->prefix);
 	return XT_CONTINUE;
 }
-- 
1.7.10.4

