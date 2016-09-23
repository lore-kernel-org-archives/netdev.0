From: =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke-LJ9M9ZcSy1A@public.gmane.org>
Subject: [PATCH 3/3] mac80211: Set lower memory limit for non-VHT devices
Date: Fri, 23 Sep 2016 21:59:11 +0200
Message-ID: <20160923195911.4572-4-toke@toke.dk>
References: <20160923195911.4572-1-toke@toke.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke-LJ9M9ZcSy1A@public.gmane.org>
To: make-wifi-fast-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160923195911.4572-1-toke-LJ9M9ZcSy1A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Small devices can run out of memory from queueing too many packets. If
VHT is not supported by the PHY, having more than 4 MBytes of total
queue in the TXQ intermediate queues is not needed, and so we can safely
limit the memory usage in these cases and avoid OOM.

Signed-off-by: Toke H=C3=B8iland-J=C3=B8rgensen <toke-LJ9M9ZcSy1A@public.gmane.org>
---
 net/mac80211/tx.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 1ff08be..82f41fc 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1434,6 +1434,8 @@ int ieee80211_txq_setup_flows(struct ieee80211_loca=
l *local)
 	struct fq *fq =3D &local->fq;
 	int ret;
 	int i;
+	bool supp_vht =3D false;
+	enum nl80211_band band;
=20
 	if (!local->ops->wake_tx_queue)
 		return 0;
@@ -1442,6 +1444,22 @@ int ieee80211_txq_setup_flows(struct ieee80211_loc=
al *local)
 	if (ret)
 		return ret;
=20
+	/*
+	 * If the hardware doesn't support VHT, it is safe to limit the maximum
+	 * queue size. 4 Mbytes is 64 max-size aggregates in 802.11n.
+	 */
+	for (band =3D 0; band < NUM_NL80211_BANDS; band++) {
+		struct ieee80211_supported_band *sband;
+
+		sband =3D local->hw.wiphy->bands[band];
+		if (!sband)
+			continue;
+
+		supp_vht =3D supp_vht || sband->vht_cap.vht_supported;
+	}
+	if (!supp_vht)
+		fq->memory_limit =3D 4 << 20; /* 4 Mbytes */
+
 	codel_params_init(&local->cparams);
 	local->cparams.interval =3D MS2TIME(100);
 	local->cparams.target =3D MS2TIME(20);
--=20
2.9.3
