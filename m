From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCHv2 next 2/3] ipvlan: mode is u16
Date: Wed, 10 Feb 2016 07:33:35 -0800
Message-ID: <1455118415-783-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33320 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbcBJPdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 10:33:40 -0500
Received: by mail-pf0-f177.google.com with SMTP id q63so13666501pfb.0
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 07:33:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

The mode argument was erronusly defined as u32 but it has always
been u16. Also use ipvlan_set_mode() helper to set the mode instead
of assigning directly. This should avoid future erronus assignments /
updates.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
v1: initial patch
v2: commit log update

 drivers/net/ipvlan/ipvlan.h      | 1 -
 drivers/net/ipvlan/ipvlan_main.c | 9 ++++++---
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 9542b7bac61a..817cab1a7959 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -115,7 +115,6 @@ static inline struct ipvl_port *ipvlan_port_get_rtnl(const struct net_device *d)
 }
 
 void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev);
-void ipvlan_set_port_mode(struct ipvl_port *port, u32 nval);
 void ipvlan_init_secret(void);
 unsigned int ipvlan_mac_hash(const unsigned char *addr);
 rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb);
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 7a3b41468a55..5bcb852c5500 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -14,7 +14,7 @@ void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev)
 	ipvlan->dev->mtu = dev->mtu - ipvlan->mtu_adj;
 }
 
-void ipvlan_set_port_mode(struct ipvl_port *port, u32 nval)
+static void ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
 {
 	struct ipvl_dev *ipvlan;
 
@@ -442,6 +442,7 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	struct ipvl_port *port;
 	struct net_device *phy_dev;
 	int err;
+	u16 mode = IPVLAN_MODE_L3;
 
 	if (!tb[IFLA_LINK])
 		return -EINVAL;
@@ -460,10 +461,10 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 			return err;
 	}
 
-	port = ipvlan_port_get_rtnl(phy_dev);
 	if (data && data[IFLA_IPVLAN_MODE])
-		port->mode = nla_get_u16(data[IFLA_IPVLAN_MODE]);
+		mode = nla_get_u16(data[IFLA_IPVLAN_MODE]);
 
+	port = ipvlan_port_get_rtnl(phy_dev);
 	ipvlan->phy_dev = phy_dev;
 	ipvlan->dev = dev;
 	ipvlan->port = port;
@@ -489,6 +490,8 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 		goto ipvlan_destroy_port;
 
 	list_add_tail_rcu(&ipvlan->pnode, &port->ipvlans);
+	ipvlan_set_port_mode(port, mode);
+
 	netif_stacked_transfer_operstate(phy_dev, dev);
 	return 0;
 
-- 
2.7.0.rc3.207.g0ac5344
