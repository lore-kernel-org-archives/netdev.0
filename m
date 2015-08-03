From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] bridge: mdb: add/del entry on all vlans if vlan_filter is enabled and vid is 0
Date: Mon,  3 Aug 2015 13:29:16 +0200
Message-ID: <1438601356-20885-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org,
	Satish Ashok <sashok@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33989 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbbHCL3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 07:29:31 -0400
Received: by wibud3 with SMTP id ud3so131852172wib.1
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 04:29:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satish Ashok <sashok@cumulusnetworks.com>

Before this patch when a vid was not specified, the entry was added with
vid 0 which is useless when vlan_filtering is enabled. This patch makes
the entry to be added on all configured vlans when vlan filtering is
enabled and respectively deleted from all, if the entry vid is 0.
This is also closer to the way fdb works with regard to vid 0 and vlan
filtering.

Example:
Setup:
$ bridge vlan add vid 256 dev eth4
$ bridge vlan add vid 1024 dev eth4
$ bridge vlan add vid 64 dev eth3
$ bridge vlan add vid 128 dev eth3
$ bridge vlan
port	vlan ids
eth3	 1 PVID Egress Untagged
	 64
	 128

eth4	 1 PVID Egress Untagged
	 256
	 1024
$ echo 1 > /sys/class/net/br0/bridge/vlan_filtering

Before:
$ bridge mdb add dev br0 port eth3 grp 239.0.0.1
$ bridge mdb
dev br0 port eth3 grp 239.0.0.1 temp

After:
$ bridge mdb add dev br0 port eth3 grp 239.0.0.1
$ bridge mdb
dev br0 port eth3 grp 239.0.0.1 temp vid 1
dev br0 port eth3 grp 239.0.0.1 temp vid 128
dev br0 port eth3 grp 239.0.0.1 temp vid 64

Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_mdb.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 60 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 5e9d1c5e1194..a7185c09519f 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -464,8 +464,11 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
+	unsigned short vid = VLAN_N_VID;
+	struct net_device *dev, *pdev;
 	struct br_mdb_entry *entry;
-	struct net_device *dev;
+	struct net_bridge_port *p;
+	struct net_port_vlans *pv;
 	struct net_bridge *br;
 	int err;
 
@@ -475,9 +478,32 @@ static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	br = netdev_priv(dev);
 
-	err = __br_mdb_add(net, br, entry);
-	if (!err)
-		__br_mdb_notify(dev, entry, RTM_NEWMDB);
+	/* If vlan filtering is enabled and VLAN is not specified
+	 * install mdb entry on all vlans configured on the port.
+	 */
+	pdev = __dev_get_by_index(net, entry->ifindex);
+	if (!pdev)
+		return -ENODEV;
+
+	p = br_port_get_rtnl(pdev);
+	if (!p || p->br != br || p->state == BR_STATE_DISABLED)
+		return -EINVAL;
+
+	pv = nbp_get_vlan_info(p);
+	if (br->vlan_enabled && pv && entry->vid == 0) {
+		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
+			entry->vid = vid;
+			err = __br_mdb_add(net, br, entry);
+			if (err)
+				break;
+			__br_mdb_notify(dev, entry, RTM_NEWMDB);
+		}
+	} else {
+		err = __br_mdb_add(net, br, entry);
+		if (!err)
+			__br_mdb_notify(dev, entry, RTM_NEWMDB);
+	}
+
 	return err;
 }
 
@@ -538,8 +564,12 @@ unlock:
 
 static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	struct net_device *dev;
+	struct net *net = sock_net(skb->sk);
+	unsigned short vid = VLAN_N_VID;
+	struct net_device *dev, *pdev;
 	struct br_mdb_entry *entry;
+	struct net_bridge_port *p;
+	struct net_port_vlans *pv;
 	struct net_bridge *br;
 	int err;
 
@@ -549,9 +579,31 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	br = netdev_priv(dev);
 
-	err = __br_mdb_del(br, entry);
-	if (!err)
-		__br_mdb_notify(dev, entry, RTM_DELMDB);
+	/* If vlan filtering is enabled and VLAN is not specified
+	 * delete mdb entry on all vlans configured on the port.
+	 */
+	pdev = __dev_get_by_index(net, entry->ifindex);
+	if (!pdev)
+		return -ENODEV;
+
+	p = br_port_get_rtnl(pdev);
+	if (!p || p->br != br || p->state == BR_STATE_DISABLED)
+		return -EINVAL;
+
+	pv = nbp_get_vlan_info(p);
+	if (br->vlan_enabled && pv && entry->vid == 0) {
+		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
+			entry->vid = vid;
+			err = __br_mdb_del(br, entry);
+			if (!err)
+				__br_mdb_notify(dev, entry, RTM_DELMDB);
+		}
+	} else {
+		err = __br_mdb_del(br, entry);
+		if (!err)
+			__br_mdb_notify(dev, entry, RTM_DELMDB);
+	}
+
 	return err;
 }
 
-- 
2.4.3
