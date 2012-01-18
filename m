From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2012-01-18
Date: Wed, 18 Jan 2012 15:12:12 -0500
Message-ID: <20120118201212.GN12733@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gr/z0/N6AeWAPJVB"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--gr/z0/N6AeWAPJVB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 4f3d09de38d234ce7ffba5ec5a7e6704f983d375

Dave,

Here is another small group of fixes intended for 3.3.  Included is
a fix from Javier Cardona to make the mesh code always use the right
headroom size for mesh management frames, a fix from Johannes Berg to
point a debugfs link to the right place, another fix from Johannes that
properly cleans-up some state in mac80211 after a deauth request,
and a fix from Stanislaw Gruszka to avoid a potential infinite
loop in brcmsmac.  Also included is a small Kconfig fix from me to
discourage configurations with overlapping hardware support between
b43 and brcmsmac.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit ccb19d263fd1c9e34948e2158c53eacbff369344:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-01-17=
 22:26:41 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git master

Javier Cardona (1):
      mac80211: Use the right headroom size for mesh mgmt frames

Johannes Berg (2):
      mac80211: fix debugfs key->station symlink
      mac80211: fix work removal on deauth request

John W. Linville (1):
      b43: add option to avoid duplicating device support with brcmsmac

Stanislaw Gruszka (1):
      brcmsmac: fix tx queue flush infinite loop

 drivers/net/wireless/b43/Kconfig               |    6 ++++
 drivers/net/wireless/b43/main.c                |    2 +
 drivers/net/wireless/brcm80211/brcmsmac/main.c |   10 +++++-
 net/mac80211/debugfs_key.c                     |    7 ++--
 net/mac80211/mesh_hwmp.c                       |    8 ++--
 net/mac80211/mesh_plink.c                      |    4 +-
 net/mac80211/mlme.c                            |   38 +++++++++++++++++---=
----
 7 files changed, 54 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wireless/b43/Kconfig b/drivers/net/wireless/b43/Kc=
onfig
index b97a40e..3876c7e 100644
--- a/drivers/net/wireless/b43/Kconfig
+++ b/drivers/net/wireless/b43/Kconfig
@@ -31,6 +31,12 @@ config B43_BCMA
 	depends on B43 && BCMA
 	default y
=20
+config B43_BCMA_EXTRA
+	bool "Hardware support that overlaps with the brcmsmac driver"
+	depends on B43_BCMA
+	default n if BRCMSMAC || BRCMSMAC_MODULE
+	default	y
+
 config B43_SSB
 	bool
 	depends on B43 && SSB
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/mai=
n.c
index b91f28e..23ffb1b 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -116,8 +116,10 @@ MODULE_PARM_DESC(pio, "Use PIO accesses by default: 0=
=3DDMA, 1=3DPIO");
 #ifdef CONFIG_B43_BCMA
 static const struct bcma_device_id b43_bcma_tbl[] =3D {
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_80211, 0x11, BCMA_ANY_CLASS),
+#ifdef CONFIG_B43_BCMA_EXTRA
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_80211, 0x17, BCMA_ANY_CLASS),
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_80211, 0x18, BCMA_ANY_CLASS),
+#endif
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_80211, 0x1D, BCMA_ANY_CLASS),
 	BCMA_CORETABLE_END
 };
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/w=
ireless/brcm80211/brcmsmac/main.c
index f7ed340..f6affc6 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -7981,13 +7981,21 @@ int brcms_c_get_curband(struct brcms_c_info *wlc)
=20
 void brcms_c_wait_for_tx_completion(struct brcms_c_info *wlc, bool drop)
 {
+	int timeout =3D 20;
+
 	/* flush packet queue when requested */
 	if (drop)
 		brcmu_pktq_flush(&wlc->pkt_queue->q, false, NULL, NULL);
=20
 	/* wait for queue and DMA fifos to run dry */
-	while (!pktq_empty(&wlc->pkt_queue->q) || brcms_txpktpendtot(wlc) > 0)
+	while (!pktq_empty(&wlc->pkt_queue->q) || brcms_txpktpendtot(wlc) > 0) {
 		brcms_msleep(wlc->wl, 1);
+
+		if (--timeout =3D=3D 0)
+			break;
+	}
+
+	WARN_ON_ONCE(timeout =3D=3D 0);
 }
=20
 void brcms_c_set_beacon_listen_interval(struct brcms_c_info *wlc, u8 inter=
val)
diff --git a/net/mac80211/debugfs_key.c b/net/mac80211/debugfs_key.c
index 38e6101..59edcd9 100644
--- a/net/mac80211/debugfs_key.c
+++ b/net/mac80211/debugfs_key.c
@@ -225,9 +225,9 @@ KEY_OPS(key);
 			    key, &key_##name##_ops);
