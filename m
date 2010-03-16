From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/3] netfilter: ctnetlink: fix reliable event delivery if
	message building fails
Date: Wed, 17 Mar 2010 00:30:21 +0100
Message-ID: <20100316233021.4185.8786.stgit@decadence>
References: <20100316232247.4185.19426.stgit@decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59027 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143Ab0CPXa2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Mar 2010 19:30:28 -0400
In-Reply-To: <20100316232247.4185.19426.stgit@decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug that allows to lose events when reliable
event delivery mode is used, ie. if NETLINK_BROADCAST_SEND_ERROR
and NETLINK_RECV_NO_ENOBUFS socket options are set.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink.h  |    2 +-
 net/netfilter/nf_conntrack_netlink.c |    4 +++-
 net/netfilter/nfnetlink.c            |    4 ++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 5392386..361d6b5 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -76,7 +76,7 @@ extern int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n);
 extern int nfnetlink_has_listeners(struct net *net, unsigned int group);
 extern int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned group,
 			  int echo, gfp_t flags);
-extern void nfnetlink_set_err(struct net *net, u32 pid, u32 group, int error);
+extern int nfnetlink_set_err(struct net *net, u32 pid, u32 group, int error);
 extern int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u_int32_t pid, int flags);
 
 extern void nfnl_lock(void);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 8b05f36..00016e0 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -582,7 +582,9 @@ nla_put_failure:
 nlmsg_failure:
 	kfree_skb(skb);
 errout:
-	nfnetlink_set_err(net, 0, group, -ENOBUFS);
+	if (nfnetlink_set_err(net, 0, group, -ENOBUFS) > 0)
+		return -ENOBUFS;
+
 	return 0;
 }
 #endif /* CONFIG_NF_CONNTRACK_EVENTS */
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 8eb0cc2..6afa3d5 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -113,9 +113,9 @@ int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 pid,
 }
 EXPORT_SYMBOL_GPL(nfnetlink_send);
 
-void nfnetlink_set_err(struct net *net, u32 pid, u32 group, int error)
+int nfnetlink_set_err(struct net *net, u32 pid, u32 group, int error)
 {
-	netlink_set_err(net->nfnl, pid, group, error);
+	return netlink_set_err(net->nfnl, pid, group, error);
 }
 EXPORT_SYMBOL_GPL(nfnetlink_set_err);
 

