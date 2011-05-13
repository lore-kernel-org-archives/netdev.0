From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq@rere.qmqm.pl>
Subject: Re: [patch 1/9] [PATCH] qeth: convert to hw_features part 2
Date: Fri, 13 May 2011 09:38:07 +0200
Message-ID: <20110513073807.GA18312@rere.qmqm.pl>
References: <20110513044500.190198403@de.ibm.com>
 <20110513044547.424857838@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47636 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757109Ab1EMHiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2011 03:38:09 -0400
Content-Disposition: inline
In-Reply-To: <20110513044547.424857838@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 13, 2011 at 06:45:01AM +0200, frank.blaschka@de.ibm.com wro=
te:
> From: Frank Blaschka <frank.blaschka@de.ibm.com>
> Set rx csum default to hw checksumming again.
> Remove sysfs interface for rx csum (checksumming) and TSO (large_send=
).
> With the new hw_features it does not work to keep the old sysfs
> interface in parallel. Convert options.checksum_type to new hw_featur=
es.

Please see following patch (replacing qeth_l3_main.c part of your patch=
) for
an illustration of my earlier comments.

Best Regards,
Micha=B3 Miros=B3aw

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3=
_main.c
index 1496661..9b8ce44 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1445,70 +1445,37 @@ static int qeth_l3_send_checksum_command(struct=
 qeth_card *card)
 	return 0;
 }
=20
-int qeth_l3_set_rx_csum(struct qeth_card *card,
-	enum qeth_checksum_types csum_type)
+static int qeth_l3_set_rx_csum(struct qeth_card *card, int on)
 {
-	int rc =3D 0;
+	int rc;
=20
-	if (card->options.checksum_type =3D=3D HW_CHECKSUMMING) {
-		if ((csum_type !=3D HW_CHECKSUMMING) &&
-			(card->state !=3D CARD_STATE_DOWN)) {
-			rc =3D qeth_l3_send_simple_setassparms(card,
-				IPA_INBOUND_CHECKSUM, IPA_CMD_ASS_STOP, 0);
-			if (rc)
-				return -EIO;
-		}
-		card->dev->features |=3D NETIF_F_RXCSUM;
-	} else {
-		if (csum_type =3D=3D HW_CHECKSUMMING) {
-			if (card->state !=3D CARD_STATE_DOWN) {
-				if (!qeth_is_supported(card,
-				    IPA_INBOUND_CHECKSUM))
-					return -EPERM;
-				rc =3D qeth_l3_send_checksum_command(card);
-				if (rc)
-					return -EIO;
-			}
-		}
-		card->dev->features &=3D ~NETIF_F_RXCSUM;
+	if (on) {
+		rc =3D qeth_l3_send_checksum_command(card);
+		if (rc)
+			return -EIO;
+	} else
+		rc =3D qeth_l3_send_simple_setassparms(card,
+			IPA_INBOUND_CHECKSUM, IPA_CMD_ASS_STOP, 0);
+		if (rc)
+			return -EIO;
 	}
-	card->options.checksum_type =3D csum_type;
-	return rc;
+
+	return 0;
 }
