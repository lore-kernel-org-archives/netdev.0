From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2] net/sctp: Validate parameter size for SCTP_GET_ASSOC_STATS
Date: Wed, 27 Feb 2013 16:00:42 -0500
Message-ID: <512E73FA.1090407@gmail.com>
References: <1361998651-19354-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Sridhar Samudrala <sri@us.ibm.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f170.google.com ([209.85.220.170]:46198 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962Ab3B0VAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 16:00:47 -0500
In-Reply-To: <1361998651-19354-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2013 03:57 PM, Guenter Roeck wrote:
> Building sctp may fail with:
>
> In function =E2=80=98copy_from_user=E2=80=99,
>      inlined from =E2=80=98sctp_getsockopt_assoc_stats=E2=80=99 at
>      net/sctp/socket.c:5656:20:
> arch/x86/include/asm/uaccess_32.h:211:26: error: call to
>      =E2=80=98copy_from_user_overflow=E2=80=99 declared with attribut=
e error: copy_from_user()
>      buffer size is not provably correct
>
> if built with W=3D1 due to a missing parameter size validation
> before the call to copy_from_user.
>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
> v2: Fix by moving the existing parameter size validation up
>      in the function instead of adding an additional one.

This works too...

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

>
>   net/sctp/socket.c |    6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index cedd9bf..9ef5c73 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -5653,6 +5653,9 @@ static int sctp_getsockopt_assoc_stats(struct s=
ock *sk, int len,
>   	if (len < sizeof(sctp_assoc_t))
>   		return -EINVAL;
>
> +	/* Allow the struct to grow and fill in as much as possible */
> +	len =3D min_t(size_t, len, sizeof(sas));
> +
>   	if (copy_from_user(&sas, optval, len))
>   		return -EFAULT;
>
> @@ -5686,9 +5689,6 @@ static int sctp_getsockopt_assoc_stats(struct s=
ock *sk, int len,
>   	/* Mark beginning of a new observation period */
>   	asoc->stats.max_obs_rto =3D asoc->rto_min;
>
> -	/* Allow the struct to grow and fill in as much as possible */
> -	len =3D min_t(size_t, len, sizeof(sas));
> -
>   	if (put_user(len, optlen))
>   		return -EFAULT;
>
>
