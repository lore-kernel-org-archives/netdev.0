From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 4/4] batman-adv: request the full table if
	tt_crc doesn't match
Date: Fri,  8 Jul 2011 00:35:46 +0200
Message-ID: <1310078146-29537-1-git-send-email-lindner_marek@yahoo.de>
References: <1310078023-28958-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1310078023-28958-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

In case of tt_crc mismatching for a certain orig_node after applying the
changes, the node must request the full table immediately.

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/routing.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 2cb98be..0f32c81 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -91,6 +91,18 @@ static void update_transtable(struct bat_priv *bat_priv,
 		 * to recompute it to spot any possible inconsistency
 		 * in the global table */
 		orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
+
+		/* The ttvn alone is not enough to guarantee consistency
+		 * because a single value could repesent different states
+		 * (due to the wrap around). Thus a node has to check whether
+		 * the resulting table (after applying the changes) is still
+		 * consistent or not. E.g. a node could disconnect while its
+		 * ttvn is X and reconnect on ttvn = X + TTVN_MAX: in this case
+		 * checking the CRC value is mandatory to detect the
+		 * inconsistency */
+		if (orig_node->tt_crc != tt_crc)
+			goto request_table;
+
 		/* Roaming phase is over: tables are in sync again. I can
 		 * unset the flag */
 		orig_node->tt_poss_change = false;
-- 
1.7.5.3
