From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 14/21] bridge: add brport flags to dflt bridge_getlink
Date: Thu, 27 Nov 2014 11:40:19 +0100
Message-ID: <1417084826-9875-15-git-send-email-jiri@resnulli.us>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:42649 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377AbaK0Kkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 05:40:46 -0500
Received: by mail-wg0-f49.google.com with SMTP id x12so6069311wgg.22
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 02:40:45 -0800 (PST)
In-Reply-To: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

To allow brport device to return current brport flags set on port.  Add
returned flags to nested IFLA_PROTINFO netlink msg built in dflt getlink.
With this change, netlink msg returned for bridge_getlink contains the port's
offloaded flag settings (the port's SELF settings).

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
v3->v4:
-no change
new in v3
---
 drivers/net/ethernet/emulex/benet/be_main.c   |  3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  2 +-
 include/linux/rtnetlink.h                     |  3 ++-
 net/core/rtnetlink.c                          | 39 ++++++++++++++++++++++++++-
 4 files changed, 43 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9070b98..6510ec8 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4362,7 +4362,8 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev,
 				       hsw_mode == PORT_FWD_TYPE_VEPA ?
-				       BRIDGE_MODE_VEPA : BRIDGE_MODE_VEB);
+				       BRIDGE_MODE_VEPA : BRIDGE_MODE_VEB,
+				       0, 0);
 }
 
 #ifdef CONFIG_BE2NET_VXLAN
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1bad9f4..eb2a04b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7773,7 +7773,7 @@ static int ixgbe_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	else
 		mode = BRIDGE_MODE_VEPA;
 
-	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode);
+	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode, 0, 0);
 }
 
 static void *ixgbe_fwd_add(struct net_device *pdev, struct net_device *vdev)
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 063f0f5..3b04190 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -103,5 +103,6 @@ extern int ndo_dflt_fdb_del(struct ndmsg *ndm,
 			    u16 vid);
 
 extern int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-				   struct net_device *dev, u16 mode);
+				   struct net_device *dev, u16 mode,
+				   u32 flags, u32 mask);
 #endif	/* __LINUX_RTNETLINK_H */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b6541f2..7525ba3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2687,12 +2687,22 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
+static int brport_nla_put_flag(struct sk_buff *skb, u32 flags, u32 mask,
+			       unsigned int attrnum, unsigned int flag)
+{
+	if (mask & flag)
+		return nla_put_u8(skb, attrnum, !!(flags & flag));
+	return 0;
+}
+
 int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-			    struct net_device *dev, u16 mode)
+			    struct net_device *dev, u16 mode,
+			    u32 flags, u32 mask)
 {
 	struct nlmsghdr *nlh;
 	struct ifinfomsg *ifm;
 	struct nlattr *br_afspec;
+	struct nlattr *protinfo;
 	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
 	struct net_device *br_dev = netdev_master_upper_dev_get(dev);
 
@@ -2731,6 +2741,33 @@ int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	}
 	nla_nest_end(skb, br_afspec);
 
+	protinfo = nla_nest_start(skb, IFLA_PROTINFO | NLA_F_NESTED);
+	if (!protinfo)
+		goto nla_put_failure;
+
+	if (brport_nla_put_flag(skb, flags, mask,
+				IFLA_BRPORT_MODE, BR_HAIRPIN_MODE) ||
+	    brport_nla_put_flag(skb, flags, mask,
+				IFLA_BRPORT_GUARD, BR_BPDU_GUARD) ||
+	    brport_nla_put_flag(skb, flags, mask,
+				IFLA_BRPORT_FAST_LEAVE,
+				BR_MULTICAST_FAST_LEAVE) ||
+	    brport_nla_put_flag(skb, flags, mask,
+				IFLA_BRPORT_PROTECT, BR_ROOT_BLOCK) ||
+	    brport_nla_put_flag(skb, flags, mask,
+				IFLA_BRPORT_LEARNING, BR_LEARNING) ||
+	    brport_nla_put_flag(skb, flags, mask,
+				IFLA_BRPORT_LEARNING_SYNC, BR_LEARNING_SYNC) ||
+	    brport_nla_put_flag(skb, flags, mask,
+				IFLA_BRPORT_UNICAST_FLOOD, BR_FLOOD) ||
+	    brport_nla_put_flag(skb, flags, mask,
+				IFLA_BRPORT_PROXYARP, BR_PROXYARP)) {
+		nla_nest_cancel(skb, protinfo);
+		goto nla_put_failure;
+	}
+
+	nla_nest_end(skb, protinfo);
+
 	return nlmsg_end(skb, nlh);
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
-- 
1.9.3
