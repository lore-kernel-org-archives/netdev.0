From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connection close
 threshold as a time value.
Date: Mon, 31 Aug 2009 16:04:11 +0200
Message-ID: <4A9BD85B.9070708@gmail.com>
References: <4A950B82.1070807@tvk.rwth-aachen.de> <4A9BD7AB.7060207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49778 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbZHaOEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 10:04:10 -0400
In-Reply-To: <4A9BD7AB.7060207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Damian Lukowski a =E9crit :
>> RFC 1122 specifies two threshold values R1 and R2 for connection tim=
eouts,
>> which may represent a number of allowed retransmissions or a timeout=
 value.
>> Currently linux uses sysctl_tcp_retries{1,2} to specify the threshol=
ds
>> in number of allowed retransmissions.
>>
>> For any desired threshold R2 (by means of time) one can specify tcp_=
retries2
>> (by means of number of retransmissions) such that TCP will not time =
out
>> earlier than R2. This is the case, because the RTO schedule follows =
a fixed
>> pattern, namely exponential backoff.
>>
>> However, the RTO behaviour is not predictable any more if RTO backof=
fs can be
>> reverted, as it is the case in the draft
>> "Make TCP more Robust to Long Connectivity Disruptions"
>> (http://tools.ietf.org/html/draft-zimmermann-tcp-lcd).
>>
>> In the worst case TCP would time out a connection after 3.2 seconds,=
 if the
>> initial RTO equaled MIN_RTO and each backoff has been reverted.
>>
>> This patch introduces a function retransmits_timed_out(N),
>> which calculates the timeout of a TCP connection, assuming an initia=
l
>> RTO of MIN_RTO and N unsuccessful, exponentially backed-off retransm=
issions.
>>
>> Whenever timeout decisions are made by comparing the retransmission =
counter
>> to some value N, this function can be used, instead.
>>
>> The meaning of tcp_retries2 will be changed, as many more RTO retran=
smissions
>> can occur than the value indicates. However, it yields a timeout whi=
ch is
>> similar to the one of an unpatched, exponentially backing off TCP in=
 the same
>> scenario. As no application could rely on an RTO greater than MIN_RT=
O, there
>> should be no risk of a regression.
>>
>> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
>> ---
>>  include/net/tcp.h    |   18 ++++++++++++++++++
>>  net/ipv4/tcp_timer.c |   11 +++++++----
>>  2 files changed, 25 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>> index c35b329..17d1a88 100644
>> --- a/include/net/tcp.h
>> +++ b/include/net/tcp.h
>> @@ -1247,6 +1247,24 @@ static inline struct sk_buff *tcp_write_queue=
_prev(struct sock *sk, struct sk_bu
>>  #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
>>  	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
>> =20
>> +static inline bool retransmits_timed_out(const struct sock *sk,
>> +					 unsigned int boundary)
>> +{
>> +	int limit, K;
>> +	if (!inet_csk(sk)->icsk_retransmits)
>> +		return false;
>> +
>> +	K =3D ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
>> +
>> +	if (boundary <=3D K)
>> +		limit =3D ((2 << boundary) - 1) * TCP_RTO_MIN;
>> +	else
>> +		limit =3D ((2 << K) - 1) * TCP_RTO_MIN +
>> +			(boundary - K) * TCP_RTO_MAX;
>=20
> Doing this computation might allow us to respect RFC 1122 here :
> =20
> "The value of R2 SHOULD correspond to at least 100 seconds."
>=20
> adding a third parameter to retransmits_timed_out(), min_limit,
> being 100*HZ if sysctl_tcp_retries2 was used...
>=20
> limit =3D min(min_limit, limit);
>=20

Oh well, typical min/max error, sorry :)

>=20
>> +
>> +	return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >=3D limit;
>> +}
>> +
>>  static inline struct sk_buff *tcp_send_head(struct sock *sk)
>>  {
>>  	return sk->sk_send_head;
>> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
>> index a3ba494..2972d7b 100644
>> --- a/net/ipv4/tcp_timer.c
>> +++ b/net/ipv4/tcp_timer.c
>> @@ -137,13 +137,14 @@ static int tcp_write_timeout(struct sock *sk)
>>  {
>>  	struct inet_connection_sock *icsk =3D inet_csk(sk);
>>  	int retry_until;
>> +	bool do_reset;
>> =20
>>  	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
>>  		if (icsk->icsk_retransmits)
>>  			dst_negative_advice(&sk->sk_dst_cache);
>>  		retry_until =3D icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries=
;
>>  	} else {
>> -		if (icsk->icsk_retransmits >=3D sysctl_tcp_retries1) {
>> +		if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
>>  			/* Black hole detection */
>>  			tcp_mtu_probing(icsk, sk);
>> =20
>> @@ -155,13 +156,15 @@ static int tcp_write_timeout(struct sock *sk)
>>  			const int alive =3D (icsk->icsk_rto < TCP_RTO_MAX);
>> =20
>>  			retry_until =3D tcp_orphan_retries(sk, alive);
>> +			do_reset =3D alive ||
>> +				   !retransmits_timed_out(sk, retry_until);
>> =20
>> -			if (tcp_out_of_resources(sk, alive || icsk->icsk_retransmits < r=
etry_until))
>> +			if (tcp_out_of_resources(sk, do_reset))
>>  				return 1;
>>  		}
>>  	}
>> =20
>> -	if (icsk->icsk_retransmits >=3D retry_until) {
>> +	if (retransmits_timed_out(sk, retry_until)) {
>>  		/* Has it gone just too far? */
>>  		tcp_write_err(sk);
>>  		return 1;
>> @@ -385,7 +388,7 @@ void tcp_retransmit_timer(struct sock *sk)
>>  out_reset_timer:
>>  	icsk->icsk_rto =3D min(icsk->icsk_rto << 1, TCP_RTO_MAX);
>>  	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, T=
CP_RTO_MAX);
>> -	if (icsk->icsk_retransmits > sysctl_tcp_retries1)
>> +	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
>>  		__sk_dst_reset(sk);
>> =20
>>  out:;
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20

