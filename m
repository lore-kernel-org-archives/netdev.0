From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH v2] ipv6: Don't depend on per socket memory for neighbour discovery messages
Date: Tue,  3 Sep 2013 13:37:01 +0200
Message-ID: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Fabio Estevam <festevam@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:59100 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932595Ab3ICLhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 07:37:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocating skbs when sending out neighbour discovery messages
currently uses sock_alloc_send_skb() based on a per net namespace
socket and thus share a socket wmem buffer space.

If a netdevice is temporarily unable to transmit due to carrier
loss or for other reasons, the queued up ndisc messages will cosnume
all of the wmem space and will thus prevent from any more skbs to
be allocated even for netdevices that are able to transmit packets.

The number of neighbour discovery messages sent is very limited,
use of alloc_skb() bypasses the socket wmem buffer size enforcement
while the manual call to skb_set_owner_w() maintains the socket
reference needed for the IPv6 output path.

This patch has orginally been posted by Eric Dumazet in a modified
form.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Stephen Warren <swarren@wwwdotorg.org>
Cc: Fabio Estevam <festevam@gmail.com>
---
 net/ipv6/ndisc.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

v2: Maintain socket reference to account for the IPv6 output path.
    Problem reported by Stephen Warren <swarren@wwwdotorg.org> and
    Fabio Estevam <festevam@gmail.com>.

    Tested on x86_64

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 04d31c2..78141fa 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -372,14 +372,11 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
 	int tlen = dev->needed_tailroom;
 	struct sock *sk = dev_net(dev)->ipv6.ndisc_sk;
 	struct sk_buff *skb;
-	int err;
 
-	skb = sock_alloc_send_skb(sk,
-				  hlen + sizeof(struct ipv6hdr) + len + tlen,
-				  1, &err);
+	skb = alloc_skb(hlen + sizeof(struct ipv6hdr) + len + tlen, GFP_ATOMIC);
 	if (!skb) {
-		ND_PRINTK(0, err, "ndisc: %s failed to allocate an skb, err=%d\n",
-			  __func__, err);
+		ND_PRINTK(0, err, "ndisc: %s failed to allocate an skb\n",
+			  __func__);
 		return NULL;
 	}
 
@@ -389,6 +386,11 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
 	skb_reserve(skb, hlen + sizeof(struct ipv6hdr));
 	skb_reset_transport_header(skb);
 
+	/* Manually assign socket ownership as we avoid calling
+	 * sock_alloc_send_pskb() to bypass wmem buffer limits
+	 */
+	skb_set_owner_w(skb, sk);
+
 	return skb;
 }
 
-- 
1.8.3.1
