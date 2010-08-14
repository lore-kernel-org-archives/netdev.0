From: Dave Kilroy <kilroyd@googlemail.com>
Subject: Re: [PATCH] orinoco: Fix walking past the end of the buffer
Date: Sat, 14 Aug 2010 10:45:39 +0100
Message-ID: <AANLkTimX1MnVtbhrHFx7-jTA5XRpSvWn2uF3OiJU8WYM@mail.gmail.com>
References: <20100811203216.GA25168@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, proski@gnu.org,
	hermes@gibson.dropbear.id.au, davem@davemloft.net,
	linux-wireless@vger.kernel.org,
	orinoco-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Denis Kirjanov <dkirjanov@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44349 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934653Ab0HNJpk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Aug 2010 05:45:40 -0400
In-Reply-To: <20100811203216.GA25168@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 11, 2010 at 9:32 PM, Denis Kirjanov <dkirjanov@kernel.org> =
wrote:
> diff --git a/drivers/net/wireless/orinoco/hw.c b/drivers/net/wireless=
/orinoco/hw.c
> index 077baa8..191bc03 100644
> --- a/drivers/net/wireless/orinoco/hw.c
> +++ b/drivers/net/wireless/orinoco/hw.c
> @@ -765,9 +765,12 @@ int orinoco_hw_get_act_bitrate(struct orinoco_pr=
ivate *priv, int *bitrate)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (bitrate_table[i].i=
ntersil_txratectrl =3D=3D val)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i >=3D BITRATE_TABLE_SIZE)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i >=3D BITRATE_TABLE_SIZE) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_INFO "%s: =
Unable to determine current bitrate (0x%04hx)\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->nde=
v->name, val);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *bitrate =3D 100001; /*=
 Mark as invalid */

We should propogate the failure by returning an error in the return
code rather than a cryptic bitrate value. The calling function(s)
should then propogate the error through wext/cfg80211 as appropriate.

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*bitrate =3D bitrate_table[i].bitrate =
* 100000;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;

We can also make the structure easier to understand by setting the
bitrate within the for loop. Something like the following (I only have
access to gmail ATM, so can't format a proper patch):

		for (i =3D 0; i < BITRATE_TABLE_SIZE; i++)
			if (bitrate_table[i].intersil_txratectrl =3D=3D val) {
				*bitrate =3D bitrate_table[i].bitrate * 100000;
				break;
			}

		if (i >=3D BITRATE_TABLE_SIZE) {
			printk(KERN_INFO "%s: Unable to determine current bitrate (0x%04hx)\=
n",
			       priv->ndev->name, val);
			err =3D -EIO; /* maybe chose a better value... */
		}

		break;

Could you update the patch along those lines please?

Thanks,

Dave.
