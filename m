From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH 2/3] net: expose ebridge FDB with priv flag
	IFF_OFFLOADED_FDB
Date: Tue, 28 Feb 2012 23:17:19 -0800
Message-ID: <20120229071719.10937.68718.stgit@jf-dev1-dcblab>
References: <20120229070418.10937.8692.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, bhutchings@solarflare.com, roprabhu@cisco.com,
	mst@redhat.com, netdev@vger.kernel.org, gregory.v.rose@intel.com,
	davem@davemloft.net
To: jhs@mojatatu.com, shemminger@vyatta.com, kernel@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36758 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030823Ab2B2HaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 02:30:22 -0500
In-Reply-To: <20120229070418.10937.8692.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a new private interface flag IFF_OFFLOADED_FDB and an
additional ndmsg flag NTF_EMBEDDED.

The private flag IFF_OFFLOADED_FDB should be set on devices to
indicate an embedded bridging component exists with a forwarding
database.

With this set PF_BRIDGE:{RTM_NEWNEIGH|RTM_DELNEIGH|RTM_GETNEIGH}
netlink msgs can manage the unicast address list on these devices
by setting the NTF_EMBEDDED flag in ndm_flags.

These commands are compatible with the SW bridge allowing the same
user space tools to be used with both SW bridges and HW bridges.

PF_BRIDGE:RTM_NEWNEIGH - adds an address to the unicast mac address
			 list. This fails if the address already
			 exists in the list. We do not allow user
			 space to bump the reference count on the
			 address list.
PF_BRIDGE:RTM_DELNEIGH - deletes an address in the unicast mac
			 address list if it exists.
PF_BRIDGE:RTM_GETNEIGH - dumps the unicast mac address list.

Examples session using the 'br'[1] tool to add, dump and then
delete a mac address with a new "embedded" option:

# ./br fdb add embedded 00:1b:21:55:23:ac dev eth6_rename
# ./br fdb
port			mac addr                flags
Embedded eth6_rename    00:1b:21:55:23:aa       local
Embedded eth6_rename    00:1b:21:55:23:ab       local
Embedded eth6_rename    00:1b:21:55:23:ac       local
	 veth2		76:99:5e:bf:e6:52       local
	 eth6_rename	00:1b:21:55:23:59       local
	 veth0		c6:09:6e:6c:7d:54       local

[1] 'br' tool was published as an RFC here and will be renamed 'bridge'
    http://patchwork.ozlabs.org/patch/117664/

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/if.h        |    2 -
 include/linux/neighbour.h |    2 +
 net/bridge/br_netlink.c   |  144 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 146 insertions(+), 2 deletions(-)

diff --git a/include/linux/if.h b/include/linux/if.h
index f995c66..bd0efbc 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -81,7 +81,7 @@
 #define IFF_UNICAST_FLT	0x20000		/* Supports unicast filtering	*/
 #define IFF_TEAM_PORT	0x40000		/* device used as team port */
 #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS */
-
+#define IFF_OFFLOADED_FDB 0x100000	/* devices used with HW FDB */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index b188f68..9a478d3 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -33,6 +33,8 @@ enum {
 #define NTF_PROXY	0x08	/* == ATF_PUBL */
 #define NTF_ROUTER	0x80
 
