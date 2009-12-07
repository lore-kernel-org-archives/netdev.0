From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCHv2 2/2] tcp: Stalling connections: Fix timeout calculation
 routine
Date: Mon, 07 Dec 2009 13:27:42 +0100
Message-ID: <op.u4kh8gosp498uc@nexus>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de> <4B1C9D94.3070504@gmail.com>
 <4B1CE45A.9010908@tvk.rwth-aachen.de> <4B1CE9EE.1040903@tvk.rwth-aachen.de>
 <alpine.DEB.2.00.0912071405200.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Frederic Leroy <fredo@starox.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: =?utf-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:50913 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933579AbZLGM1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 07:27:39 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KUA004IB7Y99240@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 07 Dec 2009 13:27:45 +0100 (CET)
In-reply-to: <alpine.DEB.2.00.0912071405200.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 07.12.2009, 13:08 Uhr, schrieb Ilpo J=C3=A4rvinen =20
<ilpo.jarvinen@helsinki.fi>:

> On Mon, 7 Dec 2009, Damian Lukowski wrote:
>
>> This patch fixes a problem in the TCP connection timeout calculation=
=2E
>> Currently, timeout decisions are made on the basis of the current
>> tcp_time_stamp and retrans_stamp, which is usually set at the first
>> retransmission.
>> However, if the retransmission fails in tcp_retransmit_skb(),
>> retrans_stamp is not updated and remains zero. This leads to wrong
>> decisions in retransmits_timed_out() if tcp_time_stamp is larger tha=
n
>> the specified timeout, which is very likely.
>> In this case, the TCP connection dies after the first attempted
>> (and unsuccessful) retransmission.
>>
>> With this patch, tcp_skb_cb->when is used instead, when retrans_stam=
p
>> is not available.
>>
>> This bug has been introduced together with retransmits_timed_out()
>> in 2.6.32, as the number of retransmissions has been used for timeou=
t
>> decisions before.
>>
>> Thanks to Ilpo J=C3=A4rvinen for code suggestions and Frederic Leroy=
 for
>> testing.
>>
>> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
>> ---
>>  net/ipv4/tcp_timer.c |    9 ++++++++-
>>  1 files changed, 8 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
>> index 5c5f739..a9d2891 100644
>> --- a/net/ipv4/tcp_timer.c
>> +++ b/net/ipv4/tcp_timer.c
>> @@ -140,10 +140,17 @@ static bool retransmits_timed_out(const struct=
 =20
>> sock *sk,
>>  				  unsigned int boundary)
>>  {
>>  	unsigned int timeout, linear_backoff_thresh;
>> +	unsigned int start_ts;
>>
>>  	if (!inet_csk(sk)->icsk_retransmits)
>>  		return false;
>>
>> +	if (unlikely(!tcp_sk(sk)->retrans_stamp))
>> +		start_ts =3D TCP_SKB_CB(tcp_write_queue_head(
>> +					(struct sock *)sk))->when;
>
> Grr, a cast....

I'm a little bit confused now (not the first time :)).
Without the cast, there are a lot of compiler warnings.
Also, I remember that I have specified const in the function signature
on purpose because of other warnings.
But now, it seems to work without const and no cast ...

>
>> +	else
>> +		start_ts =3D tcp_sk(sk)->retrans_stamp;
>> +
>>  	linear_backoff_thresh =3D ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
>>
>>  	if (boundary <=3D linear_backoff_thresh)
>> @@ -152,7 +159,7 @@ static bool retransmits_timed_out(const struct s=
ock =20
>> *sk,
>>  		timeout =3D ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
>>  			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
>>
>> -	return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >=3D timeout;
>> +	return (tcp_time_stamp - start_ts) >=3D timeout;
>>  }
>>
>>  /* A write timeout has occurred. Process the after effects. */
>>
>
> Also, in here it's more useful to provide the fix as the first patch =
=20
> (1/2)
> since it's going to stable and those people don't want the move patch
> there.

Ok, I will patch the other way round, without the cast.

Damian
