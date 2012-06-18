From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 02/19] batman-adv: fix skb->data assignment
Date: Mon, 18 Jun 2012 22:39:06 +0200
Message-ID: <1340051963-14836-3-git-send-email-ordex@autistici.org>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340051963-14836-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

skb_linearize(skb) possibly rearranges the skb internal data and then changes
the skb->data pointer value. For this reason any other pointer in the code that
was assigned skb->data before invoking skb_linearise(skb) must be re-assigned.

In the current tt_query message handling code this is not done and therefore, in
case of skb linearization, the pointer used to handle the packet header ends up
in pointing to poisoned memory. The packet is then dropped but the
translation-table mechanism is corrupted.

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/routing.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 840e2c6..015471d 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -617,6 +617,8 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 			 * changes */
 			if (skb_linearize(skb) < 0)
 				goto out;
+			/* skb_linearize() possibly changed skb->data */
+			tt_query = (struct tt_query_packet *)skb->data;
 
 			tt_len = tt_query->tt_data * sizeof(struct tt_change);
 
-- 
1.7.9.4
