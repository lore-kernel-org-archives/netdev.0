From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH] d80211: remove pkt_type/pkt_probe_resp
Date: Sat, 9 Dec 2006 01:44:54 -0500
Message-ID: <200612090144.59126.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1322207.7nJZillaCu";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:49593 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759218AbWLIGqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 01:46:04 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1322207.7nJZillaCu
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

d80211: remove pkt_type/pkt_probe_resp

Nobody uses pkt_type, and the information can be obtained from the
header. This removes it and the associated code that keeps tracks of it.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 include/net/d80211.h       |    1 -
 net/d80211/ieee80211.c     |    7 -------
 net/d80211/ieee80211_i.h   |    3 +--
 net/d80211/ieee80211_sta.c |   17 +++++++----------
 4 files changed, 8 insertions(+), 20 deletions(-)

diff --git a/include/net/d80211.h b/include/net/d80211.h
index 30980e1..f7f6318 100644
=2D-- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -135,7 +135,6 @@ struct ieee80211_low_level_stats {
 #define HW_KEY_IDX_INVALID -1
=20
 struct ieee80211_tx_control {
=2D	enum { PKT_NORMAL =3D 0, PKT_PROBE_RESP } pkt_type;
 	int tx_rate; /* Transmit rate, given as the hw specific value for the
 		      * rate (from struct ieee80211_rate) */
 	int rts_cts_rate; /* Transmit rate for RTS/CTS frame, given as the hw
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 6e10db5..5ea51a5 100644
=2D-- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1395,8 +1395,6 @@ static int ieee80211_master_start_xmit(s
 		control.flags |=3D IEEE80211_TXCTL_REQ_TX_STATUS;
 	if (pkt_data->do_not_encrypt)
 		control.flags |=3D IEEE80211_TXCTL_DO_NOT_ENCRYPT;
=2D	control.pkt_type =3D
=2D		pkt_data->pkt_probe_resp ? PKT_PROBE_RESP : PKT_NORMAL;
 	if (pkt_data->requeue)
 		control.flags |=3D IEEE80211_TXCTL_REQUEUE;
 	control.queue =3D pkt_data->queue;
@@ -1628,10 +1626,6 @@ ieee80211_mgmt_start_xmit(struct sk_buff
         pkt_data->ifindex =3D sdata->dev->ifindex;
 	pkt_data->mgmt_iface =3D (sdata->type =3D=3D IEEE80211_IF_TYPE_MGMT);
=20
=2D	if ((fc & IEEE80211_FCTL_FTYPE) =3D=3D IEEE80211_FTYPE_MGMT &&
=2D	    (fc & IEEE80211_FCTL_STYPE) =3D=3D IEEE80211_STYPE_PROBE_RESP)
=2D		pkt_data->pkt_probe_resp =3D 1;
=2D
 	skb->priority =3D 20; /* use hardcoded priority for mgmt TX queue */
 	skb->dev =3D sdata->local->mdev;
=20
@@ -4050,7 +4044,6 @@ static void ieee80211_remove_tx_extra(st
 	pkt_data->mgmt_iface =3D (control->type =3D=3D IEEE80211_IF_TYPE_MGMT);
 	pkt_data->req_tx_status =3D !!(control->flags & IEEE80211_TXCTL_REQ_TX_ST=
ATUS);
 	pkt_data->do_not_encrypt =3D !!(control->flags & IEEE80211_TXCTL_DO_NOT_E=
NCRYPT);
=2D	pkt_data->pkt_probe_resp =3D (control->pkt_type =3D=3D PKT_PROBE_RESP);
 	pkt_data->requeue =3D !!(control->flags & IEEE80211_TXCTL_REQUEUE);
 	pkt_data->queue =3D control->queue;
=20
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index ef303da..02fbdea 100644
=2D-- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -155,10 +155,9 @@ struct ieee80211_tx_packet_data {
 	unsigned long jiffies;
 	unsigned int req_tx_status:1;
 	unsigned int do_not_encrypt:1;
=2D	unsigned int pkt_probe_resp:1;
 	unsigned int requeue:1;
=2D	unsigned int queue:4;
 	unsigned int mgmt_iface:1;
+	unsigned int queue:4;
 };
=20
 struct ieee80211_tx_stored_packet {
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 04bd5cd..7594022 100644
=2D-- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -384,7 +384,7 @@ static void ieee80211_set_associated(str
=20
=20
 static void ieee80211_sta_tx(struct net_device *dev, struct sk_buff *skb,
=2D			     int encrypt, int probe_resp)
+			     int encrypt)
 {
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_tx_packet_data *pkt_data;
@@ -398,8 +398,6 @@ static void ieee80211_sta_tx(struct net_
 	pkt_data->ifindex =3D sdata->dev->ifindex;
 	pkt_data->mgmt_iface =3D (sdata->type =3D=3D IEEE80211_IF_TYPE_MGMT);
 	pkt_data->do_not_encrypt =3D !encrypt;
=2D	if (probe_resp)
=2D		pkt_data->pkt_probe_resp =3D 1;
=20
 	dev_queue_xmit(skb);
 }
@@ -436,7 +434,7 @@ static void ieee80211_send_auth(struct n
 	if (extra)
 		memcpy(skb_put(skb, extra_len), extra, extra_len);
=20
=2D	ieee80211_sta_tx(dev, skb, encrypt, 0);
+	ieee80211_sta_tx(dev, skb, encrypt);
 }
=20
=20
@@ -573,7 +571,7 @@ static void ieee80211_send_assoc(struct
 	if (ifsta->assocreq_ies)
 		memcpy(ifsta->assocreq_ies, ies, ifsta->assocreq_ies_len);
=20
=2D	ieee80211_sta_tx(dev, skb, 0, 0);
+	ieee80211_sta_tx(dev, skb, 0);
 }
=20
=20
@@ -600,7 +598,7 @@ static void ieee80211_send_deauth(struct
 	skb_put(skb, 2);
 	mgmt->u.deauth.reason_code =3D cpu_to_le16(reason);
=20
=2D	ieee80211_sta_tx(dev, skb, 0, 0);
+	ieee80211_sta_tx(dev, skb, 0);
 }
=20
=20
@@ -627,7 +625,7 @@ static void ieee80211_send_disassoc(stru
 	skb_put(skb, 2);
 	mgmt->u.disassoc.reason_code =3D cpu_to_le16(reason);
=20
=2D	ieee80211_sta_tx(dev, skb, 0, 0);
+	ieee80211_sta_tx(dev, skb, 0);
 }
=20
=20
@@ -803,7 +801,7 @@ static void ieee80211_send_probe_req(str
 			*pos =3D rate->rate / 5;
 	}
=20
=2D	ieee80211_sta_tx(dev, skb, 0, 0);
+	ieee80211_sta_tx(dev, skb, 0);
 }
=20
=20
@@ -1693,7 +1691,7 @@ static void ieee80211_rx_mgmt_probe_req(
 	printk(KERN_DEBUG "%s: Sending ProbeResp to " MAC_FMT "\n",
 	       dev->name, MAC_ARG(resp->da));
 #endif /* CONFIG_D80211_IBSS_DEBUG */
=2D	ieee80211_sta_tx(dev, skb, 0, 1);
+	ieee80211_sta_tx(dev, skb, 0);
 }
=20
=20
@@ -2046,7 +2044,6 @@ static int ieee80211_sta_join_ibss(struc
 		}
=20
 		memset(&control, 0, sizeof(control));
=2D		control.pkt_type =3D PKT_PROBE_RESP;
 		memset(&extra, 0, sizeof(extra));
 		extra.endidx =3D local->num_curr_rates;
 		rate =3D rate_control_get_rate(local, dev, skb, &extra);

--nextPart1322207.7nJZillaCu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFeltrT3Oqt9AH4aERAtn4AJ4u8NFIIQVCOTHujTHpkFZCAYLuYACg1Tnz
yb8WHoo/yPwCZgk03sxDN4s=
=8+il
-----END PGP SIGNATURE-----

--nextPart1322207.7nJZillaCu--
