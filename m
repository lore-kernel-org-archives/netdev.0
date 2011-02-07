From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH] batman-adv: Linearize fragment packets
	before merge
Date: Tue,  8 Feb 2011 00:59:21 +0100
Message-ID: <1297123161-25612-2-git-send-email-sven@narfation.org>
References: <1297123161-25612-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1297123161-25612-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

We access the data inside the skbs of two fragments directly using memmove
during the merge. The data of the skb could span over multiple skb pages. An
direct access without knowledge about the pages would lead to an invalid memory
access.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
[lindner_marek-LWAfsSFWpa4@public.gmane.org: Move return from function to the end]
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/unicast.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index ee41fef..d1a6113 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -50,12 +50,12 @@ static struct sk_buff *frag_merge_packet(struct list_head *head,
 		skb = tfp->skb;
 	}
 
+	if (skb_linearize(skb) < 0 || skb_linearize(tmp_skb) < 0)
+		goto err;
+
 	skb_pull(tmp_skb, sizeof(struct unicast_frag_packet));
-	if (pskb_expand_head(skb, 0, tmp_skb->len, GFP_ATOMIC) < 0) {
-		/* free buffered skb, skb will be freed later */
-		kfree_skb(tfp->skb);
-		return NULL;
-	}
+	if (pskb_expand_head(skb, 0, tmp_skb->len, GFP_ATOMIC) < 0)
+		goto err;
 
 	/* move free entry to end */
 	tfp->skb = NULL;
@@ -70,6 +70,11 @@ static struct sk_buff *frag_merge_packet(struct list_head *head,
 	unicast_packet->packet_type = BAT_UNICAST;
 
 	return skb;
+
+err:
+	/* free buffered skb, skb will be freed later */
+	kfree_skb(tfp->skb);
+	return NULL;
 }
 
 static void frag_create_entry(struct list_head *head, struct sk_buff *skb)
-- 
1.7.2.3
