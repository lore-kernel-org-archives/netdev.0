From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next] tcp: RFC6298 supersedes RFC2988bis
Date: Sun, 15 Apr 2012 11:33:38 -0700
Message-ID: <CAPshTCiew0w4kF2yE=Bn_E702vxdFwZipnnEpsAuhSm6OO187Q@mail.gmail.com>
References: <1334296120.5300.8404.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:44735 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750710Ab2DOSdk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Apr 2012 14:33:40 -0400
Received: by lahj13 with SMTP id j13so3469252lah.19
        for <netdev@vger.kernel.org>; Sun, 15 Apr 2012 11:33:38 -0700 (PDT)
In-Reply-To: <1334296120.5300.8404.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[send again - it looks like my previous comment was lost...]

On Thu, Apr 12, 2012 at 10:48 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Updates some comments to track RFC6298
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: H.K. Jerry Chu <hkchu@google.com>
> Cc: Tom Herbert <therbert@google.com>
> ---
> BTW, one side effect of the TCP_TIMEOUT_INIT change (3 -> 1) is
> () latency is 200% worse:

Or even worse - 300% (3/1)?

>
> It fires every 200ms and scans 40% of hash table each time, listener
> socket held.

If this becomes a real issue we could decrease TCP_SYNQ_INTERVAL,
essentially making the keepalive timer fire more often, but each time w=
ith
less work to do?

Also why is
budget =3D 2 * (lopt->nr_table_entries / (timeout / interval));
rather than
budget =3D (lopt->nr_table_entries / (timeout / interval)) + 1;
?

Acked-by: Jerry Chu <hkchu@google.com>

>
> =A0include/net/tcp.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0net/ipv4/inet_connection_sock.c | =A0 =A02 +-
> =A0net/ipv4/tcp_input.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 ++--
> =A03 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index f75a04d..057f016 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -123,7 +123,7 @@ extern void tcp_time_wait(struct sock *sk, int st=
ate, int timeo);
> =A0#endif
> =A0#define TCP_RTO_MAX =A0 =A0((unsigned)(120*HZ))
> =A0#define TCP_RTO_MIN =A0 =A0((unsigned)(HZ/5))
> -#define TCP_TIMEOUT_INIT ((unsigned)(1*HZ)) =A0 =A0/* RFC2988bis ini=
tial RTO value */
> +#define TCP_TIMEOUT_INIT ((unsigned)(1*HZ)) =A0 =A0/* RFC6298 2.1 in=
itial RTO value =A0 =A0 =A0 =A0*/
> =A0#define TCP_TIMEOUT_FALLBACK ((unsigned)(3*HZ)) =A0 =A0 =A0 =A0/* =
RFC 1122 initial RTO value, now
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 * used as a fallback RTO for the
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 * initial data transmission if no
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connecti=
on_sock.c
> index 19d66ce..c12396f 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -514,7 +514,7 @@ void inet_csk_reqsk_queue_prune(struct sock *pare=
nt,
>
> =A0 =A0 =A0 =A0/* Normally all the openreqs are young and become matu=
re
> =A0 =A0 =A0 =A0 * (i.e. converted to established socket) for first ti=
meout.
> - =A0 =A0 =A0 =A0* If synack was not acknowledged for 3 seconds, it m=
eans
> + =A0 =A0 =A0 =A0* If synack was not acknowledged for 1 second, it me=
ans
> =A0 =A0 =A0 =A0 * one of the following things: synack was lost, ack w=
as lost,
> =A0 =A0 =A0 =A0 * rtt is high or nobody planned to ack (i.e. synflood=
).
> =A0 =A0 =A0 =A0 * When server is a bit loaded, queue is populated wit=
h old
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index e886e2f..9147c27 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -933,7 +933,7 @@ static void tcp_init_metrics(struct sock *sk)
> =A0 =A0 =A0 =A0tcp_set_rto(sk);
> =A0reset:
> =A0 =A0 =A0 =A0if (tp->srtt =3D=3D 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* RFC2988bis: We've failed to get a va=
lid RTT sample from
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* RFC6298: 5.7 We've failed to get a v=
alid RTT sample from
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 3WHS. This is most likely due to re=
transmission,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * including spurious one. Reset the R=
TO back to 3secs
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * from the more aggressive 1sec to av=
oid more spurious
> @@ -943,7 +943,7 @@ reset:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inet_csk(sk)->icsk_rto =3D TCP_TIMEOUT=
_FALLBACK;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0/* Cut cwnd down to 1 per RFC5681 if SYN or SYN-ACK ha=
s been
> - =A0 =A0 =A0 =A0* retransmitted. In light of RFC2988bis' more aggres=
sive 1sec
> + =A0 =A0 =A0 =A0* retransmitted. In light of RFC6298 more aggressive=
 1sec
> =A0 =A0 =A0 =A0 * initRTO, we only reset cwnd when more than 1 SYN/SY=
N-ACK
> =A0 =A0 =A0 =A0 * retransmission has occurred.
> =A0 =A0 =A0 =A0 */
>
>
