From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 1/2] batman-adv: Even Batman should not
	dereference NULL pointers
Date: Sun, 16 Jan 2011 03:38:46 +0100
Message-ID: <1295145527-17537-2-git-send-email-sven@narfation.org>
References: <1295145527-17537-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1295145527-17537-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

From: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>

There's a problem in net/batman-adv/unicast.c::frag_send_skb().
dev_alloc_skb() allocates memory and may fail, thus returning NULL. If
this happens we'll pass a NULL pointer on to skb_split() which in turn
hands it to skb_split_inside_header() from where it gets passed to
skb_put() that lets skb_tail_pointer() play with it and that function
dereferences it. And thus the bat dies.

While I was at it I also moved the call to dev_alloc_skb() above the
assignment to 'unicast_packet' since there's no reason to do that
assignment if the memory allocation fails.

Signed-off-by: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/unicast.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index dc2e28b..ee41fef 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -229,10 +229,12 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	if (!bat_priv->primary_if)
 		goto dropped;
 
-	unicast_packet = (struct unicast_packet *) skb->data;
+	frag_skb = dev_alloc_skb(data_len - (data_len / 2) + ucf_hdr_len);
+	if (!frag_skb)
+		goto dropped;
 
+	unicast_packet = (struct unicast_packet *) skb->data;
 	memcpy(&tmp_uc, unicast_packet, uc_hdr_len);
-	frag_skb = dev_alloc_skb(data_len - (data_len / 2) + ucf_hdr_len);
 	skb_split(skb, frag_skb, data_len / 2);
 
 	if (my_skb_head_push(skb, ucf_hdr_len - uc_hdr_len) < 0 ||
-- 
1.7.2.3
