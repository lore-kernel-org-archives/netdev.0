From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: make sure rtnl is held in
 rtnl_fill_ifinfo()
Date: Wed, 18 May 2011 11:35:03 +0200
Message-ID: <1305711303.2983.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60131 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138Ab1ERJfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 05:35:07 -0400
Received: by fxm17 with SMTP id 17so1048007fxm.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 02:35:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e67f88dd12f610 (net: dont hold rtnl mutex during netlink dump
callbacks) added a problem in rtnl_fill_ifinfo() not being always called
with RTNL held, which is racy.

1) This patch extends rtnl_mutex helper functions so that :

rtnl_lock() is able to BUG_ON() if recursively called.
[This was only provided if LOCKDEP was on]

rtnl_is_locked() is able to check if current thread owns rtnl_mutex
[ASSERT_RTNL() gets this added feature too]

2) Add one ASSERT_RTNL() in rtnl_fill_ifinfo()

3) Make sure rtnl is held in rtnl_dump_ifinfo()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/rtnetlink.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d2ba259..4e09f70 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -59,15 +59,19 @@ struct rtnl_link {
 };
 
 static DEFINE_MUTEX(rtnl_mutex);
+static struct thread_info  *rtnl_owner;
 
 void rtnl_lock(void)
 {
+	BUG_ON(rtnl_owner == current_thread_info());
 	mutex_lock(&rtnl_mutex);
+	rtnl_owner = current_thread_info();
 }
 EXPORT_SYMBOL(rtnl_lock);
 
 void __rtnl_unlock(void)
 {
+	rtnl_owner = NULL;
 	mutex_unlock(&rtnl_mutex);
 }
 
@@ -80,13 +84,17 @@ EXPORT_SYMBOL(rtnl_unlock);
 
 int rtnl_trylock(void)
 {
-	return mutex_trylock(&rtnl_mutex);
+	int ret = mutex_trylock(&rtnl_mutex);
+
+	if (ret)
+		rtnl_owner = current_thread_info();
+	return ret;
 }
 EXPORT_SYMBOL(rtnl_trylock);
 
 int rtnl_is_locked(void)
 {
-	return mutex_is_locked(&rtnl_mutex);
+	return mutex_is_locked(&rtnl_mutex) && rtnl_owner == current_thread_info();
 }
 EXPORT_SYMBOL(rtnl_is_locked);
 
@@ -850,6 +858,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	struct nlattr *attr, *af_spec;
 	struct rtnl_af_ops *af_ops;
 
+	ASSERT_RTNL();
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
@@ -1003,10 +1012,12 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net_device *dev;
 	struct hlist_head *head;
 	struct hlist_node *node;
+	int rtnl_was_locked = rtnl_is_locked();
 
 	s_h = cb->args[0];
 	s_idx = cb->args[1];
-
+	if (!rtnl_was_locked)
+		rtnl_lock();
 	rcu_read_lock();
 	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
 		idx = 0;
@@ -1025,6 +1036,8 @@ cont:
 	}
 out:
 	rcu_read_unlock();
+	if (!rtnl_was_locked)
+		rtnl_unlock();
 	cb->args[1] = idx;
 	cb->args[0] = h;
 


