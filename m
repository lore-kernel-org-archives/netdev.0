From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] bridge: fix seq check in br_mdb_dump()
Date: Mon, 10 Dec 2012 20:15:35 +0800
Message-ID: <1355141735-19576-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65163 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968Ab2LJMQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 07:16:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

In case of rehashing, introduce a global variable 'br_mdb_rehash_seq'
which gets increased every time when rehashing, and assign
net->dev_base_seq + br_mdb_rehash_seq to cb->seq.

In theory cb->seq could be wrapped to zero, but this is not
easy to fix, as net->dev_base_seq is not visible inside
br_mdb_rehash(). In practice, this is rare.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/bridge/br_mdb.c       |    6 ++----
 net/bridge/br_multicast.c |    2 ++
 net/bridge/br_private.h   |    1 +
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index edc0d73..ccc43a9 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -117,10 +117,8 @@ static int br_mdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	rcu_read_lock();
 
-	/* TODO: in case of rehashing, we need to check
-	 * consistency for dumping.
-	 */
-	cb->seq = net->dev_base_seq;
+	/* In theory this could be wrapped to 0... */
+	cb->seq = net->dev_base_seq + br_mdb_rehash_seq;
 
 	for_each_netdev_rcu(net, dev) {
 		if (dev->priv_flags & IFF_EBRIDGE) {
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 68e375a..847b98a1 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -37,6 +37,7 @@
 	rcu_dereference_protected(X, lockdep_is_held(&br->multicast_lock))
 
 static void br_multicast_start_querier(struct net_bridge *br);
+unsigned int br_mdb_rehash_seq;
 
 #if IS_ENABLED(CONFIG_IPV6)
 static inline int ipv6_is_transient_multicast(const struct in6_addr *addr)
@@ -338,6 +339,7 @@ static int br_mdb_rehash(struct net_bridge_mdb_htable __rcu **mdbp, int max,
 		return err;
 	}
 
+	br_mdb_rehash_seq++;
 	call_rcu_bh(&mdb->rcu, br_mdb_free);
 
 out:
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index ae0a6ec..f95b766 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -411,6 +411,7 @@ extern int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd, void __us
 
 /* br_multicast.c */
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+extern unsigned int br_mdb_rehash_seq;
 extern int br_multicast_rcv(struct net_bridge *br,
 			    struct net_bridge_port *port,
 			    struct sk_buff *skb);
