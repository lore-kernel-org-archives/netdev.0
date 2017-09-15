From: Vincent Bernat <vincent@bernat.im>
Subject: [PATCH net-next v1] bridge: also trigger RTM_NEWLINK when interface is released from bridge
Date: Fri, 15 Sep 2017 21:38:08 +0200
Message-ID: <20170915193808.22338-1-vincent@bernat.im>
Cc: Vincent Bernat <vincent@bernat.im>
To: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:52850 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751259AbdIOTrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 15 Sep 2017 15:47:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when an interface is released from a bridge, we get a
RTM_DELLINK event through netlink:

Deleted 2: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
    link/ether 6e:23:c2:54:3a:b3

Userspace has to interpret that as a removal from the bridge, not as a
complete removal of the interface. When an bridged interface is
completely removed, we get two events:

Deleted 2: dummy0: <BROADCAST,NOARP> mtu 1500 master bridge0 state DOWN
    link/ether 6e:23:c2:54:3a:b3
Deleted 2: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default
    link/ether 6e:23:c2:54:3a:b3 brd ff:ff:ff:ff:ff:ff

In constrast, when an interface is released from a bond, we get a
RTM_NEWLINK with only the new characteristics (no master):

3: dummy1: <BROADCAST,NOARP,SLAVE,UP,LOWER_UP> mtu 1500 qdisc noqueue master bond0 state UNKNOWN group default
    link/ether ae:dc:7a:8c:9a:3c brd ff:ff:ff:ff:ff:ff
3: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/ether ae:dc:7a:8c:9a:3c brd ff:ff:ff:ff:ff:ff
4: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether ae:dc:7a:8c:9a:3c brd ff:ff:ff:ff:ff:ff
3: dummy1: <BROADCAST,NOARP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether ae:dc:7a:8c:9a:3c brd ff:ff:ff:ff:ff:ff
3: dummy1: <BROADCAST,NOARP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether ca:c8:7b:66:f8:25 brd ff:ff:ff:ff:ff:ff
4: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether ae:dc:7a:8c:9a:3c brd ff:ff:ff:ff:ff:ff

Userland may be confused by the fact we say a link is deleted while
its characteristics are only modified. A first solution would have
been to turn the RTM_DELLINK event in del_nbp() into a RTM_NEWLINK
event. However, maybe some piece of userland is relying on this
RTM_DELLINK to detect when a bridged interface is released. Instead,
we also emit a RTM_NEWLINK event once the interface is
released (without master info).

Deleted 2: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
    link/ether 8a:bb:e7:94:b1:f8
2: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/ether 8a:bb:e7:94:b1:f8 brd ff:ff:ff:ff:ff:ff

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 net/bridge/br_if.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f3aef22931ab..636e0a842f8a 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -288,6 +288,8 @@ static void del_nbp(struct net_bridge_port *p)
 
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
+	rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_MASTER, GFP_KERNEL);
+
 	netdev_rx_handler_unregister(dev);
 
 	br_multicast_del_port(p);
-- 
2.14.1
