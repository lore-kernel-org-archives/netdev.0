From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 12/17] rocker: implement ndo_fdb_dump
Date: Tue, 25 Nov 2014 11:28:43 +0100
Message-ID: <1416911328-10979-13-git-send-email-jiri@resnulli.us>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
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
	bcrl@kvack.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:32820 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186AbaKYK3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 05:29:07 -0500
Received: by mail-wi0-f180.google.com with SMTP id n3so894875wiv.13
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 02:29:06 -0800 (PST)
In-Reply-To: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
new in v3
---
 drivers/net/ethernet/rocker/rocker.c | 71 ++++++++++++++++++++++++++++++++++++
 1 file changed, 71 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 6c15aa1..1434497 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3587,6 +3587,76 @@ static int rocker_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 	return rocker_port_fdb(rocker_port, addr, vlan_id, flags);
 }
 
+static int rocker_fdb_fill_info(struct sk_buff *skb,
+				struct rocker_port *rocker_port,
+				const unsigned char *addr, u16 vid,
+				u32 portid, u32 seq, int type,
+				unsigned int flags)
+{
+	struct nlmsghdr *nlh;
+	struct ndmsg *ndm;
+
+	nlh = nlmsg_put(skb, portid, seq, type, sizeof(*ndm), flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	ndm = nlmsg_data(nlh);
+	ndm->ndm_family	 = AF_BRIDGE;
+	ndm->ndm_pad1    = 0;
+	ndm->ndm_pad2    = 0;
+	ndm->ndm_flags	 = 0;
+	ndm->ndm_type	 = 0;
+	ndm->ndm_ifindex = rocker_port->dev->ifindex;
+	ndm->ndm_state   = NUD_REACHABLE;
+
+	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, addr))
+		goto nla_put_failure;
+
+	if (vid && nla_put_u16(skb, NDA_VLAN, vid))
+		goto nla_put_failure;
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static int rocker_port_fdb_dump(struct sk_buff *skb,
+				struct netlink_callback *cb,
+				struct net_device *dev,
+				struct net_device *filter_dev,
+				int idx)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_fdb_tbl_entry *found;
+	struct hlist_node *tmp;
+	int bkt;
+	unsigned long lock_flags;
+	const unsigned char *addr;
+	u16 vid;
+
+	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
+	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
+		if (found->key.lport != rocker_port->lport)
+			continue;
+		if (idx < cb->args[0])
+			goto skip;
+		addr = found->key.addr;
+		vid = rocker_port_vlan_to_vid(rocker_port, found->key.vlan_id);
+		if (rocker_fdb_fill_info(skb, rocker_port, addr, vid,
+					 NETLINK_CB(cb->skb).portid,
+					 cb->nlh->nlmsg_seq,
+					 RTM_NEWNEIGH, NLM_F_MULTI))
+			break;
+skip:
+		++idx;
+	}
+	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, lock_flags);
+	return idx;
+}
+
 static int rocker_port_switch_parent_id_get(struct net_device *dev,
 					    struct netdev_phys_item_id *psid)
 {
@@ -3614,6 +3684,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_vlan_rx_kill_vid		= rocker_port_vlan_rx_kill_vid,
 	.ndo_fdb_add			= rocker_port_fdb_add,
 	.ndo_fdb_del			= rocker_port_fdb_del,
+	.ndo_fdb_dump			= rocker_port_fdb_dump,
 	.ndo_switch_parent_id_get	= rocker_port_switch_parent_id_get,
 	.ndo_switch_port_stp_update	= rocker_port_switch_port_stp_update,
 };
-- 
1.9.3
