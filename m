From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] ipv4: ip_frag_queue function clean-up
Date: Tue,  4 Nov 2014 20:41:37 +0100
Message-ID: <1415130097-14490-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-remove unnecessary else after break
-declare free_it sk_buff * only once (like prev and next)

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/ip_fragment.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 2811cc1..153c402 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -317,7 +317,7 @@ static int ip_frag_reinit(struct ipq *qp)
 /* Add new segment to existing queue. */
 static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 {
-	struct sk_buff *prev, *next;
+	struct sk_buff *prev, *next, *free_it;
 	struct net_device *dev;
 	int flags, offset;
 	int ihl, end;
@@ -432,23 +432,23 @@ found:
 			if (next->ip_summed != CHECKSUM_UNNECESSARY)
 				next->ip_summed = CHECKSUM_NONE;
 			break;
-		} else {
-			struct sk_buff *free_it = next;
+		}
 
-			/* Old fragment is completely overridden with
-			 * new one drop it.
-			 */
-			next = next->next;
+		free_it = next;
 
-			if (prev)
-				prev->next = next;
-			else
-				qp->q.fragments = next;
+		/* Old fragment is completely overridden with
+		 * new one drop it.
+		 */
+		next = next->next;
 
-			qp->q.meat -= free_it->len;
-			sub_frag_mem_limit(&qp->q, free_it->truesize);
-			kfree_skb(free_it);
-		}
+		if (prev)
+			prev->next = next;
+		else
+			qp->q.fragments = next;
+
+		qp->q.meat -= free_it->len;
+		sub_frag_mem_limit(&qp->q, free_it->truesize);
+		kfree_skb(free_it);
 	}
 
 	FRAG_CB(skb)->offset = offset;
-- 
1.9.3
