From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 08/21] orinoco: optimize Tx exception handling in orinoco
Date: Fri, 07 Apr 2006 04:10:34 -0400
Message-ID: <20060407081034.16107.89621.stgit@dv.roinet.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <20060407081019.16107.67672.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

When processing Tx exception, only read data until addr1.  Rename
hermes_tx_descriptor_802_11 to hermes_txexc_data since it's only used to
Tx exceptions.  Reuse existing hermes_tx_descriptor structure.  Remove
fields after addr1 - they are not read from the card.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco.c |   42 ++++++----------------------------=
------
 1 files changed, 6 insertions(+), 36 deletions(-)

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoc=
o.c
index 9550bf3..ceea494 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -201,41 +201,12 @@ #define BITRATE_TABLE_SIZE ARRAY_SIZE(bi
 /* Data types                                                       */
 /********************************************************************/
=20
-/* Used in Event handling.
- * We avoid nested structures as they break on ARM -- Moustafa */
-struct hermes_tx_descriptor_802_11 {
-	/* hermes_tx_descriptor */
-	__le16 status;
-	__le16 reserved1;
-	__le16 reserved2;
-	__le32 sw_support;
-	u8 retry_count;
-	u8 tx_rate;
-	__le16 tx_control;
-
-	/* ieee80211_hdr */
+/* Beginning of the Tx descriptor, used in TxExc handling */
+struct hermes_txexc_data {
+	struct hermes_tx_descriptor desc;
 	__le16 frame_ctl;
 	__le16 duration_id;
 	u8 addr1[ETH_ALEN];
-	u8 addr2[ETH_ALEN];
-	u8 addr3[ETH_ALEN];
-	__le16 seq_ctl;
-	u8 addr4[ETH_ALEN];
-
-	__le16 data_len;
-
-	/* ethhdr */
-	u8 h_dest[ETH_ALEN];	/* destination eth addr */
-	u8 h_source[ETH_ALEN];	/* source ether addr    */
-	__be16 h_proto;		/* packet type ID field */
-
-	/* p8022_hdr */
-	u8 dsap;
-	u8 ssap;
-	u8 ctrl;
-	u8 oui[3];
-
-	__be16 ethertype;
 } __attribute__ ((packed));
=20
 /* Rx frame header except compatibility 802.3 header */
@@ -620,7 +591,7 @@ static void __orinoco_ev_txexc(struct ne
 	struct net_device_stats *stats =3D &priv->stats;
 	u16 fid =3D hermes_read_regn(hw, TXCOMPLFID);
 	u16 status;
-	struct hermes_tx_descriptor_802_11 hdr;
+	struct hermes_txexc_data hdr;
 	int err =3D 0;
=20
 	if (fid =3D=3D DUMMY_FID)
@@ -628,8 +599,7 @@ static void __orinoco_ev_txexc(struct ne
=20
 	/* Read part of the frame header - we need status and addr1 */
 	err =3D hermes_bap_pread(hw, IRQ_BAP, &hdr,
-			       offsetof(struct hermes_tx_descriptor_802_11,
-					addr2),
+			       sizeof(struct hermes_txexc_data),
 			       fid, 0);
=20
 	hermes_write_regn(hw, TXCOMPLFID, DUMMY_FID);
@@ -649,7 +619,7 @@ static void __orinoco_ev_txexc(struct ne
 	 * exceeded, because that's the only status that really mean
 	 * that this particular node went away.
 	 * Other errors means that *we* screwed up. - Jean II */
-	status =3D le16_to_cpu(hdr.status);
+	status =3D le16_to_cpu(hdr.desc.status);
 	if (status & (HERMES_TXSTAT_RETRYERR | HERMES_TXSTAT_AGEDERR)) {
 		union iwreq_data	wrqu;
=20



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
