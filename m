From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: HTB going crazy over ~5Gbit/s (4.12.9, but problem present in
 older kernels as well)
Date: Wed, 13 Sep 2017 20:12:13 +0300
Message-ID: <57baf3c3ea2544ed4d53967b7a2d0e36@nuclearcat.com>
References: <4cd23914d8cc2cf5caf78cb5654fb245@nuclearcat.com>
 <d2aee52fda21d8f668ca012333ef3677@nuclearcat.com>
 <1505319370.15310.169.camel@edumazet-glaptop3.roam.corp.google.com>
 <9b8cdc2b39fdd2d0be7b5f559b2034e7@nuclearcat.com>
 <1505320949.15310.173.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505321747.15310.175.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:54116 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751054AbdIMRMR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 13:12:17 -0400
In-Reply-To: <1505321747.15310.175.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-09-13 19:55, Eric Dumazet wrote:
> On Wed, 2017-09-13 at 09:42 -0700, Eric Dumazet wrote:
>> On Wed, 2017-09-13 at 19:27 +0300, Denys Fedoryshchenko wrote:
>> > On 2017-09-13 19:16, Eric Dumazet wrote:
>> > > On Wed, 2017-09-13 at 18:34 +0300, Denys Fedoryshchenko wrote:
>> > >> Well, probably i am answering my own question, removing estimator from
>> > >> classes seems drastically improve situation.
>> > >> It seems estimator has some issues that cause shaper to behave
>> > >> incorrectly (throttling traffic while it should not).
>> > >> But i guess thats a bug?
>> > >> As i was not able to predict such bottleneck by CPU load measurements.
>> > >
>> > > Well, there was a reason we disabled HTB class estimators by default ;)
>> > >
>> > >
>> > > https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=64153ce0a7b61b2a5cacb01805cbf670142339e9
>> >
>> > As soon as disabling it solve my problem - i'm fine, hehe, but i guess
>> > other people who might hit this problem, should be aware how to find
>> > reason.
>> > They should not be disappointed in Linux :)
>> 
>> Well, if they enable rate estimators while kernel does not set them by
>> default, they get what they want, at a cost.
>> 
>> > Because i can't measure this bottleneck before it happens, i'm seeing on
>> > mpstat all cpu's are idle, and same time traffic is throttled.
>> 
>> Normally things were supposed to get much better in linux-4.10
>> 
>> ( 
>> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=1c0d32fde5bdf1184bc274f864c09799278a1114 
>> )
>> 
>> But I apparently added a scaling bug.
>> 
>> I will try :
>> 
>> diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
>> index 
>> 0385dece1f6fe5e26df1ce5f40956a79a2eebbf4..7c1ffd6f950172c1915d8e5fa2b5e3f77e4f4c78 
>> 100644
>> --- a/net/core/gen_estimator.c
>> +++ b/net/core/gen_estimator.c
>> @@ -83,10 +83,10 @@ static void est_timer(unsigned long arg)
>>         u64 rate, brate;
>> 
>>         est_fetch_counters(est, &b);
>> -       brate = (b.bytes - est->last_bytes) << (8 - est->ewma_log);
>> +       brate = (b.bytes - est->last_bytes) << (10 - est->ewma_log - 
>> est->intvl_log);
>>         brate -= (est->avbps >> est->ewma_log);
>> 
>> -       rate = (u64)(b.packets - est->last_packets) << (8 - 
>> est->ewma_log);
>> +       rate = (u64)(b.packets - est->last_packets) << (10 - 
>> est->ewma_log - est->intvl_log);
>>         rate -= (est->avpps >> est->ewma_log);
>> 
>>         write_seqcount_begin(&est->seq);
> 
> 
> Much better indeed
> 
> # tc -s -d class sh dev eth0 classid 7002:11 ; sleep 10 ;tc -s -d class
> sh dev eth0 classid 7002:11
> 
> class htb 7002:11 parent 7002:1 prio 5 quantum 200000 rate 5Gbit ceil
> 5Gbit linklayer ethernet burst 80000b/1 mpu 0b cburst 80000b/1 mpu 0b
> level 0 rate_handle 1
>  Sent 389085117074 bytes 256991500 pkt (dropped 0, overlimits 5926926
> requeues 0)
>  rate 4999Mbit 412762pps backlog 136260b 2p requeues 0
>  TCP pkts/rtx 256991584/0 bytes 389085252840/0
>  lended: 5961250 borrowed: 0 giants: 0
>  tokens: -1664 ctokens: -1664
> 
> class htb 7002:11 parent 7002:1 prio 5 quantum 200000 rate 5Gbit ceil
> 5Gbit linklayer ethernet burst 80000b/1 mpu 0b cburst 80000b/1 mpu 0b
> level 0 rate_handle 1
>  Sent 395336315580 bytes 261120429 pkt (dropped 0, overlimits 6021776
> requeues 0)
>  rate 4999Mbit 412788pps backlog 68Kb 2p requeues 0
>  TCP pkts/rtx 261120469/0 bytes 395336384730/0
>  lended: 6056793 borrowed: 0 giants: 0
>  tokens: -1478 ctokens: -1478
> 
> 
> echo "(395336315580-389085117074)/10*8" | bc
> 5000958800
For my case, as load increased now, i am hitting same issue (i tried to 
play with quantum / bursts as well, didnt helped):

tc -s -d class show dev eth3.777 classid 1:111;sleep 5;tc -s -d class 
show dev eth3.777 classid 1:111
class htb 1:111 parent 1:1 leaf 111: prio 0 quantum 50000 rate 20Gbit 
ceil 100Gbit linklayer ethernet burst 100000b/1 mpu 0b cburst 100000b/1 
mpu 0b level 0
  Sent 864151559 bytes 730566 pkt (dropped 15111, overlimits 0 requeues 
0)
  backlog 73968000b 39934p requeues 0
  lended: 499867 borrowed: 0 giants: 0
  tokens: 608 ctokens: 121

class htb 1:111 parent 1:1 leaf 111: prio 0 quantum 50000 rate 20Gbit 
ceil 100Gbit linklayer ethernet burst 100000b/1 mpu 0b cburst 100000b/1 
mpu 0b level 0
  Sent 1469352160 bytes 1243649 pkt (dropped 42933, overlimits 0 requeues 
0)
  backlog 82536047b 39963p requeues 0
  lended: 810475 borrowed: 0 giants: 0
  tokens: 612 ctokens: 122

(1469352160-864151559)/5*8
968320961.60000000000000000000
Less than 1Gbit and it's being throttled

Total bandwidth:

class htb 1:1 root rate 100Gbit ceil 100Gbit linklayer ethernet burst 
100000b/1 mpu 0b cburst 100000b/1 mpu 0b level 7
  Sent 7839730635 bytes 8537393 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
  lended: 0 borrowed: 0 giants: 0
  tokens: 123 ctokens: 123

class htb 1:1 root rate 100Gbit ceil 100Gbit linklayer ethernet burst 
100000b/1 mpu 0b cburst 100000b/1 mpu 0b level 7
  Sent 11043190453 bytes 12008366 pkt (dropped 0, overlimits 0 requeues 
0)
  backlog 0b 0p requeues 0
  lended: 0 borrowed: 0 giants: 0
  tokens: 124 ctokens: 124

694kpps
5.1Gbit
