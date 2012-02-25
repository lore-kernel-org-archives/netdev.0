From: pablo@netfilter.org
Subject: [PATCH 2/3] netlink: allow to pass data pointer to netlink_dump_start() callback
Date: Sat, 25 Feb 2012 01:30:16 +0100
Message-ID: <1330129817-28199-3-git-send-email-pablo@netfilter.org>
References: <1330129817-28199-1-git-send-email-pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42611 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756323Ab2BYAa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 19:30:29 -0500
In-Reply-To: <1330129817-28199-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch allows you to pass a data pointer that can be
accessed from the dump callback.

Netfilter is going to use this patch to provide filtered dumps
to user-space. This is specifically interesting in ctnetlink that
may handle lots of conntrack entries. We can save precious
cycles by skipping the conversion to TLV format of conntrack
entries that are not interesting for user-space.

More specifically, ctnetlink will include one operation to allow
to filter the dumping of conntrack entries by ctmark values.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netlink.h  |    2 ++
 net/netlink/af_netlink.c |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 1f8c1a9..a2092f5 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -225,6 +225,7 @@ struct netlink_callback {
 	int			(*dump)(struct sk_buff * skb,
 					struct netlink_callback *cb);
 	int			(*done)(struct netlink_callback *cb);
+	void			*data;
 	u16			family;
 	u16			min_dump_alloc;
 	unsigned int		prev_seq, seq;
@@ -251,6 +252,7 @@ __nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
 struct netlink_dump_control {
 	int (*dump)(struct sk_buff *skb, struct netlink_callback *);
 	int (*done)(struct netlink_callback*);
+	void *data;
 	u16 min_dump_alloc;
 };
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ab74845..32bb753 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1750,6 +1750,7 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	cb->dump = control->dump;
 	cb->done = control->done;
 	cb->nlh = nlh;
+	cb->data = control->data;
 	cb->min_dump_alloc = control->min_dump_alloc;
 	atomic_inc(&skb->users);
 	cb->skb = skb;
-- 
1.7.7.3
