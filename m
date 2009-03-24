From: Patrick McHardy <kaber@trash.net>
Subject: nefilter 40/41: nfnetlink: add nfnetlink_set_err and use it in ctnetlink
Date: Tue, 24 Mar 2009 15:04:00 +0100 (MET)
Message-ID: <20090324140356.31401.64545.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit dd5b6ce6fd465eab90357711c8e8124dc3a31ff0
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Mar 23 13:21:06 2009 +0100

    nefilter: nfnetlink: add nfnetlink_set_err and use it in ctnetlink
    
    This patch adds nfnetlink_set_err() to propagate the error to netlink
    broadcast listener in case of memory allocation errors in the
    message building.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 7d8e045..135e5cf 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -76,6 +76,7 @@ extern int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n);
 extern int nfnetlink_has_listeners(unsigned int group);
 extern int nfnetlink_send(struct sk_buff *skb, u32 pid, unsigned group, 
 			  int echo);
+extern void nfnetlink_set_err(u32 pid, u32 group, int error);
 extern int nfnetlink_unicast(struct sk_buff *skb, u_int32_t pid, int flags);
 
 extern void nfnl_lock(void);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index d1fe9d1..1b75c9e 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -518,6 +518,7 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 nla_put_failure:
 	rcu_read_unlock();
 nlmsg_failure:
+	nfnetlink_set_err(0, group, -ENOBUFS);
 	kfree_skb(skb);
 	return NOTIFY_DONE;
 }
@@ -1514,6 +1515,7 @@ static int ctnetlink_expect_event(struct notifier_block *this,
 nla_put_failure:
 	rcu_read_unlock();
 nlmsg_failure:
+	nfnetlink_set_err(0, 0, -ENOBUFS);
 	kfree_skb(skb);
 	return NOTIFY_DONE;
 }
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 9c0ba17..2785d66 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -113,6 +113,12 @@ int nfnetlink_send(struct sk_buff *skb, u32 pid, unsigned group, int echo)
 }
 EXPORT_SYMBOL_GPL(nfnetlink_send);
 
+void nfnetlink_set_err(u32 pid, u32 group, int error)
+{
+	netlink_set_err(nfnl, pid, group, error);
+}
+EXPORT_SYMBOL_GPL(nfnetlink_set_err);
+
 int nfnetlink_unicast(struct sk_buff *skb, u_int32_t pid, int flags)
 {
 	return netlink_unicast(nfnl, skb, pid, flags);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 6ee69c2..5b33879 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1106,6 +1106,7 @@ void netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
 
 	read_unlock(&nl_table_lock);
 }
+EXPORT_SYMBOL(netlink_set_err);
 
 /* must be called with netlink table grabbed */
 static void netlink_update_socket_mc(struct netlink_sock *nlk,
