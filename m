From: Alex Bergmann <alex@linlab.net>
Subject: Re: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Wed, 22 Aug 2012 10:48:05 +0200
Message-ID: <50349CC5.3050601@linlab.net>
References: <503419D3.1080700@linlab.net> <1345622798.5158.717.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345622798.5158.717.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/22/2012 10:06 AM, Eric Dumazet wrote:
>> Prior to 9ad7c049 the timeout was defined with 189secs. Now we have only
>> a timeout of 63secs.
>>
>>          ((2 << 5) - 1) * 3 secs = 189 secs
>>          ((2 << 5) - 1) * 1 secs = 63 secs
> 
> Strange maths ... here I have :
> 
> (1+2+4+8+16) * 3 = 93 secs
> vs
> (1+2+4+8+16) * 1 = 31 secs
> 
> So even before said commit, we were not rfc1122 compliant.
> 
> Using 7 retries would give 127 seconds, still not rfc compliant.

You're missing the timeout after the 5th SYN packet was sent. This 
would result in another 32 seconds (96 seconds).

The timeout is calculated here:

net/ipv4/tcp_timer.c(146:150)

	if (boundary <= linear_backoff_thresh)
		timeout = ((2 << boundary) - 1) * rto_base;
	else
		timeout = ((2 << linear_backoff_thresh) - 1) * rto_base +
			(boundary - linear_backoff_thresh) * TCP_RTO_MAX;

> 
>>
>> To fulfill the MUST constraint in RFC1122 section 4.2.3.5 about R2 for
>> SYN segments, the values of TCP_SYN_RETRIES and TCP_SYNACK_RETRIES must
>> be changed to 7 reties.
>>
>>          ((2 << 7) - 1) * 1 secs = 255 secs
>>
>> This would result in an ETIMEDOUT of 4 minutes 15 seconds.
>>
>> Signed-off-by: Alexander Bergmann <alex@linlab.net>
>> ---
>>   include/net/tcp.h |    4 ++--
>>   1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>> index 1f000ff..7eaae19 100644
>> --- a/include/net/tcp.h
>> +++ b/include/net/tcp.h
>> @@ -98,10 +98,10 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
>>                                   * 15 is ~13-30min depending on RTO.
>>                                   */
>>   
>> -#define TCP_SYN_RETRIES         5      /* number of times to retry active opening a
>> +#define TCP_SYN_RETRIES         7      /* number of times to retry active opening a
>>                                   * connection: ~180sec is RFC minimum   */
>>   
>> -#define TCP_SYNACK_RETRIES 5   /* number of times to retry passive opening a
>> +#define TCP_SYNACK_RETRIES 7   /* number of times to retry passive opening a
>>                                   * connection: ~180sec is RFC minimum   */
>>   
>>   #define TCP_TIMEWAIT_LEN (60*HZ) /* how long to wait to destroy TIME-WAIT
> 
> Nice catch !
> 
> I kind of disagree with the SYNACK part.

I will look into this. 

> RFC 1122 says in 4.2.3.5 :
> 
>    However, the values of R1 and R2 may be different for SYN
>    and data segments.  In particular, R2 for a SYN segment MUST
>    be set large enough to provide retransmission of the segment
>    for at least 3 minutes.  The application can close the
>    connection (i.e., give up on the open attempt) sooner, of
>    course.
> 
> I am not sure SYNACK segments were considered as a 'SYN segment' in this
> section. (as the application cannot 'close' the connection on the passive
> side, only kernel is aware of a SYN_RECV socket)
> 
> Increasing TCP_SYNACK_RETRIES from 5 to 7 or 8 amplifies the
> SYN/synflood problem.
> 
> A valid client should retransmit its SYN packet for 180 seconds, I dont
> believe we should make sure the SYNACK will be sent for 180 seconds as
> well.
> 
> If we _really_ want to have a 3 minutes R2 for SYNACK, I suggest
> changing things to that we dont send more than 5 SYNACKS, maybe using
> RTO=6 after one retransmit
> 
> current situation :
> 1 sec
> 2 sec
> 4 sec
> 8 sec
> 16 sec
> ----
> total of 31 seconds
> 
> 
> 1 sec
> 12 sec  // switch to RTO = 6
> 24 sec
> 48 sec
> 96 sec
> -----
> total of 181 seconds
> 
> 
> 
