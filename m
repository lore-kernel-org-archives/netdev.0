From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: don't disable BH again in BH disabled context
Date: Tue, 17 Aug 2010 14:41:37 +0800
Message-ID: <1282027297-9998-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All the matches and targets of iptables, ip6tables are in BH disabled
context, since xt_info_rdlock_bh() disables BH.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/ipv4/netfilter/ipt_LOG.c  |    8 ++++----
 net/ipv4/netfilter/ipt_ULOG.c |    6 +++---
 net/ipv6/netfilter/ip6t_LOG.c |    8 ++++----
 net/netfilter/xt_RATEEST.c    |    4 ++--
 net/netfilter/xt_connlimit.c  |    4 ++--
 net/netfilter/xt_dccp.c       |    8 ++++----
 net/netfilter/xt_limit.c      |    6 +++---
 net/netfilter/xt_quota.c      |    4 ++--
 net/netfilter/xt_rateest.c    |    8 ++++----
 net/netfilter/xt_recent.c     |    4 ++--
 10 files changed, 30 insertions(+), 30 deletions(-)
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 915fc17..3ea7cfa 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -337,12 +337,12 @@ static void dump_packet(const struct nf_loginfo *info,
 
 	/* Max length: 15 "UID=4294967295 " */
 	if ((logflags & IPT_LOG_UID) && !iphoff && skb->sk) {
-		read_lock_bh(&skb->sk->sk_callback_lock);
+		read_lock(&skb->sk->sk_callback_lock);
 		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
 			printk("UID=%u GID=%u ",
 				skb->sk->sk_socket->file->f_cred->fsuid,
 				skb->sk->sk_socket->file->f_cred->fsgid);
-		read_unlock_bh(&skb->sk->sk_callback_lock);
+		read_unlock(&skb->sk->sk_callback_lock);
 	}
 
 	/* Max length: 16 "MARK=0xFFFFFFFF " */
@@ -422,7 +422,7 @@ ipt_log_packet(u_int8_t pf,
 	if (!loginfo)
 		loginfo = &default_loginfo;
 
-	spin_lock_bh(&log_lock);
+	spin_lock(&log_lock);
 	printk("<%d>%sIN=%s OUT=%s ", loginfo->u.log.level,
 	       prefix,
 	       in ? in->name : "",
@@ -447,7 +447,7 @@ ipt_log_packet(u_int8_t pf,
 
 	dump_packet(loginfo, skb, 0);
 	printk("\n");
-	spin_unlock_bh(&log_lock);
+	spin_unlock(&log_lock);
 }
 
 static unsigned int
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 446e0f4..f2dd9eb 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -180,7 +180,7 @@ static void ipt_ulog_packet(unsigned int hooknum,
 
 	ub = &ulog_buffers[groupnum];
 
-	spin_lock_bh(&ulog_lock);
+	spin_lock(&ulog_lock);
 
 	if (!ub->skb) {
 		if (!(ub->skb = ulog_alloc_skb(size)))
@@ -264,7 +264,7 @@ static void ipt_ulog_packet(unsigned int hooknum,
 		ulog_send(groupnum);
 	}
 
-	spin_unlock_bh(&ulog_lock);
+	spin_unlock(&ulog_lock);
 
 	return;
 
@@ -272,7 +272,7 @@ nlmsg_failure:
 	pr_debug("error during NLMSG_PUT\n");
 alloc_failure:
 	pr_debug("Error building netlink message\n");
-	spin_unlock_bh(&ulog_lock);
+	spin_unlock(&ulog_lock);
 }
 
 static unsigned int
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 0a07ae7..c517239 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -360,12 +360,12 @@ static void dump_packet(const struct nf_loginfo *info,
 
 	/* Max length: 15 "UID=4294967295 " */
 	if ((logflags & IP6T_LOG_UID) && recurse && skb->sk) {
-		read_lock_bh(&skb->sk->sk_callback_lock);
+		read_lock(&skb->sk->sk_callback_lock);
 		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
 			printk("UID=%u GID=%u ",
 				skb->sk->sk_socket->file->f_cred->fsuid,
 				skb->sk->sk_socket->file->f_cred->fsgid);
-		read_unlock_bh(&skb->sk->sk_callback_lock);
+		read_unlock(&skb->sk->sk_callback_lock);
 	}
 
 	/* Max length: 16 "MARK=0xFFFFFFFF " */
@@ -445,7 +445,7 @@ ip6t_log_packet(u_int8_t pf,
 	if (!loginfo)
 		loginfo = &default_loginfo;
 
-	spin_lock_bh(&log_lock);
+	spin_lock(&log_lock);
 	printk("<%d>%sIN=%s OUT=%s ", loginfo->u.log.level,
 		prefix,
 		in ? in->name : "",
@@ -457,7 +457,7 @@ ip6t_log_packet(u_int8_t pf,
 
 	dump_packet(loginfo, skb, skb_network_offset(skb), 1);
 	printk("\n");
-	spin_unlock_bh(&log_lock);
+	spin_unlock(&log_lock);
 }
 
 static unsigned int
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index de079ab..74a602b 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -87,10 +87,10 @@ xt_rateest_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	const struct xt_rateest_target_info *info = par->targinfo;
 	struct gnet_stats_basic_packed *stats = &info->est->bstats;
 
-	spin_lock_bh(&info->est->lock);
+	spin_lock(&info->est->lock);
 	stats->bytes += skb->len;
 	stats->packets++;
-	spin_unlock_bh(&info->est->lock);
+	spin_unlock(&info->est->lock);
 
 	return XT_CONTINUE;
 }
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 5c5b6b9..6851b98 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -199,10 +199,10 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		addr.ip = iph->saddr;
 	}
 
-	spin_lock_bh(&info->data->lock);
+	spin_lock(&info->data->lock);
 	connections = count_them(net, info->data, tuple_ptr, &addr,
 	                         &info->mask, par->family);
-	spin_unlock_bh(&info->data->lock);
+	spin_unlock(&info->data->lock);
 
 	if (connections < 0) {
 		/* kmalloc failed, drop it entirely */
diff --git a/net/netfilter/xt_dccp.c b/net/netfilter/xt_dccp.c
index b63d2a3..3472f97 100644
--- a/net/netfilter/xt_dccp.c
+++ b/net/netfilter/xt_dccp.c
@@ -52,7 +52,7 @@ dccp_find_option(u_int8_t option,
 	if (!optlen)
 		return false;
 
-	spin_lock_bh(&dccp_buflock);
+	spin_lock(&dccp_buflock);
 	op = skb_header_pointer(skb, protoff + optoff, optlen, dccp_optbuf);
 	if (op == NULL) {
 		/* If we don't have the whole header, drop packet. */
@@ -61,7 +61,7 @@ dccp_find_option(u_int8_t option,
 
 	for (i = 0; i < optlen; ) {
 		if (op[i] == option) {
-			spin_unlock_bh(&dccp_buflock);
+			spin_unlock(&dccp_buflock);
 			return true;
 		}
 
@@ -71,11 +71,11 @@ dccp_find_option(u_int8_t option,
 			i += op[i+1]?:1;
 	}
 
-	spin_unlock_bh(&dccp_buflock);
+	spin_unlock(&dccp_buflock);
 	return false;
 
 partial:
-	spin_unlock_bh(&dccp_buflock);
+	spin_unlock(&dccp_buflock);
 invalid:
 	*hotdrop = true;
 	return false;
diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index 32b7a57..08894a4 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -71,7 +71,7 @@ limit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	struct xt_limit_priv *priv = r->master;
 	unsigned long now = jiffies;
 
-	spin_lock_bh(&limit_lock);
+	spin_lock(&limit_lock);
 	priv->credit += (now - xchg(&priv->prev, now)) * CREDITS_PER_JIFFY;
 	if (priv->credit > r->credit_cap)
 		priv->credit = r->credit_cap;
@@ -79,11 +79,11 @@ limit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (priv->credit >= r->cost) {
 		/* We're not limited. */
 		priv->credit -= r->cost;
-		spin_unlock_bh(&limit_lock);
+		spin_unlock(&limit_lock);
 		return true;
 	}
 
-	spin_unlock_bh(&limit_lock);
+	spin_unlock(&limit_lock);
 	return false;
 }
 
diff --git a/net/netfilter/xt_quota.c b/net/netfilter/xt_quota.c
index 70eb2b4..ba2042d 100644
--- a/net/netfilter/xt_quota.c
+++ b/net/netfilter/xt_quota.c
@@ -28,7 +28,7 @@ quota_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	struct xt_quota_priv *priv = q->master;
 	bool ret = q->flags & XT_QUOTA_INVERT;
 
-	spin_lock_bh(&priv->lock);
+	spin_lock(&priv->lock);
 	if (priv->quota >= skb->len) {
 		priv->quota -= skb->len;
 		ret = !ret;
@@ -36,7 +36,7 @@ quota_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		/* we do not allow even small packets from now on */
 		priv->quota = 0;
 	}
-	spin_unlock_bh(&priv->lock);
+	spin_unlock(&priv->lock);
 
 	return ret;
 }
diff --git a/net/netfilter/xt_rateest.c b/net/netfilter/xt_rateest.c
index 76a0831..d69a280 100644
--- a/net/netfilter/xt_rateest.c
+++ b/net/netfilter/xt_rateest.c
@@ -22,7 +22,7 @@ xt_rateest_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	u_int32_t bps1, bps2, pps1, pps2;
 	bool ret = true;
 
-	spin_lock_bh(&info->est1->lock);
+	spin_lock(&info->est1->lock);
 	r = &info->est1->rstats;
 	if (info->flags & XT_RATEEST_MATCH_DELTA) {
 		bps1 = info->bps1 >= r->bps ? info->bps1 - r->bps : 0;
@@ -31,13 +31,13 @@ xt_rateest_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		bps1 = r->bps;
 		pps1 = r->pps;
 	}
-	spin_unlock_bh(&info->est1->lock);
+	spin_unlock(&info->est1->lock);
 
 	if (info->flags & XT_RATEEST_MATCH_ABS) {
 		bps2 = info->bps2;
 		pps2 = info->pps2;
 	} else {
-		spin_lock_bh(&info->est2->lock);
+		spin_lock(&info->est2->lock);
 		r = &info->est2->rstats;
 		if (info->flags & XT_RATEEST_MATCH_DELTA) {
 			bps2 = info->bps2 >= r->bps ? info->bps2 - r->bps : 0;
@@ -46,7 +46,7 @@ xt_rateest_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			bps2 = r->bps;
 			pps2 = r->pps;
 		}
-		spin_unlock_bh(&info->est2->lock);
+		spin_unlock(&info->est2->lock);
 	}
 
 	switch (info->mode) {
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 76aec6a..5ddd90d 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -259,7 +259,7 @@ recent_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (par->out != NULL && skb->sk == NULL)
 		ttl++;
 
-	spin_lock_bh(&recent_lock);
+	spin_lock(&recent_lock);
 	t = recent_table_lookup(recent_net, info->name);
 	e = recent_entry_lookup(t, &addr, par->family,
 				(info->check_set & XT_RECENT_TTL) ? ttl : 0);
@@ -302,7 +302,7 @@ recent_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		e->ttl = ttl;
 	}
 out:
-	spin_unlock_bh(&recent_lock);
+	spin_unlock(&recent_lock);
 	return ret;
 }
 
