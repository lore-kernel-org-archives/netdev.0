From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH net-next 5/8] net: core: another layer of lists, around
 PF_MEMALLOC skb handling
Date: Tue, 19 Apr 2016 14:36:13 +0100
Message-ID: <5716344D.3060001@solarflare.com>
References: <5716338E.4050003@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:19684 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752866AbcDSNgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 09:36:23 -0400
In-Reply-To: <5716338E.4050003@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First example of a layer splitting the list (rather than merely taking
individual packets off it).

Again, trying to factor the common parts wouldn't make this any nicer.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 net/core/dev.c | 36 ++++++++++++++++++++++++++++++++++--
 1 file changed, 34 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 586807d..0f914bf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4216,6 +4216,14 @@ out:
 	return ret;
 }
 
+static void __netif_receive_skb_list_core(struct sk_buff_head *list, bool pfmemalloc)
+{
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(list)) != NULL)
+		__netif_receive_skb_core(skb, pfmemalloc);
+}
+
 static int __netif_receive_skb(struct sk_buff *skb)
 {
 	int ret;
@@ -4243,10 +4251,34 @@ static int __netif_receive_skb(struct sk_buff *skb)
 
 static void __netif_receive_skb_list(struct sk_buff_head *list)
 {
+	struct sk_buff_head sublist;
+	bool pfmemalloc = false; /* Is current sublist PF_MEMALLOC? */
+	unsigned long pflags;
 	struct sk_buff *skb;
 
-	while ((skb = __skb_dequeue(list)) != NULL)
-		__netif_receive_skb(skb);
+	__skb_queue_head_init(&sublist);
+
+	while ((skb = __skb_dequeue(list)) != NULL) {
+		if ((sk_memalloc_socks() && skb_pfmemalloc(skb)) != pfmemalloc) {
+			/* Handle the previous sublist */
+			__netif_receive_skb_list_core(&sublist, pfmemalloc);
+			pfmemalloc = !pfmemalloc;
+			/* See comments in __netif_receive_skb */
+			if (pfmemalloc) {
+				pflags = current->flags;
+				current->flags |= PF_MEMALLOC;
+			} else {
+				tsk_restore_flags(current, pflags, PF_MEMALLOC);
+			}
+			__skb_queue_head_init(&sublist);
+		}
+		__skb_queue_tail(&sublist, skb);
+	}
+	/* Handle the last sublist */
+	__netif_receive_skb_list_core(&sublist, pfmemalloc);
+	/* Restore pflags */
+	if (pfmemalloc)
+		tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 static int netif_receive_skb_internal(struct sk_buff *skb)
