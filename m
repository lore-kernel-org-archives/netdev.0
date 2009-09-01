From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connection close
 threshold as a time value.
Date: Tue, 01 Sep 2009 14:25:18 +0200
Message-ID: <4A9D12AE.8050109@gmail.com>
References: <4A950B82.1070807@tvk.rwth-aachen.de> <4A9BD7AB.7060207@gmail.com> <4A9D0A67.6070000@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39528 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754320AbZIAMZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 08:25:18 -0400
In-Reply-To: <4A9D0A67.6070000@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Damian Lukowski a =E9crit :
> Eric Dumazet schrieb:
>> Damian Lukowski a =E9crit :
>>> RFC 1122 specifies two threshold values R1 and R2 for connection ti=
meouts,
>>> which may represent a number of allowed retransmissions or a timeou=
t value.
>>> Currently linux uses sysctl_tcp_retries{1,2} to specify the thresho=
lds
>>> in number of allowed retransmissions.
>>>
>>> For any desired threshold R2 (by means of time) one can specify tcp=
_retries2
>>> (by means of number of retransmissions) such that TCP will not time=
 out
>>> earlier than R2. This is the case, because the RTO schedule follows=
 a fixed
>>> pattern, namely exponential backoff.
>>>
>>> However, the RTO behaviour is not predictable any more if RTO backo=
ffs can be
>>> reverted, as it is the case in the draft
>>> "Make TCP more Robust to Long Connectivity Disruptions"
>>> (http://tools.ietf.org/html/draft-zimmermann-tcp-lcd).
>>>
>>> In the worst case TCP would time out a connection after 3.2 seconds=
, if the
>>> initial RTO equaled MIN_RTO and each backoff has been reverted.
>>>
>>> This patch introduces a function retransmits_timed_out(N),
>>> which calculates the timeout of a TCP connection, assuming an initi=
al
>>> RTO of MIN_RTO and N unsuccessful, exponentially backed-off retrans=
missions.
>>>
>>> Whenever timeout decisions are made by comparing the retransmission=
 counter
>>> to some value N, this function can be used, instead.
>>>
>>> The meaning of tcp_retries2 will be changed, as many more RTO retra=
nsmissions
>>> can occur than the value indicates. However, it yields a timeout wh=
ich is
>>> similar to the one of an unpatched, exponentially backing off TCP i=
n the same
>>> scenario. As no application could rely on an RTO greater than MIN_R=
TO, there
>>> should be no risk of a regression.
>>>
>>> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
>>> ---
>>>  include/net/tcp.h    |   18 ++++++++++++++++++
>>>  net/ipv4/tcp_timer.c |   11 +++++++----
>>>  2 files changed, 25 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>>> index c35b329..17d1a88 100644
>>> --- a/include/net/tcp.h
>>> +++ b/include/net/tcp.h
>>> @@ -1247,6 +1247,24 @@ static inline struct sk_buff *tcp_write_queu=
e_prev(struct sock *sk, struct sk_bu
>>>  #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
>>>  	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
>>> =20
>>> +static inline bool retransmits_timed_out(const struct sock *sk,
>>> +					 unsigned int boundary)
>>> +{
>>> +	int limit, K;
>>> +	if (!inet_csk(sk)->icsk_retransmits)
>>> +		return false;
>>> +
>>> +	K =3D ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
>>> +
>>> +	if (boundary <=3D K)
>>> +		limit =3D ((2 << boundary) - 1) * TCP_RTO_MIN;
>>> +	else
>>> +		limit =3D ((2 << K) - 1) * TCP_RTO_MIN +
>>> +			(boundary - K) * TCP_RTO_MAX;
>> Doing this computation might allow us to respect RFC 1122 here :
>> =20
>> "The value of R2 SHOULD correspond to at least 100 seconds."
>>
>> adding a third parameter to retransmits_timed_out(), min_limit,
>> being 100*HZ if sysctl_tcp_retries2 was used...
>>
>> limit =3D min(min_limit, limit);
>=20
> Hi.
> Hm, with this restriction, we would make it a MUST instead of a SHOUL=
D.
> The current approach does also allow retries2 values, which can yield
> lower timeouts than 100 seconds.
> I could implement the min_timeout, but in my opinion, the 100 seconds
> shouldn't be enforced. We could make a patch later, which introduces =
a
> lower limit to the sysctl, so the user gets feedback, if he tries to =
adjust
> the limit below the recommended 100 seconds, or something like that.
>=20

=46air enough, this 100 seconds limit is only a hint, not an enforcemen=
t.
