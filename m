From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2] htb: improved accuracy at high rates
Date: Sun, 21 Oct 2012 13:09:47 +0200
Message-ID: <1350817787.13333.1949.camel@edumazet-glaptop>
References: <1350751116-70056-1-git-send-email-j.vimal@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev@vger.kernel.org
To: Vimalkumar <j.vimal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33123 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464Ab2JULJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 07:09:52 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so631732eek.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 04:09:51 -0700 (PDT)
In-Reply-To: <1350751116-70056-1-git-send-email-j.vimal@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-10-20 at 09:38 -0700, Vimalkumar wrote:
> Current HTB (and TBF) uses rate table computed by the "tc"
> userspace program, which has the following issue:
>=20
> The rate table has 256 entries to map packet lengths
> to token (time units).  With TSO sized packets, the
> 256 entry granularity leads to loss/gain of rate,
> making the token bucket inaccurate.
>=20
> Thus, instead of relying on rate table, this patch
> explicitly computes the time and accounts for packet
> transmission times with nanosecond granularity.
>=20
> This greatly improves accuracy of HTB with a wide
> range of packet sizes.
>=20
> Example:
>=20
> tc qdisc add dev $dev root handle 1: \
>         htb default 1
>=20
> tc class add dev $dev classid 1:1 parent 1: \
>         rate 5Gbit mtu 64k
>=20
> Here is an example of inaccuracy:
>=20
> $ iperf -c host -t 10 -i 1
>=20
> With old htb:
> eth4:   34.76 Mb/s In  5827.98 Mb/s Out -  65836.0 p/s In  481273.0 p=
/s Out
> [SUM]  9.0-10.0 sec   669 MBytes  5.61 Gbits/sec
> [SUM]  0.0-10.0 sec  6.50 GBytes  5.58 Gbits/sec
>=20
> With new htb:
> eth4:   28.36 Mb/s In  5208.06 Mb/s Out -  53704.0 p/s In  430076.0 p=
/s Out
> [SUM]  9.0-10.0 sec   594 MBytes  4.98 Gbits/sec
> [SUM]  0.0-10.0 sec  5.80 GBytes  4.98 Gbits/sec
>=20
> The bits per second on the wire is still 5200Mb/s with new HTB
> because qdisc accounts for packet length using skb->len, which
> is smaller than total bytes on the wire if GSO is used.  But
> that is for another patch regardless of how time is accounted.
>=20
> Many thanks to Eric Dumazet for review and feedback.
>=20
> Signed-off-by: Vimalkumar <j.vimal@gmail.com>
> ---
>  net/sched/sch_htb.c |  123 +++++++++++++++++++++++++++++++++--------=
----------
>  1 files changed, 80 insertions(+), 43 deletions(-)
>=20
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 9d75b77..1f26d6b 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -55,6 +55,7 @@
> =20
>  static int htb_hysteresis __read_mostly =3D 0; /* whether to use mod=
e hysteresis for speedup */
>  #define HTB_VER 0x30011		/* major must be matched with number suplie=
d by TC as version */
> +#define HTB_MIN_PKT_BYTES (64)

This is not used in your patch.


is htb_precompute_ratedata() safe/correct for very low speeds, as 8000
bits/sec ?

If my maths are correct, there is an overflow.

factor =3D 8LLU * NSEC_PER_SEC * (1 << r->shift);

so factor =3D 262144000000000

r->mult =3D div64_u64(factor, r->rate_bps);

the result of the divide is 32768000000, and its bigger than an u32

So you should have a loop to reduce r->shift to make sure you dont have
an overflow for r->mult

> -	if (nla_put(skb, TCA_HTB_INIT, sizeof(gopt), &gopt))
> -		goto nla_put_failure;
> +	NLA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
>  	nla_nest_end(skb, nest);
=2E..

> -	if (nla_put(skb, TCA_HTB_PARMS, sizeof(opt), &opt))
> -		goto nla_put_failure;
> +	NLA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);


Thats unfortunate, you apparently didnt compile your module and tested
it.

# make net/sched/sch_htb.ko
make[1]: Nothing to be done for `all'.
make[1]: Nothing to be done for `relocs'.
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CC [M]  net/sched/sch_htb.o
net/sched/sch_htb.c: In function =E2=80=98htb_dump=E2=80=99:
net/sched/sch_htb.c:1092: error: implicit declaration of function
=E2=80=98NLA_PUT=E2=80=99
make[1]: *** [net/sched/sch_htb.o] Error 1
make: *** [net/sched/sch_htb.ko] Error 2


You should understand this is an absolute requirement, or else people
are less likely to take a serious look at your work.

So triple check next time you submit.

Read again Documentation/SubmitChecklist

Take your time, so that other people dont loose their time.

Thanks

PS : Documentation/SubmittingPatches =20
   10) Don't get discouraged.  Re-submit.
