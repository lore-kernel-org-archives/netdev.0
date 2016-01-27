From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] macvlan: make operstate and carrier more accurate
Date: Wed, 27 Jan 2016 17:50:43 +0100
Message-ID: <1453913443-4934-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34154 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151AbcA0Qur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 11:50:47 -0500
Received: by mail-wm0-f68.google.com with SMTP id p63so4431997wmp.1
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 08:50:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Currently when a macvlan is being initialized and the lower device is
netif_carrier_ok(), the macvlan device doesn't run through
rfc2863_policy() and is left with UNKNOWN operstate. Fix it by adding an
unconditional linkwatch event for the new macvlan device. Similar fix is
already used by the 8021q device (see register_vlan_dev()). Also fix the
inconsistent state when the lower device has been down and its carrier
was changed (when a device is down NETDEV_CHANGE doesn't get generated).
The second issue can be seen f.e. when we have a macvlan on top of a 8021q
device which has been down and its real device has been changing carrier
states, after setting the 8021q device up, the macvlan device will have
the same carrier state as it was before even though the 8021q can now
have a different state.
Example for case 1:
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP mode DEFAULT group default qlen 1000

$ ip l add l eth2 macvl0 type macvlan
$ ip l set macvl0 up
$ ip l sh macvl0
72: macvl0@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
noqueue state UNKNOWN mode DEFAULT group default
    link/ether f6:0b:54:0a:9d:a3 brd ff:ff:ff:ff:ff:ff

Example for case 2 (order is important):
Prestate: eth2 UP/CARRIER, vlan1 down, vlan1-macvlan down
$ ip l set vlan1-macvlan up
$ ip l sh vlan1-macvlan
71: vlan1-macvlan@vlan1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/ether 4a:b8:44:56:b9:b9 brd ff:ff:ff:ff:ff:ff

[ eth2 loses CARRIER before vlan1 has been UP-ed ]

$ ip l sh eth2
4: eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast
state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:bf:57:16 brd ff:ff:ff:ff:ff:ff
$ ip l sh vlan1-macvlan
71: vlan1-macvlan@vlan1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/ether 4a:b8:44:56:b9:b9 brd ff:ff:ff:ff:ff:ff
$ ip l set vlan1 up
$ ip l sh vlan1
70: vlan1@eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc
noqueue state LOWERLAYERDOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:bf:57:16 brd ff:ff:ff:ff:ff:ff
$ ip l sh vlan1-macvlan
71: vlan1-macvlan@vlan1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/ether 4a:b8:44:56:b9:b9 brd ff:ff:ff:ff:ff:ff

vlan1-macvlan is still UP, still has carrier and is still in the same
operstate as before. After the patch in case 1 macvl0 has state UP as it
should and in case 2 vlan1-macvlan has state LOWERLAYERDOWN again as it
should. Note that while the lower macvlan device is down their carrier
and thus operstate can go out of sync but that will be fixed once the
lower device goes up again.
This behaviour seems to have been present since beginning of git history.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
Note: We've been having issues with routing daemons not operating correctly
due to the wrong oper states of the macvlan device.
If the behaviour change isn't acceptable, I'm open to other ideas on how
to get it fixed. To me this seemed like the least intrusive way to do it
and at the very least it removes the operation dependency (need to up the
lower device first and then the macvlan).

 drivers/net/macvlan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 6a57a005e0ca..94e688805dd2 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1323,6 +1323,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 
 	list_add_tail_rcu(&vlan->list, &port->vlans);
 	netif_stacked_transfer_operstate(lowerdev, dev);
+	linkwatch_fire_event(dev);
 
 	return 0;
 
@@ -1522,6 +1523,7 @@ static int macvlan_device_event(struct notifier_block *unused,
 	port = macvlan_port_get_rtnl(dev);
 
 	switch (event) {
+	case NETDEV_UP:
 	case NETDEV_CHANGE:
 		list_for_each_entry(vlan, &port->vlans, list)
 			netif_stacked_transfer_operstate(vlan->lowerdev,
-- 
2.4.3
