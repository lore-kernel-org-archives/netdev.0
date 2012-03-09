From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v1 3/4] net: add fdb generic dump routine
Date: Fri, 09 Mar 2012 14:48:07 -0800
Message-ID: <20120309224806.2514.50237.stgit@jf-dev1-dcblab>
References: <20120309223621.2514.82321.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, roprabhu@cisco.com, netdev@vger.kernel.org,
	mst@redhat.com, chrisw@redhat.com, davem@davemloft.net,
	gregory.v.rose@intel.com, kvm@vger.kernel.org, sri@us.ibm.com,
	chealy@imsco-us.com
To: jhs@mojatatu.com, shemminger@vyatta.com, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11056 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758603Ab2CIXAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2012 18:00:22 -0500
In-Reply-To: <20120309223621.2514.82321.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a generic dump routine drivers can call. It
should be sufficient to handle any bridging model that
uses the unicast address list. This should be most SR-IOV
enabled NICs.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/rtnetlink.c |   56 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 8c3278a..35ee2d6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2082,6 +2082,62 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	return err;
 }
 
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
+	struct netdev_hw_addr *ha;
+	struct nlmsghdr *nlh;
+	struct ndmsg *ndm;
+	u32 pid, seq;
+
+	pid = NETLINK_CB(cb->skb).pid;
+	seq = cb->nlh->nlmsg_seq;
+
+	netif_addr_lock_bh(dev);
+	list_for_each_entry(ha, &dev->uc.list, list) {
+		if (idx < cb->args[0])
+			goto skip;
+
+		nlh = nlmsg_put(skb, pid, seq,
+				RTM_NEWNEIGH, sizeof(*ndm), NLM_F_MULTI);
+		if (!nlh)
+			break;
+
+		ndm = nlmsg_data(nlh);
+		ndm->ndm_family  = AF_BRIDGE;
+		ndm->ndm_pad1	 = 0;
+		ndm->ndm_pad2    = 0;
+		ndm->ndm_flags	 = NTF_LOWERDEV;
+		ndm->ndm_type	 = 0;
+		ndm->ndm_ifindex = dev->ifindex;
+		ndm->ndm_state   = NUD_PERMANENT;
+
+		NLA_PUT(skb, NDA_LLADDR, ETH_ALEN, ha->addr);
+
+		nlmsg_end(skb, nlh);
+skip:
+		++idx;
+	}
+	netif_addr_unlock_bh(dev);
+
+	return idx;
+nla_put_failure:
+	netif_addr_unlock_bh(dev);
+	nlmsg_cancel(skb, nlh);
+	return idx;
+}
+EXPORT_SYMBOL(ndo_dflt_fdb_dump);
+
 static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx = 0;
