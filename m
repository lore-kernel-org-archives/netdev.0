From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] tun: teach the tun/tap driver to support netpoll
Date: Wed, 15 Jun 2011 11:25:01 -0400
Message-ID: <1308151501-8434-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Rik van Riel <riel@redhat.com>,
	Maxim Krasnyansky <maxk@qualcomm.com>,
	Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57378 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796Ab1FOPZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 11:25:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8d8fc29d02a33e4bd5f4fa47823c1fd386346093 changed the behavior of slave
devices in regards to netpoll.  Specifically it created a mutually exclusive
relationship between being a slave and a netpoll-capable device.  This creates
problems for KVM because guests relied on needing netconsole active on a slave
device to a bridge.  Ideally libvirtd could just attach netconsole to the bridge
device instead, but thats currently infeasible, because while the bridge device
supports netpoll, it requires that all slave interface also support it, but the
tun/tap driver currently does not.  The most direct solution is to teach tun/tap
to support netpoll, which is implemented by the patch below.

I've not tested this yet, but its pretty straightforward.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Rik van Riel <riel@redhat.com>
CC: Rik van Riel <riel@redhat.com>
CC: Maxim Krasnyansky <maxk@qualcomm.com>
CC: Cong Wang <amwang@redhat.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/tun.c |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4dab85e..9a6b382 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -460,7 +460,23 @@ static u32 tun_net_fix_features(struct net_device *dev, u32 features)
 
 	return (features & tun->set_features) | (features & ~TUN_USER_FEATURES);
 }
-
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void tun_poll_controller(struct net_device *dev)
+{
+	/*
+	 * Tun only receives frames when:
+	 * 1) the char device endpoint gets data from user space
+	 * 2) the tun socket gets a sendmsg call from user space
+	 * Since both of those are syncronous operations, we are guaranteed
+	 * never to have pending data when we poll for it
+	 * so theres nothing to do here but return.
+	 * We need this though so netpoll recognizes us as an interface that
+	 * supports polling, which enables bridge devices in virt setups to
+	 * still use netconsole
+	 */
+	return;
+}
+#endif
 static const struct net_device_ops tun_netdev_ops = {
 	.ndo_uninit		= tun_net_uninit,
 	.ndo_open		= tun_net_open,
@@ -468,6 +484,9 @@ static const struct net_device_ops tun_netdev_ops = {
 	.ndo_start_xmit		= tun_net_xmit,
 	.ndo_change_mtu		= tun_net_change_mtu,
 	.ndo_fix_features	= tun_net_fix_features,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= tun_poll_controller,
+#endif
 };
 
 static const struct net_device_ops tap_netdev_ops = {
@@ -480,6 +499,9 @@ static const struct net_device_ops tap_netdev_ops = {
 	.ndo_set_multicast_list	= tun_net_mclist,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= tun_poll_controller,
+#endif
 };
 
 /* Initialize net device. */
-- 
1.7.5.4

