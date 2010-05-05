From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 3/6] netlink: Implment netlink_broadcast_filtered
Date: Tue,  4 May 2010 17:36:46 -0700
Message-ID: <1273019809-16472-3-git-send-email-ebiederm@xmission.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Cc: Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34755 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934266Ab0EEAhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 20:37:02 -0400
In-Reply-To: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

When netlink sockets are used to convey data that is in a namespace
we need a way to select a subset of the listening sockets to deliver
the packet to.  For the network namespace we have been doing this
by only transmitting packets in the correct network namespace.

For data belonging to other namespaces netlink_bradcast_filtered
provides a mechanism that allows us to examine the destination
socket and to decide if we should transmit the specified packet
to it.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/netlink.h  |    4 ++++
 net/netlink/af_netlink.c |   21 +++++++++++++++++++--
 2 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index fde27c0..4f7bf4b 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -188,6 +188,10 @@ extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 pid,
 			     __u32 group, gfp_t allocation);
+extern int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb,
+	__u32 pid, __u32 group, gfp_t allocation,
+	int (*filter)(struct sock *dsk, struct sk_buff *skb, void *data),
+	void *filter_data);
 extern void netlink_set_err(struct sock *ssk, __u32 pid, __u32 group, int code);
 extern int netlink_register_notifier(struct notifier_block *nb);
 extern int netlink_unregister_notifier(struct notifier_block *nb);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 320d042..4f16d68 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -975,6 +975,8 @@ struct netlink_broadcast_data {
 	int delivered;
 	gfp_t allocation;
 	struct sk_buff *skb, *skb2;
+	int (*tx_filter)(struct sock *dsk, struct sk_buff *skb, void *data);
+	void *tx_data;
 };
 
 static inline int do_one_broadcast(struct sock *sk,
@@ -1017,6 +1019,9 @@ static inline int do_one_broadcast(struct sock *sk,
 		p->failure = 1;
 		if (nlk->flags & NETLINK_BROADCAST_SEND_ERROR)
 			p->delivery_failure = 1;
+	} else if (p->tx_filter && p->tx_filter(sk, p->skb2, p->tx_data)) {
+		kfree_skb(p->skb2);
+		p->skb2 = NULL;
 	} else if (sk_filter(sk, p->skb2)) {
 		kfree_skb(p->skb2);
 		p->skb2 = NULL;
@@ -1035,8 +1040,10 @@ out:
 	return 0;
 }
 
-int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
-		      u32 group, gfp_t allocation)
+int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 pid,
+	u32 group, gfp_t allocation,
+	int (*filter)(struct sock *dsk, struct sk_buff *skb, void *data),
+	void *filter_data)
 {
 	struct net *net = sock_net(ssk);
 	struct netlink_broadcast_data info;
@@ -1056,6 +1063,8 @@ int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 	info.allocation = allocation;
 	info.skb = skb;
 	info.skb2 = NULL;
+	info.tx_filter = filter;
+	info.tx_data = filter_data;
 
 	/* While we sleep in clone, do not allow to change socket list */
 
@@ -1080,6 +1089,14 @@ int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 	}
 	return -ESRCH;
 }
+EXPORT_SYMBOL(netlink_broadcast_filtered);
+
+int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
+		      u32 group, gfp_t allocation)
+{
+	return netlink_broadcast_filtered(ssk, skb, pid, group, allocation,
+		NULL, NULL);
+}
 EXPORT_SYMBOL(netlink_broadcast);
 
 struct netlink_set_err_data {
-- 
1.6.5.2.143.g8cc62

