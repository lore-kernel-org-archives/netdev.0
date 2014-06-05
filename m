From: "Cedric Debarge" <cedric.debarge@acksys.fr>
Subject: [RFC]mac80211: Add radiotap field in parser
Date: Thu, 5 Jun 2014 10:54:25 +0200
Message-ID: <773DB8A82AB6A046AE0195C68612A319017BCF36@sbs2003.acksys.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out06.msg.oleane.net ([62.161.7.4]:35183 "EHLO
	smtp-out06.msg.oleane.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbaFEJmM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 05:42:12 -0400
Received: from smtp29.msg.oleane.net (smtp29.mail.priv [172.17.20.151])
	by smtp-out06.msg.oleane.net with ESMTP id s559Ell6022118
	for <netdev@vger.kernel.org>; Thu, 5 Jun 2014 11:14:47 +0200
Received: from acksys.fr ([195.6.104.67]) (authenticated)
	by smtp29.msg.oleane.net (MTA) with ESMTP id s558sQTN013564
	for <netdev@vger.kernel.org>; Thu, 5 Jun 2014 10:54:26 +0200
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the radiotap field IEEE80211_RADIOTAP_RATE and
IEEE80211_RADIOTAP_MCS radiotap parser.

These additions are compatible with the radiotap definition
(http://www.radiotap.org/Radiotap)

Previous attempts were made on this mailing list using a new flag in
ieee80211_tx_info. But since this field is now full, I choose to use a =
bit field
in the rate control part of the ieee80211_tx_info.

signed-off-by: C=E9dric Debarge <cedric.debarge@acksys.fr>
---
 include/net/mac80211.h |    1 +
 net/mac80211/tx.c      |   72 ++++++++++++++++++++++++++++++++++++++++=
++++++--
 2 files changed, 70 insertions(+), 3 deletions(-)

diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 421b6ec..3ed63d8 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -721,6 +721,7 @@ struct ieee80211_tx_info {
 					u8 use_cts_prot:1;
 					u8 short_preamble:1;
 					u8 skip_table:1;
+					u8 tx_ctl_rc_bypass:1;
 					/* 2 bytes free */
 				};
 				/* only needed before rate control */
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 5214686..7aff9b5 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -657,6 +657,9 @@ ieee80211_tx_h_rate_ctrl(struct ieee80211_tx_data *=
tx)
 	struct ieee80211_sta_rates *ratetbl =3D NULL;
 	bool assoc =3D false;
=20
+	if (info->control.tx_ctl_rc_bypass)
+		return TX_CONTINUE;
+
 	memset(&txrc, 0, sizeof(txrc));
=20
 	sband =3D tx->local->hw.wiphy->bands[info->band];
@@ -1530,19 +1533,30 @@ void ieee80211_xmit(struct ieee80211_sub_if_dat=
a *sdata, struct sk_buff *skb,
 	ieee80211_tx(sdata, skb, false, band);
 }
=20
-static bool ieee80211_parse_tx_radiotap(struct sk_buff *skb)
+static bool ieee80211_parse_tx_radiotap(struct sk_buff *skb,
+										struct ieee80211_local *local)
 {
 	struct ieee80211_radiotap_iterator iterator;
 	struct ieee80211_radiotap_header *rthdr =3D
 		(struct ieee80211_radiotap_header *) skb->data;
 	struct ieee80211_tx_info *info =3D IEEE80211_SKB_CB(skb);
+	struct ieee80211_channel *chan =3D local->monitor_chandef.chan;=20
+	struct ieee80211_supported_band *sband =3D
+		local->hw.wiphy->bands[chan->band];
+ 	u16 txflags;
+	s8 rate_idx;
+	u16 bit_rate;
+	int i;
+	unsigned char known;
+	unsigned char flags;
 	int ret =3D ieee80211_radiotap_iterator_init(&iterator, rthdr, skb->l=
en,
 						   NULL);
-	u16 txflags;
=20
 	info->flags |=3D IEEE80211_TX_INTFL_DONT_ENCRYPT |
 		       IEEE80211_TX_CTL_DONTFRAG;
=20
+	info->control.tx_ctl_rc_bypass =3D 0;
+
 	/*
 	 * for every radiotap entry that is present
 	 * (ieee80211_radiotap_iterator_next returns -ENOENT when no more
@@ -1589,6 +1603,58 @@ static bool ieee80211_parse_tx_radiotap(struct s=
k_buff *skb)
 				info->flags |=3D IEEE80211_TX_CTL_NO_ACK;
 			break;
=20
+		case IEEE80211_RADIOTAP_RATE:=20
+			rate_idx =3D -1;
+			/* convert legacy rate; NB: .5 Mb/s -> 100 kb/s */
+			bit_rate =3D *iterator.this_arg * 5;
+			for (i =3D 0; i < sband->n_bitrates; i++){
+				if (sband->bitrates[i].bitrate =3D=3D bit_rate) {
+					rate_idx =3D i;
+					break;
+				}
+			}
+			/* Rate not available - rejecting */
+			if (rate_idx < 0)
+				return false;
+
+			info->control.tx_ctl_rc_bypass =3D 1;
+			info->control.rates[0].idx =3D rate_idx;
+			info->control.rates[0].count =3D 1;
+			break;
+			=09
+		case IEEE80211_RADIOTAP_MCS:
+			known =3D iterator.this_arg[0];
+			flags =3D iterator.this_arg[1];
+			rate_idx =3D iterator.this_arg[2];
+
+			/* 11n not supported - rejecting */
+			if(!sband->ht_cap.ht_supported) {
+				return false;
+			}
+
+			/* set mcs */
+			if(known & IEEE80211_RADIOTAP_MCS_HAVE_MCS) {
+				info->control.rates[0].idx =3D rate_idx;
+				info->control.rates[0].flags |=3D=20
+					IEEE80211_TX_RC_MCS;
+			}
+
+			/* set GI */
+			if ((known & IEEE80211_RADIOTAP_MCS_HAVE_GI) &&
+				(flags & IEEE80211_RADIOTAP_MCS_SGI))
+				info->control.rates[0].flags |=3D=20
+					IEEE80211_TX_RC_SHORT_GI;
+
+			/* set bandwith */
+			if ((known & IEEE80211_RADIOTAP_MCS_HAVE_BW) &&
+			    (flags & IEEE80211_RADIOTAP_MCS_BW_40))
+				info->control.rates[0].flags |=3D=20
+					IEEE80211_TX_RC_40_MHZ_WIDTH;
+
+			info->control.rates[0].count =3D 1;
+			info->control.tx_ctl_rc_bypass =3D 1;
+			break;
+
 		/*
 		 * Please update the file
 		 * Documentation/networking/mac80211-injection.txt
@@ -1684,7 +1750,7 @@ netdev_tx_t ieee80211_monitor_start_xmit(struct s=
k_buff *skb,
 		      IEEE80211_TX_CTL_INJECTED;
=20
 	/* process and remove the injection radiotap header */
-	if (!ieee80211_parse_tx_radiotap(skb))
+	if (!ieee80211_parse_tx_radiotap(skb, local))
 		goto fail;
=20
 	rcu_read_lock();
--=20
1.7.9.5

C=E9dric DEBARGE