+#define NTF_EMBEDDED	0x02	/* PF_BRIDGE embedded entry */
+
 /*
  *	Neighbor Cache Entry States.
  */
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 9e70191..7b1a581 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -211,6 +211,57 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static int rtnl_offloaded_fdb_add(struct nlmsghdr *nlh, struct net_device *dev)
+{
+	struct ndmsg *ndm;
+	struct netdev_hw_addr *ha;
+	struct nlattr *tb[NDA_MAX+1];
+	__u8 *addr;
+	int err;
+
+	ASSERT_RTNL();
+
+	if (!(dev->priv_flags & IFF_OFFLOADED_FDB))
+		return -ENODEV;
+
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
+	if (err < 0)
+		return err;
+
+	ndm = nlmsg_data(nlh);
+	if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) != ETH_ALEN) {
+		pr_info("fdb_add: RTM_NEWNEIGH with invalid address\n");
+		return -EINVAL;
+	}
+
+	addr = nla_data(tb[NDA_LLADDR]);
+	if (!is_valid_ether_addr(addr)) {
+		pr_info("fdb_add: RTM_NEWNEIGH with invalid ether address\n");
+		return -EINVAL;
+	}
+
+	if (ndm->ndm_state & NUD_PERMANENT) {
+		pr_info("fdb_add: RTM_NEWNEIGH with invalid state %#x\n",
+			ndm->ndm_state);
+		return -EINVAL;
+	}
+
+	if (is_multicast_ether_addr(addr))
+		return -EINVAL;
+
+	netif_addr_lock_bh(dev);
+	list_for_each_entry(ha, &dev->uc.list, list) {
+		if (!compare_ether_addr(ha->addr, addr)) {
+			netif_addr_unlock_bh(dev);
+			return -EEXIST;
+		}
+	}
+	netif_addr_unlock_bh(dev);
+
+	err = dev_uc_add(dev, addr);
+	return err;
+}
+
 static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -235,7 +286,9 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		return -ENODEV;
 	}
 
-	if (dev->priv_flags & IFF_BRIDGE_PORT)
+	if (ndm->ndm_flags & NTF_EMBEDDED)
+		err = rtnl_offloaded_fdb_add(nlh, dev);
+	else if (dev->priv_flags & IFF_BRIDGE_PORT)
 		err = br_fdb_add(nlh, dev);
 	else
 		err = -ENODEV;
@@ -243,6 +296,43 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	return err;
 }
 
+static int rtnl_offloaded_fdb_del(struct nlmsghdr *nlh, struct net_device *dev)
+{
+	struct ndmsg *ndm;
+	struct nlattr *tb[NDA_MAX+1];
+	__u8 *addr;
+	int err;
+
+	ASSERT_RTNL();
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
+	if (err < 0)
+		return err;
+
+	ndm = nlmsg_data(nlh);
+	if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) != ETH_ALEN) {
+		pr_info("fdb_add: RTM_NEWNEIGH with invalid address\n");
+		return -EINVAL;
+	}
+
+	addr = nla_data(tb[NDA_LLADDR]);
+	if (!is_valid_ether_addr(addr)) {
+		pr_info("fdb_add: RTM_NEWNEIGH with invalid ether address\n");
+		return -EINVAL;
+	}
+
+	if (ndm->ndm_state & NUD_PERMANENT) {
+		pr_info("fdb_add: RTM_NEWNEIGH with invalid state %#x\n",
+			ndm->ndm_state);
+		return -EINVAL;
+	}
+
+	if (is_multicast_ether_addr(addr))
+		return -EINVAL;
+
+	err = dev_uc_del(dev, addr);
+	return err;
+}
+
 static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -268,12 +358,61 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 	if (dev->priv_flags & IFF_BRIDGE_PORT)
 		err = br_fdb_del(nlh, dev);
+	else if (dev->priv_flags & IFF_OFFLOADED_FDB)
+		err = rtnl_offloaded_fdb_del(nlh, dev);
 	else
 		err = -ENODEV;
 
 	return err;
 }
 
+static int rtnl_offloaded_fdb_dump(struct sk_buff *skb,
+				   struct netlink_callback *cb,
+				   struct net_device *dev,
+				   int idx)
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
+		ndm->ndm_flags	 = NTF_EMBEDDED;
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
+
 static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx = 0;
@@ -284,6 +423,9 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	for_each_netdev_rcu(net, dev) {
 		if (dev->priv_flags & IFF_EBRIDGE)
 			idx = br_fdb_dump(skb, cb, dev, idx);
+
+		if (dev->priv_flags & IFF_OFFLOADED_FDB)
+			idx = rtnl_offloaded_fdb_dump(skb, cb, dev, idx);
 	}
 	rcu_read_unlock();
 
