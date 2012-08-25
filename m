From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: soft lockup - CPU#6 stuck for 22s! [httpd2-event:15597]
Date: Sat, 25 Aug 2012 19:52:37 +0200
Message-ID: <1345917157.19483.1063.camel@edumazet-glaptop>
References: <5038215E.60403@opensuse.org>
	 <1345885186.19483.109.camel@edumazet-glaptop>
	 <1345886085.19483.141.camel@edumazet-glaptop>
	 <1345895225.19483.447.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Cristian =?ISO-8859-1?Q?Rodr=EDguez?= <crrodriguez@opensuse.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:39011 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699Ab2HYRwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 13:52:43 -0400
Received: by wgbdr13 with SMTP id dr13so2401677wgb.1
        for <netdev@vger.kernel.org>; Sat, 25 Aug 2012 10:52:41 -0700 (PDT)
In-Reply-To: <1345895225.19483.447.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-08-25 at 13:47 +0200, Eric Dumazet wrote:
> On Sat, 2012-08-25 at 11:14 +0200, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >=20
> > On Sat, 2012-08-25 at 10:59 +0200, Eric Dumazet wrote:
> > > On Fri, 2012-08-24 at 20:50 -0400, Cristian Rodr=C3=ADguez wrote:
> > > > Hi, the issue I reported with IPV6 few weeks ago seems to be go=
ne, but
> > > > now I am getting the following crash..
> >=20
> > > Oh, I now see the bug, I'll send a patch asap
> >=20
> > Please try the following fix.
> >=20
> > Thanks !
>=20
> Well, this v2 seems cleaner :
>=20
> [PATCH v2] tcp: tcp_slow_start() should not decrease snd_cwnd
>=20
> Cristian Rodr=C3=ADguez reported various lockups in TCP stack,
> introduced by commit 9dc274151a548 (tcp: fix ABC in tcp_slow_start())
>=20
> We could exit tcp_slow_start() with a zeroed snd_cwnd,
> and next time we enter tcp_slow_start(), we run an infinite loop.
>=20
> Reported-by: Cristian Rodr=C3=ADguez <crrodriguez@opensuse.org>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/tcp_cong.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
> index 1432cdb..e656c72 100644
> --- a/net/ipv4/tcp_cong.c
> +++ b/net/ipv4/tcp_cong.c
> @@ -337,7 +337,7 @@ void tcp_slow_start(struct tcp_sock *tp)
>  		tp->snd_cwnd_cnt -=3D tp->snd_cwnd;
>  		delta++;
>  	}
> -	tp->snd_cwnd =3D min(tp->snd_cwnd + delta, tp->snd_cwnd_clamp);
> +	tp->snd_cwnd =3D clamp(tp->snd_cwnd + delta, tp->snd_cwnd, tp->snd_=
cwnd_clamp);
>  }
>  EXPORT_SYMBOL_GPL(tcp_slow_start);
> =20
>=20

Hmm...

We probably have a bug in tcp_metrics.c, because snd_cwnd_clamp should
not be zero.

With RCU, it seems following code in tcpm_new() is racy :

tm->tcpm_addr =3D *addr;
=2E..
tcpm_suck_dst(tm, dst);

Coupled with the code in tcpm_suck_dst(tm, dst)=20

static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entr=
y *dst)
{
        u32 val;

        tm->tcpm_stamp =3D jiffies;

        val =3D 0;
        if (dst_metric_locked(dst, RTAX_RTT))
                val |=3D 1 << TCP_METRIC_RTT;
        if (dst_metric_locked(dst, RTAX_RTTVAR))
                val |=3D 1 << TCP_METRIC_RTTVAR;
        if (dst_metric_locked(dst, RTAX_SSTHRESH))
                val |=3D 1 << TCP_METRIC_SSTHRESH;
        if (dst_metric_locked(dst, RTAX_CWND))
                val |=3D 1 << TCP_METRIC_CWND;
        if (dst_metric_locked(dst, RTAX_REORDERING))
                val |=3D 1 << TCP_METRIC_REORDERING;
        tm->tcpm_lock =3D val;

// HERE we set tcpm_lock before the tcpm_vals[]

        tm->tcpm_vals[TCP_METRIC_RTT] =3D dst_metric_raw(dst, RTAX_RTT)=
;
        tm->tcpm_vals[TCP_METRIC_RTTVAR] =3D dst_metric_raw(dst, RTAX_R=
TTVAR);
        tm->tcpm_vals[TCP_METRIC_SSTHRESH] =3D dst_metric_raw(dst, RTAX=
_SSTHRESH);
        tm->tcpm_vals[TCP_METRIC_CWND] =3D dst_metric_raw(dst, RTAX_CWN=
D);
        tm->tcpm_vals[TCP_METRIC_REORDERING] =3D dst_metric_raw(dst, RT=
AX_REORDERING);
        tm->tcpm_ts =3D 0;
        tm->tcpm_ts_stamp =3D 0;
        tm->tcpm_fastopen.mss =3D 0;
        tm->tcpm_fastopen.syn_loss =3D 0;
        tm->tcpm_fastopen.cookie.len =3D 0;
}
