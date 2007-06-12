From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC PATCH net-2.6] [TCP]: Congestion control API RTT sampling
 fix
Date: Tue, 12 Jun 2007 08:23:08 -0700
Message-ID: <20070612082308.2e93f2c8@localhost>
References: <Pine.LNX.4.64.0706121500530.15358@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVuIg==?= <ilpo.jarvinen@helsinki.fi>"@smtp2.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42646 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753279AbXFLP2i convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 11:28:38 -0400
In-Reply-To: <Pine.LNX.4.64.0706121500530.15358@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Jun 2007 15:06:57 +0300 (EEST)
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> I was thinking something like this to fix the cc module breakage=20
> introduced by the API change (haven't tested it besides compile):
>=20
>=20
> [RFC PATCH net-2.6] [TCP]: Congestion control API RTT sampling fix
>=20
>=20
> Commit 164891aadf1721fca4dce473bb0e0998181537c6 broke RTT
> sampling of congestion control modules. Inaccurate timestamps
> could be fed to them without providing any way for them to
> identify such cases. Previously RTT sampler was called only if
> FLAG_RETRANS_DATA_ACKED was not set filtering inaccurate
> timestamps nicely. In addition, the new behavior could give an
> invalid timestamp (zero) to RTT sampler if only skbs with
> TCPCB_RETRANS were ACKed. This solves both problems.
>=20
> Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  include/linux/ktime.h   |   18 ++++++++++++++++++
>  include/linux/skbuff.h  |    4 ++++
>  net/ipv4/tcp_illinois.c |    3 +++
>  net/ipv4/tcp_input.c    |    6 +++++-
>  net/ipv4/tcp_lp.c       |    3 ++-
>  net/ipv4/tcp_vegas.c    |    3 +++
>  net/ipv4/tcp_veno.c     |    3 +++
>  7 files changed, 38 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/ktime.h b/include/linux/ktime.h
> index c762954..9f7fa3e 100644
> --- a/include/linux/ktime.h
> +++ b/include/linux/ktime.h
> @@ -102,6 +102,12 @@ static inline ktime_t ktime_set(const long secs,=
 const unsigned long nsecs)
>  #define ktime_add_ns(kt, nsval) \
>  		({ (ktime_t){ .tv64 =3D (kt).tv64 + (nsval) }; })
> =20
> +/* Compare two ktime_t variables, returns 1 if equal */
> +static inline int ktime_equal(const ktime_t cmp1, const ktime_t cmp2=
)
> +{
> +	return cmp1.tv64 =3D=3D cmp2.tv64;
> +}
> +
>  /* convert a timespec to ktime_t format: */
>  static inline ktime_t timespec_to_ktime(struct timespec ts)
>  {
> @@ -200,6 +206,18 @@ static inline ktime_t ktime_add(const ktime_t ad=
d1, const ktime_t add2)
>  extern ktime_t ktime_add_ns(const ktime_t kt, u64 nsec);
> =20
>  /**
> + * ktime_equal - Compares two ktime_t variables to see if they are e=
qual
> + * @cmp1:	comparable1
> + * @cmp2:	comparable2
> + *
> + * Compare two ktime_t variables, returns 1 if equal
> + */
> +static inline int ktime_equal(const ktime_t cmp1, const ktime_t cmp2=
)
> +{
> +	return !((cmp1.tv.sec ^ cmp2.tv.sec) | (cmp1.tv.usec ^ cmp2.tv.usec=
));
> +}

Since ktime is a union just comparing the two 64bit values should
be simpler.

static inline int ktime_equal(const ktime_t t1, const ktime_t t2)
{
	return t1.s64 =3D=3D t2.s64;
}

