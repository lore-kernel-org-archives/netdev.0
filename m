From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] tcp: restore correct limit
Date: Tue, 10 Apr 2012 18:29:45 +0800
Message-ID: <4F840B99.8040409@redhat.com>
References: <4F83EB0E.4020104@monstr.eu>  <1334046444.3126.12.camel@edumazet-glaptop>  <1334046746.3126.13.camel@edumazet-glaptop>  <4F83F166.4010208@monstr.eu>  <1334047544.3126.14.camel@edumazet-glaptop>  <4F83F959.3070302@monstr.eu>  <1334049896.3126.23.camel@edumazet-glaptop>  <4F83FD7A.5010602@monstr.eu>  <1334050698.3126.30.camel@edumazet-glaptop> <1334052194.3126.66.camel@edumazet-glaptop> <4F8407F7.8070703@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>,
	Glauber Costa <glommer@parallels.com>
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3018 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756116Ab2DJK36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 06:29:58 -0400
In-Reply-To: <4F8407F7.8070703@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2012 06:14 PM, Michal Simek wrote:
> On 04/10/2012 12:03 PM, Eric Dumazet wrote:
>> Commit c43b874d5d714f (tcp: properly initialize tcp memory limits)
>> added a regression on machines with low amount of memory, since sockets
>> cant use 1/128 of memory but 1/1024
>>
>> Fix this to match comment and previous behavior.
>>
>> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
>> Cc: Jason Wang<jasowang@redhat.com>
>> Cc: Glauber Costa<glommer@parallels.com>
>> ---
>>   net/ipv4/tcp.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
>> index 5d54ed3..67d726e 100644
>> --- a/net/ipv4/tcp.c
>> +++ b/net/ipv4/tcp.c
>> @@ -3302,7 +3302,7 @@ void __init tcp_init(void)
>>
>>       tcp_init_mem(&init_net);
>>       /* Set per-socket limits to no more than 1/128 the pressure 
>> threshold */
>> -    limit = nr_free_buffer_pages()<<  (PAGE_SHIFT - 10);
>> +    limit = nr_free_buffer_pages()<<  (PAGE_SHIFT - 7);
>>       limit = max(limit, 128UL);
>>       max_share = min(4UL*1024*1024, limit);
>>
>
> hw design with csum is also much better.
> Tested-by: Michal Simek <monstr@monstr.eu>
>
> Thanks for help,
> Michal
>
>
>
>
>
Hi Michal and Eric:

Which version of kernel did you test, did you try the newest kernel? The 
reason I use (PAGE_SHIFT - 10) is in the commit before 3dc43e3, the 
limit were calculated with:

     limit = nr_free_buffer_pages() / 8;
     limit = max(limit, 128UL);
...
     limit = ((unsigned long)sysctl_tcp_mem[1]) << (PAGE_SHIFT - 7);

So the rmem should be ok. But there's a defect (which I think does 
affect the regression) of my patch would could cause limit that we 
should shift after comparing with 128UL like:

     limit = nr_free_buffer_pages() / 8;
     limit = max(limit, 128UL) << (PAGE_SHIFT - 7);

Is anything I miss?

Thanks
