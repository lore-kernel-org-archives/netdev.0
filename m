From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis purpose.
Date: Thu, 17 Mar 2011 13:16:15 -0700
Message-ID: <AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>
References: <1300349189-2731-1-git-send-email-hkchu@google.com>
	<1300351330.10164.712.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:11251 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955Ab1CQUQS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 16:16:18 -0400
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p2HKGHOG021143
	for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 13:16:17 -0700
Received: from yic15 (yic15.prod.google.com [10.243.65.143])
	by kpbe11.cbf.corp.google.com with ESMTP id p2HKGCIx003291
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 13:16:16 -0700
Received: by yic15 with SMTP id 15so1381277yic.36
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 13:16:16 -0700 (PDT)
In-Reply-To: <1300351330.10164.712.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric, thanks for the prompt feedback.

On Thu, Mar 17, 2011 at 1:42 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 17 mars 2011 =E0 01:06 -0700, H.K. Jerry Chu a =E9crit :
>> From: Jerry Chu <hkchu@google.com>
>>
>> This patch add a number of very useful counters/stats (defined in
>> tcp_stats.h) to help diagnosing TCP related problems.
>>
>> create_time =A0 =A0 - when the connection was created (in jiffies)
>> total_inbytes =A0 - total inbytes as consumed by the receiving apps.
>> total_outbytes =A0- total outbytes sent down from the transmitting a=
pps.
>>
>> total_outdatasegs - total data carrying segments sent so far, includ=
ing
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 retransmitted ones.
>>
>> total_xmit =A0 =A0 =A0- total accumulated time (usecs) when the conn=
ection
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 has something to send.
>>
>> total_retrans_time - total time (usecs, accumulated) the connection
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 spends trying to recover lost packets. F=
or each
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 loss event the time is measured from the=
 lost packet
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 was first sent till the retransmitted pa=
cket was
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 eventually ack'ed.
>>
>> total_cwnd_limit - total time (usecs, excluding time spent on loss
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 recovery) the xmit is stopped due to cwn=
d limited
>>
>> total_swnd_limit - total time (usecs) theconnection is swnd limited
>>
>> The following two counters are for listeners only:
>>
>> accepted_reqs =A0 - total # of accepted connection requests.
>> listen_drops =A0 =A0- total # of dropped SYN reqs (SYN cookies exclu=
ded) due
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 to listener's queue overflow.
>>
>> total_retrans_time/total_retrans ratio gives a rough picture of how
>> quickly in average the connection can recover from a pkt loss. E.g.,
>> when the network is more congested, or the traffic contains mainly
>> smaller RPC where tail drop often requires RTO to recover,
>> the total_retrans_time/total_retrans ratio tends to be higher.
>>
>> Currently the new counters/stats are exported through /proc/net/tcp.
>
> Please dont. Use iproute2 instead.
>
>> Some simple, abbreviated field names have been added to the output o=
f
>> /proc/net/tcp in order to allow backward/forward compatibility in th=
e
>> future. Obviously the new counters/stats can also be easily exported
>> through other APIs.
>>
>
> /proc/net/tcp is legacy. You should touch it eventually, but after
> "other APIS" are done. It was the old way (quick but a bit ugly)

Understood. /proc/net/tcp is a much more expedient way of exporting the=
se
counters because it doesn't requires any additional, special tool to re=
ad it,
unless other APIs (e.g., netlink). Note that backward compatibility to
/proc/net/tcp has been ensured by adding field names in the heading.

