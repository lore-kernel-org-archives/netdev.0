From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v3 4/5] net/tun: implement ndo_set_rx_headroom
Date: Fri, 26 Feb 2016 10:45:40 +0100
Message-ID: <e9bd024c342f52a77872a0642669e3b44d224213.1456412101.git.pabeni@redhat.com>
References: <cover.1456412101.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752443AbcBZJqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 04:46:12 -0500
In-Reply-To: <cover.1456412101.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ndo_set_rx_headroom controls the align value used by tun devices to
allocate skbs on frame reception.
When the xmit device adds a large encapsulation, this avoids an skb
head reallocation on forwarding.

The measured improvement when forwarding towards a vxlan dev with
frame size below the egress device MTU is as follow:

vxlan over ipv6, bridged: +6%
vxlan over ipv6, ovs: +7%

In case of ipv4 tunnels there is no improvement, since the tun
device default alignment provides enough headroom to avoid the skb
head reallocation.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
v2: initialize the align value to NET_SKB_PAD
---
 drivers/net/tun.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 88bb8cc..afdf950 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -187,6 +187,7 @@ struct tun_struct {
 #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
 			  NETIF_F_TSO6|NETIF_F_UFO)
 
+	int			align;
 	int			vnet_hdr_sz;
 	int			sndbuf;
 	struct tap_filter	txflt;
@@ -934,6 +935,17 @@ static void tun_poll_controller(struct net_device *dev)
 	return;
 }
 #endif
+
+static void tun_set_headroom(struct net_device *dev, int new_hr)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+
+	if (new_hr < NET_SKB_PAD)
+		new_hr = NET_SKB_PAD;
+
+	tun->align = new_hr;
+}
+
 static const struct net_device_ops tun_netdev_ops = {
 	.ndo_uninit		= tun_net_uninit,
 	.ndo_open		= tun_net_open,
@@ -945,6 +957,7 @@ static const struct net_device_ops tun_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tun_poll_controller,
 #endif
+	.ndo_set_rx_headroom	= tun_set_headroom,
 };
 
 static const struct net_device_ops tap_netdev_ops = {
@@ -962,6 +975,7 @@ static const struct net_device_ops tap_netdev_ops = {
 	.ndo_poll_controller	= tun_poll_controller,
 #endif
 	.ndo_features_check	= passthru_features_check,
+	.ndo_set_rx_headroom	= tun_set_headroom,
 };
 
 static void tun_flow_init(struct tun_struct *tun)
@@ -1086,7 +1100,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	struct tun_pi pi = { 0, cpu_to_be16(ETH_P_IP) };
 	struct sk_buff *skb;
 	size_t total_len = iov_iter_count(from);
-	size_t len = total_len, align = NET_SKB_PAD, linear;
+	size_t len = total_len, align = tun->align, linear;
 	struct virtio_net_hdr gso = { 0 };
 	int good_linear;
 	int copylen;
@@ -1694,6 +1708,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		tun->txflt.count = 0;
 		tun->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
 
+		tun->align = NET_SKB_PAD;
 		tun->filter_attached = false;
 		tun->sndbuf = tfile->socket.sk->sk_sndbuf;
 
-- 
1.8.3.1
