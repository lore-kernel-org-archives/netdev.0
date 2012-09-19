From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCHv2 bridge 7/7] bridge:  Add the ability to show dump the vlan map from a bridge port
Date: Wed, 19 Sep 2012 08:42:16 -0400
Message-ID: <1348058536-22607-8-git-send-email-vyasevic@redhat.com>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756400Ab2ISMmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 08:42:24 -0400
In-Reply-To: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the RTM_GETLINK dump the vlan map of a given bridge port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/if_link.h |    1 +
 net/bridge/br_netlink.c |   73 +++++++++++++++++++++++++++++++++++++++++++---
 net/bridge/br_private.h |    2 +
 3 files changed, 71 insertions(+), 5 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 38dbcff..6953233 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -416,6 +416,7 @@ enum {
 	IFLA_BR_VLAN_UNSPEC,
 	IFLA_BR_VLAN_ADD,
 	IFLA_BR_VLAN_DEL,
+	IFLA_BR_VLAN_MAP,
 	__IFLA_BR_VLAN_MAX,
 };
 #define IFLA_BR_VLAN_MAX (__IFLA_BR_VLAN_MAX - 1)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 8a97f93..72fec1b 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -69,9 +69,35 @@ static int br_fill_ifinfo(struct sk_buff *skb, const struct net_bridge_port *por
 	     nla_put(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr)) ||
 	    (dev->ifindex != dev->iflink &&
 	     nla_put_u32(skb, IFLA_LINK, dev->iflink)) ||
-	    (event == RTM_NEWLINK &&
+	    ((event == RTM_NEWLINK || event == RTM_GETLINK) &&
 	     nla_put_u8(skb, IFLA_PROTINFO, port->state)))
 		goto nla_put_failure;
+
+	if (event == RTM_GETLINK) {
+		unsigned long *map = rcu_dereference(port->vlan_map);
+		struct nlattr *af;
+		struct nlattr *vidinfo;
+
+		if (!map)
+			goto done;
+
+		af = nla_nest_start(skb, IFLA_AF_SPEC);
+		if (!af)
+			goto nla_put_failure;
+
+		vidinfo = nla_nest_start(skb, IFLA_BR_VLAN_INFO);
+		if (!vidinfo)
+			goto nla_put_failure;
+
+		if (nla_put(skb, IFLA_BR_VLAN_MAP,
+			    BITS_TO_LONGS(br_vid(VLAN_N_VID)), map))
+			goto nla_put_failure;
+
+		nla_nest_end(skb, vidinfo);
+		nla_nest_end(skb, af);
+	}
+
+done:
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -129,7 +155,7 @@ static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 
 		if (br_fill_ifinfo(skb, port,
 				   NETLINK_CB(cb->skb).pid,
-				   cb->nlh->nlmsg_seq, RTM_NEWLINK,
+				   cb->nlh->nlmsg_seq, RTM_GETLINK,
 				   NLM_F_MULTI) < 0)
 			break;
 skip:
@@ -283,6 +309,36 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static size_t br_get_link_af_size(const struct net_device *dev)
+{
+	struct net_bridge_port *p;
+	unsigned long *map;
+
+	rcu_read_lock();
+	p = br_port_get_rcu(dev);
+	if (!p)
+		goto err;
+
+	map = rcu_dereference(p->vlan_map);
+	if (!map)
+		goto err;
+
+	rcu_read_unlock();
+
+	/* Account for the full bitmap length.  We are going to export the
+	 * whole bitmap.
+	 */
+	return nla_total_size(BITS_TO_LONGS(br_vid(VLAN_N_VID)));
+err:
+	rcu_read_unlock();
+	return 0;
+}
+
+struct rtnl_af_ops br_af_ops = {
+	.family			= AF_BRIDGE,
+	.get_link_af_size	= br_get_link_af_size,
+};
+
 struct rtnl_link_ops br_link_ops __read_mostly = {
 	.kind		= "bridge",
 	.priv_size	= sizeof(struct net_bridge),
@@ -299,19 +355,25 @@ int __init br_netlink_init(void)
 	if (err < 0)
 		goto err1;
 
+	err = rtnl_af_register(&br_af_ops);
+	if (err < 0)
+		goto err2;
+
 	err = __rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL,
 			      br_dump_ifinfo, NULL);
 	if (err)
-		goto err2;
+		goto err3;
 	err = __rtnl_register(PF_BRIDGE, RTM_SETLINK,
 			      br_rtm_setlink, NULL, NULL);
 	if (err)
-		goto err3;
+		goto err4;
 
 	return 0;
 
-err3:
+err4:
 	rtnl_unregister_all(PF_BRIDGE);
+err3:
+	rtnl_af_unregister(&br_af_ops);
 err2:
 	rtnl_link_unregister(&br_link_ops);
 err1:
@@ -320,6 +382,7 @@ err1:
 
 void __exit br_netlink_fini(void)
 {
+	rtnl_af_unregister(&br_af_ops);
 	rtnl_link_unregister(&br_link_ops);
 	rtnl_unregister_all(PF_BRIDGE);
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8eb3ffc..0575edb 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -419,6 +419,8 @@ extern netdev_features_t br_features_recompute(struct net_bridge *br,
 	netdev_features_t features);
 extern int br_set_port_vlan(struct net_bridge_port *p, unsigned short vid);
 extern int br_del_port_vlan(struct net_bridge_port *p, unsigned short vid);
+extern size_t br_port_fill_vlans(struct net_bridge_port *p, char *buf,
+				unsigned long max, unsigned long skip);
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
-- 
1.7.7.6
