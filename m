From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-05-02
Date: Mon, 2 May 2011 14:20:13 -0400
Message-ID: <20110502182013.GA6768@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here are a few more intended for 2.6.39.  There is a one-liner for b43
which adds a missing MODULE_FIRMWARE declaration (so maybe someone's
initrd will get generated correctly), an iwlegacy fix from Wey-Yi that
corrects an LED flashing change that people are complaining about,
an iwl4965 WARNING fix from Stanislaw, and a matching pair of iwlagn
and iwl4965 regression fixes also from Stanislaw that correct problems
with using the wrong station ID for block ACK sessions.

Please let me know if there are problems!

John

P.S.  I know the LED flashing fix is questionable, but it is an
annoyance and it should not effect any other hardware.

---

The following changes since commit 7cfd260910b881250cde76ba92ebe3cbf849=
3a8f:

  ipv4: don't spam dmesg with "Using LC-trie" messages (2011-05-01 23:1=
7:50 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it master

Rafa=C5=82 Mi=C5=82ecki (1):
      b43: trivial: update module info about ucode16_mimo firmware

Stanislaw Gruszka (3):
      iwl4965: fix "TX Power requested while scanning"
      iwlagn: fix "Received BA when not expected"
      iwl4965: fix "Received BA when not expected"

Wey-Yi Guy (1):
      iwlegacy: led stay solid on when no traffic

 drivers/net/wireless/b43/main.c              |    1 +
 drivers/net/wireless/iwlegacy/iwl-4965-tx.c  |   18 ++++++++++++------
 drivers/net/wireless/iwlegacy/iwl-led.c      |   20 ++++++++++++++++++=
+-
 drivers/net/wireless/iwlegacy/iwl4965-base.c |    8 ++++----
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c    |   17 +++++++++++------
 5 files changed, 47 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43=
/main.c
index 57eb5b6..7841b95 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -72,6 +72,7 @@ MODULE_FIRMWARE("b43/ucode11.fw");
 MODULE_FIRMWARE("b43/ucode13.fw");
 MODULE_FIRMWARE("b43/ucode14.fw");
 MODULE_FIRMWARE("b43/ucode15.fw");
+MODULE_FIRMWARE("b43/ucode16_mimo.fw");
 MODULE_FIRMWARE("b43/ucode5.fw");
 MODULE_FIRMWARE("b43/ucode9.fw");
=20
diff --git a/drivers/net/wireless/iwlegacy/iwl-4965-tx.c b/drivers/net/=
wireless/iwlegacy/iwl-4965-tx.c
index fbec88d..79ac081 100644
--- a/drivers/net/wireless/iwlegacy/iwl-4965-tx.c
+++ b/drivers/net/wireless/iwlegacy/iwl-4965-tx.c
@@ -316,12 +316,18 @@ int iwl4965_tx_skb(struct iwl_priv *priv, struct =
sk_buff *skb)
=20
 	hdr_len =3D ieee80211_hdrlen(fc);
