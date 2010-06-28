From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2] vhost-net: add dhclient work-around from userspace
Date: Mon, 28 Jun 2010 13:08:07 +0300
Message-ID: <20100628100807.GA30685__40398.6619705849$1277720023$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Aristeu Rozanski <arozansk@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>,
	Juan Quintela <quintela@redhat.com>,
	"David S. Miller" <davem@redha
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12001 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398Ab0F1KNS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 06:13:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userspace virtio server has the following hack
so guests rely on it, and we have to replicate it, too:

Use port number to detect incoming IPv4 DHCP response packets,
and fill in the checksum for these.

The issue we are solving is that on linux guests, some apps
that use recvmsg with AF_PACKET sockets, don't know how to
handle CHECKSUM_PARTIAL;
The interface to return the relevant information was added
in 8dc4194474159660d7f37c495e3fc3f10d0db8cc,
and older userspace does not use it.
One important user of recvmsg with AF_PACKET is dhclient,
so we add a work-around just for DHCP.

Don't bother applying the hack to IPv6 as userspace virtio does not
have a work-around for that - let's hope guests will do the right
thing wrt IPv6.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Dave, I'm going to put this patch on the vhost tree,
no need for you to bother merging it - you'll get
it with a pull request.


 drivers/vhost/net.c |   44 +++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index cc19595..03bba6a 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -24,6 +24,10 @@
 #include <linux/if_tun.h>
 #include <linux/if_macvlan.h>
 
+#include <linux/ip.h>
+#include <linux/udp.h>
+#include <linux/netdevice.h>
+
 #include <net/sock.h>
 
 #include "vhost.h"
@@ -186,6 +190,44 @@ static void handle_tx(struct vhost_net *net)
 	unuse_mm(net->dev.mm);
 }
 
+static int peek_head(struct sock *sk)
+{
+	struct sk_buff *skb;
+
+	lock_sock(sk);
+	skb = skb_peek(&sk->sk_receive_queue);
+	if (unlikely(!skb)) {
+		release_sock(sk);
+		return 0;
+	}
+	/* Userspace virtio server has the following hack so
+	 * guests rely on it, and we have to replicate it, too: */
+	/* Use port number to detect incoming IPv4 DHCP response packets,
+	 * and fill in the checksum. */
+
+	/* The issue we are solving is that on linux guests, some apps
+	 * that use recvmsg with AF_PACKET sockets, don't know how to
+	 * handle CHECKSUM_PARTIAL;
+	 * The interface to return the relevant information was added in
+	 * 8dc4194474159660d7f37c495e3fc3f10d0db8cc,
+	 * and older userspace does not use it.
+	 * One important user of recvmsg with AF_PACKET is dhclient,
+	 * so we add a work-around just for DHCP. */
+	if (skb->ip_summed == CHECKSUM_PARTIAL &&
+	    skb_headlen(skb) >= skb_transport_offset(skb) +
+				sizeof(struct udphdr) &&
+	    udp_hdr(skb)->dest == htons(68) &&
+	    skb_network_header_len(skb) >= sizeof(struct iphdr) &&
+	    ip_hdr(skb)->protocol == IPPROTO_UDP &&
+	    skb->protocol == htons(ETH_P_IP)) {
+		skb_checksum_help(skb);
+		/* Restore ip_summed value: tun passes it to user. */
+		skb->ip_summed = CHECKSUM_PARTIAL;
+	}
+	release_sock(sk);
+	return 1;
+}
+
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
 static void handle_rx(struct vhost_net *net)
@@ -222,7 +264,7 @@ static void handle_rx(struct vhost_net *net)
 	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
 		vq->log : NULL;
 
-	for (;;) {
+	while (peek_head(sock->sk)) {
 		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
 					 ARRAY_SIZE(vq->iov),
 					 &out, &in,
-- 
1.7.1.12.g42b7f