=20
 void ieee80211_debugfs_key_add(struct ieee80211_key *key)
-  {
+{
 	static int keycount;
-	char buf[50];
+	char buf[100];
 	struct sta_info *sta;
=20
 	if (!key->local->debugfs.keys)
@@ -244,7 +244,8 @@ void ieee80211_debugfs_key_add(struct ieee80211_key *ke=
y)
=20
 	sta =3D key->sta;
 	if (sta) {
-		sprintf(buf, "../../stations/%pM", sta->sta.addr);
+		sprintf(buf, "../../netdev:%s/stations/%pM",
+			sta->sdata->name, sta->sta.addr);
 		key->debugfs.stalink =3D
 			debugfs_create_symlink("station", key->debugfs.dir, buf);
 	}
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 73abb75..54df1b2 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -119,12 +119,12 @@ static int mesh_path_sel_frame_tx(enum mpath_frame_ty=
pe action, u8 flags,
 	int hdr_len =3D offsetof(struct ieee80211_mgmt, u.action.u.mesh_action) +
 		      sizeof(mgmt->u.action.u.mesh_action);
=20
-	skb =3D dev_alloc_skb(local->hw.extra_tx_headroom +
+	skb =3D dev_alloc_skb(local->tx_headroom +
 			    hdr_len +
 			    2 + 37); /* max HWMP IE */
 	if (!skb)
 		return -1;
-	skb_reserve(skb, local->hw.extra_tx_headroom);
+	skb_reserve(skb, local->tx_headroom);
 	mgmt =3D (struct ieee80211_mgmt *) skb_put(skb, hdr_len);
 	memset(mgmt, 0, hdr_len);
 	mgmt->frame_control =3D cpu_to_le16(IEEE80211_FTYPE_MGMT |
@@ -250,12 +250,12 @@ int mesh_path_error_tx(u8 ttl, u8 *target, __le32 tar=
get_sn,
 	if (time_before(jiffies, ifmsh->next_perr))
 		return -EAGAIN;
=20
-	skb =3D dev_alloc_skb(local->hw.extra_tx_headroom +
+	skb =3D dev_alloc_skb(local->tx_headroom +
 			    hdr_len +
 			    2 + 15 /* PERR IE */);
 	if (!skb)
 		return -1;
-	skb_reserve(skb, local->tx_headroom + local->hw.extra_tx_headroom);
+	skb_reserve(skb, local->tx_headroom);
 	mgmt =3D (struct ieee80211_mgmt *) skb_put(skb, hdr_len);
 	memset(mgmt, 0, hdr_len);
 	mgmt->frame_control =3D cpu_to_le16(IEEE80211_FTYPE_MGMT |
diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index 41ef1b4..a172517 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -172,7 +172,7 @@ static int mesh_plink_frame_tx(struct ieee80211_sub_if_=
data *sdata,
 	int hdr_len =3D offsetof(struct ieee80211_mgmt, u.action.u.self_prot) +
 		      sizeof(mgmt->u.action.u.self_prot);
=20
-	skb =3D dev_alloc_skb(local->hw.extra_tx_headroom +
+	skb =3D dev_alloc_skb(local->tx_headroom +
 			    hdr_len +
 			    2 + /* capability info */
 			    2 + /* AID */
@@ -186,7 +186,7 @@ static int mesh_plink_frame_tx(struct ieee80211_sub_if_=
data *sdata,
 			    sdata->u.mesh.ie_len);
 	if (!skb)
 		return -1;
-	skb_reserve(skb, local->hw.extra_tx_headroom);
+	skb_reserve(skb, local->tx_headroom);
 	mgmt =3D (struct ieee80211_mgmt *) skb_put(skb, hdr_len);
 	memset(mgmt, 0, hdr_len);
 	mgmt->frame_control =3D cpu_to_le16(IEEE80211_FTYPE_MGMT |
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index ecb4c84..295be92 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -2750,7 +2750,6 @@ int ieee80211_mgd_deauth(struct ieee80211_sub_if_data=
 *sdata,
 {
 	struct ieee80211_local *local =3D sdata->local;
 	struct ieee80211_if_managed *ifmgd =3D &sdata->u.mgd;
-	struct ieee80211_work *wk;
 	u8 bssid[ETH_ALEN];
 	bool assoc_bss =3D false;
=20
@@ -2763,30 +2762,47 @@ int ieee80211_mgd_deauth(struct ieee80211_sub_if_da=
ta *sdata,
 		assoc_bss =3D true;
 	} else {
 		bool not_auth_yet =3D false;
+		struct ieee80211_work *tmp, *wk =3D NULL;
=20
 		mutex_unlock(&ifmgd->mtx);
=20
 		mutex_lock(&local->mtx);
-		list_for_each_entry(wk, &local->work_list, list) {
-			if (wk->sdata !=3D sdata)
+		list_for_each_entry(tmp, &local->work_list, list) {
+			if (tmp->sdata !=3D sdata)
 				continue;
=20
-			if (wk->type !=3D IEEE80211_WORK_DIRECT_PROBE &&
-			    wk->type !=3D IEEE80211_WORK_AUTH &&
-			    wk->type !=3D IEEE80211_WORK_ASSOC &&
-			    wk->type !=3D IEEE80211_WORK_ASSOC_BEACON_WAIT)
+			if (tmp->type !=3D IEEE80211_WORK_DIRECT_PROBE &&
+			    tmp->type !=3D IEEE80211_WORK_AUTH &&
+			    tmp->type !=3D IEEE80211_WORK_ASSOC &&
+			    tmp->type !=3D IEEE80211_WORK_ASSOC_BEACON_WAIT)
 				continue;
=20
-			if (memcmp(req->bss->bssid, wk->filter_ta, ETH_ALEN))
+			if (memcmp(req->bss->bssid, tmp->filter_ta, ETH_ALEN))
 				continue;
=20
-			not_auth_yet =3D wk->type =3D=3D IEEE80211_WORK_DIRECT_PROBE;
-			list_del_rcu(&wk->list);
-			free_work(wk);
+			not_auth_yet =3D tmp->type =3D=3D IEEE80211_WORK_DIRECT_PROBE;
+			list_del_rcu(&tmp->list);
+			synchronize_rcu();
+			wk =3D tmp;
 			break;
 		}
 		mutex_unlock(&local->mtx);
=20
+		if (wk && wk->type =3D=3D IEEE80211_WORK_ASSOC) {
+			/* clean up dummy sta & TX sync */
+			sta_info_destroy_addr(wk->sdata, wk->filter_ta);
+			if (wk->assoc.synced)
+				drv_finish_tx_sync(local, wk->sdata,
+						   wk->filter_ta,
+						   IEEE80211_TX_SYNC_ASSOC);
+		} else if (wk && wk->type =3D=3D IEEE80211_WORK_AUTH) {
+			if (wk->probe_auth.synced)
+				drv_finish_tx_sync(local, wk->sdata,
+						   wk->filter_ta,
+						   IEEE80211_TX_SYNC_AUTH);
+		}
+		kfree(wk);
+
 		/*
 		 * If somebody requests authentication and we haven't
 		 * sent out an auth frame yet there's no need to send
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--gr/z0/N6AeWAPJVB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPFyecAAoJEJctW/TcYTgGQT4QAJAj6+3Nz1beHonyPvubUVkC
PjlaSwu6pvAxOdZgo/euCw024YSGibyWuq5UYgST3BYUQJAphfMxZp774h4b43ig
2smAWEm4Vl/3LakY2yu2lN5ovwcTxmg2Pmrhyfwy/5iCRgkusz4CWqWFkolk6lZ7
fklcYrDGNF/bRQvcCoOTg4RxmzUR0u4WFjMX7Rcx4Kc1aMhKBtdHMTf4KBD+YxVK
lOn0yfzpGAy7mY5EhiEGe9lhS7uc4m/IbcXchiI4cjhPUCB4mDPhBXqYVg4kxvCn
tbfiA6j/BUVs8hpMJGNdt3rgQN1/tw3Apl02Hbj58VX2ixUyc4i1f4iWCk3fQ7A9
c7ehaWNNsn2d9XPd75NtwZGlgzGbrp8jH/nz0W78BYSlsOEKi4kjNHCGGu54cLmF
bQIdAm407mfUWQ6hbaLVbJXBuMlUULjcpCfqqBX5SNBea1fPddhI3DOvzpMJIqe+
vZbV95lMmkKbfXOG44irw2LhsH1JL4M2xIjSF/DTdMWyxgAYUy3reyRAQCjpEibV
X9o5/VurjYV0izM1t6aqhie4YfPFlsrI7/IPMkOOlpBrTzA0LmWcJjEUf6sq/+IO
ahNg+rw4jnLqRAzsQejkfr2zU75Wx70SDURCGnQoZJHBZPe58GhY4uxI3bucy8h3
+aHIwV7tBTrlhe0pDHG+
=0c+g
-----END PGP SIGNATURE-----

--gr/z0/N6AeWAPJVB--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
