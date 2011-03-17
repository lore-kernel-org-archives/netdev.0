From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis
 purpose.
Date: Thu, 17 Mar 2011 14:20:30 -0700
Message-ID: <20110317142030.62af785a@nehalam>
References: <1300349189-2731-1-git-send-email-hkchu@google.com>
	<1300351330.10164.712.camel@edumazet-laptop>
	<AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40824 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755473Ab1CQVUf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 17:20:35 -0400
In-Reply-To: <AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Mar 2011 13:16:15 -0700
Jerry Chu <hkchu@google.com> wrote:

> Eric, thanks for the prompt feedback.
>=20
> On Thu, Mar 17, 2011 at 1:42 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le jeudi 17 mars 2011 =C3=A0 01:06 -0700, H.K. Jerry Chu a =C3=A9cr=
it :
> >> From: Jerry Chu <hkchu@google.com>
> >>
> >> This patch add a number of very useful counters/stats (defined in
> >> tcp_stats.h) to help diagnosing TCP related problems.
> >>
> >> create_time =C2=A0 =C2=A0 - when the connection was created (in ji=
ffies)
> >> total_inbytes =C2=A0 - total inbytes as consumed by the receiving =
apps.
> >> total_outbytes =C2=A0- total outbytes sent down from the transmitt=
ing apps.
> >>
> >> total_outdatasegs - total data carrying segments sent so far, incl=
uding
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 retransmitted one=
s.
> >>
> >> total_xmit =C2=A0 =C2=A0 =C2=A0- total accumulated time (usecs) wh=
en the connection
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 has something to =
send.
> >>
> >> total_retrans_time - total time (usecs, accumulated) the connectio=
n
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spends trying to =
recover lost packets. For each
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 loss event the ti=
me is measured from the lost packet
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 was first sent ti=
ll the retransmitted packet was
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eventually ack'ed=
=2E
> >>
> >> total_cwnd_limit - total time (usecs, excluding time spent on loss
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 recovery) the xmi=
t is stopped due to cwnd limited
> >>
> >> total_swnd_limit - total time (usecs) theconnection is swnd limite=
d
> >>
> >> The following two counters are for listeners only:
> >>
> >> accepted_reqs =C2=A0 - total # of accepted connection requests.
> >> listen_drops =C2=A0 =C2=A0- total # of dropped SYN reqs (SYN cooki=
es excluded) due
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 to listener's que=
ue overflow.
> >>
> >> total_retrans_time/total_retrans ratio gives a rough picture of ho=
w
> >> quickly in average the connection can recover from a pkt loss. E.g=
=2E,
> >> when the network is more congested, or the traffic contains mainly
> >> smaller RPC where tail drop often requires RTO to recover,
> >> the total_retrans_time/total_retrans ratio tends to be higher.
> >>
> >> Currently the new counters/stats are exported through /proc/net/tc=
p.
> >
> > Please dont. Use iproute2 instead.
> >
> >> Some simple, abbreviated field names have been added to the output=
 of
