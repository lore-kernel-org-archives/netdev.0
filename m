From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC PATCH] netlink: Increase netlink dump skb message size
Date: Mon, 25 Apr 2011 15:01:57 -0700
Message-ID: <20110425220157.2012.96707.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11143 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756344Ab1DYWB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 18:01:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The message size allocated for rtnl info dumps was limited to a single page.
This is not enough for additional interface info available with devices
that support SR-IOV.  Check that the amount of data allocated is sufficient
for the amount of data requested.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 include/linux/rtnetlink.h |    1 +
 net/core/rtnetlink.c      |    6 ++++++
 net/netlink/af_netlink.c  |   37 +++++++++++++++++++++++++++++++------
 3 files changed, 38 insertions(+), 6 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index bbad657..d1ff937 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -622,6 +622,7 @@ extern int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
 extern int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst,
 			      u32 id, u32 ts, u32 tsage, long expires,
 			      u32 error);
+extern size_t rtnl_get_nlmsg_size(const struct net_device *dev);
 
 extern void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data);
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d7c4bb4..001c947 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -764,6 +764,12 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev)
 	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
 }
 
+size_t rtnl_get_nlmsg_size(const struct net_device *dev)
+{
+	return if_nlmsg_size(dev);
+}
+EXPORT_SYMBOL(rtnl_get_nlmsg_size);
+
 static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
 {
 	struct nlattr *vf_ports;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c8f35b5..5b1106c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1664,23 +1664,48 @@ static void netlink_destroy_callback(struct netlink_callback *cb)
 static int netlink_dump(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
+	struct net *net = sock_net(sk);
 	struct netlink_callback *cb;
 	struct sk_buff *skb;
 	struct nlmsghdr *nlh;
+	struct net_device *dev;
+	struct hlist_head *head;
+	struct hlist_node *node;
 	int len, err = -ENOBUFS;
-
-	skb = sock_rmalloc(sk, NLMSG_GOODSIZE, 0, GFP_KERNEL);
-	if (!skb)
-		goto errout;
+	int h, s_h;
+	int idx = 0, s_idx;
+	size_t alloc_size = NLMSG_GOODSIZE;
 
 	mutex_lock(nlk->cb_mutex);
 
 	cb = nlk->cb;
 	if (cb == NULL) {
 		err = -EINVAL;
-		goto errout_skb;
+		goto errout;
 	}
 
+	s_h = cb->args[0];
+	s_idx = cb->args[1];
+
+	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		hlist_for_each_entry(dev, node, head, index_hlist) {
+			if (idx < s_idx) {
+				idx++;
+				continue;
+			}
+			alloc_size = rtnl_get_nlmsg_size(dev);
+			if (alloc_size < NLMSG_GOODSIZE)
+				alloc_size = NLMSG_GOODSIZE;
+			break;
+		}
+	}
+
+	skb = sock_rmalloc(sk, alloc_size, 0, GFP_KERNEL);
+	if (!skb)
+		goto errout;
+
 	len = cb->dump(skb, cb);
 
 	if (len > 0) {
@@ -1717,9 +1742,9 @@ static int netlink_dump(struct sock *sk)
 	return 0;
 
 errout_skb:
-	mutex_unlock(nlk->cb_mutex);
 	kfree_skb(skb);
 errout:
+	mutex_unlock(nlk->cb_mutex);
 	return err;
 }
 

