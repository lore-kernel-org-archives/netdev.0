From: Tom Herbert <therbert@google.com>
Subject: [PATCH] tcp: fix setting csum_start in tcp_gso_segment
Date: Tue, 24 Jun 2014 21:03:51 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406242056330.29780@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: torvalds@linux-foundation.org, davej@redhat.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jones reported that a crash is occuring in

csum_partial
tcp_gso_segment
inet_gso_segment
? update_dl_migration
skb_mac_gso_segment
__skb_gso_segment
dev_hard_start_xmit
sch_direct_xmit
__dev_queue_xmit
? dev_hard_start_xmit
dev_queue_xmit
ip_finish_output
? ip_output
ip_output
ip_forward_finish
ip_forward
ip_rcv_finish
ip_rcv
__netif_receive_skb_core
? __netif_receive_skb_core
? trace_hardirqs_on
__netif_receive_skb
netif_receive_skb_internal
napi_gro_complete
? napi_gro_complete
dev_gro_receive
? dev_gro_receive
napi_gro_receive

It looks like a likely culprit is that SKB_GSO_CB()->csum_start is
not set correctly when doing non-scatter gather. We are using
offset as opposed to doffset.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/skbuff.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9cd5344..c1a3303 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2993,7 +2993,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 							    skb_put(nskb, len),
 							    len, 0);
 			SKB_GSO_CB(nskb)->csum_start =
-			    skb_headroom(nskb) + offset;
+			    skb_headroom(nskb) + doffset;
 			continue;
 		}
 
-- 
2.0.0.526.g5318336
