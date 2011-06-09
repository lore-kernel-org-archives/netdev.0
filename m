From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 1/6] batman-adv: accept delayed rebroadcasts
	to avoid bogus routing under heavy load
Date: Thu,  9 Jun 2011 23:09:09 +0200
Message-ID: <1307653754-5014-2-git-send-email-sven@narfation.org>
References: <1307653754-5014-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1307653754-5014-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

From: Daniele Furlan <daniele.furlan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

When a link is saturated (re)broadcasts of OGMs are delayed. Under heavy
load this delay may exceed the orig interval which leads to OGMs being
dropped (the code would only accept an OGM rebroadcast if it arrived
before the next OGM was broadcasted). With this patch batman-adv will
also accept delayed OGMs in order to avoid a bogus influence on the
routing metric.

Signed-off-by: Daniele Furlan <daniele.furlan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/routing.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 368ceeb..934f1f2 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -698,17 +698,16 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 
 		/* neighbor has to indicate direct link and it has to
 		 * come via the corresponding interface */
-		/* if received seqno equals last send seqno save new
-		 * seqno for bidirectional check */
+		/* save packet seqno for bidirectional check */
 		if (has_directlink_flag &&
 		    compare_eth(if_incoming->net_dev->dev_addr,
-				batman_packet->orig) &&
-		    (batman_packet->seqno - if_incoming_seqno + 2 == 0)) {
+				batman_packet->orig)) {
 			offset = if_incoming->if_num * NUM_WORDS;
 
 			spin_lock_bh(&orig_neigh_node->ogm_cnt_lock);
 			word = &(orig_neigh_node->bcast_own[offset]);
-			bit_mark(word, 0);
+			bit_mark(word,
+				 if_incoming_seqno - batman_packet->seqno - 2);
 			orig_neigh_node->bcast_own_sum[if_incoming->if_num] =
 				bit_packet_count(word);
 			spin_unlock_bh(&orig_neigh_node->ogm_cnt_lock);
-- 
1.7.5.3
