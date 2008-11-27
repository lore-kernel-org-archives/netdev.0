From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/29: xt_NFLOG: don't call nf_log_packet in NFLOG module.
Date: Thu, 27 Nov 2008 17:15:04 +0100 (MET)
Message-ID: <20081127161504.13891.81597.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 5f7340eff8f68f41b7e5c7ad47ec4cd1ea1afb40
Author: Eric Leblond <eric@inl.fr>
Date:   Tue Nov 4 14:21:08 2008 +0100

    netfilter: xt_NFLOG: don't call nf_log_packet in NFLOG module.
    
    This patch modifies xt_NFLOG to suppress the call to nf_log_packet()
    function. The call of this wrapper in xt_NFLOG was causing NFLOG to
    use the first initialized module. Thus, if ipt_ULOG is loaded before
    nfnetlink_log all NFLOG rules are treated as plain LOG rules.
    
    Signed-off-by: Eric Leblond <eric@inl.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nfnetlink_log.h b/include/net/netfilter/nfnetlink_log.h
new file mode 100644
index 0000000..9b67f94
--- /dev/null
+++ b/include/net/netfilter/nfnetlink_log.h
@@ -0,0 +1,14 @@
+#ifndef _KER_NFNETLINK_LOG_H
+#define _KER_NFNETLINK_LOG_H
+
+void
+nfulnl_log_packet(unsigned int pf,
+		  unsigned int hooknum,
+		  const struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  const struct nf_loginfo *li_user,
+		  const char *prefix);
+
+#endif /* _KER_NFNETLINK_LOG_H */
+
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 41e0105..a51892b 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -533,7 +533,7 @@ static struct nf_loginfo default_loginfo = {
 };
 
 /* log handler for internal netfilter logging api */
-static void
+void
 nfulnl_log_packet(u_int8_t pf,
 		  unsigned int hooknum,
 		  const struct sk_buff *skb,
@@ -648,6 +648,7 @@ alloc_failure:
 	/* FIXME: statistics */
 	goto unlock_and_release;
 }
+EXPORT_SYMBOL_GPL(nfulnl_log_packet);
 
 static int
 nfulnl_rcv_nl_event(struct notifier_block *this,
diff --git a/net/netfilter/xt_NFLOG.c b/net/netfilter/xt_NFLOG.c
index 50e3a52..a57c5cf 100644
--- a/net/netfilter/xt_NFLOG.c
+++ b/net/netfilter/xt_NFLOG.c
@@ -13,6 +13,7 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_NFLOG.h>
 #include <net/netfilter/nf_log.h>
+#include <net/netfilter/nfnetlink_log.h>
 
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
 MODULE_DESCRIPTION("Xtables: packet logging to netlink using NFLOG");
@@ -31,8 +32,8 @@ nflog_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	li.u.ulog.group	     = info->group;
 	li.u.ulog.qthreshold = info->threshold;
 
-	nf_log_packet(par->family, par->hooknum, skb, par->in,
-	              par->out, &li, "%s", info->prefix);
+	nfulnl_log_packet(par->family, par->hooknum, skb, par->in,
+			  par->out, &li, info->prefix);
 	return XT_CONTINUE;
 }
 
