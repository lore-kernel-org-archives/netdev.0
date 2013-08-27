From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] ipv6: Don't depend on per socket memory for neighbour discovery messages
Date: Wed, 28 Aug 2013 01:07:25 +0200
Message-ID: <361d4275efc79e3048191306df25ad003ed497d7.1377644830.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:46026 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522Ab3H0XHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 19:07:31 -0400
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
simply use alloc_skb() and don't depend on any socket wmem space any
longer.

This patch has orginally been posted by Eric Dumazet in a modified
form.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/ndisc.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index b3b5730..bf028a7 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -370,16 +370,12 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
 {
 	int hlen = LL_RESERVED_SPACE(dev);
 	int tlen = dev->needed_tailroom;
-	struct sock *sk = dev_net(dev)->ipv6.ndisc_sk;
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
 
-- 
1.8.3.1
