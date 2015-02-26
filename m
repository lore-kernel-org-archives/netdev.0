From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCHv2 net-next 4/4] ipv4: Create probe timer for tcp PMTU
 as per RFC4821
Date: Thu, 26 Feb 2015 14:24:10 +0800
Message-ID: <54EEBC0A.1040103@gmail.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com>  <1424922566-6787-1-git-send-email-fan.du@intel.com>  <1424922566-6787-5-git-send-email-fan.du@intel.com> <1424924362.5565.143.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, johnwheffner@gmail.com,
	edumazet@google.com, davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:45618 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbbBZG3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 01:29:04 -0500
Received: by pablf10 with SMTP id lf10so11451219pab.12
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 22:29:03 -0800 (PST)
In-Reply-To: <1424924362.5565.143.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B402=E6=9C=8826=E6=97=A5 12:19, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Thu, 2015-02-26 at 11:49 +0800, Fan Du wrote:
>> As per RFC4821 7.3.  Selecting Probe Size, a probe timer should
>> be armed once probing has converged. Once this timer expired,
>> probing again to take advantage of any path PMTU change. The
>> recommended probing interval is 10 minutes per RFC1981. Probing
>> interval could be sysctled by sysctl_tcp_probe_interval.
>>
>> Eric suggested to implement pseudo timer based on 32bits jiffies
>> tcp_time_stamp instead of using classic timer for such rare event.
>>
>> Signed-off-by: Fan Du <fan.du@intel.com>
>> ---
>> v2:
>>     - Create a pseudo timer based on 32bits jiffies tcp_time_stamp
>>       to control when to reprobing as suggested by Eric.
>
> ...
>
>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>> index c418829..0e9ee6a 100644
>> --- a/net/ipv4/tcp_output.c
>> +++ b/net/ipv4/tcp_output.c
>> @@ -1354,6 +1354,8 @@ void tcp_mtup_init(struct sock *sk)
>>   			       icsk->icsk_af_ops->net_header_len;
>>   	icsk->icsk_mtup.search_low =3D tcp_mss_to_mtu(sk, net->ipv4.sysct=
l_tcp_base_mss);
>>   	icsk->icsk_mtup.probe_size =3D 0;
>> +	if (icsk->icsk_mtup.enabled)
>
> I guess the test can be removed.
>
> Assignment of probe_timestamp can be done regardless of the flag.

Exactly speaking, the assignment should honor enabled variable,
once enabled is 1, probing actually starts, so probe_timestamp should a=
lso be marked from that point.
one place missing is below:

