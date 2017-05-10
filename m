From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] libertas: Avoid reading past end of buffer
Date: Wed, 10 May 2017 12:24:51 -0700
Message-ID: <20170510192451.GA115771@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, Kalle Valo <kvalo@codeaurora.org>,
        libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        Daniel Micay <danielmicay@gmail.com>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using memcpy() from a string that is shorter than the length copied means
the destination buffer is being filled with arbitrary data from the kernel
rodata segment. Instead, redefine the stat strings to be ETH_GSTRING_LEN
sizes, like other drivers. This lets us use a single memcpy that does not
leak rodata contents. Additionally adjust indentation to keep checkpatch.pl
happy.

This was found with the future CONFIG_FORTIFY_SOURCE feature.

Cc: Daniel Micay <danielmicay@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
v2: use ETH_GSTRING_LEN; joe
---
 drivers/net/wireless/marvell/libertas/mesh.c | 26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/marvell/libertas/mesh.c b/drivers/net/wireless/marvell/libertas/mesh.c
index d0c881dd5846..6076c83ce5ab 100644
--- a/drivers/net/wireless/marvell/libertas/mesh.c
+++ b/drivers/net/wireless/marvell/libertas/mesh.c
@@ -1108,15 +1108,15 @@ void lbs_mesh_set_txpd(struct lbs_private *priv,
  * Ethtool related
  */
 
-static const char * const mesh_stat_strings[] = {
-			"drop_duplicate_bcast",
-			"drop_ttl_zero",
-			"drop_no_fwd_route",
-			"drop_no_buffers",
-			"fwded_unicast_cnt",
-			"fwded_bcast_cnt",
-			"drop_blind_table",
-			"tx_failed_cnt"
+static const char mesh_stat_strings[MESH_STATS_NUM][ETH_GSTRING_LEN] = {
+	"drop_duplicate_bcast",
+	"drop_ttl_zero",
+	"drop_no_fwd_route",
+	"drop_no_buffers",
+	"fwded_unicast_cnt",
+	"fwded_bcast_cnt",
+	"drop_blind_table",
+	"tx_failed_cnt"
 };
 
 void lbs_mesh_ethtool_get_stats(struct net_device *dev,
@@ -1170,17 +1170,11 @@ int lbs_mesh_ethtool_get_sset_count(struct net_device *dev, int sset)
 void lbs_mesh_ethtool_get_strings(struct net_device *dev,
 	uint32_t stringset, uint8_t *s)
 {
-	int i;
-
 	lbs_deb_enter(LBS_DEB_ETHTOOL);
 
 	switch (stringset) {
 	case ETH_SS_STATS:
-		for (i = 0; i < MESH_STATS_NUM; i++) {
-			memcpy(s + i * ETH_GSTRING_LEN,
-					mesh_stat_strings[i],
-					ETH_GSTRING_LEN);
-		}
+		memcpy(s, *mesh_stat_strings, sizeof(mesh_stat_strings));
 		break;
 	}
 	lbs_deb_enter(LBS_DEB_ETHTOOL);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
