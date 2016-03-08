From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH] csum: Update csum_block_add to use rotate
 instead of byteswap
Date: Tue, 08 Mar 2016 15:25:57 -0800
Message-ID: <1457479557.4067.9.camel@perches.com>
References: <20160308224238.16551.73881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0023.hostedemail.com ([216.40.44.23]:51029 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750985AbcCHX0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 18:26:02 -0500
In-Reply-To: <20160308224238.16551.73881.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-08 at 14:42 -0800, Alexander Duyck wrote:
> The code for csum_block_add was doing a funky byteswap to swap the ev=
en and
> odd bytes of the checksum if the offset was odd.=A0=A0Instead of doin=
g this we
> can save ourselves some trouble and just shift by 8 as this should ha=
ve the
> same effect in terms of the final checksum value and only requires on=
e
> instruction.

3 instructions?

> In addition we can update csum_block_sub to just use csum_block_add w=
ith a
> inverse value for csum2.=A0=A0This way we follow the same code path a=
s
> csum_block_add without having to duplicate it.
>=20
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
> =A0include/net/checksum.h |=A0=A0=A011 +++++------
> =A01 file changed, 5 insertions(+), 6 deletions(-)
>=20
> diff --git a/include/net/checksum.h b/include/net/checksum.h
> index 10a16b5bd1c7..f9fac66c0e66 100644
> --- a/include/net/checksum.h
> +++ b/include/net/checksum.h
> @@ -88,8 +88,10 @@ static inline __wsum
> =A0csum_block_add(__wsum csum, __wsum csum2, int offset)
> =A0{
> =A0	u32 sum =3D (__force u32)csum2;
> -	if (offset&1)
> -		sum =3D ((sum&0xFF00FF)<<8)+((sum>>8)&0xFF00FF);
> +
> +	if (offset & 1)
> +		sum =3D (sum << 24) + (sum >> 8);

Maybe use ror32(sum, 8);

or maybe something like:

{
	u32 sum;

	/*=A0rotated csum2 of odd offset will be the right checksum */
	if (offset & 1)
		sum =3D ror32((__force u32)csum2, 8);
	else
		sum =3D (__force u32)csum2;