@@ -108,6 +108,7 @@ static void tcp_blackhole_probe(struct inet_connect=
ion_sock *icsk,
         if (net->ipv4.sysctl_tcp_mtu_probing) {
                 if (!icsk->icsk_mtup.enabled) {
                         icsk->icsk_mtup.enabled =3D 1;
+                       icsk->icsk_mtup.probe_timestamp =3D tcp_time_st=
amp;

>> +		icsk->icsk_mtup.probe_timestamp =3D tcp_time_stamp;
>>   }
>>   EXPORT_SYMBOL(tcp_mtup_init);
>>
>> @@ -1823,6 +1825,35 @@ send_now:
>>   	return false;
>>   }
>>
>> +static inline void tcp_mtu_check_reprobe(struct sock *sk)
>> +{
>> +	struct inet_connection_sock *icsk =3D inet_csk(sk);
>> +	struct net *net =3D sock_net(sk);
>> +	struct tcp_sock *tp =3D tcp_sk(sk);
>> +
>
> extra newline
>
>> +	u32 delta;
>> +	u32 now =3D tcp_time_stamp;
>> +	u32 interval =3D net->ipv4.sysctl_tcp_probe_interval;
>
>
> Please try to keep variables sorted by lengths, it helps readability =
:
>
> 	u32 interval =3D net->ipv4.sysctl_tcp_probe_interval;
> 	struct inet_connection_sock *icsk =3D inet_csk(sk);
> 	struct tcp_sock *tp =3D tcp_sk(sk);
> 	struct net *net =3D sock_net(sk);
> 	s32 delta;

then I have to arrange those variable like this ;)

+static inline void tcp_mtu_check_reprobe(struct sock *sk)
+{
+       struct inet_connection_sock *icsk =3D inet_csk(sk);
+       struct tcp_sock *tp =3D tcp_sk(sk);
+       struct net *net =3D sock_net(sk);
+       u32 interval;
+       s32 delta;
+
+       interval =3D net->ipv4.sysctl_tcp_probe_interval;
+       delta =3D tcp_time_stamp - icsk->icsk_mtup.probe_timestamp;
+       if (unlikely(delta >=3D interval * HZ)) {
+               int mss =3D tcp_current_mss(sk);
+
+               /* Update current search range */
+               icsk->icsk_mtup.search_high =3D tp->rx_opt.mss_clamp +
+                       sizeof(struct tcphdr) +
+                       icsk->icsk_af_ops->net_header_len;
+               icsk->icsk_mtup.search_low =3D tcp_mss_to_mtu(sk, mss);
+               icsk->icsk_mtup.probe_size =3D 0;
+
+               /* Update probe time stamp */
+               icsk->icsk_mtup.probe_timestamp =3D tcp_time_stamp;
+       }
+}

And thanks for the all the comments.

>
>
>> +
>> +	if (likely(now > icsk->icsk_mtup.probe_timestamp))
>
> Wrapping issue.
>
>   if ((s32)(now - icsk->icsk_mtup.probe_timestamp)) > 0) ...
>
>
>> +		delta =3D now - icsk->icsk_mtup.probe_timestamp;
>> +	else
>> +		delta =3D now + (U32_MAX - icsk->icsk_mtup.probe_timestamp);
>
>
> oh well..
>
> delta =3D tcp_time_stamp - icsk->icsk_mtup.probe_timestamp;
>
> is fine (if delta is declared as s32).
> Adding U32_MAX makes no sense. No need for @now var.
>
>> +	if (unlikely(jiffies_to_msecs(delta) >=3D interval * MSEC_PER_SC))=
 {
>
> if (unlikely(delta >=3D interval * HZ)) {
>
>> +		int mss =3D tcp_current_mss(sk);
>> +
>> +		/* Update current search range */
>> +		icsk->icsk_mtup.search_high =3D tp->rx_opt.mss_clamp +
>> +			sizeof(struct tcphdr) +
>> +			icsk->icsk_af_ops->net_header_len;
>> +		icsk->icsk_mtup.search_low =3D tcp_mss_to_mtu(sk, mss);
>> +		icsk->icsk_mtup.probe_size =3D 0;
>> +
>> +		/* Update probe time stamp */
>> +		icsk->icsk_mtup.probe_timestamp =3D now;
>
> 		icsk->icsk_mtup.probe_timestamp =3D tcp_time_stamp;
>> +	}
>> +}
>> +
>>   /* Create a new MTU probe if we are ready.
>>    * MTU probe is regularly attempting to increase the path MTU by
>>    * deliberately sending larger packets.  This discovers routing
>> @@ -1866,8 +1897,11 @@ static int tcp_mtu_probe(struct sock *sk)
>>   	size_needed =3D probe_size + (tp->reordering + 1) * tp->mss_cache=
;
>>   	interval =3D icsk->icsk_mtup.search_high - icsk->icsk_mtup.search=
_low;
>>   	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high) =
||
>> -	    interval < net->ipv4.sysctl_tcp_probe_threshold) {
>> -		/* TODO: set timer for probe_converge_event */
>> +		interval < net->ipv4.sysctl_tcp_probe_threshold) {
>> +		/* Check whether enough time has elaplased for
>> +		 * another round of probing.
>> +		 */
>> +		tcp_mtu_check_reprobe(sk);
>>   		return -1;
>>   	}
>>
>
>
