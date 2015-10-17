From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 25/35] netfilter: nfnetlink_log: consolidate check for instance in nfulnl_recv_config()
Date: Sat, 17 Oct 2015 13:33:00 +0200
Message-ID: <1445081590-2924-26-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch consolidates the check for valid logger instance once we have
passed the command handling:

The config message that we receive may contain the following info:

1) Command only: We always get a valid instance pointer if we just
   created it. In case that the instance is being destroyed or the
   command is unknown, we jump to exit path of nfulnl_recv_config().
   This patch doesn't modify this handling.

2) Config only: In this case, the instance must always exist since the
   user is asking for configuration updates. If the instance doesn't exist
   this returns -ENODEV.

3) No command and no configs are specified: This case is rare. The
   user is sending us a config message with neither commands nor
   config options. In this case, we have to check if the instance exists
   and bail out otherwise. Before this patch, it was possible to send a
   config message with no command and no config updates for an
   unexisting instance without triggering an error. So this is the only
   case that changes.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Tested-by: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
---
 net/netfilter/nfnetlink_log.c | 28 +++++-----------------------
 1 file changed, 5 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index f8d9bd8..2002d57 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -874,16 +874,15 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 			ret = -ENOTSUPP;
 			break;
 		}
+	} else if (!inst) {
+		ret = -ENODEV;
+		goto out;
 	}
 
 	if (nfula[NFULA_CFG_MODE]) {
-		struct nfulnl_msg_config_mode *params;
-		params = nla_data(nfula[NFULA_CFG_MODE]);
+		struct nfulnl_msg_config_mode *params =
+			nla_data(nfula[NFULA_CFG_MODE]);
 
-		if (!inst) {
-			ret = -ENODEV;
-			goto out;
-		}
 		nfulnl_set_mode(inst, params->copy_mode,
 				ntohl(params->copy_range));
 	}
@@ -891,41 +890,24 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 	if (nfula[NFULA_CFG_TIMEOUT]) {
 		__be32 timeout = nla_get_be32(nfula[NFULA_CFG_TIMEOUT]);
 
-		if (!inst) {
-			ret = -ENODEV;
-			goto out;
-		}
 		nfulnl_set_timeout(inst, ntohl(timeout));
 	}
 
 	if (nfula[NFULA_CFG_NLBUFSIZ]) {
 		__be32 nlbufsiz = nla_get_be32(nfula[NFULA_CFG_NLBUFSIZ]);
 
-		if (!inst) {
-			ret = -ENODEV;
-			goto out;
-		}
 		nfulnl_set_nlbufsiz(inst, ntohl(nlbufsiz));
 	}
 
 	if (nfula[NFULA_CFG_QTHRESH]) {
 		__be32 qthresh = nla_get_be32(nfula[NFULA_CFG_QTHRESH]);
 
-		if (!inst) {
-			ret = -ENODEV;
-			goto out;
-		}
 		nfulnl_set_qthresh(inst, ntohl(qthresh));
 	}
 
 	if (nfula[NFULA_CFG_FLAGS]) {
 		u16 flags = ntohs(nla_get_be16(nfula[NFULA_CFG_FLAGS]));
 
-		if (!inst) {
-			ret = -ENODEV;
-			goto out;
-		}
-
 		if (flags & NFULNL_CFG_F_CONNTRACK &&
 		    !rcu_access_pointer(nfnl_ct_hook)) {
 #ifdef CONFIG_MODULES
-- 
2.1.4

