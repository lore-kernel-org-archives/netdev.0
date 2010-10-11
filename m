From: Andrey Vagin <avagin@openvz.org>
Subject: [STABLE 2.6.32 PATCH] net: release dst entry while cache-hot for GSO case too
Date: Mon, 11 Oct 2010 19:20:13 +0400
Message-ID: <1286810413-30238-1-git-send-email-avagin@openvz.org>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrey Vagin <avagin@openvz.org>
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:9665 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755133Ab0JKPYD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 11:24:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

commit 068a2de57ddf4f472e32e7af868613c574ad1d88 upstream.

Non-GSO code drops dst entry for performance reasons, but
the same is missing for GSO code. Drop dst while cache-hot
for GSO case too.

Note: Without this patch the kernel may oops if used bridged veth
devices. A bridge set skb->dst = fake_dst_ops, veth transfers this skb
to netif_receive_skb...ip_rcv_finish and it calls dst_input(skb), but
fake_dst_ops->input = NULL -> Oops

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 net/core/dev.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 915d0ae..c325ab6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1747,6 +1747,14 @@ gso:
 
 		skb->next = nskb->next;
 		nskb->next = NULL;
+
+		/*
+		 * If device doesnt need nskb->dst, release it right now while
+		 * its hot in this cpu cache
+		 */
+		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
+			skb_dst_drop(nskb);
+
 		rc = ops->ndo_start_xmit(nskb, dev);
 		if (unlikely(rc != NETDEV_TX_OK)) {
 			nskb->next = skb->next;
-- 
1.7.2.1

