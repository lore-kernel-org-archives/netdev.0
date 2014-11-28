From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 18/21] rocker: implement ndo_fdb_dump
Date: Fri, 28 Nov 2014 14:34:29 +0100
Message-ID: <1417181672-11531-19-git-send-email-jiri@resnulli.us>
References: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-wg0-f50.google.com ([74.125.82.50]:54148 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbaK1Ne4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 08:34:56 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so8854180wgh.37
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 05:34:55 -0800 (PST)
In-Reply-To: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
v4->v5:
-no change
v3->v4:
-ndm->ndm_flags set to NTF_SELF as pointed out by Scott
-use err to store retval of rocker_fdb_fill_info and break only in case < 0
new in v3
---
 drivers/net/ethernet/rocker/rocker.c | 73 ++++++++++++++++++++++++++++++++++++
 1 file changed, 73 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 6c15aa1..fea49e8 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3587,6 +3587,78 @@ static int rocker_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
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
+	ndm->ndm_flags	 = NTF_SELF;
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
+	int err;
+
+	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
+	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
+		if (found->key.lport != rocker_port->lport)
+			continue;
+		if (idx < cb->args[0])
+			goto skip;
+		addr = found->key.addr;
+		vid = rocker_port_vlan_to_vid(rocker_port, found->key.vlan_id);
+		err = rocker_fdb_fill_info(skb, rocker_port, addr, vid,
+					   NETLINK_CB(cb->skb).portid,
+					   cb->nlh->nlmsg_seq,
+					   RTM_NEWNEIGH, NLM_F_MULTI);
+		if (err < 0)
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
@@ -3614,6 +3686,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_vlan_rx_kill_vid		= rocker_port_vlan_rx_kill_vid,
 	.ndo_fdb_add			= rocker_port_fdb_add,
 	.ndo_fdb_del			= rocker_port_fdb_del,
+	.ndo_fdb_dump			= rocker_port_fdb_dump,
 	.ndo_switch_parent_id_get	= rocker_port_switch_parent_id_get,
 	.ndo_switch_port_stp_update	= rocker_port_switch_port_stp_update,
 };
-- 
1.9.3