> >> /proc/net/tcp in order to allow backward/forward compatibility in =
the
> >> future. Obviously the new counters/stats can also be easily export=
ed
> >> through other APIs.
> >>
> >
> > /proc/net/tcp is legacy. You should touch it eventually, but after
> > "other APIS" are done. It was the old way (quick but a bit ugly)
>=20
> Understood. /proc/net/tcp is a much more expedient way of exporting t=
hese
> counters because it doesn't requires any additional, special tool to =
read it,
> unless other APIs (e.g., netlink). Note that backward compatibility t=
o
> /proc/net/tcp has been ensured by adding field names in the heading.
>=20
> >
> >
> >
> >> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
> >> ---
> >> =C2=A0include/linux/ktime.h =C2=A0 =C2=A0| =C2=A0 =C2=A03 ++
> >> =C2=A0include/linux/tcp.h =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 +
> >> =C2=A0include/net/tcp_stats.h =C2=A0| =C2=A0 65 ++++++++++++++++++=
++++++++++++++++++++++++++++
> >> =C2=A0net/ipv4/tcp.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 3=
0 ++++++++++++++++++---
> >> =C2=A0net/ipv4/tcp_input.c =C2=A0 =C2=A0 | =C2=A0 13 +++++++++
> >> =C2=A0net/ipv4/tcp_ipv4.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 41 ++++++++=
++++++++++++++++++---
> >> =C2=A0net/ipv4/tcp_minisocks.c | =C2=A0 =C2=A09 ++++++
> >> =C2=A0net/ipv4/tcp_output.c =C2=A0 =C2=A0| =C2=A0 47 +++++++++++++=
++++++++++++++++++--
> >> =C2=A0net/ipv6/tcp_ipv6.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A08 +++=
++
> >> =C2=A09 files changed, 206 insertions(+), 11 deletions(-)
> >> =C2=A0create mode 100644 include/net/tcp_stats.h
> >>
> >> diff --git a/include/linux/ktime.h b/include/linux/ktime.h
> >> index e1ceaa9..e60e758 100644
> >> --- a/include/linux/ktime.h
> >> +++ b/include/linux/ktime.h
> >> @@ -333,6 +333,9 @@ extern void ktime_get_ts(struct timespec *ts);
> >> =C2=A0/* Get the real (wall-) time in timespec format: */
> >> =C2=A0#define ktime_get_real_ts(ts) =C2=A0 =C2=A0 =C2=A0 =C2=A0get=
nstimeofday(ts)
> >
> > Hmm, this kind of changes are out of netdev scope and should be avo=
ided
>=20
> Ok. (It was moved out of tcp_stats.h only at the last minute.)
>=20
> >
> >>
> >> +#define ktime_since(a) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ktime_to_us(ktime_sub(ktime_get(), (a)))
> >
> > us are implied in ktime_since() ? thats strange.
>=20
> Ok.
>=20
> >
> >> +#define ktime_zero(a) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0ktime_equal((a), ktime_set(0, 0))
> >
> > ktime_zero() sounds like : "give me zero time" or "clear the ktime
> > field".
>=20
> Yes I actually have been flip-flopping on the name...
>=20
> >
> >> +
> >> =C2=A0static inline ktime_t ns_to_ktime(u64 ns)
> >> =C2=A0{
> >> =C2=A0 =C2=A0 =C2=A0 static const ktime_t ktime_zero =3D { .tv64 =3D=
 0 };
> >> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> >> index e64f4c6..ea5cb5d 100644
> >> --- a/include/linux/tcp.h
> >> +++ b/include/linux/tcp.h
> >> @@ -460,6 +460,7 @@ struct tcp_sock {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0* contains related tcp_cookie_transacti=
ons fields.
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> >> =C2=A0 =C2=A0 =C2=A0 struct tcp_cookie_values =C2=A0*cookie_values=
;
> >> + =C2=A0 =C2=A0 struct tcp_stats =C2=A0 =C2=A0 =C2=A0 =C2=A0*conn_=
stats;
> >> =C2=A0};
> >
> > Really, using separate cache lines to store some stats is expensive=
=2E
> > You should add counters in existing structure, to avoid additional =
cache
> > line dirties. Carefully placing stats in already dirtied cache line=
s.
>=20
> This was how it was done initially but then we wanted to allow future
> extension to include possibly a lot more counters, something like Web=
100
> (RFC4898). For the latter the memory/performance hit will likely requ=
ire
> a config option, and a separate structure will make this easier. Does=
 it
> make sense?
>=20
> >
> > You also should use native ktime_t infrastructure, to make the math=
s
> > really fast in fast path.
> >
> > Only when stats are to be returned to user, you'll have to convert =
the
> > native timestamps to user exportable ones.
>=20
> Good point! Will do. (I mistakenly thought ktime_t is a larger struct=
ure.)
>=20
> >
> > Quite frankly, using u64 fields allow nanosec resolution.
>=20
> I wish to use less bits because the final report only needs ms or eve=
n
> sec resolution but the intermediate computation needs to capture usec
> resolution.
>=20
> >
> > BTW, we probably could 'export' sk->sk_drops for TCP, like we do fo=
r
> > UDP.
>=20
> There are many other potentially useful counters/stats (spurious_retr=
ans,
> min_rtt, total_rto,...) but there is a tradeoff against memory/perfor=
mance hit
> so for the first round I'm focusing on what i feel is the most useful=
 set.
>=20
> Thanks,
>=20
> Jerry

These stats are best added via netlink, the tool ss already prints lots
of similar stats. Look at INET_DIAG_INFO and the output of:
 ss -i -t






--=20
