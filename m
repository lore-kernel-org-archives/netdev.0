From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH netdev] "wrong timeout value" in sk_wait_data()
Date: Thu, 24 May 2007 06:36:05 +0200
Message-ID: <46551635.30809@cosmosbay.com>
References: <465512EB.4000808@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	devel@openvz.org
To: Vasily Averin <vvs@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:45264 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759246AbXEXElt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 00:41:49 -0400
In-Reply-To: <465512EB.4000808@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vasily Averin a =C3=A9crit :
> sys_setsockopt() do not check properly timeout values for
> SO_RCVTIMEO/SO_SNDTIMEO, for example it's possible to set negative ti=
meout
> values. POSIX do not defines behaviour for sys_setsockopt in case neg=
ative
> timeouts, but requires that setsockopt() shall fail with -EDOM if the=
 send and
> receive timeout values are too big to fit into the timeout fields in =
the socket
> structure.
> In current implementation negative timeout can lead to error messages=
 like
> "schedule_timeout: wrong timeout value".
>=20
> Proposed patch:
> - checks tv_usec and returns -EDOM if it is wrong
> - do not allows to set negative timeout values (sets 0 instead) and o=
utputs
> ratelimited information message about such attempts.
>=20
> Signed-Off-By:	Vasily Averin <vvs@sw.ru>
>=20
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 22183c2..27d7a46 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -206,7 +206,19 @@ static int sock_set_timeout(long *timeo_p, char =
__user
> *optval, int optlen)
>  		return -EINVAL;
>  	if (copy_from_user(&tv, optval, sizeof(tv)))
>  		return -EFAULT;
> -
> +	if (tv.tv_usec < 0 || tv.tv_usec >=3D 1000000)
> +		return -EDOM;

Please use USEC_PER_SEC instead of 1000000

> +
> +	if (tv.tv_sec < 0) {
> +		static int warned =3D 0;
> +		*timeo_p =3D 0;
> +		if (warned < 10 && net_ratelimit())
> +			warned++;
> +			printk(KERN_INFO "sock_set_timeout: `%s' (pid %d) "
> +			       "tries to set negative timeout\n",
> +			        current->comm, current->pid);
> +		return 0;
> +	}
>  	*timeo_p =3D MAX_SCHEDULE_TIMEOUT;
>  	if (tv.tv_sec =3D=3D 0 && tv.tv_usec =3D=3D 0)
>  		return 0;
>=20

