From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis purpose.
Date: Thu, 17 Mar 2011 21:33:50 -0700
Message-ID: <AANLkTi=W-=8zhQpfJZ=DrDyUCwrT==5JkwRBiHaDkVXK@mail.gmail.com>
References: <1300349189-2731-1-git-send-email-hkchu@google.com>
	<1300351330.10164.712.camel@edumazet-laptop>
	<AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>
	<20110317142030.62af785a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:1471 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268Ab1CREdx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 00:33:53 -0400
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p2I4XpGi012722
	for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 21:33:51 -0700
Received: from yxd5 (yxd5.prod.google.com [10.190.1.197])
	by hpaq11.eem.corp.google.com with ESMTP id p2I4XNJR000471
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 21:33:50 -0700
Received: by yxd5 with SMTP id 5so1867262yxd.35
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 21:33:50 -0700 (PDT)
In-Reply-To: <20110317142030.62af785a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2011 at 2:20 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Thu, 17 Mar 2011 13:16:15 -0700
> Jerry Chu <hkchu@google.com> wrote:
>
>> Eric, thanks for the prompt feedback.
>>
>> On Thu, Mar 17, 2011 at 1:42 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> > Le jeudi 17 mars 2011 =E0 01:06 -0700, H.K. Jerry Chu a =E9crit :
>> >> From: Jerry Chu <hkchu@google.com>
>> >>
>> >> This patch add a number of very useful counters/stats (defined in
>> >> tcp_stats.h) to help diagnosing TCP related problems.
>> >>
>> >> create_time =A0 =A0 - when the connection was created (in jiffies=
)
>> >> total_inbytes =A0 - total inbytes as consumed by the receiving ap=
ps.
>> >> total_outbytes =A0- total outbytes sent down from the transmittin=
g apps.
>> >>
>> >> total_outdatasegs - total data carrying segments sent so far, inc=
luding
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 retransmitted ones.
>> >>
>> >> total_xmit =A0 =A0 =A0- total accumulated time (usecs) when the c=
onnection
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 has something to send.
>> >>
>> >> total_retrans_time - total time (usecs, accumulated) the connecti=
on
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 spends trying to recover lost packets=
=2E For each
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 loss event the time is measured from =
the lost packet
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 was first sent till the retransmitted=
 packet was
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 eventually ack'ed.
>> >>
>> >> total_cwnd_limit - total time (usecs, excluding time spent on los=
s
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 recovery) the xmit is stopped due to =
cwnd limited
>> >>
>> >> total_swnd_limit - total time (usecs) theconnection is swnd limit=
ed
>> >>
>> >> The following two counters are for listeners only:
>> >>
>> >> accepted_reqs =A0 - total # of accepted connection requests.
>> >> listen_drops =A0 =A0- total # of dropped SYN reqs (SYN cookies ex=
cluded) due
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 to listener's queue overflow.
>> >>
>> >> total_retrans_time/total_retrans ratio gives a rough picture of h=
ow
>> >> quickly in average the connection can recover from a pkt loss. E.=
g.,
>> >> when the network is more congested, or the traffic contains mainl=
y
>> >> smaller RPC where tail drop often requires RTO to recover,
>> >> the total_retrans_time/total_retrans ratio tends to be higher.
>> >>
>> >> Currently the new counters/stats are exported through /proc/net/t=
cp.
>> >
>> > Please dont. Use iproute2 instead.
>> >
>> >> Some simple, abbreviated field names have been added to the outpu=
t of
>> >> /proc/net/tcp in order to allow backward/forward compatibility in=
 the
>> >> future. Obviously the new counters/stats can also be easily expor=
ted
>> >> through other APIs.
>> >>
>> >
>> > /proc/net/tcp is legacy. You should touch it eventually, but after
>> > "other APIS" are done. It was the old way (quick but a bit ugly)
>>
>> Understood. /proc/net/tcp is a much more expedient way of exporting =
these
>> counters because it doesn't requires any additional, special tool to=
 read it,
