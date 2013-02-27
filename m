From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: af_packet: Validate parameter size for PACKET_HDRLEN
 control message
Date: Wed, 27 Feb 2013 21:22:17 +0100
Message-ID: <512E6AF9.3030901@redhat.com>
References: <1361994418-1403-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7337 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752945Ab3B0UWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 15:22:25 -0500
In-Reply-To: <1361994418-1403-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2013 08:46 PM, Guenter Roeck wrote:
> Building af_packet may fail with
>
> In function =E2=80=98copy_from_user=E2=80=99,
>      inlined from =E2=80=98packet_getsockopt=E2=80=99 at
>      net/packet/af_packet.c:3215:21:
> arch/x86/include/asm/uaccess_32.h:211:26: error: call to
>      =E2=80=98copy_from_user_overflow=E2=80=99 declared with attribut=
e error: copy_from_user()
>      buffer size is not provably correct
>
> if built with W=3D1 due to a missing parameter size validation.
>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>   net/packet/af_packet.c |    2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index c7bfeff..1976b23 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -3210,6 +3210,8 @@ static int packet_getsockopt(struct socket *soc=
k, int level, int optname,
>   		val =3D po->tp_version;
>   		break;
>   	case PACKET_HDRLEN:
> +		if (len < sizeof(int))
> +			return -EINVAL;

I think this could break some user space applications here, those who e=
=2Eg. only pass
an uint16_t to packet_getsockopt with PACKET_HDRLEN.

>   		if (len > sizeof(int))
>   			len =3D sizeof(int);
>   		if (copy_from_user(&val, optval, len))