=20
-	/* Find index into station table for destination station */
-	sta_id =3D iwl_legacy_sta_id_or_broadcast(priv, ctx, info->control.st=
a);
-	if (sta_id =3D=3D IWL_INVALID_STATION) {
-		IWL_DEBUG_DROP(priv, "Dropping - INVALID STATION: %pM\n",
-			       hdr->addr1);
-		goto drop_unlock;
+	/* For management frames use broadcast id to do not break aggregation=
 */
+	if (!ieee80211_is_data(fc))
+		sta_id =3D ctx->bcast_sta_id;
+	else {
+		/* Find index into station table for destination station */
+		sta_id =3D iwl_legacy_sta_id_or_broadcast(priv, ctx, info->control.s=
ta);
+
+		if (sta_id =3D=3D IWL_INVALID_STATION) {
+			IWL_DEBUG_DROP(priv, "Dropping - INVALID STATION: %pM\n",
+				       hdr->addr1);
+			goto drop_unlock;
+		}
 	}
=20
 	IWL_DEBUG_TX(priv, "station Id %d\n", sta_id);
diff --git a/drivers/net/wireless/iwlegacy/iwl-led.c b/drivers/net/wire=
less/iwlegacy/iwl-led.c
index 15eb8b7..bda0d61 100644
--- a/drivers/net/wireless/iwlegacy/iwl-led.c
+++ b/drivers/net/wireless/iwlegacy/iwl-led.c
@@ -48,8 +48,21 @@ module_param(led_mode, int, S_IRUGO);
 MODULE_PARM_DESC(led_mode, "0=3Dsystem default, "
 		"1=3DOn(RF On)/Off(RF Off), 2=3Dblinking");
=20
+/* Throughput		OFF time(ms)	ON time (ms)
+ *	>300			25		25
+ *	>200 to 300		40		40
+ *	>100 to 200		55		55
+ *	>70 to 100		65		65
+ *	>50 to 70		75		75
+ *	>20 to 50		85		85
+ *	>10 to 20		95		95
+ *	>5 to 10		110		110
+ *	>1 to 5			130		130
+ *	>0 to 1			167		167
+ *	<=3D0					SOLID ON
+ */
 static const struct ieee80211_tpt_blink iwl_blink[] =3D {
-	{ .throughput =3D 0 * 1024 - 1, .blink_time =3D 334 },
+	{ .throughput =3D 0, .blink_time =3D 334 },
 	{ .throughput =3D 1 * 1024 - 1, .blink_time =3D 260 },
 	{ .throughput =3D 5 * 1024 - 1, .blink_time =3D 220 },
 	{ .throughput =3D 10 * 1024 - 1, .blink_time =3D 190 },
@@ -101,6 +114,11 @@ static int iwl_legacy_led_cmd(struct iwl_priv *pri=
v,
 	if (priv->blink_on =3D=3D on && priv->blink_off =3D=3D off)
 		return 0;
=20
+	if (off =3D=3D 0) {
+		/* led is SOLID_ON */
+		on =3D IWL_LED_SOLID;
+	}
+
 	IWL_DEBUG_LED(priv, "Led blink time compensation=3D%u\n",
 			priv->cfg->base_params->led_compensation);
 	led_cmd.on =3D iwl_legacy_blink_compensation(priv, on,
diff --git a/drivers/net/wireless/iwlegacy/iwl4965-base.c b/drivers/net=
/wireless/iwlegacy/iwl4965-base.c
index d484c36..a62fe24 100644
--- a/drivers/net/wireless/iwlegacy/iwl4965-base.c
+++ b/drivers/net/wireless/iwlegacy/iwl4965-base.c
@@ -2984,15 +2984,15 @@ static void iwl4965_bg_txpower_work(struct work=
_struct *work)
 	struct iwl_priv *priv =3D container_of(work, struct iwl_priv,
 			txpower_work);
=20
+	mutex_lock(&priv->mutex);
+
 	/* If a scan happened to start before we got here
 	 * then just return; the statistics notification will
 	 * kick off another scheduled work to compensate for
 	 * any temperature delta we missed here. */
 	if (test_bit(STATUS_EXIT_PENDING, &priv->status) ||
 	    test_bit(STATUS_SCANNING, &priv->status))
-		return;
-
-	mutex_lock(&priv->mutex);
+		goto out;
=20
 	/* Regardless of if we are associated, we must reconfigure the
 	 * TX power since frames can be sent on non-radar channels while
@@ -3002,7 +3002,7 @@ static void iwl4965_bg_txpower_work(struct work_s=
truct *work)
 	/* Update last_temperature to keep is_calib_needed from running
 	 * when it isn't needed... */
 	priv->last_temperature =3D priv->temperature;
-
+out:
 	mutex_unlock(&priv->mutex);
 }
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c b/drivers/net/wi=
reless/iwlwifi/iwl-agn-tx.c
index 2dd7d54..0712b67 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
@@ -568,12 +568,17 @@ int iwlagn_tx_skb(struct iwl_priv *priv, struct s=
k_buff *skb)
=20
 	hdr_len =3D ieee80211_hdrlen(fc);
=20
-	/* Find index into station table for destination station */
-	sta_id =3D iwl_sta_id_or_broadcast(priv, ctx, info->control.sta);
-	if (sta_id =3D=3D IWL_INVALID_STATION) {
-		IWL_DEBUG_DROP(priv, "Dropping - INVALID STATION: %pM\n",
-			       hdr->addr1);
-		goto drop_unlock;
+	/* For management frames use broadcast id to do not break aggregation=
 */
+	if (!ieee80211_is_data(fc))
+		sta_id =3D ctx->bcast_sta_id;
+	else {
+		/* Find index into station table for destination station */
+		sta_id =3D iwl_sta_id_or_broadcast(priv, ctx, info->control.sta);
+		if (sta_id =3D=3D IWL_INVALID_STATION) {
+			IWL_DEBUG_DROP(priv, "Dropping - INVALID STATION: %pM\n",
+				       hdr->addr1);
+			goto drop_unlock;
+		}
 	}
=20
 	IWL_DEBUG_TX(priv, "station Id %d\n", sta_id);
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
