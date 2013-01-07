From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/net/wireless/ipw2x00: use strlcpy instead of
 strncpy
Date: Mon, 07 Jan 2013 10:49:50 +0800
Message-ID: <50EA37CE.1090901@asianux.com>
References: <50E82D7D.4090107@asianux.com> <1357396966.21156.4.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stas.yakovlev@gmail.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:4821 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009Ab3AGCs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 21:48:58 -0500
In-Reply-To: <1357396966.21156.4.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B401=E6=9C=8805=E6=97=A5 22:42, Joe Perches =E5=86=
=99=E9=81=93:
> This happens because escaped is declared the wrong size.
>=20
> It'd be better to change
> 	char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
> to
> 	DECLARE_SSID_BUF(escaped);
> and use
> 	print_ssid(escaped, network->ssid, network->ssid_len)
> in the debug.
>=20

  if what you said is true:
    it is better to delete escaped variable
    use ssid instead of escaped, directly.

  but I think the original author intended to use escaped instead of ss=
id
    DECLARE_SSID_BUF(ssid)  (line 5525, 5737)
    use ssid to print debug information directly
      (such as: line 5530..5535, 5545..5549, 5745..5749, ...)
    when need print additional information, use escaped
      (line 5559..5569, 5773..5782, 5791..5799)

  so, I still suggest:
    only fix the bug (use strlcpy instead of strncpy)
    and not touch original features which orignal author intended using=
=2E

  Regards

gchen.

