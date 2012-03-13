From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-03-13
Date: Tue, 13 Mar 2012 15:21:20 -0400
Message-ID: <20120313192119.GC5837@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gKMricLos+KVdGMg"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Stanislaw has given us two late-breaking fixes intended for 3.3.  One
avoids a NULL pointer dereference in iwl3945, and the other corrects a
locking issue in the rt2x00 driver that can lead to random traffic
stalls.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d:

  tun: don't hold network namespace by tun sockets (2012-03-12 17:14:00 -07=
00)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Stanislaw Gruszka (2):
      iwl3945: fix possible il->txq NULL pointer dereference in delayed wor=
ks
      rt2x00: fix random stalls

 drivers/net/wireless/iwlegacy/3945-mac.c  |    2 +-
 drivers/net/wireless/iwlegacy/3945.c      |    7 ++++---
 drivers/net/wireless/rt2x00/rt2x00dev.c   |    6 +++++-
 drivers/net/wireless/rt2x00/rt2x00mac.c   |    9 +++++++++
 drivers/net/wireless/rt2x00/rt2x00queue.c |    3 +++
 5 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireles=
s/iwlegacy/3945-mac.c
index 54b2d39..a7dfba8 100644
--- a/drivers/net/wireless/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/iwlegacy/3945-mac.c
@@ -2475,7 +2475,7 @@ il3945_bg_alive_start(struct work_struct *data)
 	    container_of(data, struct il_priv, alive_start.work);
=20
 	mutex_lock(&il->mutex);
-	if (test_bit(S_EXIT_PENDING, &il->status))
+	if (test_bit(S_EXIT_PENDING, &il->status) || il->txq =3D=3D NULL)
 		goto out;
=20
 	il3945_alive_start(il);
diff --git a/drivers/net/wireless/iwlegacy/3945.c b/drivers/net/wireless/iw=
legacy/3945.c
index 1489b15..c80eb9b 100644
--- a/drivers/net/wireless/iwlegacy/3945.c
+++ b/drivers/net/wireless/iwlegacy/3945.c
@@ -1870,11 +1870,12 @@ il3945_bg_reg_txpower_periodic(struct work_struct *=
work)
 	struct il_priv *il =3D container_of(work, struct il_priv,
 					  _3945.thermal_periodic.work);
=20
-	if (test_bit(S_EXIT_PENDING, &il->status))
-		return;
-
 	mutex_lock(&il->mutex);
+	if (test_bit(S_EXIT_PENDING, &il->status) || il->txq =3D=3D NULL)
+		goto out;
+
 	il3945_reg_txpower_periodic(il);
+out:
 	mutex_unlock(&il->mutex);
 }
=20
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless=
/rt2x00/rt2x00dev.c
index d2a1ea9..fd356b7 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -426,10 +426,14 @@ void rt2x00lib_txdone(struct queue_entry *entry,
 	/*
 	 * If the data queue was below the threshold before the txdone
 	 * handler we must make sure the packet queue in the mac80211 stack
-	 * is reenabled when the txdone handler has finished.
+	 * is reenabled when the txdone handler has finished. This has to be
+	 * serialized with rt2x00mac_tx(), otherwise we can wake up queue
+	 * before it was stopped.
 	 */
+	spin_lock_bh(&entry->queue->tx_lock);
 	if (!rt2x00queue_threshold(entry->queue))
 		rt2x00queue_unpause_queue(entry->queue);
+	spin_unlock_bh(&entry->queue->tx_lock);
 }
 EXPORT_SYMBOL_GPL(rt2x00lib_txdone);
=20
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless=
/rt2x00/rt2x00mac.c
index ede3c58..2df2eb6 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -152,13 +152,22 @@ void rt2x00mac_tx(struct ieee80211_hw *hw, struct sk_=
buff *skb)
 	if (unlikely(rt2x00queue_write_tx_frame(queue, skb, false)))
 		goto exit_fail;
=20
+	/*
+	 * Pausing queue has to be serialized with rt2x00lib_txdone(). Note
+	 * we should not use spin_lock_bh variant as bottom halve was already
+	 * disabled before ieee80211_xmit() call.
+	 */
+	spin_lock(&queue->tx_lock);
 	if (rt2x00queue_threshold(queue))
 		rt2x00queue_pause_queue(queue);
+	spin_unlock(&queue->tx_lock);
=20
 	return;
=20
  exit_fail:
+	spin_lock(&queue->tx_lock);
 	rt2x00queue_pause_queue(queue);
+	spin_unlock(&queue->tx_lock);
  exit_free_skb:
 	ieee80211_free_txskb(hw, skb);
 }
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wirele=
ss/rt2x00/rt2x00queue.c
index 5adfb3e..9b1b2b7 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -619,6 +619,9 @@ int rt2x00queue_write_tx_frame(struct data_queue *queue=
, struct sk_buff *skb,
 	else if (test_bit(REQUIRE_DMA, &queue->rt2x00dev->cap_flags))
 		rt2x00queue_align_frame(skb);
=20
+	/*
+	 * That function must be called with bh disabled.
+	 */
 	spin_lock(&queue->tx_lock);
=20
 	if (unlikely(rt2x00queue_full(queue))) {
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--gKMricLos+KVdGMg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPX54vAAoJEJctW/TcYTgG0n0QAJtc0AIOD0Wr2zpapWi9l2hy
QjADABvIGTyXtJs+7ea2ho6kogQexCsit6wUnobexFcy4K7gFRrgeOwTrurXqWgx
egwGlIwQ6v2sy8tfiiSuCJmaMrXC6IDQIdOUObiTL4nAa3q7UlLizkeQFZmTNu7Z
WRY/dcdhh2zTNRQJ/ka/XkxrCIvsD3jmr8uwvvmgEero8Mc2lxDka6u7h9drEYz2
wB+TkPLDfbUkV9pdyF8266QQBpya4Bmuegn4qCsGjlPmduB3jczD76vu5PEG0O1Y
6OaiM2p9XugJ7bFCS4bDY3M1/phIfPK+G57gbeTi0+ralfMQnG5SRafEaEeHveGu
6QYb+TYQmLeh9S39x0H2bIQ+FvgHr1jL7L1q30hMnmfs/+7TN5btgTzHdHVAbQie
jwDZuiZHzFkQ6P3e8nRWiEQiF1zvSVZ/8O3yq1K6BJcY/iheAWARG7l0K87SctF+
di9OIJOingxhYCMV40/QkXY+zn/Yhf4MLWnogVXbcuMFHR3w+tyXQJNv2kddqWT3
DZKt3uNqYv+8Kmdqh4u7QlZMHan4JUJhgiqJQZjbqL1WFPk6MVr6nxeRTa+87tMz
P0kbVZVEOgMLHp+0L7zYenVZkm1cm6MRt2SlDOAQFXnjV3KU1u40gdkEQeVY4CKl
PoDLcxW7fGpAJuN8omhl
=i/pt
-----END PGP SIGNATURE-----

--gKMricLos+KVdGMg--
