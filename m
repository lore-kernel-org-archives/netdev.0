From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next v3] xen-netfront: avoid packet loss when ethernet header crosses page boundary
Date: Mon, 19 Sep 2016 12:53:40 +0200
Message-ID: <1474282420-9723-1-git-send-email-vkuznets@redhat.com>
Cc: linux-kernel@vger.kernel.org,
        Patrick Talbert <ptalbert@redhat.com>,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        David Vrabel <david.vrabel@citrix.com>,
        Juergen Gross <jgross@suse.com>,
        David Miller <davem@davemloft.net>,
        xen-devel@lists.xenproject.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39686 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750745AbcISKxo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 06:53:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Small packet loss is reported on complex multi host network configurations
including tunnels, NAT, ... My investigation led me to the following check
in netback which drops packets:

        if (unlikely(txreq.size < ETH_HLEN)) {
                netdev_err(queue->vif->dev,
                           "Bad packet size: %d\n", txreq.size);
                xenvif_tx_err(queue, &txreq, extra_count, idx);
                break;
        }

But this check itself is legitimate. SKBs consist of a linear part (which
has to have the ethernet header) and (optionally) a number of frags.
Netfront transmits the head of the linear part up to the page boundary
as the first request and all the rest becomes frags so when we're
reconstructing the SKB in netback we can't distinguish between original
frags and the 'tail' of the linear part. The first SKB needs to be at
least ETH_HLEN size. So in case we have an SKB with its linear part
starting too close to the page boundary the packet is lost.

I see two ways to fix the issue:
- Change the 'wire' protocol between netfront and netback to start keeping
  the original SKB structure. We'll have to add a flag indicating the fact
  that the particular request is a part of the original linear part and not
  a frag. We'll need to know the length of the linear part to pre-allocate
  memory.
- Avoid transmitting SKBs with linear parts starting too close to the page
  boundary. That seems preferable short-term and shouldn't bring
  significant performance degradation as such packets are rare. That's what
  this patch is trying to achieve with skb_copy().

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
Acked-by: David Vrabel <david.vrabel@citrix.com>
---
- Changes since 'v2':
  Move 'len' calculation after the 'if' instead of re-calculating it
  inside. [David Vrabel]

- Changes since 'v1':
  Recalculate 'len' as in some cases it changes after skb_copy()
  [David Miller]
  I keep David's ACK on my patch as I think the change doesn't
  significantly change the patch, sorry in advance if I'm wrong.
---
 drivers/net/xen-netfront.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 96ccd4e..e17879d 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -565,6 +565,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct netfront_queue *queue = NULL;
 	unsigned int num_queues = dev->real_num_tx_queues;
 	u16 queue_index;
+	struct sk_buff *nskb;
 
 	/* Drop the packet if no queues are set up */
 	if (num_queues < 1)
@@ -593,6 +594,20 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	page = virt_to_page(skb->data);
 	offset = offset_in_page(skb->data);
+
+	/* The first req should be at least ETH_HLEN size or the packet will be
+	 * dropped by netback.
+	 */
+	if (unlikely(PAGE_SIZE - offset < ETH_HLEN)) {
+		nskb = skb_copy(skb, GFP_ATOMIC);
+		if (!nskb)
+			goto drop;
+		dev_kfree_skb_any(skb);
+		skb = nskb;
+		page = virt_to_page(skb->data);
+		offset = offset_in_page(skb->data);
+	}
+
 	len = skb_headlen(skb);
 
 	spin_lock_irqsave(&queue->tx_lock, flags);
-- 
2.7.4