=20
 static int qeth_l3_start_ipa_checksum(struct qeth_card *card)
 {
-	int rc =3D 0;
-
 	QETH_CARD_TEXT(card, 3, "strtcsum");
=20
-	if (card->options.checksum_type =3D=3D NO_CHECKSUMMING) {
-		dev_info(&card->gdev->dev,
-			"Using no checksumming on %s.\n",
-			QETH_CARD_IFNAME(card));
-		return 0;
-	}
-	if (card->options.checksum_type =3D=3D SW_CHECKSUMMING) {
-		dev_info(&card->gdev->dev,
-			"Using SW checksumming on %s.\n",
-			QETH_CARD_IFNAME(card));
-		return 0;
-	}
-	if (!qeth_is_supported(card, IPA_INBOUND_CHECKSUM)) {
-		dev_info(&card->gdev->dev,
-			"Inbound HW Checksumming not "
-			"supported on %s,\ncontinuing "
-			"using Inbound SW Checksumming\n",
-			QETH_CARD_IFNAME(card));
-		card->options.checksum_type =3D SW_CHECKSUMMING;
-		return 0;
+	if (card->dev->features & NETIF_F_RXCSUM) {
+		rtnl_lock();
+		/* force set_features call */
+		card->dev->features &=3D ~NETIF_F_RXCSUM;
+		netdev_update_features(card->dev);
+		rtnl_unlock();
 	}
-	rc =3D qeth_l3_send_checksum_command(card);
-	if (!rc)
-		dev_info(&card->gdev->dev,
-			"HW Checksumming (inbound) enabled\n");
=20
-	return rc;
+	return 0;
 }
=20
 static int qeth_l3_start_ipa_tx_checksum(struct qeth_card *card)
@@ -2037,14 +2004,7 @@ static inline int qeth_l3_rebuild_skb(struct qet=
h_card *card,
 		is_vlan =3D 1;
 	}
=20
-	switch (card->options.checksum_type) {
-	case SW_CHECKSUMMING:
-		skb->ip_summed =3D CHECKSUM_NONE;
-		break;
-	case NO_CHECKSUMMING:
-		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
-		break;
-	case HW_CHECKSUMMING:
+	if (card->dev->features & NETIF_F_RXCSUM) {
 		if ((hdr->hdr.l3.ext_flags &
 		    (QETH_HDR_EXT_CSUM_HDR_REQ |
 		     QETH_HDR_EXT_CSUM_TRANSP_REQ)) =3D=3D
@@ -2053,7 +2013,8 @@ static inline int qeth_l3_rebuild_skb(struct qeth=
_card *card,
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 		else
 			skb->ip_summed =3D CHECKSUM_NONE;
-	}
+	} else
+		skb->ip_summed =3D CHECKSUM_NONE;
=20
 	return is_vlan;
 }
@@ -3235,20 +3196,20 @@ static u32 qeth_l3_fix_features(struct net_devi=
ce *dev, u32 features)
=20
 static int qeth_l3_set_features(struct net_device *dev, u32 features)
 {
-	enum qeth_checksum_types csum_type;
 	struct qeth_card *card =3D dev->ml_priv;
 	u32 changed =3D dev->features ^ features;
+	int on;
=20
 	if (!(changed & NETIF_F_RXCSUM))
 		return 0;
=20
-	if (features & NETIF_F_RXCSUM)
-		csum_type =3D HW_CHECKSUMMING;
-	else
-		csum_type =3D SW_CHECKSUMMING;
+	if (card->state =3D=3D CARD_STATE_DOWN)
+		return 0;
=20
+	/* commit other changes in case of error */
 	dev->features =3D features ^ NETIF_F_RXCSUM;
-	return qeth_l3_set_rx_csum(card, csum_type);
+
+	return qeth_l3_set_rx_csum(card, features & NETIF_F_RXCSUM);
 }
=20
 static const struct ethtool_ops qeth_l3_ethtool_ops =3D {
@@ -3342,6 +3303,12 @@ static int qeth_l3_setup_netdev(struct qeth_card=
 *card)
 			if (!(card->info.unique_id & UNIQUE_ID_NOT_BY_CARD))
 				card->dev->dev_id =3D card->info.unique_id &
 							 0xffff;
+			if (!card->info.guestlan) {
+				card->dev->hw_features =3D NETIF_F_SG |
+					NETIF_F_RXCSUM | NETIF_F_IP_CSUM |
+					NETIF_F_TSO;
+				card->dev->features =3D NETIF_F_RXCSUM;
+			}
 		}
 	} else if (card->info.type =3D=3D QETH_CARD_TYPE_IQD) {
 		card->dev =3D alloc_netdev(0, "hsi%d", ether_setup);
@@ -3357,8 +3324,6 @@ static int qeth_l3_setup_netdev(struct qeth_card =
*card)
 	card->dev->watchdog_timeo =3D QETH_TX_TIMEOUT;
 	card->dev->mtu =3D card->info.initial_mtu;
 	SET_ETHTOOL_OPS(card->dev, &qeth_l3_ethtool_ops);
-	card->dev->hw_features =3D NETIF_F_SG | NETIF_F_RXCSUM |
-		NETIF_F_IP_CSUM | NETIF_F_TSO;
 	card->dev->features |=3D	NETIF_F_HW_VLAN_TX |
 				NETIF_F_HW_VLAN_RX |
 				NETIF_F_HW_VLAN_FILTER;
@@ -3382,9 +3347,6 @@ static int qeth_l3_probe_device(struct ccwgroup_d=
evice *gdev)
 	card->discipline.output_handler =3D (qdio_handler_t *)
 		qeth_qdio_output_handler;
 	card->discipline.recover =3D qeth_l3_recover;
-	if ((card->info.type =3D=3D QETH_CARD_TYPE_OSD) ||
-	    (card->info.type =3D=3D QETH_CARD_TYPE_OSX))
-		card->options.checksum_type =3D HW_CHECKSUMMING;
 	return 0;
 }
=20
