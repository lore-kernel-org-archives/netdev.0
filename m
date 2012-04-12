From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v2 4/8] net: rtnetlink notify events for FDB NTF_SELF
	adds and deletes
Date: Wed, 11 Apr 2012 23:57:31 -0700
Message-ID: <20120412065730.3112.66554.stgit@jf-dev1-dcblab>
References: <20120412064858.3112.65818.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com
To: shemminger@vyatta.com, mst@redhat.com, davem@davemloft.net,
	bhutchings@solarflare.com, sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55079 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757468Ab2DLHKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 03:10:35 -0400
In-Reply-To: <20120412064858.3112.65818.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is useful to be able to monitor for FDB events in user space.
This patch adds support to generate netlink events when a change
is made to a device supporting the FDB ops.

This brings embedded switches inline with the SW net/bridge which
triggers events on FDB updates as well.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/rtnetlink.c |   35 +++++++++++++++++++++++++++++++++--
 1 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 347c420..4b7ed7b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2011,6 +2011,33 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static inline size_t rtnl_fdb_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct ndmsg)) + nla_total_size(ETH_ALEN);
+}
+
+static void rtnl_fdb_notify(struct net_device *dev, u8 *addr, int type)
+{
+	struct net *net = dev_net(dev);
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(rtnl_fdb_nlmsg_size(), GFP_ATOMIC);
+	if (!skb)
+		goto errout;
+
+	err = nlmsg_populate_fdb_fill(skb, dev, addr, 0, 0, type, NTF_SELF);
+	if (err < 0) {
+		kfree_skb(skb);
+		goto errout;
+	}
+
+	rtnl_notify(skb, net, 0, RTNLGRP_NEIGH, NULL, GFP_ATOMIC);
+	return;
+errout:
+	rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
+}
+
 static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -2067,8 +2094,10 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		err = dev->netdev_ops->ndo_fdb_add(ndm, dev, addr,
 						   nlh->nlmsg_flags);
 
-		if (!err)
+		if (!err) {
+			rtnl_fdb_notify(dev, addr, RTM_NEWNEIGH);
 			ndm->ndm_flags &= ~NTF_SELF;
+		}
 	}
 out:
 	return err;
@@ -2125,8 +2154,10 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	if ((ndm->ndm_flags & NTF_SELF) && dev->netdev_ops->ndo_fdb_del) {
 		err = dev->netdev_ops->ndo_fdb_del(ndm, dev, addr);
 
-		if (!err)
+		if (!err) {
+			rtnl_fdb_notify(dev, addr, RTM_DELNEIGH);
 			ndm->ndm_flags &= ~NTF_SELF;
+		}
 	}
 out:
 	return err;
