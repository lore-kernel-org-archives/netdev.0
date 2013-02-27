From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net/sctp: Validate parameter size for
 SCTP_GET_ASSOC_STATS control message
Date: Wed, 27 Feb 2013 15:09:31 -0500
Message-ID: <20130227200931.GB7993@hmsreliant.think-freely.org>
References: <1361994231-5355-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56142 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286Ab3B0UJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 15:09:55 -0500
Content-Disposition: inline
In-Reply-To: <1361994231-5355-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 27, 2013 at 11:43:51AM -0800, Guenter Roeck wrote:
> Building sctp may fail with:
>=20
> In function =E2=80=98copy_from_user=E2=80=99,
>     inlined from =E2=80=98sctp_getsockopt_assoc_stats=E2=80=99 at
>     net/sctp/socket.c:5656:20:
> arch/x86/include/asm/uaccess_32.h:211:26: error: call to
>     =E2=80=98copy_from_user_overflow=E2=80=99 declared with attribute=
 error: copy_from_user()
>     buffer size is not provably correct
>=20
> if built with W=3D1 due to a missing parameter size validation.
>=20
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>  net/sctp/socket.c |    2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index cedd9bf..0a5f2bf 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -5652,6 +5652,8 @@ static int sctp_getsockopt_assoc_stats(struct s=
ock *sk, int len,
>  	/* User must provide at least the assoc id */
>  	if (len < sizeof(sctp_assoc_t))
>  		return -EINVAL;
> +	if (len > sizeof(struct sctp_assoc_stats))
> +		len =3D sizeof(struct sctp_assoc_stats);
> =20
>  	if (copy_from_user(&sas, optval, len))
>  		return -EFAULT;
> --=20
> 1.7.9.7
>=20
>=20

Theres more than that going on here.  This will fix the warning, but th=
e
function is written such that, if you pass in a size that is greater th=
an the
size of a struct sctp_association, but less than a struct sctp_assoc_st=
ats.  I'm
not sure that a partial stat struct is really that useful to people.  W=
hat if
you were to check for max(struct sctp_association, struct sctp_assoc_st=
ats) as
your minimum length check, then just did a copy_from_user of that lengt=
h.  It
would save you having to compute two lengths separately, since you coul=
d then
just do a copy_to_user(...,sizeof(struct sctp_assoc_stats), at the bott=
om of
that function.

Thanks!
Neil
