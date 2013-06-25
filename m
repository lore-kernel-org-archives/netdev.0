From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-06-25
Date: Tue, 25 Jun 2013 13:45:07 -0400
Message-ID: <20130625174507.GB31220@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fUYQa+Pmc3FrFX/N"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dave@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

A few more late-breaking fixes hoping for 3.10...

Regarding the Bluetooth fix, Gustavo says:

"A important fix to 3.10, this patch fixes an issues that was preventing
the l2cap info response command to be handled properly."

Also for that Bluetooth fix, Johan adds:

"Once the code gives up parsing this PDU it also gives up essential
parts of the L2CAP connection creation process, i.e. without this
patch the stack will fail to establish connections properly."

Moving onto ath9k, Felix Fietkau fixes an RCU locking issue in
the transmit path.  As for ath9k_htc, Sujith Manoharan fixes some
authentication timeouts by ensuring that a chip reset is done when
IDLE is turned off.

I think these are all micro-fixes that shouldn't cause any trouble.
Please let me know if there are problems!

John

---

The following changes since commit f57da7a65b386dd4535daa4f7a3773a025fbb022:

  qlcnic: Do not sleep while holding spinlock (2013-06-24 00:28:28 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 9d5c34f568a8d80cb69cc89ebb426ceb1d1f4737:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-06-25 13:24:12 -0400)

----------------------------------------------------------------

Felix Fietkau (1):
      ath9k: fix an RCU issue in calling ieee80211_get_tx_rates

Jaganath Kanakkassery (1):
      Bluetooth: Fix invalid length check in l2cap_information_rsp()

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Sujith Manoharan (1):
      ath9k_htc: Handle IDLE state transition properly

 drivers/net/wireless/ath/ath9k/htc_drv_main.c | 2 +-
 drivers/net/wireless/ath/ath9k/xmit.c         | 6 +++++-
 net/bluetooth/l2cap_core.c                    | 2 +-
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wi=
reless/ath/ath9k/htc_drv_main.c
index 0743a47..62f1b76 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -1174,7 +1174,7 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, =
u32 changed)
 		mutex_lock(&priv->htc_pm_lock);
=20
 		priv->ps_idle =3D !!(conf->flags & IEEE80211_CONF_IDLE);
-		if (priv->ps_idle)
+		if (!priv->ps_idle)
 			chip_reset =3D true;
=20
 		mutex_unlock(&priv->htc_pm_lock);
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index 1c9b1ba..83ab6be 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1570,6 +1570,8 @@ void ath_txq_schedule(struct ath_softc *sc, struct at=
h_txq *txq)
 	    txq->axq_ampdu_depth >=3D ATH_AGGR_MIN_QDEPTH)
 		return;
=20
+	rcu_read_lock();
+
 	ac =3D list_first_entry(&txq->axq_acq, struct ath_atx_ac, list);
 	last_ac =3D list_entry(txq->axq_acq.prev, struct ath_atx_ac, list);
=20
@@ -1608,8 +1610,10 @@ void ath_txq_schedule(struct ath_softc *sc, struct a=
th_txq *txq)
=20
 		if (ac =3D=3D last_ac ||
 		    txq->axq_ampdu_depth >=3D ATH_AGGR_MIN_QDEPTH)
-			return;
+			break;
 	}
+
+	rcu_read_unlock();
 }
=20
 /***********/
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 4be6a26..68843a2 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -4333,7 +4333,7 @@ static inline int l2cap_information_rsp(struct l2cap_=
conn *conn,
 	struct l2cap_info_rsp *rsp =3D (struct l2cap_info_rsp *) data;
 	u16 type, result;
=20
-	if (cmd_len !=3D sizeof(*rsp))
+	if (cmd_len < sizeof(*rsp))
 		return -EPROTO;
=20
 	type   =3D __le16_to_cpu(rsp->type);
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--fUYQa+Pmc3FrFX/N
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRydciAAoJEJctW/TcYTgGRuQQAJOxbpJToNMK1R6YYU7yCWr5
XI6t6TePOhr6zUFJNN1hIBq564vRn4Nn5uJHpgeMfOxNEHmjM10gmL3BuWqrFE8k
aehld7p+zDKgZMypZUzpG9OP7pNTiRmC7MVjYd9gP4OraT7OqtwMLQHMaytutBrk
sgHufOkeidqul7J0tJVmVtLfaTvME3rL2o+vxw6cnm3wFqf+bkR4exhC6gQHNbva
z/uMTmg6BcxfyaNHlFxQPVrnrCL57fzNeXqzezQCOthKk9pWEJZfFVV2us41Dpfn
zyaqTEBc1qwFflzn4vzsQylNd+WFlSAoLHv4Onr+tjOMDDi+L/w7QX/dw4thGAi8
2FZaiPSotxlRSlXnsz3wbdK6WqStYTHrwzOr6u+DdG5adVJv0JbDAzPZP6QDnPYS
k0ub382D6OyufACDZ0quU/QQ0CdUKRt9MJGQJ7HQfscQ5l+gyd643XnVeY+mssH1
67pidDvDdTLR1KvdFhCPTZY0O+0G2OKeADKE/3s9vku4YNEf5ZOxcgHvqoKiPkrq
xumLQ4KaDCFoTqnwyZEiz0nQv8x/j5xkpjfk4RUU1iugpL1S6E2KQ96JgeRmF64k
eeqt2vBDxJNKefzXqg3Nww7fczd7EX3oGOhTd5mlRHHVSSWaGVWRbvi8ZlC1cJzv
TIrx/RL+jxWMq6MB43SR
=zVgD
-----END PGP SIGNATURE-----

--fUYQa+Pmc3FrFX/N--
