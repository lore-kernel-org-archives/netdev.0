From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [PATCH net-next] tcp: Change txhash on every SYN and RTO
 retransmit
Date: Tue, 27 Sep 2016 23:07:53 +0000
Message-ID: <D4102B75.1F212%brakmo@fb.com>
References: <20160927160629.1174360-1-brakmo@fb.com>
 <1474993790.28155.60.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33183 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753639AbcI0XIV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 19:08:21 -0400
In-Reply-To: <1474993790.28155.60.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Content-ID: <173DE400389D3741BD85C2DECD45B531@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric, thank you for comments. V2 should be out shortly.

Thanks!

On 9/27/16, 9:29 AM, "netdev-owner@vger.kernel.org on behalf of Eric
Dumazet" <netdev-owner@vger.kernel.org on behalf of
eric.dumazet@gmail.com> wrote:

>On Tue, 2016-09-27 at 09:06 -0700, Lawrence Brakmo wrote:
>> The current code changes txhash (flowlables) on every retransmitted
>> SYN/ACK, but only after the 2nd retransmitted SYN and only after
>> tcp_retries1 RTO retransmits.
>>=20
>> With this patch:
>> 1) txhash is changed with every SYN retransmist
>> 2) adds the option for the txhash to be changed before tcp_retries1
>>    RTO retransmits. A new sysctl tcp_rto_txhash_prob represents the
>>    probability that txhash will be changed. The default value is 0
>>    which maintains previous behavior and a value of 100 will always
>>    change it.
>
>...
>
>> @@ -213,6 +215,11 @@ static int tcp_write_timeout(struct sock *sk)
>>  			tcp_mtu_probing(icsk, sk);
>> =20
>>  			dst_negative_advice(sk);
>> +		} else if (sk->sk_txhash && sysctl_tcp_rto_txhash_prob > 0) {
>> +			u32 v =3D prandom_u32() % 100;
>> +
>> +			if (v < sysctl_tcp_rto_txhash_prob)
>> +				sk_set_txhash(sk);
>> =20
>
>Write timeouts are rare events and sk_txhash should already be set.
>
>Also prandom_u32_max() is a bit faster (no divide, and even no multiply
>for 100 which is 5*5*4, compiler can emit 2 lea instructions )
>
>I would suggest not using all these tests and instead be very simple :
>
> 	} else if (prandom_u32_max(100) < sysctl_tcp_rto_txhash_prob) {
>		sk_set_txhash(sk);
>	}
>
>Finally, adding a new sysctl requires a Documentation update
>( Documentation/networking/ip-sysctl.txt )
>
>Thanks.
>
>
>