>
>
>
>> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
>> ---
>> =A0include/linux/ktime.h =A0 =A0| =A0 =A03 ++
>> =A0include/linux/tcp.h =A0 =A0 =A0| =A0 =A01 +
>> =A0include/net/tcp_stats.h =A0| =A0 65 +++++++++++++++++++++++++++++=
+++++++++++++++++
>> =A0net/ipv4/tcp.c =A0 =A0 =A0 =A0 =A0 | =A0 30 ++++++++++++++++++---
>> =A0net/ipv4/tcp_input.c =A0 =A0 | =A0 13 +++++++++
>> =A0net/ipv4/tcp_ipv4.c =A0 =A0 =A0| =A0 41 +++++++++++++++++++++++++=
+---
>> =A0net/ipv4/tcp_minisocks.c | =A0 =A09 ++++++
>> =A0net/ipv4/tcp_output.c =A0 =A0| =A0 47 +++++++++++++++++++++++++++=
++++--
>> =A0net/ipv6/tcp_ipv6.c =A0 =A0 =A0| =A0 =A08 +++++
>> =A09 files changed, 206 insertions(+), 11 deletions(-)
>> =A0create mode 100644 include/net/tcp_stats.h
>>
>> diff --git a/include/linux/ktime.h b/include/linux/ktime.h
>> index e1ceaa9..e60e758 100644
>> --- a/include/linux/ktime.h
>> +++ b/include/linux/ktime.h
>> @@ -333,6 +333,9 @@ extern void ktime_get_ts(struct timespec *ts);
>> =A0/* Get the real (wall-) time in timespec format: */
>> =A0#define ktime_get_real_ts(ts) =A0 =A0 =A0 =A0getnstimeofday(ts)
>
> Hmm, this kind of changes are out of netdev scope and should be avoid=
ed

Ok. (It was moved out of tcp_stats.h only at the last minute.)

>
>>
>> +#define ktime_since(a) =A0 =A0 =A0 =A0 =A0 =A0 =A0 ktime_to_us(ktim=
e_sub(ktime_get(), (a)))
>
> us are implied in ktime_since() ? thats strange.

Ok.

>
>> +#define ktime_zero(a) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ktime_equal((a=
), ktime_set(0, 0))
>
> ktime_zero() sounds like : "give me zero time" or "clear the ktime
> field".

Yes I actually have been flip-flopping on the name...

>
>> +
>> =A0static inline ktime_t ns_to_ktime(u64 ns)
>> =A0{
>> =A0 =A0 =A0 static const ktime_t ktime_zero =3D { .tv64 =3D 0 };
>> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
>> index e64f4c6..ea5cb5d 100644
>> --- a/include/linux/tcp.h
>> +++ b/include/linux/tcp.h
>> @@ -460,6 +460,7 @@ struct tcp_sock {
>> =A0 =A0 =A0 =A0* contains related tcp_cookie_transactions fields.
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 struct tcp_cookie_values =A0*cookie_values;
>> + =A0 =A0 struct tcp_stats =A0 =A0 =A0 =A0*conn_stats;
>> =A0};
>
> Really, using separate cache lines to store some stats is expensive.
> You should add counters in existing structure, to avoid additional ca=
che
> line dirties. Carefully placing stats in already dirtied cache lines.

This was how it was done initially but then we wanted to allow future
extension to include possibly a lot more counters, something like Web10=
0
(RFC4898). For the latter the memory/performance hit will likely requir=
e
a config option, and a separate structure will make this easier. Does i=
t
make sense?

>
> You also should use native ktime_t infrastructure, to make the maths
> really fast in fast path.
>
> Only when stats are to be returned to user, you'll have to convert th=
e
> native timestamps to user exportable ones.

Good point! Will do. (I mistakenly thought ktime_t is a larger structur=
e.)

>
> Quite frankly, using u64 fields allow nanosec resolution.

I wish to use less bits because the final report only needs ms or even
sec resolution but the intermediate computation needs to capture usec
resolution.

>
> BTW, we probably could 'export' sk->sk_drops for TCP, like we do for
> UDP.

There are many other potentially useful counters/stats (spurious_retran=
s,
min_rtt, total_rto,...) but there is a tradeoff against memory/performa=
nce hit
so for the first round I'm focusing on what i feel is the most useful s=
et.

Thanks,

Jerry

>
>
>
>
