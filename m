From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH net-next 2/2] net: Loosen constraints for
	recalculating checksum in skb_segment()
Date: Tue, 23 Apr 2013 11:19:16 +0900
Message-ID: <1366683556-4956-3-git-send-email-horms@verge.net.au>
References: <1366683556-4956-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Joseph Gasparakis <joseph.gasparakis-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1366683556-4956-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

In the case where a non-MPLS GSO skb becomes an MPLS GSO skb, via
Open vSwitch's push MPLS action it is desirable to provide segmentation
in software. In this case the original protocol of the skb may have allowed
its checksumming to be offloaded but this may no longer be supported now
the skb is MPLS. Actually it seems to me that this is the likely case.

In order to allow the checksum to be updated in this case loosen
the rules for recalculating the checksum on in skb_segment().

N.B.: I must confess that I am a little unsure of the details of
the implementation of skb_checksum(). But I have observed that this
is necessary as skb_checksum() hits the following:

		if (!hsize && i >= nfrags) {
			...
			fskb = fskb->next;
			...
		}
		...
		if (fskb != skb_shinfo(skb)->frag_list)
			...

Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 net/core/skbuff.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f23d136..81c9856 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2854,7 +2854,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 						 doffset + tnl_hlen);
 
 		if (fskb != skb_shinfo(skb)->frag_list)
-			continue;
+			goto csum;
 
 		if (!sg) {
 			nskb->ip_summed = CHECKSUM_NONE;
@@ -2918,6 +2918,7 @@ skip_fraglist:
 		nskb->len += nskb->data_len;
 		nskb->truesize += nskb->data_len;
 
+csum:
 		if (!csum) {
 			nskb->csum = skb_checksum(nskb, doffset,
 						  nskb->len - doffset, 0);
-- 
1.8.2.1
