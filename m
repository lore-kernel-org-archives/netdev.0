From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH net] batman-adv: Fix memory leak on tt add
	with invalid vlan
Date: Tue, 18 Aug 2015 13:37:01 +0200
Message-ID: <1439897821-7480-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
 Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
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

The object tt_local is allocated with kmalloc and not initialized when the
function batadv_tt_local_add checks for the vlan. But this function can
only cleanup the object when the (not yet initialized) reference counter of
the object is 1. This is unlikely and thus the object would leak when the
vlan could not be found.

Instead the uninitialized object tt_local has to be freed manually and the
pointer has to set to NULL to avoid calling the function which would try to
decrement the reference counter of the not existing object.

CID: 1316518
Fixes: 354136bcc3c4 ("batman-adv: fix kernel crash due to missing NULL checks")
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
Hi,

sorry for sending the patch directly to you. But Marek told me that neither
he or Antonio have currently time to prepare/send a patch for this problem.
Instead he told me that it would be ok to send the patch directly to you.

The problematic patch is currently in net.git and was accepted a week ago
by you [1]. I was also told that this patch has also been queued for
different stable trees.

Kind regards,
	Sven

[1] http://www.spinics.net/lists/netdev/msg338630.html
---
 net/batman-adv/translation-table.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 75bc678ea116..4228b10c47ea 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -598,8 +598,11 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 	/* increase the refcounter of the related vlan */
 	vlan = batadv_softif_vlan_get(bat_priv, vid);
 	if (WARN(!vlan, "adding TT local entry %pM to non-existent VLAN %d",
-		 addr, BATADV_PRINT_VID(vid)))
+		 addr, BATADV_PRINT_VID(vid))) {
+		kfree(tt_local);
+		tt_local = NULL;
 		goto out;
+	}
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new local tt entry: %pM (vid: %d, ttvn: %d)\n",
-- 
2.5.0
