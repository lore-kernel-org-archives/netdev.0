From: Per Hurtig <per.hurtig@kau.se>
Subject: Re: [RFC PATCH net-next 1/2] tcp: RTO Restart (RTOR)
Date: Tue, 8 Dec 2015 10:25:38 +0100
Message-ID: <589C4457-5C20-4FC2-8656-F7CF600B6697@kau.se>
References: <cover.1449478261.git.per.hurtig@kau.se> <4719073d7d8285006b2fe5f1b67a3fe5255c503e.1449478261.git.per.hurtig@kau.se> <CAK6E8=efnk_bL-JP-6avUtqc1+Xnp7YM3=Tphw7B6oevO4jbeQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.1 \(3096.5\))
Content-Type: multipart/signed; boundary="Apple-Mail=_FFC79C31-E03B-4CE0-9BC5-9615E53C8C2D"; protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Tom Herbert <tom@herbertland.com>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	Florian Westphal <fw@strlen.de>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Willem de Bruijn <willemb@google.com>,
	=?utf-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Pasi Sarolahti <pasi.sarolahti@iki.fi>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	=?utf-8?Q?Anna_Brunstr=C3=B6m?= <anna.brunstrom@kau.se>,
	Andreas Petlund <apetlund@simula.no>,
	Michael Welzl <michawe@ifi.uio.no>,
	Mohammad Rajiullah <mohammad.rajiullah@kau.se>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.38]:42531 "EHLO tiger.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932516AbbLHJ0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 04:26:23 -0500
In-Reply-To: <CAK6E8=efnk_bL-JP-6avUtqc1+Xnp7YM3=Tphw7B6oevO4jbeQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_FFC79C31-E03B-4CE0-9BC5-9615E53C8C2D
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8


