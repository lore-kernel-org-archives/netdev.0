From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: Re: [PATCH v2 1/2] tcp: setup timestamp offset when write_seq already
 set
Date: Wed, 22 Feb 2017 17:31:47 +0300
Message-ID: <1842438a-56da-a868-5bb4-309d8e25e144@oracle.com>
References: <1487759036-2800-1-git-send-email-alexey.kodanev@oracle.com>
 <1487769474.9415.44.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50877 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932480AbdBVOZd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 09:25:33 -0500
In-Reply-To: <1487769474.9415.44.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/22/2017 04:17 PM, Eric Dumazet wrote:
> On Wed, 2017-02-22 at 13:23 +0300, Alexey Kodanev wrote:
>> ...
>>
>> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>> index fe9da4f..c5169b8 100644
>> --- a/net/ipv4/tcp_ipv4.c
>> +++ b/net/ipv4/tcp_ipv4.c
>> @@ -145,6 +145,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>>  	struct flowi4 *fl4;
>>  	struct rtable *rt;
>>  	int err;
>> +	u32 seq;
>>  	struct ip_options_rcu *inet_opt;
>>  
>>  	if (addr_len < sizeof(struct sockaddr_in))
>> @@ -232,12 +233,15 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>>  	sk->sk_gso_type = SKB_GSO_TCPV4;
>>  	sk_setup_caps(sk, &rt->dst);
>>  
>> -	if (!tp->write_seq && likely(!tp->repair))
>> -		tp->write_seq = secure_tcp_sequence_number(inet->inet_saddr,
>> -							   inet->inet_daddr,
>> -							   inet->inet_sport,
>> -							   usin->sin_port,
>> -							   &tp->tsoffset);
>> +	if (likely(!tp->repair)) {
>> +		seq = secure_tcp_sequence_number(inet->inet_saddr,
>> +						 inet->inet_daddr,
>> +						 inet->inet_sport,
>> +						 usin->sin_port,
>> +						 &tp->tsoffset);
>> +		if (!tp->write_seq)
>> +			tp->write_seq = seq;
>> +	}
>>  
> Nice catch !
>
> secure_tcp_sequence_number() could be renamed, because it has two
> purposes really.

What about "secure_tcp_seq_and_tsoff(...)" ?

Also,

tcp_v4_init_sequence(...) -> tcp_v4_init_seq_and_tsoff(...)
tcp_v6_init_sequence(...) -> tcp_v6_init_seq_and_tsoff(...)


Thanks,
Alexey
