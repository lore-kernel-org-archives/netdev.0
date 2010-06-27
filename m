From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] vhost-net: add dhclient work-around from userspace
Date: Sun, 27 Jun 2010 18:46:57 +0300
Message-ID: <20100627154657.GA9723__6265.85421055115$1277653969$gmane$org@redhat.com>
References: <20100626.200320.43025947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Sridhar Samudrala <samudrala@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	kvm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8519 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755482Ab0F0PwT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jun 2010 11:52:19 -0400
Content-Disposition: inline
In-Reply-To: <20100626.200320.43025947.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userspace virtio server has the following hack
so guests rely on it, and we have to replicate it, too:

use source port to detect incoming IPv4 DHCP response packets,
and fill in the checksum for these.

The issue we are solving is that on linux guests, some apps
that use recvmsg with AF_PACKET sockets, don't know how to
handle CHECKSUM_PARTIAL;
The interface to return the relevant information was added
in 8dc4194474159660d7f37c495e3fc3f10d0db8cc,
and older userspace does not use it.
One important user of recvmsg with AF_PACKET is dhclient,
so we add a work-around just for DHCP.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

So here's what I came up with: I basically copied
the work-around from userspace virtio.
As suggested by Dave (assuming I understood the suggestion
correctly) this implements the workaround in vhost-net, so
other tun users don't start relying on it.
Untested.

 drivers/vhost/net.c |   42 +++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 41 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 54096ee..9ed4051 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -25,6 +25,10 @@
 #include <linux/if_tun.h>
 #include <linux/if_macvlan.h>
 
+#include <linux/ip.h>
+#include <linux/udp.h>
+#include <linux/netdevice.h>
+
 #include <net/sock.h>
 
 #include "vhost.h"
@@ -191,6 +195,42 @@ static void handle_tx(struct vhost_net *net)
 	unuse_mm(net->dev.mm);
 }
 
+static int peek_head(struct sock *sk)
+{
+	struct sk_buff *head;
+	int ret;
+
+	lock_sock(sk);
+	head = skb_peek(&sk->sk_receive_queue);
+	if (likely(head)) {
+		ret = 1;
+		/* Userspace virtio server has the following hack so
+		 * guests rely on it, and we have to replicate it, too: */
+		/* On linux guests, some apps that use recvmsg with AF_PACKET
+		 * sockets, don't know how to handle CHECKSUM_PARTIAL;
+		 * The interface to return the relevant information was added in
+		 * 8dc4194474159660d7f37c495e3fc3f10d0db8cc,
+		 * and older userspace does not use it.
+		 * One important user of recvmsg with AF_PACKET is dhclient,
+		 * so we add a work-around just for DHCP. */
+		/* We use source port to detect DHCP packets. */
+		if (skb->ip_summed == CHECKSUM_PARTIAL &&
+		    skb->protocol == htons(ETH_P_IP) &&
+		    skb_network_header_len(skb) >= sizeof(struct iphdr) &&
+		    ip_hdr(skb)->protocol == IPPRODO_UDP &&
+		    skb_headlen(skb) >= skb_transport_offset(skb) + sizeof(struct udphdr) &&
+		    udp_hdr(skb)->source == htons(0x67)) {
+			skb_checksum_help(skb);
+			/* Restore ip_summed value: tun passes it to user. */
+			skb->ip_summed = CHECKSUM_PARTIAL;
+		}
+	} else {
+		ret = 0;
+	}
+	release_sock(sk);
+	return len;
+}
+
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
 static void handle_rx(struct vhost_net *net)
@@ -228,7 +268,7 @@ static void handle_rx(struct vhost_net *net)
 	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
 		vq->log : NULL;
 
-	for (;;) {
+	while (peek_head(sock)) {
 		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
 					 ARRAY_SIZE(vq->iov),
 					 &out, &in,
-- 
1.7.1.12.g42b7f
