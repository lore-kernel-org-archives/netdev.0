From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connection close
 threshold as a time value.
Date: Tue, 01 Sep 2009 13:28:20 +0200
Message-ID: <4A9D0554.1010508@tvk.rwth-aachen.de>
References: <4A950B82.1070807@tvk.rwth-aachen.de>
 <alpine.DEB.2.00.0908311555230.29341@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:46434 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753178AbZIAL2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 07:28:24 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KPA00K8BIJAK390@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 01 Sep 2009 13:28:22 +0200 (CEST)
In-reply-to: <alpine.DEB.2.00.0908311555230.29341@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen schrieb:
> On Wed, 26 Aug 2009, Damian Lukowski wrote:
>=20
>> RFC 1122 specifies two threshold values R1 and R2 for connection
>> timeouts,
>> which may represent a number of allowed retransmissions or a timeout
>> value.
>> Currently linux uses sysctl_tcp_retries{1,2} to specify the threshol=
ds
>> in number of allowed retransmissions.
>>
>> For any desired threshold R2 (by means of time) one can specify
>> tcp_retries2
>> (by means of number of retransmissions) such that TCP will not time =
out
>> earlier than R2. This is the case, because the RTO schedule follows =
a
>> fixed
>> pattern, namely exponential backoff.
>>
>> However, the RTO behaviour is not predictable any more if RTO backof=
fs
>> can be
>> reverted, as it is the case in the draft
>> "Make TCP more Robust to Long Connectivity Disruptions"
>> (http://tools.ietf.org/html/draft-zimmermann-tcp-lcd).
>>
>> In the worst case TCP would time out a connection after 3.2 seconds,
>> if the
>> initial RTO equaled MIN_RTO and each backoff has been reverted.
>>
>> This patch introduces a function retransmits_timed_out(N),
>> which calculates the timeout of a TCP connection, assuming an initia=
l
>> RTO of MIN_RTO and N unsuccessful, exponentially backed-off
>> retransmissions.
>>
>> Whenever timeout decisions are made by comparing the retransmission
>> counter
>> to some value N, this function can be used, instead.
>>
>> The meaning of tcp_retries2 will be changed, as many more RTO
>> retransmissions
>> can occur than the value indicates. However, it yields a timeout whi=
ch is
>> similar to the one of an unpatched, exponentially backing off TCP in
>> the same
>> scenario. As no application could rely on an RTO greater than MIN_RT=
O,
>> there
>> should be no risk of a regression.
>>
>> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
>> ---
>> include/net/tcp.h    |   18 ++++++++++++++++++
>> net/ipv4/tcp_timer.c |   11 +++++++----
>> 2 files changed, 25 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>> index c35b329..17d1a88 100644
>> --- a/include/net/tcp.h
>> +++ b/include/net/tcp.h
>> @@ -1247,6 +1247,24 @@ static inline struct sk_buff
>> *tcp_write_queue_prev(struct sock *sk, struct sk_bu
>> #define tcp_for_write_queue_from_safe(skb, tmp, sk)            \
>>     skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
>>
>=20
> IMHO, having an introductionary comment here wouldn't hurt as this is=
 a
> bit tricky thing we end up doing here :-).
>=20
>> +static inline bool retransmits_timed_out(const struct sock *sk,
>> +                     unsigned int boundary)
>> +{
>> +    int limit, K;
>=20
> An empty line after local variables. Just rename the K to max_backoff=
 or
> something like that (more meaningful).
>=20
>> +    if (!inet_csk(sk)->icsk_retransmits)
>> +        return false;
>> +
>> +    K =3D ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
>> +
>> +    if (boundary <=3D K)
>> +        limit =3D ((2 << boundary) - 1) * TCP_RTO_MIN;
>> +    else
>> +        limit =3D ((2 << K) - 1) * TCP_RTO_MIN +
>> +            (boundary - K) * TCP_RTO_MAX;
>> +
>> +    return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >=3D limit;
>> +}
>> +
>> static inline struct sk_buff *tcp_send_head(struct sock *sk)
>> {
>>     return sk->sk_send_head;
>> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
>> index a3ba494..2972d7b 100644
>> --- a/net/ipv4/tcp_timer.c
>> +++ b/net/ipv4/tcp_timer.c
>> @@ -137,13 +137,14 @@ static int tcp_write_timeout(struct sock *sk)
>> {
>>     struct inet_connection_sock *icsk =3D inet_csk(sk);
>>     int retry_until;
>> +    bool do_reset;
>>
>>     if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
>>         if (icsk->icsk_retransmits)
>>             dst_negative_advice(&sk->sk_dst_cache);
>>         retry_until =3D icsk->icsk_syn_retries ? : sysctl_tcp_syn_re=
tries;
>>     } else {
>> -        if (icsk->icsk_retransmits >=3D sysctl_tcp_retries1) {
>> +        if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
>>             /* Black hole detection */
>>             tcp_mtu_probing(icsk, sk);
>>
>> @@ -155,13 +156,15 @@ static int tcp_write_timeout(struct sock *sk)
>>             const int alive =3D (icsk->icsk_rto < TCP_RTO_MAX);
>>
>>             retry_until =3D tcp_orphan_retries(sk, alive);
>> +            do_reset =3D alive ||
>> +                   !retransmits_timed_out(sk, retry_until);
>>
>> -            if (tcp_out_of_resources(sk, alive ||
>> icsk->icsk_retransmits < retry_until))
>> +            if (tcp_out_of_resources(sk, do_reset))
>>                 return 1;
>>         }
>>     }
>>
>> -    if (icsk->icsk_retransmits >=3D retry_until) {
>> +    if (retransmits_timed_out(sk, retry_until)) {
>>         /* Has it gone just too far? */
>>         tcp_write_err(sk);
>>         return 1;
>> @@ -385,7 +388,7 @@ void tcp_retransmit_timer(struct sock *sk)
>> out_reset_timer:
>>     icsk->icsk_rto =3D min(icsk->icsk_rto << 1, TCP_RTO_MAX);
>>     inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto,
>> TCP_RTO_MAX);
>> -    if (icsk->icsk_retransmits > sysctl_tcp_retries1)
>> +    if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
>>         __sk_dst_reset(sk);
>>
>> out:;
>=20
> The implementation itself seems ok. I was a bit concerned that the us=
e
> of retrans_stamp would result in considerably different behavior than
> the use of icsk_retransmits but it seems I was wrong.
>=20
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> I'm fine with this approach as no matter what we would do the previou=
s
> approach just isn't fitting the new model that breaks the assumptions
> behind the previous model. I don't expect the change in the timing to=
 be
> significant for anybody unless one did copy our code exactly somewher=
e
> (including rtt calculation). ...but if somebody has some objections i=
n
> this, please speak up! After all, it will change how the sysctl behav=
es.
>=20
> Perhaps we should mention this artificial timing change in ip-sysctl.=
txt
> too...?
>=20
> It would be worth to do a trivial pull-the-plug testing comparing thi=
s
> and the previous approach in the rto < TCP_RTO_MIN region without any
> icmps to verify that this didn't change the timing a bit, afaict, it
> shouldn't (If you didn't do that already). Just to be on very sure gr=
ounds.

Hi,
thanks for reviewing all the patches.
Which region do you mean exactly? I mean, rto < TCP_RTO_MIN should be
impossible by definition, shouldn't it?
However, there are differences between new and old timing, which maybe
should be discussed. The new timeout values can deviate from the old=20
approach by up to the value of the last actual RTO. Consider following:

retries2 is set to 15 and MIN_RTO/MAX_RTO are 0.2 and 120 seconds,
respectively. retrans_timed_out() calculates 924.6 seconds as timeout,
regardless of the actual RTO. Assume, that rtt measurement calculates
0.4 seconds as RTO before connectivity breaks.
An unpatched TCP - as well as patched TCP without ICMPs - will do the
standard backoff procedure and fire it's 15th retransmission after 924.=
4
seconds, i.e. 0.2 seconds before the calculated timeout of 924.6 second=
s.

Then, patched TCP will wait for the next RTO, before checking again if =
the
timeout expired - and will finally time out 119.8 seconds later
than calculated. However, unpatched TCP will also wait until the 16th R=
TO
(924.4 + 120 seconds) and then time out. So in this case, the effective
timeouts for unpatched and patched TCP without ICMPs are the same, thou=
gh
not intended by retransmits_timed_out().

On the other hand, when ICMPs will revert backoffs, patched TCP will
time out somewhere nearby the calculated value.

So one can say the following:
Since retransmits_timed_out() does always underestimate the effective t=
imeout
of an unpatched TCP (it assumes initial RTO =3D=3D MIN_RTO), the higher=
 effective
timeout of the patched TCP (compared to the calculated) is not too bad,=
 if
compared to the effective unpatched timeout, instead.
When consecutive RTOs remain small due to reverts, the effective timeou=
t
will be closer to the calculated one.

I have made a simple test with a netem delay of 30ms at the sender,
and retries2 set to 6:
Unpatched TCP times out after ~29.7 seconds,
patched TCP without ICMPs also after ~29.7 seconds,
and patched TCP with ICMPs after ~25.6 seconds.

The same scenario but with netem delay of 150ms:
Unpatched TCP times out after ~46 seconds,
patched TCP without ICMPs after ~45 seconds,
and patched TCP with ICMPs after ~25.9 seconds.

Anyway, what is the procedure for further updates? As David has applied
the current patches, I assume that I should post a new series of two
subpatches; one concerning your suggestions and the second concerning
the ip-sysctl.txt update?

Best regards
 Damian

