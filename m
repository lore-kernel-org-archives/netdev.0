From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: veth: Be more robust on network device creation when no attributes
Date: Wed, 21 Jun 2017 12:02:16 +0300
Message-ID: <1498035736-9330-1-git-send-email-serhe.popovych@gmail.com>
References: <20170620.124059.822096659295374001.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36756 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750927AbdFUJC2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 05:02:28 -0400
Received: by mail-wr0-f193.google.com with SMTP id 77so24667653wrb.3
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 02:02:27 -0700 (PDT)
In-Reply-To: <20170620.124059.822096659295374001.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are number of problems with configuration peer
network device in absence of IFLA_VETH_PEER attributes
where attributes for main network device shared with
peer.

First it is not feasible to configure both network
devices with same MAC address since this makes
communication in such configuration problematic.

This case can be reproduced with following sequence:

  # ip link add address 02:11:22:33:44:55 type veth
  # ip li sh
  ...
  26: veth0@veth1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc \
  noop state DOWN mode DEFAULT qlen 1000
      link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff
  27: veth1@veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc \
  noop state DOWN mode DEFAULT qlen 1000
      link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff

Second it is not possible to register both main and
peer network devices with same name, that happens
when name for main interface is given with IFLA_IFNAME
and same attribute reused for peer.

This case can be reproduced with following sequence:

  # ip link add dev veth1a type veth
  RTNETLINK answers: File exists

To fix both of the cases check if corresponding netlink
attributes are taken from peer_tb when valid or
name based on rtnl ops kind and random address is used.

Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
---
 v2: Rebase to kernel/davem/net.git
 
 drivers/net/veth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 0689433..17714db 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -383,7 +383,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 		tbp = tb;
 	}
 
-	if (tbp[IFLA_IFNAME]) {
+	if (ifmp && tbp[IFLA_IFNAME]) {
 		nla_strlcpy(ifname, tbp[IFLA_IFNAME], IFNAMSIZ);
 		name_assign_type = NET_NAME_USER;
 	} else {
@@ -402,7 +402,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 		return PTR_ERR(peer);
 	}
 
-	if (tbp[IFLA_ADDRESS] == NULL)
+	if (!ifmp || !tbp[IFLA_ADDRESS])
 		eth_hw_addr_random(peer);
 
 	if (ifmp && dev->ifindex > 0)
-- 
1.8.3.1