> On 08 Dec 2015, at 03:05, Yuchung Cheng <ycheng@google.com> wrote:
>=20
> On Mon, Dec 7, 2015 at 1:00 AM, Per Hurtig <per.hurtig@kau.se> wrote:
>> This patch implements the RTO restart modification (RTOR). When data =
is
>> ACKed, and the RTO timer is restarted, the time elapsed since the =
last
>> outstanding segment was transmitted is subtracted from the calculated =
RTO
>> value. This way, the RTO timer will expire after exactly RTO seconds, =
and
>> not RTO + RTT [+ delACK] seconds.
>>=20
>> This patch also implements a new sysctl (tcp_timer_restart) that is =
used
>> to control the timer restart behavior.
>>=20
>> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>> ---
>> Documentation/networking/ip-sysctl.txt | 12 ++++++++++++
>> include/net/tcp.h                      |  4 ++++
>> net/ipv4/sysctl_net_ipv4.c             | 10 ++++++++++
>> net/ipv4/tcp_input.c                   | 24 ++++++++++++++++++++++++
>> 4 files changed, 50 insertions(+)
>>=20
>> diff --git a/Documentation/networking/ip-sysctl.txt =
b/Documentation/networking/ip-sysctl.txt
>> index 2ea4c45..4094128 100644
>> --- a/Documentation/networking/ip-sysctl.txt
>> +++ b/Documentation/networking/ip-sysctl.txt
>> @@ -591,6 +591,18 @@ tcp_syn_retries - INTEGER
>>        with the current initial RTO of 1second. With this the final =
timeout
>>        for an active TCP connection attempt will happen after =
127seconds.
>>=20
>> +tcp_timer_restart - INTEGER
>> +       Controls how the RTO and PTO timers are restarted (RTOR and =
TLPR).
>> +       If set (per timer or combined) the timers are restarted with
>> +       respect to the earliest outstanding segment, to not extend =
tail loss
>> +       latency unnecessarily.
>> +       Possible values:
>> +               0 disables RTOR and TLPR.
>> +               1 enables RTOR.
>> +               2 enables TLPR.
>> +               3 enables RTOR and TLPR.
>> +       Default: 3
>> +
>> tcp_timestamps - BOOLEAN
>>        Enable timestamps as defined in RFC1323.
>>=20
>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>> index f80e74c..bf98768 100644
>> --- a/include/net/tcp.h
>> +++ b/include/net/tcp.h
>> @@ -76,6 +76,9 @@ void tcp_time_wait(struct sock *sk, int state, int =
timeo);
>> /* After receiving this amount of duplicate ACKs fast retransmit =
starts. */
>> #define TCP_FASTRETRANS_THRESH 3
>>=20
>> +/* Disable RTO Restart if the number of outstanding segments is at =
least. */
>> +#define TCP_RTORESTART_THRESH  4
>> +
>> /* Maximal number of ACKs sent quickly to accelerate slow-start. */
>> #define TCP_MAX_QUICKACKS      16U
>>=20
>> @@ -284,6 +287,7 @@ extern int sysctl_tcp_autocorking;
>> extern int sysctl_tcp_invalid_ratelimit;
>> extern int sysctl_tcp_pacing_ss_ratio;
>> extern int sysctl_tcp_pacing_ca_ratio;
>> +extern int sysctl_tcp_timer_restart;
>>=20
>> extern atomic_long_t tcp_memory_allocated;
>> extern struct percpu_counter tcp_sockets_allocated;
>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
>> index a0bd7a5..dfb6968 100644
>> --- a/net/ipv4/sysctl_net_ipv4.c
>> +++ b/net/ipv4/sysctl_net_ipv4.c
>> @@ -28,6 +28,7 @@
>>=20
>> static int zero;
>> static int one =3D 1;
>> +static int three =3D 3;
>> static int four =3D 4;
>> static int thousand =3D 1000;
>> static int gso_max_segs =3D GSO_MAX_SEGS;
>> @@ -745,6 +746,15 @@ static struct ctl_table ipv4_table[] =3D {
>>                .extra2         =3D &thousand,
>>        },
>>        {
>> +               .procname       =3D "tcp_timer_restart",
>> +               .data           =3D &sysctl_tcp_timer_restart,
>> +               .maxlen         =3D sizeof(int),
>> +               .mode           =3D 0644,
>> +               .proc_handler   =3D proc_dointvec_minmax,
>> +               .extra1         =3D &zero,
>> +               .extra2         =3D &three,
>> +       },
>> +       {
>>                .procname       =3D "tcp_autocorking",
>>                .data           =3D &sysctl_tcp_autocorking,
>>                .maxlen         =3D sizeof(int),
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index fdd88c3..66e0425 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -101,6 +101,7 @@ int sysctl_tcp_thin_dupack __read_mostly;
>>=20
>> int sysctl_tcp_moderate_rcvbuf __read_mostly =3D 1;
>> int sysctl_tcp_early_retrans __read_mostly =3D 3;
>> +int sysctl_tcp_timer_restart __read_mostly =3D 3;
>> int sysctl_tcp_invalid_ratelimit __read_mostly =3D HZ/2;
>>=20
>> #define FLAG_DATA              0x01 /* Incoming frame contained data. =
         */
>> @@ -2997,6 +2998,18 @@ static void tcp_cong_avoid(struct sock *sk, =
u32 ack, u32 acked)
>>        tcp_sk(sk)->snd_cwnd_stamp =3D tcp_time_stamp;
>> }
>>=20
>> +static u32 tcp_unsent_pkts(const struct sock *sk)
>> +{
>> +       struct sk_buff *skb =3D tcp_send_head(sk);
>> +       u32 pkts =3D 0;
>> +
>> +       if (skb)
>> +               tcp_for_write_queue_from(skb, sk)
>> +                       pkts +=3D tcp_skb_pcount(skb);
>> +
>> +       return pkts;
>> +}
>> +
>> /* Restart timer after forward progress on connection.
>>  * RFC2988 recommends to restart timer to now+rto.
>>  */
>> @@ -3027,6 +3040,17 @@ void tcp_rearm_rto(struct sock *sk)
>>                         */
>>                        if (delta > 0)
>>                                rto =3D delta;
>> +               } else if (icsk->icsk_pending =3D=3D =
ICSK_TIME_RETRANS &&
>> +                          (sysctl_tcp_timer_restart =3D=3D 1 ||
>> +                           sysctl_tcp_timer_restart =3D=3D 3) &&
>> +                          (tp->packets_out + tcp_unsent_pkts(sk) <
> We re-arm RTO every ACK. Do we really need a loop here to improve
> short-transfer RTO performance?
>=20
> Going one level up: what's the rationale to arm RTO differently
> depending on the #packets in the write queue? if the idea is to offset
> the elapsed of the first unacked packet in RTO, it should generally
> apply to any packet w/ any inflight, and we can forgo another packet
> counting heuristic.
>=20
The rationale is to not risk being overly aggressive when there is =
enough
packets in the write queue to allow other recovery strategies than RTO
to kick in. However, this version of the patch tightly follows the IETF
internet-draft of the mechanism. If people like a more aggressive
approach I=E2=80=99m all for that, it=E2=80=99ll at least be a cleaner =
solution in terms of
code :)

> While larger inflight can trigger more fast recoveries, tail drops can
> happen at any time. This is why TLP is always enabled of any inflight.
> Sounds like we can benefit if RTO-restart is always used too? I am
> planning to experiment your patch w and w/o the packet count checks.
>=20
This is of course possible. We welcome any experimentation with this
piece of code to make it better!

>=20
>> +                           TCP_RTORESTART_THRESH)) {
>> +                       struct sk_buff *skb =3D =
tcp_write_queue_head(sk);
>> +                       const u32 rto_time_stamp =3D =
tcp_skb_timestamp(skb);
>> +                       s32 delta =3D (s32)(tcp_time_stamp - =
rto_time_stamp);
>> +
>> +                       if (delta > 0 && rto > delta)
>> +                               rto -=3D delta;
>>                }
>>                inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, rto,
>>                                          TCP_RTO_MAX);
>> --
>> 1.9.1
>>=20
>>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Apple-Mail=_FFC79C31-E03B-4CE0-9BC5-9615E53C8C2D
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCAAGBQJWZqIXAAoJEMzXVkqMT/z2tCYH/2kynPgjDCI+S+QDVatYltry
R6Zbavk3K+bZ6PozmGhdmJ9hEwb9Yb7+5yRzyqyPKL88jhXn59nJUZghUnO+2Tyw
VtRmcEWks4N5qo+P3rMzaM88/XfkkTt3xOGVPWSebm3H+QKsHFuuYt68lloZl8AJ
KNNA7AdQOAqLIS7A63wACmveZXGU0Ya3iZmkEv1a5oyPRCa7G6n/FB/Fswwm1ewd
nXHFKgLI35/GyojORwHmXX8stnVuGmn3yZdotdkhvIwI327duUQD/3U103HN1Ag9
tHj2rcFWWoS4V7XmC+eaK92+bldJJ66DV7EZdDfXLjH60jq8Q+hcfY58bp7BGUs=
=nUJT
-----END PGP SIGNATURE-----

--Apple-Mail=_FFC79C31-E03B-4CE0-9BC5-9615E53C8C2D--
