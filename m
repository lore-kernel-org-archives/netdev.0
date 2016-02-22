From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] bridge: increase mtu to 9000
Date: Mon, 22 Feb 2016 17:29:11 +0800
Message-ID: <1456133351-10292-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:46719 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149AbcBVJ3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 04:29:13 -0500
Received: from localhost (lrq.corp.ad.wrs.com [128.224.162.139])
	by mail.windriver.com (8.15.2/8.15.1) with ESMTP id u1M9TCwO028845
	for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 01:29:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

A linux bridge always adopts the smallest MTU of the enslaved devices.
When no device are enslaved, it defaults to a MTU of 1500 and refuses to
use a larger one. This is problematic when using bridges enslaving only
virtual NICs (vnetX) like it's common with KVM guests.

Steps to reproduce the problem

1) sudo ip link add br-test0 type bridge # create an empty bridge
2) sudo ip link set br-test0 mtu 9000 # attempt to set MTU > 1500
3) ip link show dev br-test0 # confirm MTU

Here, 2) returns "RTNETLINK answers: Invalid argument". One (cumbersome)
way around this is:

4) sudo modprobe dummy
5) sudo ip link set dummy0 mtu 9000 master br-test0

Then the bridge's MTU can be changed from anywhere to 9000.

This is especially annoying for the virtualization case because the
KVM's tap driver will by default adopt the bridge's MTU on startup
making it impossible (without the workaround) to use a large MTU on the
guest VMs.

https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1399064

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/bridge/br_if.c      | 4 ++--
 net/bridge/br_private.h | 2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c367b3e..38ced44 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -390,7 +390,7 @@ int br_del_bridge(struct net *net, const char *name)
 	return ret;
 }
 
-/* MTU of the bridge pseudo-device: ETH_DATA_LEN or the minimum of the ports */
+/* MTU of the bridge pseudo-device: BR_JUMBO_MTU or the minimum of the ports */
 int br_min_mtu(const struct net_bridge *br)
 {
 	const struct net_bridge_port *p;
@@ -399,7 +399,7 @@ int br_min_mtu(const struct net_bridge *br)
 	ASSERT_RTNL();
 
 	if (list_empty(&br->port_list))
-		mtu = ETH_DATA_LEN;
+		mtu = BR_JUMBO_MTU;
 	else {
 		list_for_each_entry(p, &br->port_list, list) {
 			if (!mtu  || p->dev->mtu < mtu)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 302ab0a..d3c29f6 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -32,6 +32,8 @@
 
 #define BR_VERSION	"2.3"
 
+#define BR_JUMBO_MTU		9000
+
 /* Control of forwarding link local multicast */
 #define BR_GROUPFWD_DEFAULT	0
 /* Don't allow forwarding of control protocols like STP, MAC PAUSE and LACP */
-- 
2.1.4
