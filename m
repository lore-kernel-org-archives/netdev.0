From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: BUG: All network processes hang (brcmsmac/wpa_supplicant)
Date: Wed, 19 Oct 2011 18:48:17 +0200
Message-ID: <4E9EFF51.6000104__9733.09526821158$1319042953$gmane$org@broadcom.com>
References: <20111019123602.GA11883@schottelius.org>
 <1319028563.8416.1.camel@edumazet-laptop>
 <20111019130749.GD11883@schottelius.org>
 <20111019142837.GA1414@schottelius.org> <4E9EE20F.1030403@broadcom.com>
 <20111019145501.GB1414@schottelius.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
 boundary=------------enigA07F9DB473624253F0F2E7DF;
 micalg=pgp-sha1;
 protocol="application/pgp-signature"
To: "Nico Schottelius" <nico-linux-20111017@schottelius.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireles
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1847 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363Ab1JSQsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 12:48:35 -0400
In-Reply-To: <20111019145501.GB1414@schottelius.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--------------enigA07F9DB473624253F0F2E7DF
Content-Type: multipart/mixed;
 boundary="------------050700030803050803080209"

This is a multi-part message in MIME format.
--------------050700030803050803080209
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/19/2011 04:55 PM, Nico Schottelius wrote:
> Hey Arend,
>=20
>=20
> Arend van Spriel [Wed, Oct 19, 2011 at 04:43:27PM +0200]:
>> I actually don't see the rtnl_lock or mutex_lock that was listed in yo=
ur
>> original dmesg. There are a lot of warning traces from mac80211.c.

The warnings are probably a diversion. This is the warning in
ieee80211_rx():

			if (WARN_ON(status->rate_idx < 0 ||
				    status->rate_idx >=3D sband->n_bitrates))
				goto drop;
			rate =3D &sband->bitrates[status->rate_idx];

This means that the driver (brcmsmac) provides a data packet with an
out-of-range rate index. This reminded me of a fix I made about a month
ago. Could you apply the attached patch file. It is based on:

commit bee709ab1d390afe69e4407bc86bb706c6fb2965
Merge: ad1c761 1f2c7e9
Author: Nico Schottelius <nico@kr.ethz.ch>
Date:   Tue Oct 18 00:04:05 2011 +0200

    Merge branch 'fix-edp-vdd-power' of ../keithp/linux

As it drops receive packets it may be your problem. Is your AP on 5GHz?

Gr. AvS

--------------050700030803050803080209
Content-Type: text/x-patch;
 name="0001-staging-brcm80211-fix-for-rate-index-in-receive-stat.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename*0="0001-staging-brcm80211-fix-for-rate-index-in-receive-stat.pa";
 filename*1="tch"

=46rom 7d14bd6cbfbf26369c5958e56a468fd8429841d7 Mon Sep 17 00:00:00 2001
From: Arend van Spriel <arend@broadcom.com>
Date: Wed, 19 Oct 2011 18:42:45 +0200
Subject: [PATCH] staging: brcm80211: fix for rate index in receive status=


Made a patch for Nico to try whether this resolves his issue.

Signed-off-by: Arend van Spriel <arend@broadcom.com>
---
 drivers/staging/brcm80211/brcmsmac/main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/brcm80211/brcmsmac/main.c b/drivers/staging/=
brcm80211/brcmsmac/main.c
index 1763c45..49c8eb9 100644
--- a/drivers/staging/brcm80211/brcmsmac/main.c
+++ b/drivers/staging/brcm80211/brcmsmac/main.c
@@ -4608,6 +4608,10 @@ prep_mac80211_status(struct brcms_c_info *wlc, str=
uct d11rxhdr *rxh,
 			wiphy_err(wlc->wiphy, "%s: Unknown rate\n", __func__);
 		}
=20
+		/* DEBUG: fix rate index in receive status */
+		if (rx_status->band =3D=3D IEEE80211_BAND_5GHZ)
+			rx_status->rate_idx -=3D 4;
+
 		/* Determine short preamble and rate_idx */
 		preamble =3D 0;
 		if (IS_CCK(rspec)) {
--=20
1.7.4.1


--------------050700030803050803080209--

--------------enigA07F9DB473624253F0F2E7DF
Content-Type: application/pgp-signature;
 name=signature.asc
Content-Description: OpenPGP digital signature
Content-Disposition: attachment;
 filename=signature.asc
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBAgAGBQJOnv9VAAoJELcEx/G14aEWmocQAKMxRi2iV1qeli1CWe5ehupH
QjYI2u8n2a4uNhlBi0W29BYTaxngF0ukdcnck1026oZrSEnW9POEnk+cN4kFxDWA
lV52DeKJuQ/RRY+BPK+uy1XVl1ZhRf/xp7EKwEphTs2iElHE7BxOGd/52G3vLJys
ggSq6bzfbVQGarsNhPdztmdrwSoNVh5L2y3Dt5vKtWKNc8hbs2oAoxjxt3Otdke1
zX6rkWnqKLy6tWBwU+xckBV8cf5XSF3cxFVNiHnzOAFisLjXbTHIAqe0F7J3dqUW
2diWMo9C8vAp8WCntmP4NDn729JRQXXL61cfysE8MxiRUQd2/7OMVRhtvXUDI/DU
qPxfyYuZSXgp+ch5qSxwPb9QN7Sm4uDkfU8tMIJTvClF9Ff/PRnpE/IQoqK7jVWL
JObNrCXZMWpDo6KnBTU/7i3Pr7ayZu/hTzbWuM1lafiAgEdLzcDqgJ7PwwUs+5Ne
TZMZ4V2KK1r4DW+yHUiEGdTPTS04mDr/MOPwXSgKHtRsmO7XUlGmNtt0G2F2FMO6
RIKbREpCR57Zd5q07x98cBEe7FOsjVuQ2dslH95mKfo8NmjfbDREoWdl24iMxcti
7DhuC9EJhWLM76MHt4+3M+IZIJOyrA89ITTdCKWeXWKFfdPcVpbgTW5xw4aswRR2
3cuxlCwS7r4TGzTRm/K7
=0p/5
-----END PGP SIGNATURE-----

--------------enigA07F9DB473624253F0F2E7DF--
