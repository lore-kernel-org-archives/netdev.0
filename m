From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 3/6] macvtap: socket rx busy polling support
Date: Thu, 31 Mar 2016 13:50:36 +0800
Message-ID: <1459403439-6011-4-git-send-email-jasowang@redhat.com>
References: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 95394ed..1891aff 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -20,6 +20,7 @@
 #include <net/net_namespace.h>
 #include <net/rtnetlink.h>
 #include <net/sock.h>
+#include <net/busy_poll.h>
 #include <linux/virtio_net.h>
 
 /*
@@ -369,6 +370,7 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 			goto drop;
 
 		if (!segs) {
+			sk_mark_napi_id(&q->sk, skb);
 			skb_queue_tail(&q->sk.sk_receive_queue, skb);
 			goto wake_up;
 		}
@@ -378,6 +380,7 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 			struct sk_buff *nskb = segs->next;
 
 			segs->next = NULL;
+			sk_mark_napi_id(&q->sk, segs);
 			skb_queue_tail(&q->sk.sk_receive_queue, segs);
 			segs = nskb;
 		}
@@ -391,6 +394,7 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 		    !(features & NETIF_F_CSUM_MASK) &&
 		    skb_checksum_help(skb))
 			goto drop;
+		sk_mark_napi_id(&q->sk, skb);
 		skb_queue_tail(&q->sk.sk_receive_queue, skb);
 	}
 
-- 
2.5.0
