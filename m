From: roy.qing.li@gmail.com
Subject: [PATCH][net-next][v2] bridge: allow the maximum mtu to 64k
Date: Tue, 23 Feb 2016 09:00:56 +0800
Message-ID: <1456189256-7811-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62965 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756093AbcBWBA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 20:00:58 -0500
Received: from localhost (lrq.corp.ad.wrs.com [128.224.162.139])
	by mail.windriver.com (8.15.2/8.15.1) with ESMTP id u1N10vBA009987
	for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 17:00:57 -0800 (PST)
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
 net/bridge/br_if.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c367b3e..a2ed99d 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -390,7 +390,9 @@ int br_del_bridge(struct net *net, const char *name)
 	return ret;
 }
 
-/* MTU of the bridge pseudo-device: ETH_DATA_LEN or the minimum of the ports */
+/* MTU of the bridge pseudo-device: the maximum IP packet size
+ * or the minimum of the ports
+ */
 int br_min_mtu(const struct net_bridge *br)
 {
 	const struct net_bridge_port *p;
@@ -399,7 +401,7 @@ int br_min_mtu(const struct net_bridge *br)
 	ASSERT_RTNL();
 
 	if (list_empty(&br->port_list))
-		mtu = ETH_DATA_LEN;
+		mtu = 64 * 1024;
 	else {
 		list_for_each_entry(p, &br->port_list, list) {
 			if (!mtu  || p->dev->mtu < mtu)
-- 
2.1.4
