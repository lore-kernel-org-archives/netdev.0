From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: [PATCH] veth: Be more robust on network device creation when no attributes
Date: Fri, 16 Jun 2017 18:05:00 +0300
Message-ID: <1497625500-19440-1-git-send-email-serhe.popovych@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35120 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751980AbdFPPFF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 11:05:05 -0400
Received: by mail-lf0-f66.google.com with SMTP id v20so4505036lfa.2
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 08:05:04 -0700 (PDT)
Received: from tuxracer.synapse.com ([195.238.92.77])
        by smtp.gmail.com with ESMTPSA id y2sm488319ljd.41.2017.06.16.08.05.02
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 08:05:02 -0700 (PDT)
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

Second it is not possible to register main network device
with given name and automatically create peer network
device name. That happens because IFLA_IFNAME used when
creating main and reused when creating peer.

This case can be reproduced with following sequence:

  # ip link add dev veth1a type veth
  RTNETLINK answers: File exists

To fix both of the cases check if corresponding netlink
attributes are taken from peer_tb when valid or
name based on rtnl ops kind and random address is used.

Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
---
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
