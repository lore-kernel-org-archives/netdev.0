From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis
 purpose.
Date: Thu, 17 Mar 2011 09:42:10 +0100
Message-ID: <1300351330.10164.712.camel@edumazet-laptop>
References: <1300349189-2731-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "H.K. Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56859 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab1CQImR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 04:42:17 -0400
Received: by bwz15 with SMTP id 15so2259308bwz.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 01:42:15 -0700 (PDT)
In-Reply-To: <1300349189-2731-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 mars 2011 =C3=A0 01:06 -0700, H.K. Jerry Chu a =C3=A9crit :
> From: Jerry Chu <hkchu@google.com>
>=20
> This patch add a number of very useful counters/stats (defined in
> tcp_stats.h) to help diagnosing TCP related problems.
>=20
> create_time     - when the connection was created (in jiffies)
> total_inbytes   - total inbytes as consumed by the receiving apps.
> total_outbytes  - total outbytes sent down from the transmitting apps=
=2E
>=20
> total_outdatasegs - total data carrying segments sent so far, includi=
ng
> 		retransmitted ones.
>=20
> total_xmit      - total accumulated time (usecs) when the connection
> 		has something to send.
>=20
> total_retrans_time - total time (usecs, accumulated) the connection
> 		spends trying to recover lost packets. For each
> 		loss event the time is measured from the lost packet
> 		was first sent till the retransmitted packet was
> 		eventually ack'ed.
>=20
> total_cwnd_limit - total time (usecs, excluding time spent on loss
>     		recovery) the xmit is stopped due to cwnd limited
>=20
> total_swnd_limit - total time (usecs) theconnection is swnd limited
>=20
> The following two counters are for listeners only:
>=20
> accepted_reqs   - total # of accepted connection requests.
> listen_drops    - total # of dropped SYN reqs (SYN cookies excluded) =
due
>     		to listener's queue overflow.
>=20
> total_retrans_time/total_retrans ratio gives a rough picture of how
> quickly in average the connection can recover from a pkt loss. E.g.,
> when the network is more congested, or the traffic contains mainly
> smaller RPC where tail drop often requires RTO to recover,
> the total_retrans_time/total_retrans ratio tends to be higher.
>=20
> Currently the new counters/stats are exported through /proc/net/tcp.

Please dont. Use iproute2 instead.

> Some simple, abbreviated field names have been added to the output of
> /proc/net/tcp in order to allow backward/forward compatibility in the
> future. Obviously the new counters/stats can also be easily exported
> through other APIs.
>=20

/proc/net/tcp is legacy. You should touch it eventually, but after
"other APIS" are done. It was the old way (quick but a bit ugly)



> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
> ---
>  include/linux/ktime.h    |    3 ++
>  include/linux/tcp.h      |    1 +
>  include/net/tcp_stats.h  |   65 ++++++++++++++++++++++++++++++++++++=
++++++++++
>  net/ipv4/tcp.c           |   30 ++++++++++++++++++---
>  net/ipv4/tcp_input.c     |   13 +++++++++
>  net/ipv4/tcp_ipv4.c      |   41 ++++++++++++++++++++++++++---
>  net/ipv4/tcp_minisocks.c |    9 ++++++
>  net/ipv4/tcp_output.c    |   47 +++++++++++++++++++++++++++++++--
>  net/ipv6/tcp_ipv6.c      |    8 +++++
>  9 files changed, 206 insertions(+), 11 deletions(-)
>  create mode 100644 include/net/tcp_stats.h
>=20
> diff --git a/include/linux/ktime.h b/include/linux/ktime.h
> index e1ceaa9..e60e758 100644
> --- a/include/linux/ktime.h
> +++ b/include/linux/ktime.h
> @@ -333,6 +333,9 @@ extern void ktime_get_ts(struct timespec *ts);
>  /* Get the real (wall-) time in timespec format: */
>  #define ktime_get_real_ts(ts)	getnstimeofday(ts)

Hmm, this kind of changes are out of netdev scope and should be avoided

> =20
> +#define ktime_since(a)		ktime_to_us(ktime_sub(ktime_get(), (a)))

us are implied in ktime_since() ? thats strange.

> +#define ktime_zero(a)		ktime_equal((a), ktime_set(0, 0))

ktime_zero() sounds like : "give me zero time" or "clear the ktime
field".=20

> +
>  static inline ktime_t ns_to_ktime(u64 ns)
>  {
>  	static const ktime_t ktime_zero =3D { .tv64 =3D 0 };
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index e64f4c6..ea5cb5d 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -460,6 +460,7 @@ struct tcp_sock {
>  	 * contains related tcp_cookie_transactions fields.
>  	 */
>  	struct tcp_cookie_values  *cookie_values;
> +	struct tcp_stats	*conn_stats;
>  };

Really, using separate cache lines to store some stats is expensive.
You should add counters in existing structure, to avoid additional cach=
e
line dirties. Carefully placing stats in already dirtied cache lines.

You also should use native ktime_t infrastructure, to make the maths
really fast in fast path.

Only when stats are to be returned to user, you'll have to convert the
native timestamps to user exportable ones.

Quite frankly, using u64 fields allow nanosec resolution.

BTW, we probably could 'export' sk->sk_drops for TCP, like we do for
UDP.



