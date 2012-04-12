From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v2 3/8] net: add fdb generic dump routine
Date: Wed, 11 Apr 2012 23:57:25 -0700
Message-ID: <20120412065725.3112.24113.stgit@jf-dev1-dcblab>
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
Received: from mga09.intel.com ([134.134.136.24]:2982 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757468Ab2DLHK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 03:10:29 -0400
In-Reply-To: <20120412064858.3112.65818.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a generic dump routine drivers can call. It
should be sufficient to handle any bridging model that
uses the unicast address list. This should be most SR-IOV
enabled NICs.

v2: return error on nlmsg_put and use -EMSGSIZE instead
    of -ENOMEM this is inline other usages

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/rtnetlink.c |   84 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 84 insertions(+), 0 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5ec09d5..347c420 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1980,6 +1980,37 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_LINK, err);
 }
 
+static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
+				   struct net_device *dev,
+				   u8 *addr, u32 pid, u32 seq,
+				   int type, unsigned int flags)
+{
+	struct nlmsghdr *nlh;
+	struct ndmsg *ndm;
+
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ndm), NLM_F_MULTI);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	ndm = nlmsg_data(nlh);
+	ndm->ndm_family  = AF_BRIDGE;
+	ndm->ndm_pad1	 = 0;
+	ndm->ndm_pad2    = 0;
+	ndm->ndm_flags	 = flags;
+	ndm->ndm_type	 = 0;
+	ndm->ndm_ifindex = dev->ifindex;
+	ndm->ndm_state   = NUD_PERMANENT;
+
+	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, addr))
+		goto nla_put_failure;
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
 static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -2101,6 +2132,59 @@ out:
 	return err;
 }
 
+static int nlmsg_populate_fdb(struct sk_buff *skb,
+			      struct netlink_callback *cb,
+			      struct net_device *dev,
+			      int *idx,
+			      struct netdev_hw_addr_list *list)
+{
+	struct netdev_hw_addr *ha;
+	int err;
+	u32 pid, seq;
+
+	pid = NETLINK_CB(cb->skb).pid;
+	seq = cb->nlh->nlmsg_seq;
+
+	list_for_each_entry(ha, &list->list, list) {
+		if (*idx < cb->args[0])
+			goto skip;
+
+		err = nlmsg_populate_fdb_fill(skb, dev, ha->addr,
+					      pid, seq, 0, NTF_SELF);
+		if (err < 0)
+			break;
+skip:
+		*idx += 1;
+	}
+	return 0;
+}
+
+/**
+ * ndo_dflt_fdb_dump: default netdevice operation to dump an FDB table.
+ * @nlh: netlink message header
+ * @dev: netdevice
+ *
+ * Default netdevice operation to dump the existing unicast address list.
+ * Returns zero on success.
+ */
+int ndo_dflt_fdb_dump(struct sk_buff *skb,
+		      struct netlink_callback *cb,
+		      struct net_device *dev,
+		      int idx)
+{
+	int err;
+
+	netif_addr_lock_bh(dev);
+	err = nlmsg_populate_fdb(skb, cb, dev, &idx, &dev->uc);
+	if (err)
+		goto out;
+	nlmsg_populate_fdb(skb, cb, dev, &idx, &dev->mc);
+out:
+	netif_addr_unlock_bh(dev);
+	return idx;
+}
+EXPORT_SYMBOL(ndo_dflt_fdb_dump);
+
 static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx = 0;
