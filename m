From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connection
 close threshold as a time value.
Date: Tue, 1 Sep 2009 16:23:21 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0909011615130.29341@wel-95.cs.helsinki.fi>
References: <4A950B82.1070807@tvk.rwth-aachen.de> <4A9BD7AB.7060207@gmail.com> <4A9D0A67.6070000@tvk.rwth-aachen.de> <4A9D12AE.8050109@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1006983804-1251811401=:29341"
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33943 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754704AbZIANXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 09:23:21 -0400
In-Reply-To: <4A9D12AE.8050109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1006983804-1251811401=:29341
Content-Type: TEXT/PLAIN; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 8BIT

On Tue, 1 Sep 2009, Eric Dumazet wrote:

> Damian Lukowski a écrit :
>> Eric Dumazet schrieb:
>>> Damian Lukowski a écrit :
>>>> RFC 1122 specifies two threshold values R1 and R2 for connection timeouts,
>>>> which may represent a number of allowed retransmissions or a timeout value.
>>>> Currently linux uses sysctl_tcp_retries{1,2} to specify the thresholds
>>>> in number of allowed retransmissions.
>>>>
>>>> For any desired threshold R2 (by means of time) one can specify tcp_retries2
>>>> (by means of number of retransmissions) such that TCP will not time out
>>>> earlier than R2. This is the case, because the RTO schedule follows a fixed
>>>> pattern, namely exponential backoff.
>>>>
>>>> However, the RTO behaviour is not predictable any more if RTO backoffs can be
>>>> reverted, as it is the case in the draft
>>>> "Make TCP more Robust to Long Connectivity Disruptions"
>>>> (http://tools.ietf.org/html/draft-zimmermann-tcp-lcd).
>>>>
>>>> In the worst case TCP would time out a connection after 3.2 seconds, if the
>>>> initial RTO equaled MIN_RTO and each backoff has been reverted.
>>>>
>>>> This patch introduces a function retransmits_timed_out(N),
>>>> which calculates the timeout of a TCP connection, assuming an initial
>>>> RTO of MIN_RTO and N unsuccessful, exponentially backed-off retransmissions.
>>>>
>>>> Whenever timeout decisions are made by comparing the retransmission counter
>>>> to some value N, this function can be used, instead.
>>>>
>>>> The meaning of tcp_retries2 will be changed, as many more RTO retransmissions
>>>> can occur than the value indicates. However, it yields a timeout which is
>>>> similar to the one of an unpatched, exponentially backing off TCP in the same
>>>> scenario. As no application could rely on an RTO greater than MIN_RTO, there
>>>> should be no risk of a regression.
>>>>
>>>> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
>>>> ---
>>>>  include/net/tcp.h    |   18 ++++++++++++++++++
>>>>  net/ipv4/tcp_timer.c |   11 +++++++----
>>>>  2 files changed, 25 insertions(+), 4 deletions(-)
>>>>
>>>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>>>> index c35b329..17d1a88 100644
>>>> --- a/include/net/tcp.h
>>>> +++ b/include/net/tcp.h
>>>> @@ -1247,6 +1247,24 @@ static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_bu
>>>>  #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
>>>>  	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
>>>>
>>>> +static inline bool retransmits_timed_out(const struct sock *sk,
>>>> +					 unsigned int boundary)
>>>> +{
>>>> +	int limit, K;
>>>> +	if (!inet_csk(sk)->icsk_retransmits)
>>>> +		return false;
>>>> +
>>>> +	K = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
>>>> +
>>>> +	if (boundary <= K)
>>>> +		limit = ((2 << boundary) - 1) * TCP_RTO_MIN;
>>>> +	else
>>>> +		limit = ((2 << K) - 1) * TCP_RTO_MIN +
>>>> +			(boundary - K) * TCP_RTO_MAX;
>>> Doing this computation might allow us to respect RFC 1122 here :
>>>
>>> "The value of R2 SHOULD correspond to at least 100 seconds."
>>>
>>> adding a third parameter to retransmits_timed_out(), min_limit,
>>> being 100*HZ if sysctl_tcp_retries2 was used...
>>>
>>> limit = min(min_limit, limit);
>>
>> Hi.
>> Hm, with this restriction, we would make it a MUST instead of a SHOULD.
>> The current approach does also allow retries2 values, which can yield
>> lower timeouts than 100 seconds.
>> I could implement the min_timeout, but in my opinion, the 100 seconds
>> shouldn't be enforced. We could make a patch later, which introduces a
>> lower limit to the sysctl, so the user gets feedback, if he tries to adjust
>> the limit below the recommended 100 seconds, or something like that.
>>
>
> Fair enough, this 100 seconds limit is only a hint, not an enforcement.

Please excuse my curiousness. Were you aiming for some particular case 
with this thought of a lower bound? ...To me it seems quite a small 
difference. I can understand that one can construct a scenario with small 
retries and heterogenous rtts but how significant that is in practice 
whether we timeout 100s or slightly earlier the small rtt'ed ones (as the 
enforced limits are anyway quite strict I doubt we really would care that 
much on those hanging around for long).

-- 
  i.
--8323329-1006983804-1251811401=:29341--
