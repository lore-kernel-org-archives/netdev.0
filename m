From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH v2 net-next 3/3] bridge: Implement IFF_UNICAST_FLT
Date: Thu,  7 Mar 2013 16:28:48 -0500
Message-ID: <1362691728-13289-4-git-send-email-vyasevic@redhat.com>
References: <1362691728-13289-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4352 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932858Ab3CGV2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 16:28:54 -0500
In-Reply-To: <1362691728-13289-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement IFF_UNICAST_FLT on the bridge.  Unicast addresses added
to the bridge device are synched to the uplink devices.  This
allows for uplink devices to change while preserving mac assignment.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c |   11 ++++++++++-
 net/bridge/br_fdb.c    |    6 ++++++
 net/bridge/br_if.c     |    2 ++
 3 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 37f611f..91fff56 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -106,6 +106,15 @@ static int br_dev_open(struct net_device *dev)
 
 static void br_dev_set_multicast_list(struct net_device *dev)
 {
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_port *port;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(port, &br->port_list, list) {
+		if (port->flags & BR_UPLINK)
+			dev_uc_sync(uplink->dev, dev);
+	}
+	rcu_read_unlock();
 }
 
 static int br_dev_stop(struct net_device *dev)
@@ -384,7 +393,7 @@ void br_dev_setup(struct net_device *dev)
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
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 02b4440..5196a79 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -145,6 +145,8 @@ static void del_nbp(struct net_bridge_port *p)
 
 	nbp_vlan_flush(p);
 	br_fdb_delete_by_port(br, p, 1);
+	if (p->flags & BR_UPLINK)
+		dev_uc_unsync(dev, br->dev);
 
 	list_del_rcu(&p->list);
 
-- 
1.7.7.6
