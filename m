From: "John W. Linville" <linville@tuxdriver.com>
Subject: One more patch... -- Re: Please pull 'upstream-jgarzik' branch of
	wireless-2.6
Date: Tue, 8 Jan 2008 17:42:02 -0500
Message-ID: <20080108224202.GE3086@tuxdriver.com>
References: <20080108222305.GD3086@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2177 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751619AbYAHWuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 17:50:03 -0500
Content-Disposition: inline
In-Reply-To: <20080108222305.GD3086@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 08, 2008 at 05:23:05PM -0500, John W. Linville wrote:
> Jeff,
>=20
> Another round of patches intended for 2.6.25...the biggest factions a=
re
> rt2x00 and b43 updates, as well as some Viro-isms... :-)
>=20
> Please let me know if there are any problems!
>=20
> John
>=20
> P.S.  Copying Dave in case he is handling these requests...FWIW, it
> will definitely depend on the patches already in netdev-2.6#upstream.=
=2E.

I left out a patch.  I have pushed it on top of the previous request.

Let me know if there are problems!

Thanks,

John

---

The following changes since commit f94de7b013f78ad8bbe1064c108dd55141ef=
b177:
  Miguel Bot=F3n (1):
        iwlwifi: fix compilation warning in 'iwl-4965.c'

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it upstream-jgarzik

Michael Buesch (1):
      zd1211rw: fix alignment for QOS and WDS frames

 drivers/net/wireless/zd1211rw/zd_mac.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wirel=
ess/zd1211rw/zd_mac.c
index 14fb727..7b86930 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -623,6 +623,8 @@ int zd_mac_rx(struct ieee80211_hw *hw, const u8 *bu=
ffer, unsigned int length)
 	const struct rx_status *status;
 	struct sk_buff *skb;
 	int bad_frame =3D 0;
+	u16 fc;
+	bool is_qos, is_4addr, need_padding;
=20
 	if (length < ZD_PLCP_HEADER_SIZE + 10 /* IEEE80211_1ADDR_LEN */ +
 	             FCS_LEN + sizeof(struct rx_status))
@@ -674,9 +676,22 @@ int zd_mac_rx(struct ieee80211_hw *hw, const u8 *b=
uffer, unsigned int length)
 			&& !mac->pass_ctrl)
 		return 0;
=20
-	skb =3D dev_alloc_skb(length);
+	fc =3D le16_to_cpu(*((__le16 *) buffer));
+
+	is_qos =3D ((fc & IEEE80211_FCTL_FTYPE) =3D=3D IEEE80211_FTYPE_DATA) =
&&
+		 ((fc & IEEE80211_FCTL_STYPE) =3D=3D IEEE80211_STYPE_QOS_DATA);
+	is_4addr =3D (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) =3D=
=3D
+		   (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS);
+	need_padding =3D is_qos ^ is_4addr;
+
+	skb =3D dev_alloc_skb(length + (need_padding ? 2 : 0));
 	if (skb =3D=3D NULL)
 		return -ENOMEM;
+	if (need_padding) {
+		/* Make sure the the payload data is 4 byte aligned. */
+		skb_reserve(skb, 2);
+	}
+
 	memcpy(skb_put(skb, length), buffer, length);
=20
 	ieee80211_rx_irqsafe(hw, skb, &stats);
--=20
John W. Linville
linville@tuxdriver.com
