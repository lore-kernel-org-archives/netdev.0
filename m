From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 12/14] netpoll: handle vlan tags in netpoll tx and rx path
Date: Fri, 10 Aug 2012 15:10:35 +0800
Message-ID: <1344582637-18261-13-git-send-email-amwang@redhat.com>
References: <1344582637-18261-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, Benjamin LaHaise <bcrl@kvack.org>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14446 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756436Ab2HJHL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 03:11:28 -0400
In-Reply-To: <1344582637-18261-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this patch, I can't get netconsole logs remotely over
vlan. The reason is probably we don't handle vlan tags in either
netpoll tx or rx path.

I am not sure if I use these vlan functions correctly, at
least this patch works.

Cc: Benjamin LaHaise <bcrl@kvack.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/netpoll.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 174346a..e4ba3e7 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -26,6 +26,7 @@
 #include <linux/workqueue.h>
 #include <linux/slab.h>
 #include <linux/export.h>
+#include <linux/if_vlan.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <asm/unaligned.h>
@@ -334,6 +335,14 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 		     tries > 0; --tries) {
 			if (__netif_tx_trylock(txq)) {
 				if (!netif_xmit_stopped(txq)) {
+					if (vlan_tx_tag_present(skb) &&
+					    !(netif_skb_features(skb) & NETIF_F_HW_VLAN_TX)) {
+						skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
+						if (unlikely(!skb))
+							break;
+						skb->vlan_tci = 0;
+					}
+
 					status = ops->ndo_start_xmit(skb, dev);
 					if (status == NETDEV_TX_OK)
 						txq_trans_update(txq);
@@ -567,6 +576,12 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 		return 1;
 	}
 
+	if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
+		skb = vlan_untag(skb);
+		if (unlikely(!skb))
+			goto out;
+	}
+
 	proto = ntohs(eth_hdr(skb)->h_proto);
 	if (proto != ETH_P_IP)
 		goto out;
-- 
1.7.7.6
