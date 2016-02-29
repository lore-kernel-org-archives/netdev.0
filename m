From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 2/3] ipvlan: Implement L3-symmetric mode.
Date: Mon, 29 Feb 2016 14:08:20 -0800
Message-ID: <1456783700-18675-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36510 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754163AbcB2WIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 17:08:24 -0500
Received: by mail-pf0-f194.google.com with SMTP id q129so3445358pfb.3
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:08:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Current packet processing from IPtables perspective is asymmetric
for IPvlan L3 mode. On egress path, packets hit LOCAL_OUT and
POST_ROUTING hooks in slave-ns as well as master's ns however
during ingress path, LOCAL_IN and PRE_ROUTING hooks are hit only
in slave's ns. L3 mode is restrictive and uses master's L3 for
packet processing, so it does not make sense to skip these hooks
in ingress path in master's ns.

The changes in this patch nominates master-dev to be the device
for L3 ingress processing when skb device is the IPvlan slave.
Since master device is used for L3 processing, the IPT hooks are
hit in master's ns making the packet processing symmetric.

The other minor change this patch does to add a force parameter
for set_port_mode() to ensure correct settings are set during the
device initialization phase.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Eric Dumazet <edumazet@google.com>
CC: Tim Hockin <thockin@google.com>
CC: Alex Pollitt <alex.pollitt@metaswitch.com>
CC: Matthew Dupre <matthew.dupre@metaswitch.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 5802b9025765..734c25e52c60 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -14,16 +14,19 @@ static void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev)
 	ipvlan->dev->mtu = dev->mtu - ipvlan->mtu_adj;
 }
 
-static void ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
+static void ipvlan_set_port_mode(struct ipvl_port *port, u16 nval, bool force)
 {
 	struct ipvl_dev *ipvlan;
 
-	if (port->mode != nval) {
+	if (port->mode != nval || force) {
 		list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
-			if (nval == IPVLAN_MODE_L3)
+			if (nval == IPVLAN_MODE_L3) {
 				ipvlan->dev->flags |= IFF_NOARP;
-			else
+				ipvlan->dev->l3_dev = port->dev;
+			} else {
 				ipvlan->dev->flags &= ~IFF_NOARP;
+				ipvlan->dev->l3_dev = ipvlan->dev;
+			}
 		}
 		port->mode = nval;
 	}
@@ -392,7 +395,7 @@ static int ipvlan_nl_changelink(struct net_device *dev,
 	if (data && data[IFLA_IPVLAN_MODE]) {
 		u16 nmode = nla_get_u16(data[IFLA_IPVLAN_MODE]);
 
-		ipvlan_set_port_mode(port, nmode);
+		ipvlan_set_port_mode(port, nmode, false);
 	}
 	return 0;
 }
@@ -479,7 +482,6 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	memcpy(dev->dev_addr, phy_dev->dev_addr, ETH_ALEN);
 
 	dev->priv_flags |= IFF_IPVLAN_SLAVE;
-
 	port->count += 1;
 	err = register_netdevice(dev);
 	if (err < 0)
@@ -490,7 +492,7 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 		goto ipvlan_destroy_port;
 
 	list_add_tail_rcu(&ipvlan->pnode, &port->ipvlans);
-	ipvlan_set_port_mode(port, mode);
+	ipvlan_set_port_mode(port, mode, true);
 
 	netif_stacked_transfer_operstate(phy_dev, dev);
 	return 0;
-- 
2.7.0.rc3.207.g0ac5344
