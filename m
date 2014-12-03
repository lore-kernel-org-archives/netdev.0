From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-12-03
Date: Wed, 3 Dec 2014 15:34:33 -0500
Message-ID: <20141203203432.GF2896@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

One last(?) batch of fixes hoping to make 3.18...

In this episode, we have another trio of rtlwifi fixes
repairing a little more damage from the major update of the
rtlwifi-family of drivers.  These editing mistakes caused some
memory corruption and missed a flag critical to proper interrupt
handling.  Together, these fix the kernel regression reported at
https://bugzilla.kernel.org/show_bug.cgi?id=3D88951 by Catalin Iacob.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 7d63a5f9b25ba6b130da8eb2d32a72b1462d0249:

  rtlwifi: Change order in device startup (2014-11-25 14:22:22 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-12-01

for you to fetch changes up to 87141db0848aa20c43d453f5545efc8f390d4372:

  rtlwifi: rtl8192ce: Fix missing interrupt ready flag (2014-12-01 15:22:02=
 -0500)

----------------------------------------------------------------
Larry Finger (3):
      rtlwifi: rtl8192ce: Fix editing error that causes silent memory corru=
ption
      rtlwifi: rtl8192ce: Fix kernel crashes due to missing callback entry
      rtlwifi: rtl8192ce: Fix missing interrupt ready flag

 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c  |  3 ++-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c  |  3 +++
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c | 24 ++++++++++++++++++++----
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h |  2 ++
 4 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8192ce/hw.c
index 55357d69397a..d2ec5160bbf0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -1287,6 +1287,7 @@ void rtl92ce_enable_interrupt(struct ieee80211_hw *hw)
=20
 	rtl_write_dword(rtlpriv, REG_HIMR, rtlpci->irq_mask[0] & 0xFFFFFFFF);
 	rtl_write_dword(rtlpriv, REG_HIMRE, rtlpci->irq_mask[1] & 0xFFFFFFFF);
+	rtlpci->irq_enabled =3D true;
 }
=20
 void rtl92ce_disable_interrupt(struct ieee80211_hw *hw)
@@ -1296,7 +1297,7 @@ void rtl92ce_disable_interrupt(struct ieee80211_hw *h=
w)
=20
 	rtl_write_dword(rtlpriv, REG_HIMR, IMR8190_DISABLED);
 	rtl_write_dword(rtlpriv, REG_HIMRE, IMR8190_DISABLED);
-	synchronize_irq(rtlpci->pdev->irq);
+	rtlpci->irq_enabled =3D false;
 }
