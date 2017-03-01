From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 1/2] batman-adv: Fix double free during
	fragment merge error
Date: Wed,  1 Mar 2017 16:53:32 +0100
Message-ID: <20170301155333.19406-2-sw@simonwunderlich.de>
References: <20170301155333.19406-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20170301155333.19406-1-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

The function batadv_frag_skb_buffer was supposed not to consume the skbuff
on errors. This was followed in the helper function
batadv_frag_insert_packet when the skb would potentially be inserted in the
fragment queue. But it could happen that the next helper function
batadv_frag_merge_packets would try to merge the fragments and fail. This
results in a kfree_skb of all the enqueued fragments (including the just
inserted one). batadv_recv_frag_packet would detect the error in
batadv_frag_skb_buffer and try to free the skb again.

The behavior of batadv_frag_skb_buffer (and its helper
batadv_frag_insert_packet) must therefore be changed to always consume the
skbuff to have a common behavior and avoid the double kfree_skb.

Fixes: 610bfc6bc99b ("batman-adv: Receive fragmented packets and merge")
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/fragmentation.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 0854ebd8613e..31e97e9aee0d 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -239,8 +239,10 @@ static bool batadv_frag_insert_packet(struct batadv_orig_node *orig_node,
 	spin_unlock_bh(&chain->lock);
 
 err:
-	if (!ret)
+	if (!ret) {
 		kfree(frag_entry_new);
+		kfree_skb(skb);
+	}
 
 	return ret;
 }
@@ -313,7 +315,7 @@ batadv_frag_merge_packets(struct hlist_head *chain)
  *
  * There are three possible outcomes: 1) Packet is merged: Return true and
  * set *skb to merged packet; 2) Packet is buffered: Return true and set *skb
- * to NULL; 3) Error: Return false and leave skb as is.
+ * to NULL; 3) Error: Return false and free skb.
  *
  * Return: true when packet is merged or buffered, false when skb is not not
  * used.
@@ -338,9 +340,9 @@ bool batadv_frag_skb_buffer(struct sk_buff **skb,
 		goto out_err;
 
 out:
-	*skb = skb_out;
 	ret = true;
 out_err:
+	*skb = skb_out;
 	return ret;
 }
 
-- 
2.11.0