>> unless other APIs (e.g., netlink). Note that backward compatibility =
to
>> /proc/net/tcp has been ensured by adding field names in the heading.
>>
>> >
>> >
>> >
>> >> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
>> >> ---
>> >> =A0include/linux/ktime.h =A0 =A0| =A0 =A03 ++
>> >> =A0include/linux/tcp.h =A0 =A0 =A0| =A0 =A01 +
>> >> =A0include/net/tcp_stats.h =A0| =A0 65 ++++++++++++++++++++++++++=
++++++++++++++++++++
>> >> =A0net/ipv4/tcp.c =A0 =A0 =A0 =A0 =A0 | =A0 30 ++++++++++++++++++=
---
>> >> =A0net/ipv4/tcp_input.c =A0 =A0 | =A0 13 +++++++++
>> >> =A0net/ipv4/tcp_ipv4.c =A0 =A0 =A0| =A0 41 ++++++++++++++++++++++=
++++---
>> >> =A0net/ipv4/tcp_minisocks.c | =A0 =A09 ++++++
>> >> =A0net/ipv4/tcp_output.c =A0 =A0| =A0 47 ++++++++++++++++++++++++=
+++++++--
>> >> =A0net/ipv6/tcp_ipv6.c =A0 =A0 =A0| =A0 =A08 +++++
>> >> =A09 files changed, 206 insertions(+), 11 deletions(-)
>> >> =A0create mode 100644 include/net/tcp_stats.h
>> >>
>> >> diff --git a/include/linux/ktime.h b/include/linux/ktime.h
>> >> index e1ceaa9..e60e758 100644
>> >> --- a/include/linux/ktime.h
>> >> +++ b/include/linux/ktime.h
>> >> @@ -333,6 +333,9 @@ extern void ktime_get_ts(struct timespec *ts)=
;
>> >> =A0/* Get the real (wall-) time in timespec format: */
>> >> =A0#define ktime_get_real_ts(ts) =A0 =A0 =A0 =A0getnstimeofday(ts=
)
>> >
>> > Hmm, this kind of changes are out of netdev scope and should be av=
oided
>>
>> Ok. (It was moved out of tcp_stats.h only at the last minute.)
>>
>> >
>> >>
>> >> +#define ktime_since(a) =A0 =A0 =A0 =A0 =A0 =A0 =A0 ktime_to_us(k=
time_sub(ktime_get(), (a)))
>> >
>> > us are implied in ktime_since() ? thats strange.
>>
>> Ok.
>>
>> >
>> >> +#define ktime_zero(a) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ktime_equal=
((a), ktime_set(0, 0))
>> >
>> > ktime_zero() sounds like : "give me zero time" or "clear the ktime
>> > field".
>>
>> Yes I actually have been flip-flopping on the name...
>>
>> >
>> >> +
>> >> =A0static inline ktime_t ns_to_ktime(u64 ns)
>> >> =A0{
>> >> =A0 =A0 =A0 static const ktime_t ktime_zero =3D { .tv64 =3D 0 };
>> >> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
>> >> index e64f4c6..ea5cb5d 100644
>> >> --- a/include/linux/tcp.h
>> >> +++ b/include/linux/tcp.h
>> >> @@ -460,6 +460,7 @@ struct tcp_sock {
>> >> =A0 =A0 =A0 =A0* contains related tcp_cookie_transactions fields.
>> >> =A0 =A0 =A0 =A0*/
>> >> =A0 =A0 =A0 struct tcp_cookie_values =A0*cookie_values;
>> >> + =A0 =A0 struct tcp_stats =A0 =A0 =A0 =A0*conn_stats;
>> >> =A0};
>> >
>> > Really, using separate cache lines to store some stats is expensiv=
e.
>> > You should add counters in existing structure, to avoid additional=
 cache
>> > line dirties. Carefully placing stats in already dirtied cache lin=
es.
>>
>> This was how it was done initially but then we wanted to allow futur=
e
>> extension to include possibly a lot more counters, something like We=
b100
>> (RFC4898). For the latter the memory/performance hit will likely req=
uire
>> a config option, and a separate structure will make this easier. Doe=
s it
>> make sense?
>>
>> >
>> > You also should use native ktime_t infrastructure, to make the mat=
hs
>> > really fast in fast path.
>> >
>> > Only when stats are to be returned to user, you'll have to convert=
 the
>> > native timestamps to user exportable ones.
>>
>> Good point! Will do. (I mistakenly thought ktime_t is a larger struc=
ture.)
>>
>> >
>> > Quite frankly, using u64 fields allow nanosec resolution.
>>
>> I wish to use less bits because the final report only needs ms or ev=
en
>> sec resolution but the intermediate computation needs to capture use=
c
>> resolution.
>>
>> >
>> > BTW, we probably could 'export' sk->sk_drops for TCP, like we do f=
or
>> > UDP.
>>
>> There are many other potentially useful counters/stats (spurious_ret=
rans,
>> min_rtt, total_rto,...) but there is a tradeoff against memory/perfo=
rmance hit
>> so for the first round I'm focusing on what i feel is the most usefu=
l set.
>>
>> Thanks,
>>
>> Jerry
>
> These stats are best added via netlink, the tool ss already prints lo=
ts
> of similar stats. Look at INET_DIAG_INFO and the output of:
> =A0ss -i -t

Yes I'm familiar with ss and how inet_csk_diag_fill() calls into
tcp_diag_get_info(),..., etc. Like I mentioned previously the netlink
interface
requires a new version of reader app (e.g., ss) to ship every time a ne=
w
counter is added and exported by the kernel, whereas /proc/net/tcp does
not have such a problem.

Anyway I can add a INET_DIAG_INFO_EXT of some sort to netlink in
addition to /proc/net/tcp. That's easy to do.

Thanks,

Jerry

>
>
>
>
>
>
> --
>
