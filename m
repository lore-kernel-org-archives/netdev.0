From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: rfkill rewrite bug
Date: Sat, 18 Apr 2009 10:28:02 +0200
Message-ID: <1240043283.5792.0.camel@johannes.local>
References: <49DCA88E.6060400@tuffmail.co.uk>
	 (sfid-20090408_153722_059382_FB44D658) <1239204090.16477.1.camel@johannes.local>
	 <49DCDD2E.80705@tuffmail.co.uk>  <49E38BBC.5010708@tuffmail.co.uk>
	 (sfid-20090413_205524_915082_56358705) <1239741968.4205.1.camel@johannes.local>
	 <49E98C86.2040308@tuffmail.co.uk> (sfid-20090418_101208_980691_83127E2F)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-odTrq7N4eqbbbmDizktk"
Cc: netdev@vger.kernel.org
To: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:57587 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbZDRI2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 04:28:07 -0400
In-Reply-To: <49E98C86.2040308@tuffmail.co.uk> (sfid-20090418_101208_980691_83127E2F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-odTrq7N4eqbbbmDizktk
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2009-04-18 at 09:17 +0100, Alan Jenkins wrote:

> When I looked at the code earlier, I saw no obvious replacement for=20
> rfkill_set_default().  So I tried disabling the wireless and rebooting=20
> to see what happened.  It didn't like that :-).

Ok that wasn't too hard -- try this on top if you get a chance:

--- wireless-testing.orig/net/rfkill/core.c	2009-04-18 10:16:53.000000000 +=
0200
+++ wireless-testing/net/rfkill/core.c	2009-04-18 10:18:17.000000000 +0200
@@ -401,6 +401,9 @@ bool rfkill_set_hw_state(struct rfkill *
=20
 	ret =3D __rfkill_set_hw_state(rfkill, blocked, &change);
=20
+	if (!rfkill->registered)
+		return ret;
+
 	if (change)
 		schedule_work(&rfkill->uevent_work);
=20
@@ -422,13 +425,17 @@ bool rfkill_set_sw_state(struct rfkill *
 					    &rfkill->blocked);
=20
 	hwblock =3D !!test_bit(RFKILL_BLOCK_HW_BIT, &rfkill->blocked);
+	blocked =3D blocked || hwblock;
+
+	if (!rfkill->registered)
+		return blocked;
=20
 	if (prev !=3D blocked && !hwblock)
 		schedule_work(&rfkill->uevent_work);
=20
 	rfkill_led_trigger_event(rfkill);
=20
-	return blocked || hwblock;
+	return blocked;
 }
 EXPORT_SYMBOL(rfkill_set_sw_state);
=20
@@ -452,6 +459,9 @@ void rfkill_set_states(struct rfkill *rf
 		hwprev =3D !!test_and_clear_bit(RFKILL_BLOCK_HW_BIT,
 					      &rfkill->blocked);
=20
+	if (!rfkill->registered)
+		return;
+
 	if (swprev !=3D sw || hwprev !=3D hw)
 		schedule_work(&rfkill->uevent_work);
=20


--=-odTrq7N4eqbbbmDizktk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJ6Y8PAAoJEKVg1VMiehFY0bkQAIjAXCceh9eTjlia3CuFp6C/
J5TTeOnlScE3akfy9BVkCoUGkYpvJNAdb7925gv/+x3mIRnqVXu7R3DeEcjbyIUi
M9St0ewuFzInPYW5WzOxWgaG6Qi624yoctmHbz9hqZ6GamwgJ2Q16C9Mi9qS6Avn
EbHA6xM4SchZateYRKgpufpQMZGLBpexrSPY75sfWuaXDsrdJkDbe+VbjdWT3gWs
q1+1oiL0+zhJP062uk3gXAqfW9WTZp4vyrwdoP6IWndM4q5QkzSZ190+P2CPL2Nn
Wt3M4B0Je4+BWHUSLiUryO7TDh39vHcZm81xhyz9NWzPz2GFI54kVrfil7NgT2WY
0q73wPB4e8N/G1+pqgbCz9HZPdKGF71zgSkBzBKub8sgyeRtYTCTjzfjvFEPJrYy
LtY5a/ncYGNonAzDihOABfcRrkkHibM6TmGFJbYFiyP1jJwQiQC2nSVpzhZr7RYj
vQqNDF7PSDQEIdT7VMGk847O68TPC7/w+RXE5NtIy/N85kdwNeD+Yz4/wn+IIIPd
YoeKZMtbsyvwSBD7DRODsiDE3soz7bbHnIepDLvM5rnO62FCYISmTaSHaJj+wfRO
jNy8Sgu69evzlf5ItCA8nqD7nm03BbzPNb2MXGy/5pFxs3jg/R45tlxFzDuI1eRS
/afbWLWehGV31nboLGsM
=UDTE
-----END PGP SIGNATURE-----

--=-odTrq7N4eqbbbmDizktk--

