From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH net-next 3/3] bridge: Implement IFF_UNICAST_FLT
Date: Wed,  6 Mar 2013 21:31:25 -0500
Message-ID: <1362623485-18209-4-git-send-email-vyasevic@redhat.com>
References: <1362623485-18209-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758718Ab3CGCbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 21:31:33 -0500
In-Reply-To: <1362623485-18209-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement IFF_UNICAST_FLT on the bridge.  Unicast addresses added
to the bridge device are synched to the uplink devices.  This
allows for uplink devices to change while preserving mac assignment.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c |    9 ++++++++-
 net/bridge/br_fdb.c    |    6 ++++++
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index c525e36..61514c1 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -106,6 +106,13 @@ static int br_dev_open(struct net_device *dev)
 
 static void br_dev_set_multicast_list(struct net_device *dev)
 {
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_port *uplink;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(uplink, &br->uplink_list, uplink_list)
+		dev_uc_sync(uplink->dev, dev);
+	rcu_read_unlock();
 }
 
 static int br_dev_stop(struct net_device *dev)
@@ -384,7 +391,7 @@ void br_dev_setup(struct net_device *dev)
 	SET_ETHTOOL_OPS(dev, &br_ethtool_ops);
 	SET_NETDEV_DEVTYPE(dev, &br_type);
 	dev->tx_queue_len = 0;
-	dev->priv_flags = IFF_EBRIDGE;
+	dev->priv_flags = IFF_EBRIDGE | IFF_UNICAST_FLT;
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			NETIF_F_GSO_MASK | NETIF_F_HW_CSUM | NETIF_F_LLTX |
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index b0812c9..ef7b51e 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -677,6 +677,9 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	struct net_port_vlans *pv;
 	unsigned short vid = VLAN_N_VID;
 
+	if ((ndm->ndm_flags & NTF_SELF) && (dev->priv_flags & IFF_EBRIDGE))
+		return ndo_dflt_fdb_add(ndm, tb, dev, addr, nlh_flags);
+
 	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE))) {
 		pr_info("bridge: RTM_NEWNEIGH with invalid state %#x\n", ndm->ndm_state);
 		return -EINVAL;
@@ -774,6 +777,9 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 	struct net_port_vlans *pv;
 	unsigned short vid = VLAN_N_VID;
 
+	if ((ndm->ndm_flags & NTF_SELF) && (dev->priv_flags & IFF_EBRIDGE))
+		return ndo_dflt_fdb_del(ndm, tb, dev, addr);
+
 	if (tb[NDA_VLAN]) {
 		if (nla_len(tb[NDA_VLAN]) != sizeof(unsigned short)) {
 			pr_info("bridge: RTM_NEWNEIGH with invalid vlan\n");
-- 
1.7.7.6