in drivers/net/wireless/ipw2x00/ipw2200.c:

 5519 static int ipw_find_adhoc_network(struct ipw_priv *priv,
 5520                                   struct ipw_network_match *match=
,
 5521                                   struct libipw_network *network,
 5522                                   int roaming)
 5523 {
 5524         struct ipw_supported_rates rates;
 5525         DECLARE_SSID_BUF(ssid);
 5526=20
 5527         /* Verify that this network's capability is compatible wi=
th the
 5528          * current mode (AdHoc or Infrastructure) */
 5529         if ((priv->ieee->iw_mode =3D=3D IW_MODE_ADHOC &&
 5530              !(network->capability & WLAN_CAPABILITY_IBSS))) {
 5531                 IPW_DEBUG_MERGE("Network '%s (%pM)' excluded due =
to "
 5532                                 "capability mismatch.\n",
 5533                                 print_ssid(ssid, network->ssid,
 5534                                            network->ssid_len),
 5535                                 network->bssid);
 5536                 return 0;
 5537         }
 5538=20
 5539         if (unlikely(roaming)) {
 5540                 /* If we are roaming, then ensure check if this i=
s a valid
 5541                  * network to try and roam to */
 5542                 if ((network->ssid_len !=3D match->network->ssid_=
len) ||
 5543                     memcmp(network->ssid, match->network->ssid,
 5544                            network->ssid_len)) {
 5545                         IPW_DEBUG_MERGE("Network '%s (%pM)' exclu=
ded "
 5546                                         "because of non-network E=
SSID.\n",
 5547                                         print_ssid(ssid, network-=
>ssid,
 5548                                                    network->ssid_=
len),
 5549                                         network->bssid);
 5550                         return 0;
 5551                 }
 5552         } else {
 5553                 /* If an ESSID has been configured then compare t=
he broadcast
 5554                  * ESSID to ours */
 5555                 if ((priv->config & CFG_STATIC_ESSID) &&
 5556                     ((network->ssid_len !=3D priv->essid_len) ||
 5557                      memcmp(network->ssid, priv->essid,
 5558                             min(network->ssid_len, priv->essid_le=
n)))) {
 5559                         char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
 5560=20
 5561                         strncpy(escaped,
 5562                                 print_ssid(ssid, network->ssid,
 5563                                            network->ssid_len),
 5564                                 sizeof(escaped));
 5565                         IPW_DEBUG_MERGE("Network '%s (%pM)' exclu=
ded "
 5566                                         "because of ESSID mismatc=
h: '%s'.\n",
 5567                                         escaped, network->bssid,
 5568                                         print_ssid(ssid, priv->es=
sid,
 5569                                                    priv->essid_le=
n));
 5570                         return 0;
 5571                 }
 5572         }
 ...
=20
 5732 static int ipw_best_network(struct ipw_priv *priv,
 5733                             struct ipw_network_match *match,
 5734                             struct libipw_network *network, int r=
oaming)
 5735 {
 5736         struct ipw_supported_rates rates;
 5737         DECLARE_SSID_BUF(ssid);
 5738=20
 5739         /* Verify that this network's capability is compatible wi=
th the
 5740          * current mode (AdHoc or Infrastructure) */
 5741         if ((priv->ieee->iw_mode =3D=3D IW_MODE_INFRA &&
 5742              !(network->capability & WLAN_CAPABILITY_ESS)) ||
 5743             (priv->ieee->iw_mode =3D=3D IW_MODE_ADHOC &&
 5744              !(network->capability & WLAN_CAPABILITY_IBSS))) {
 5745                 IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded due =
to "
 5746                                 "capability mismatch.\n",
 5747                                 print_ssid(ssid, network->ssid,
 5748                                            network->ssid_len),
 5749                                 network->bssid);
 5750                 return 0;
 5751         }
 5752=20
 5753         if (unlikely(roaming)) {
 5754                 /* If we are roaming, then ensure check if this i=
s a valid
 5755                  * network to try and roam to */
 5756                 if ((network->ssid_len !=3D match->network->ssid_=
len) ||
 5757                     memcmp(network->ssid, match->network->ssid,
 5758                            network->ssid_len)) {
 5759                         IPW_DEBUG_ASSOC("Network '%s (%pM)' exclu=
ded "
 5760                                         "because of non-network E=
SSID.\n",
 5761                                         print_ssid(ssid, network-=
>ssid,
 5762                                                    network->ssid_=
len),
 5763                                         network->bssid);
 5764                         return 0;
 5765                 }
 5766         } else {
 5767                 /* If an ESSID has been configured then compare t=
he broadcast
 5768                  * ESSID to ours */
 5769                 if ((priv->config & CFG_STATIC_ESSID) &&
 5770                     ((network->ssid_len !=3D priv->essid_len) ||
 5771                      memcmp(network->ssid, priv->essid,
 5772                             min(network->ssid_len, priv->essid_le=
n)))) {
 5773                         char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
 5774                         strncpy(escaped,
 5775                                 print_ssid(ssid, network->ssid,
 5776                                            network->ssid_len),
 5777                                 sizeof(escaped));
 5778                         IPW_DEBUG_ASSOC("Network '%s (%pM)' exclu=
ded "
 5779                                         "because of ESSID mismatc=
h: '%s'.\n",
 5780                                         escaped, network->bssid,
 5781                                         print_ssid(ssid, priv->es=
sid,
 5782                                                    priv->essid_le=
n));
 5783                         return 0;
 5784                 }
 5785         }
 5786=20
 5787         /* If the old network rate is better than this one, don't=
 bother
 5788          * testing everything else. */
 5789         if (match->network && match->network->stats.rssi > networ=
k->stats.rssi) {
 5790                 char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
 5791                 strncpy(escaped,
 5792                         print_ssid(ssid, network->ssid, network->=
ssid_len),
 5793                         sizeof(escaped));
 5794                 IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded beca=
use "
 5795                                 "'%s (%pM)' has a stronger signal=
=2E\n",
 5796                                 escaped, network->bssid,
 5797                                 print_ssid(ssid, match->network->=
ssid,
 5798                                            match->network->ssid_l=
en),
 5799                                 match->network->bssid);
 5800                 return 0;
 5801         }

--=20
Chen Gang

Asianux Corporation
