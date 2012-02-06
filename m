From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next 2012-02-06
Date: Mon, 06 Feb 2012 15:53:53 -0500 (EST)
Message-ID: <20120206.155353.837462133668656662.davem@davemloft.net>
References: <20120206201827.GH21048@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120206201827.GH21048-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Mon, 6 Feb 2012 15:18:27 -0500

> Here is a big pull request full of wireless updates intended for 3.4!
>=20
> Highlights include a round of NFC updates from Ilan Elias, a big batc=
h
> of spruce-ups from Joe Perches, and the usual round of updates from
> Larry Finger (rtlwifi), Rafa=A9=A9 Mi=A9=A9ecki (bcma, b43), Johannes=
 Berg
> (mac80211), and a variety of other contributors.
>=20
> Please let me know if there are problems!

Pulled, but there are some locations that need coding style
fixups, particularly the NFC changes.  It seems that the TI
engineer making changes there is not capable of tabbing with
spaces.  So things like:

	if (x &&
	    y)

ends up being:

	if (x &&
		y)

which looks like crap.  Specifically:

net/nfc/nci/rsp.c:151
+	/* If target was active, complete the request only in deactivate_ntf =
*/
+	if ((status !=3D NCI_STATUS_OK) ||
+		(!test_bit(NCI_POLL_ACTIVE, &ndev->flags)))
+		nci_req_complete(ndev, status);

net/nfc/nci/ntf.c:115
+	pr_debug("bit_rate %d, sensf_res_len %d\n",
+		nfcf_poll->bit_rate, nfcf_poll->sensf_res_len);

net/nfc/nci/ntf.c:169
+		pr_debug("attrib_res_len %d\n",
+			nfcb_poll->attrib_res_len);
 ...
+			memcpy(nfcb_poll->attrib_res,
+				data,
+				nfcb_poll->attrib_res_len);

net/nfc/nci/ntf.c:212
+			memcpy(nfc_tgt.nfcid1,
+				ntf->rf_tech_specific_params.nfca_poll.nfcid1,
+				nfc_tgt.nfcid1_len);

net/nfc/nci/ntf.c:290
+			data =3D nci_extract_rf_params_nfcb_passive_poll(ndev,
+				&ntf, data);
 ...
+			data =3D nci_extract_rf_params_nfcf_passive_poll(ndev,
+				&ntf, data);

net/nfc/netlink.c:70
+	if (target->sensb_res_len > 0)
+		NLA_PUT(msg, NFC_ATTR_TARGET_SENSB_RES, target->sensb_res_len,
+				target->sensb_res);
+	if (target->sensf_res_len > 0)
+		NLA_PUT(msg, NFC_ATTR_TARGET_SENSF_RES, target->sensf_res_len,
+				target->sensf_res);

There's a lot more, these are just a tiny example of the issues I saw i=
n the
patches contained in this pull request.

Actually, it seems nobody has been paying attention to this tabbing
issue at all in the entire NFC stack, so someone needs to go in there
and wholesale fix all of this stuff.

mwifiex had some turds too:

drivers/net/wireless/mwifiex/init.c:526
 		dev_dbg(adapter->dev, "info: delete BSS priority table,"
-				" index =3D %d, i =3D %d, head =3D %p, cur =3D %p\n",
-			      priv->bss_index, i, head, *cur);
+				" bss_type =3D %d, bss_num =3D %d, i =3D %d,"
+				" head =3D %p, cur =3D %p\n",
+			      priv->bss_type, priv->bss_num, i, head, *cur);

drivers/net/wireless/mwifiex/main.c:424
+	dev_dbg(priv->adapter->dev, "data: %lu BSS(%d-%d): Data <=3D kernel\n=
",
+				jiffies, priv->bss_type, priv->bss_num);

drivers/net/wireless/mwifiex/main.c:532
+	dev_err(priv->adapter->dev, "%lu : Tx timeout, bss_type-num =3D %d-%d=
\n",
+				jiffies, priv->bss_type, priv->bss_num);

drivers/net/wireless/mwifiex/sta_rx.c:43
+	struct mwifiex_private *priv =3D mwifiex_get_priv_by_id(adapter,
+			rx_info->bss_num, rx_info->bss_type);

drivers/net/wireless/mwifiex/sta_rx.c:125
+	struct mwifiex_private *priv =3D mwifiex_get_priv_by_id(adapter,
+			rx_info->bss_num, rx_info->bss_type);

drivers/net/wireless/mwifiex/txrx.c:131
+	priv =3D mwifiex_get_priv_by_id(adapter, tx_info->bss_num,
+			tx_info->bss_type);

drivers/net/wireless/mwifiex/util.c:159
+	priv =3D mwifiex_get_priv_by_id(adapter, rx_info->bss_num,
+			rx_info->bss_type);

and so on, and so forth, you get the idea.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
