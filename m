From: Benjamin Poirier <benjamin.poirier-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org>
Subject: [PATCH] net: Take GSO into account when capturing
	packets
Date: Mon, 06 Jul 2009 14:04:32 -0400
Message-ID: <4A523CB0.8080005@polymtl.ca>
Reply-To: Developer support list for Wireshark <wireshark-dev-IZ8446WsY0/dtAWm4Da02A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tcpdump-workers-YE1jQ5a0g24KACXWX4p+q9i2O/JbrIOy@public.gmane.org, wireshark-dev-IZ8446WsY0/dtAWm4Da02A@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <wireshark-dev-bounces-IZ8446WsY0/dtAWm4Da02A@public.gmane.org>
List-Unsubscribe: <https://wireshark.org/mailman/listinfo/wireshark-dev>,
	<mailto:wireshark-dev-request-IZ8446WsY0/dtAWm4Da02A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.wireshark.org/lists/wireshark-dev>
List-Post: <mailto:wireshark-dev-IZ8446WsY0/dtAWm4Da02A@public.gmane.org>
List-Help: <mailto:wireshark-dev-request-IZ8446WsY0/dtAWm4Da02A@public.gmane.org?subject=help>
List-Subscribe: <https://wireshark.org/mailman/listinfo/wireshark-dev>,
	<mailto:wireshark-dev-request-IZ8446WsY0/dtAWm4Da02A@public.gmane.org?subject=subscribe>
Sender: wireshark-dev-bounces-IZ8446WsY0/dtAWm4Da02A@public.gmane.org
Errors-To: wireshark-dev-bounces-IZ8446WsY0/dtAWm4Da02A@public.gmane.org
List-Id: netdev.vger.kernel.org

move the point where the support routine for packet capture is called to
better reflect what is transmitted on the wire when GSO is active.

At the moment, packet capture (a la tcpdump) on the transmission side happens
before GSO takes place (if it does). Therefore, even if a packet gets
segmented by GSO, the capture shows that one big packet was sent when in fact
many small packets were sent on the wire. This behavior does not reflect the
"reality" of what is transmitted and could lead to confusion, especially since
a capture on the receiving side shows the segmented packets.

Signed-off-by: Benjamin Poirier <benjamin.poirier-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org>

---

I've tested that the patch does what it intends to do by taking a capture on
the sending and receiving side of a network benchmark that sends incrementally
larger chunks of data. Without the patch, Wireshark shows that frames larger
than the MTU were sent as is and it shows that they were received as many
smaller frames. With the patch it shows that many small frames were sent and
received.

I would've liked to test the performance impact of the additional
list_empty() tests in the GSO loop but unfortunately I'm already limited by
the network speed, not the cpu. Fast Ethernet, blah

 net/core/dev.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 70c27e0..e87bbaf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1686,9 +1686,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 	int rc;
 
 	if (likely(!skb->next)) {
-		if (!list_empty(&ptype_all))
-			dev_queue_xmit_nit(skb, dev);
-
 		if (netif_needs_gso(dev, skb)) {
 			if (unlikely(dev_gso_segment(skb)))
 				goto out_kfree_skb;
@@ -1696,6 +1693,9 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				goto gso;
 		}
 
+		if (!list_empty(&ptype_all))
+			dev_queue_xmit_nit(skb, dev);
+
 		/*
 		 * If device doesnt need skb->dst, release it right now while
 		 * its hot in this cpu cache
@@ -1729,6 +1729,10 @@ gso:
 
 		skb->next = nskb->next;
 		nskb->next = NULL;
+
+		if (!list_empty(&ptype_all))
+			dev_queue_xmit_nit(nskb, dev);
+
 		rc = ops->ndo_start_xmit(nskb, dev);
 		if (unlikely(rc)) {
 			nskb->next = skb->next;
-- 
1.6.3.3

___________________________________________________________________________
Sent via:    Wireshark-dev mailing list <wireshark-dev-IZ8446WsY0/dtAWm4Da02A@public.gmane.org>
Archives:    http://www.wireshark.org/lists/wireshark-dev
Unsubscribe: https://wireshark.org/mailman/options/wireshark-dev
             mailto:wireshark-dev-request-IZ8446WsY0/dtAWm4Da02A@public.gmane.org?subject=unsubscribe
