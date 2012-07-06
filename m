From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-07-06
Date: Fri, 6 Jul 2012 15:20:35 -0400
Message-ID: <20120706192034.GA1879@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="h31gzZEtNLTqOjlF"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49655 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757724Ab2GFTd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 15:33:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 50787c0dfcffe9be908994bdd7bb28b1a49192b5

Dave,

Please accept these fixes for the 3.5 stream...

Eliad Peller provides a mac80211 fix to properly clean-up after an
association failure.

Sasha Levin offers an NFC fix to prevent a NULL pointer derference
in llcp_sock_getname.

Thomas Huehn provides an mwl8k fix for a race that can result in
a use-after-free bug.  Also, he provides a mac80211 fix to correct
some kzalloc arguments, and another fix to address an issue found
with that fix after I had already committed the original patch.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 9e85a6f9dc231f3ed3c1dc1b12217505d970142a:

  Merge tag 'clk-fixes-for-linus' of git://git.linaro.org/people/mturquette=
/linux (2012-07-03 18:06:49 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 50787c0dfcffe9be908994bdd7bb28b1a49192b5:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2012-07-06 14:48:50 -0400)

----------------------------------------------------------------

Eliad Peller (1):
      mac80211: destroy assoc_data correctly if assoc fails

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Sasha Levin (1):
      NFC: Prevent NULL deref when getting socket name

Thomas Huehn (3):
      mac80211: correct size the argument to kzalloc in minstrel_ht
      mwl8k: fix possible race condition in info->control.sta use
      mac80211: fix kzalloc memory corruption introduced in minstrel_ht

 drivers/net/wireless/mwl8k.c       |    3 ++-
 net/mac80211/mlme.c                |    6 ++----
 net/mac80211/rc80211_minstrel_ht.c |    2 +-
 net/nfc/llcp/sock.c                |    2 +-
 4 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index cf7bdc6..1404373 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -1665,7 +1665,8 @@ mwl8k_txq_reclaim(struct ieee80211_hw *hw, int index,=
 int limit, int force)
=20
 		info =3D IEEE80211_SKB_CB(skb);
 		if (ieee80211_is_data(wh->frame_control)) {
-			sta =3D info->control.sta;
+			sta =3D ieee80211_find_sta_by_ifaddr(hw, wh->addr1,
+								wh->addr2);
 			if (sta) {
 				sta_info =3D MWL8K_STA(sta);
 				BUG_ON(sta_info =3D=3D NULL);
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index a4bb856..0db5d34 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -2174,15 +2174,13 @@ ieee80211_rx_mgmt_assoc_resp(struct ieee80211_sub_i=
f_data *sdata,
 		       sdata->name, mgmt->sa, status_code);
 		ieee80211_destroy_assoc_data(sdata, false);
 	} else {
-		printk(KERN_DEBUG "%s: associated\n", sdata->name);
-
 		if (!ieee80211_assoc_success(sdata, *bss, mgmt, len)) {
 			/* oops -- internal error -- send timeout for now */
-			ieee80211_destroy_assoc_data(sdata, true);
-			sta_info_destroy_addr(sdata, mgmt->bssid);
+			ieee80211_destroy_assoc_data(sdata, false);
 			cfg80211_put_bss(*bss);
 			return RX_MGMT_CFG80211_ASSOC_TIMEOUT;
 		}
+		printk(KERN_DEBUG "%s: associated\n", sdata->name);
=20
 		/*
 		 * destroy assoc_data afterwards, as otherwise an idle
diff --git a/net/mac80211/rc80211_minstrel_ht.c b/net/mac80211/rc80211_mins=
trel_ht.c
index 2d1acc6..f9e51ef 100644
--- a/net/mac80211/rc80211_minstrel_ht.c
+++ b/net/mac80211/rc80211_minstrel_ht.c
@@ -809,7 +809,7 @@ minstrel_ht_alloc_sta(void *priv, struct ieee80211_sta =
*sta, gfp_t gfp)
 			max_rates =3D sband->n_bitrates;
 	}
=20
-	msp =3D kzalloc(sizeof(struct minstrel_ht_sta), gfp);
+	msp =3D kzalloc(sizeof(*msp), gfp);
 	if (!msp)
 		return NULL;
=20
diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
index 17a707d..e06d458 100644
--- a/net/nfc/llcp/sock.c
+++ b/net/nfc/llcp/sock.c
@@ -292,7 +292,7 @@ static int llcp_sock_getname(struct socket *sock, struc=
t sockaddr *addr,
=20
 	pr_debug("%p\n", sk);
=20
-	if (llcp_sock =3D=3D NULL)
+	if (llcp_sock =3D=3D NULL || llcp_sock->dev =3D=3D NULL)
 		return -EBADFD;
=20
 	addr->sa_family =3D AF_NFC;
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--h31gzZEtNLTqOjlF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJP9zqCAAoJEJctW/TcYTgGKMYP/i7Vx6dS1a0lWPykLgY2/I5Q
subWBXZvkiBSSXxU/fP3MWsjQoWDigKThdkf2aOYXRR3XXJPh/pZyzrFYm85j3oY
ywXyGxTIW9biUoDFn9CHwX7gdrbmLRWf7FJh0/WLXQVv+VT/mpwFbLJsksohTtvG
SNUHw5jtsA7+gqO4cqSnHNuOiSJyT4X8bwDPY6GTO89G7Wl2LU0t/xn97GRyqlfr
O1SjpgEuWZpMf8UTxSngqLAYNM9Ep1GgDSlMQoiOU4KVPKpYnMP9i1RaS7UHCBpD
wqeoosOXwz42QThSrsuXw9NvV/+JUqB1MDtfzsysXh4nkL70xG39QjFUpirkBIBR
I9wKlIN2VX4xUrLP/kPbCBBA6iKHhwHy+CQCVE/GO/iZ3U/yQJKVcfzI9+3Yosjw
9EekWa67Kt1aG8pZy96nEO6UCO8mEbkimApWH54jX9wrYpFBcHDUYUPvtyo7IUEx
bLi0ZTzBl1UbJ+CibVOiI7zH8Q5MzNoClPpWTA1sL9gl45afGqKcPoKdsEj5iZia
/8VfvsznV2Bi6bdAH44LDkO5EmCdIXiwSm6AfxNGfFuwvjb3EAltozuPAvy8hoe3
wzS5nRuFuMZBXS5btHg5qelH4DSj+k4jhdKN5v4s7TbM0E3ZcIGGjKjvEw1Qzu8v
uA9UTLbmsFE9Efb9grII
=oVPg
-----END PGP SIGNATURE-----

--h31gzZEtNLTqOjlF--
