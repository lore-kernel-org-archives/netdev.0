From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: netlink: filter particular protocols from analyzers
Date: Thu,  5 Sep 2013 17:48:47 +0200
Message-ID: <1378396127-8342-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkmann@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63193 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753421Ab3IEPst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 11:48:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkmann@redhat.com>

Fix finer-grained control and let only a whitelist of allowed netlink
protocols pass, in our case related to networking. If later on, other
subsystems decide they want to add their protocol as well to the list
of allowed protocols they shall simply add it. While at it, we also
need to tell what protocol is in use otherwise BPF_S_ANC_PROTOCOL can
not pick it up (as it's not filled out).

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/netlink/af_netlink.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 0c61b59..350187e 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -168,16 +168,43 @@ int netlink_remove_tap(struct netlink_tap *nt)
 }
 EXPORT_SYMBOL_GPL(netlink_remove_tap);
 
+static bool netlink_filter_tap(const struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+	bool pass = false;
+
+	/* We take the more conservative approach and
+	 * whitelist socket protocols that may pass.
+	 */
+	switch (sk->sk_protocol) {
+	case NETLINK_ROUTE:
+	case NETLINK_USERSOCK:
+	case NETLINK_SOCK_DIAG:
+	case NETLINK_NFLOG:
+	case NETLINK_XFRM:
+	case NETLINK_FIB_LOOKUP:
+	case NETLINK_NETFILTER:
+	case NETLINK_GENERIC:
+		pass = true;
+		break;
+	}
+
+	return pass;
+}
+
 static int __netlink_deliver_tap_skb(struct sk_buff *skb,
 				     struct net_device *dev)
 {
 	struct sk_buff *nskb;
+	struct sock *sk = skb->sk;
 	int ret = -ENOMEM;
 
 	dev_hold(dev);
 	nskb = skb_clone(skb, GFP_ATOMIC);
 	if (nskb) {
 		nskb->dev = dev;
+		nskb->protocol = htons((u16) sk->sk_protocol);
+
 		ret = dev_queue_xmit(nskb);
 		if (unlikely(ret > 0))
 			ret = net_xmit_errno(ret);
@@ -192,6 +219,9 @@ static void __netlink_deliver_tap(struct sk_buff *skb)
 	int ret;
 	struct netlink_tap *tmp;
 
+	if (!netlink_filter_tap(skb))
+		return;
+
 	list_for_each_entry_rcu(tmp, &netlink_tap_all, list) {
 		ret = __netlink_deliver_tap_skb(skb, tmp->dev);
 		if (unlikely(ret))
-- 
1.8.3.1
