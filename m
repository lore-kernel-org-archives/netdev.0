From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch v2 net-next] veth: add netpoll support
Date: Mon, 23 Jun 2014 15:36:02 -0700
Message-ID: <1403562962-17502-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Stefan Priebe <s.priebe@profihost.ag>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:56545 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbaFWWg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 18:36:29 -0400
Received: by mail-pd0-f173.google.com with SMTP id r10so6165991pdi.18
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2014 15:36:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is trivial to add netpoll support to veth, since
it is not a stacked device, we don't need to setup and
clean up netpoll.

Reported-by: Stefan Priebe <s.priebe@profihost.ag>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Neil Horman <nhorman@tuxdriver.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/veth.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index b4a10bc..9b945e6 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -248,6 +248,21 @@ static void veth_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void veth_poll_controller(struct net_device *dev)
+{
+	/* veth only receives frames when its peer sends one
+	 * Since it's a synchronous operation, we are guaranteed
+	 * never to have pending data when we poll for it so
+	 * there is nothing to do here.
+	 *
+	 * We need this though so netpoll recognizes us as an interface that
+	 * supports polling, which enables bridge devices in virt setups to
+	 * still use netconsole
+	 */
+}
+#endif	/* CONFIG_NET_POLL_CONTROLLER */
+
 static const struct net_device_ops veth_netdev_ops = {
 	.ndo_init            = veth_dev_init,
 	.ndo_open            = veth_open,
@@ -257,6 +272,9 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_get_stats64     = veth_get_stats64,
 	.ndo_set_rx_mode     = veth_set_multicast_list,
 	.ndo_set_mac_address = eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= veth_poll_controller,
+#endif
 };
 
 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
-- 
1.8.3.1