=20
 static void _rtl92ce_poweroff_adapter(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192ce/sw.c
index 46ea07605eb4..dd5aa089126a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -228,6 +228,7 @@ static struct rtl_hal_ops rtl8192ce_hal_ops =3D {
 	.led_control =3D rtl92ce_led_control,
 	.set_desc =3D rtl92ce_set_desc,
 	.get_desc =3D rtl92ce_get_desc,
+	.is_tx_desc_closed =3D rtl92ce_is_tx_desc_closed,
 	.tx_polling =3D rtl92ce_tx_polling,
 	.enable_hw_sec =3D rtl92ce_enable_hw_security_config,
 	.set_key =3D rtl92ce_set_key,
@@ -271,6 +272,8 @@ static struct rtl_hal_cfg rtl92ce_hal_cfg =3D {
 	.maps[MAC_RCR_ACRC32] =3D ACRC32,
 	.maps[MAC_RCR_ACF] =3D ACF,
 	.maps[MAC_RCR_AAP] =3D AAP,
+	.maps[MAC_HIMR] =3D REG_HIMR,
+	.maps[MAC_HIMRE] =3D REG_HIMRE,
=20
 	.maps[EFUSE_TEST] =3D REG_EFUSE_TEST,
 	.maps[EFUSE_CTRL] =3D REG_EFUSE_CTRL,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8192ce/trx.c
index dc3d20b17a26..e88dcd0e0af1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -720,16 +720,15 @@ u32 rtl92ce_get_desc(u8 *p_desc, bool istx, u8 desc_n=
ame)
 			break;
 		}
 	} else {
-		struct rx_desc_92c *pdesc =3D (struct rx_desc_92c *)p_desc;
 		switch (desc_name) {
 		case HW_DESC_OWN:
-			ret =3D GET_RX_DESC_OWN(pdesc);
+			ret =3D GET_RX_DESC_OWN(p_desc);
 			break;
 		case HW_DESC_RXPKT_LEN:
-			ret =3D GET_RX_DESC_PKT_LEN(pdesc);
+			ret =3D GET_RX_DESC_PKT_LEN(p_desc);
 			break;
 		case HW_DESC_RXBUFF_ADDR:
-			ret =3D GET_RX_STATUS_DESC_BUFF_ADDR(pdesc);
+			ret =3D GET_RX_DESC_BUFF_ADDR(p_desc);
 			break;
 		default:
 			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
@@ -740,6 +739,23 @@ u32 rtl92ce_get_desc(u8 *p_desc, bool istx, u8 desc_na=
me)
 	return ret;
 }
=20
+bool rtl92ce_is_tx_desc_closed(struct ieee80211_hw *hw,
+			       u8 hw_queue, u16 index)
+{
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring =3D &rtlpci->tx_ring[hw_queue];
+	u8 *entry =3D (u8 *)(&ring->desc[ring->idx]);
+	u8 own =3D (u8)rtl92ce_get_desc(entry, true, HW_DESC_OWN);
+
+	/*beacon packet will only use the first
+	 *descriptor defautly,and the own may not
+	 *be cleared by the hardware
+	 */
+	if (own)
+		return false;
+	return true;
+}
+
 void rtl92ce_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
 {
 	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.h b/drivers/net/wir=
eless/rtlwifi/rtl8192ce/trx.h
index 9a39ec4204dd..4bec4b07e3e0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.h
@@ -723,6 +723,8 @@ bool rtl92ce_rx_query_desc(struct ieee80211_hw *hw,
 void rtl92ce_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 		      u8 desc_name, u8 *val);
 u32 rtl92ce_get_desc(u8 *pdesc, bool istx, u8 desc_name);
+bool rtl92ce_is_tx_desc_closed(struct ieee80211_hw *hw,
+			       u8 hw_queue, u16 index);
 void rtl92ce_tx_polling(struct ieee80211_hw *hw, u8 hw_queue);
 void rtl92ce_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 			     bool b_firstseg, bool b_lastseg,
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUf3PYAAoJEJctW/TcYTgGGfEP+wbILZyEbdI+KZ9jqFeQf/IQ
Hf5hKTZpiNfWDSD+CpwPn2iFV9AfPeu9pkiZ5kD5CjqS0jPq5sIC2kG4o9Uod2NO
1kU2lSMDAFA1Ts90k7QJiMRULAvHc2HzfaqB+e4keLY8TJcfvIXTYEbyAZNJf3OS
4Zc7HkbxzWFmnDsoZ8N5GFA1yvwR/nvvR1WKqP/Ov2YDD0tWafoD+plo18G0bS6d
1dSUajkbwVtEikZ75NLleBp3Y5LbW4bsIQcWSppuz8Yn1YvfHwJz74X0w6nueV8b
E0jEnfCHj35WS1EEvCU5Yl8aXt/hCMYA7xZq4M4gIdMsOMJeVlIIHccxHlGQF1YJ
gjzzs1LiDubCaZuJ8e4GIG1OOT4PJt6bGlVtVKhnAHybw4FgiVZ5EDATNK+UGWf9
U15iLKhQCTYspQlCBNY6LFFKpLaBztHbT/ZhIHbEfX4ZLKNN6m+QKzoXEWu7LRHc
jIHocWc2ufnOjh0XITVXgKJdSqNbS2098exi7eRSX42pUkKdk0Yy2qNR6IKT0fQJ
67uckksiggROL8hzRo9g6MQbKUlGMFJ2v+dA5LBPFibbOn4GnbLgeVcuyQcreaak
ktI+o3TWcP+H1QNMtW1GIu7apJu0h9nvl2SkqxTmnZOUEpMD3DV9C05qeuR8Uaq7
0NjfVwYlilp+r+e3hFAY
=R3j8
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--
