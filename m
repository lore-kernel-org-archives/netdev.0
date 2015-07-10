From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] netlink: enable skb header refcounting before sending first
 broadcast
Date: Fri, 10 Jul 2015 14:51:41 +0300
Message-ID: <20150710115141.12980.88829.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1m.cmail.yandex.net ([5.255.216.100]:49501 "EHLO
	forward-corp1m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754208AbbGJLvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 07:51:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes race between non-atomic updates of adjacent bit-fields:
skb->cloned could be lost because netlink broadcast clones skb after
sending it to the first listener who sets skb->peeked at the same skb.
As a result atomic refcounting of skb header stays disabled and
skb_release_data() frees it twice. Race leads to double-free in kmalloc-xxx.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Fixes: b19372273164 ("net: reorganize sk_buff for faster __copy_skb_header()")
---
 net/netlink/af_netlink.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index dea925388a5b..921e0d8dfe3a 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2028,6 +2028,12 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid
 	info.tx_filter = filter;
 	info.tx_data = filter_data;
 
+	/* Enable atomic refcounting in skb_release_data() before first send:
+	 * non-atomic set of that bit-field in __skb_clone() could race with
+	 * __skb_recv_datagram() which touches the same set of bit-fields.
+	 */
+	skb->cloned = 1;
+
 	/* While we sleep in clone, do not allow to change socket list */
 
 	netlink_lock_table();
