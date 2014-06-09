From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 01/13] i40e: add checks for AQ error status bits
Date: Mon, 09 Jun 2014 13:35:14 -0700
Message-ID: <1402346114.2183.5.camel@jtkirshe-mobl.jf.intel.com>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1402303758-1429-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5395B4C1.7070004@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-XHclAmxMU6hOHevhERFq"
Cc: davem@davemloft.net, Shannon Nelson <shannon.nelson@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56870 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736AbaFIUkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 16:40:19 -0400
In-Reply-To: <5395B4C1.7070004@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XHclAmxMU6hOHevhERFq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-06-09 at 17:21 +0400, Sergei Shtylyov wrote:
> Hello.
>=20
> On 06/09/2014 12:49 PM, Jeff Kirsher wrote:
>=20
> > From: Shannon Nelson <shannon.nelson@intel.com>
>=20
> > Check for error status bits on the AdminQ event queue and announce them
> > if seen.  If the Firmware sets these bits, it will trigger an AdminQ
> > interrupt to get the driver's attention to process the ARQ, which will
> > likely be enough to clear the actual issue.
>=20
> > Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> > Change-ID: I009e0ebc8be764e40e193b29aed2863f43eb5cb0
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >   drivers/net/ethernet/intel/i40e/i40e_main.c | 36 ++++++++++++++++++++=
+++++++++
> >   1 file changed, 36 insertions(+)
>=20
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/=
ethernet/intel/i40e/i40e_main.c
> > index 8c16e18..ab0b6e1 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > @@ -5132,11 +5132,47 @@ static void i40e_clean_adminq_subtask(struct i4=
0e_pf *pf)
> >   	u16 pending, i =3D 0;
> >   	i40e_status ret;
> >   	u16 opcode;
> > +	u32 oldval;
> >   	u32 val;
> >
> >   	if (!test_bit(__I40E_ADMINQ_EVENT_PENDING, &pf->state))
> >   		return;
> >
> > +	/* check for error indications */
> > +	val =3D rd32(&pf->hw, pf->hw.aq.arq.len);
> > +	oldval =3D val;
> > +	if (val & I40E_PF_ARQLEN_ARQVFE_MASK) {
> > +		dev_info(&pf->pdev->dev, "ARQ VF Error detected\n");
>=20
>     Hm, why not dev_err() here and below?

The thought was that these should be more of "FYI..." type of messages
not "Oh Crap!..." messages.  So that is why dev_err() was not used,
although we are not opposed to changing it if you feel it warrants it in
a follow-up patch.

>=20
> > +		val &=3D ~I40E_PF_ARQLEN_ARQVFE_MASK;
> > +	}
> > +	if (val & I40E_PF_ARQLEN_ARQOVFL_MASK) {
> > +		dev_info(&pf->pdev->dev, "ARQ Overflow Error detected\n");
> > +		val &=3D ~I40E_PF_ARQLEN_ARQOVFL_MASK;
> > +	}
> > +	if (val & I40E_PF_ARQLEN_ARQCRIT_MASK) {
> > +		dev_info(&pf->pdev->dev, "ARQ Critical Error detected\n");
> > +		val &=3D ~I40E_PF_ARQLEN_ARQCRIT_MASK;
> > +	}
> > +	if (oldval !=3D val)
> > +		wr32(&pf->hw, pf->hw.aq.arq.len, val);
> > +
> > +	val =3D rd32(&pf->hw, pf->hw.aq.asq.len);
> > +	oldval =3D val;
> > +	if (val & I40E_PF_ATQLEN_ATQVFE_MASK) {
> > +		dev_info(&pf->pdev->dev, "ASQ VF Error detected\n");
> > +		val &=3D ~I40E_PF_ATQLEN_ATQVFE_MASK;
> > +	}
> > +	if (val & I40E_PF_ATQLEN_ATQOVFL_MASK) {
> > +		dev_info(&pf->pdev->dev, "ASQ Overflow Error detected\n");
> > +		val &=3D ~I40E_PF_ATQLEN_ATQOVFL_MASK;
> > +	}
> > +	if (val & I40E_PF_ATQLEN_ATQCRIT_MASK) {
> > +		dev_info(&pf->pdev->dev, "ASQ Critical Error detected\n");
> > +		val &=3D ~I40E_PF_ATQLEN_ATQCRIT_MASK;
> > +	}
> > +	if (oldval !=3D val)
> > +		wr32(&pf->hw, pf->hw.aq.asq.len, val);
> > +
>=20
> WBR, Sergei
>=20



--=-XHclAmxMU6hOHevhERFq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTlhqCAAoJEOVv75VaS+3ODJ8P+wfeXZ1yM6JE9296/fWlgYDk
HjW1dxTuj7gNx8IbJ0ZTZTIKKiTn6FUeda6244Qe59saqktq5wV4JyXmM8jInSFb
lPQwYNDNszzU2TzRvMzV/+z0tCEMgEsxzd9JW5tVz1TOLe1WfL8pZwKZJKCvEThh
Vr6OtVKkDczGytxr/ELMeX54GEruHWmsuSI5g26boH7x4HqJbIh7oYCSuwRTg/vC
BjfEzGDhWPbYvimImtIpcRp6KMiRR7ZXXFsA6hfEM0YNMcksxQjw/gvBAKtV+4Se
RQLk7g/R+sgBFeF0nesKXqjC26rZKRWYdN3+x4h+A/gWfwhxvlgej4avbMx0h7q0
OcMtjj4JI2gBbHMS9EcdOT8VJQOwH6foiyomWzXmOQsxrRo89G44mdExxUjowb0F
O9w0FTsraB6ihwXIpUjF71l1Xk3PuFkIx1fkQPs83SlqzMKXoUi9hKXZ9AJwshpc
fYyyiAA0jgbzz1Y+27iSIh+P1J23D1Ig6/QvkzIQQf8+eyQltHsQ9CFGxG1c0XvT
NCO7tjAbf+/tFdf/J7bUVMC0T3rHWuwJJaM70u+/RpESVEr96+PWuYuukTuz+sFc
o9K/5wcLelys6MOJale3fL6OVG+9+TMIuq9t+uhz9BYwLCD2fgKTN8HVfd3idWGm
goNO5j63udf2/J87G02R
=B+V5
-----END PGP SIGNATURE-----

--=-XHclAmxMU6hOHevhERFq--
