From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [RFC] gianfar: low gigabit throughput
Date: Wed, 7 May 2008 17:28:23 +0400
Message-ID: <20080507132823.GA10988@polina.dev.rtsoft.ru>
References: <20080506192008.GA30148@polina.dev.rtsoft.ru> <4820BA72.3090903@hp.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:38536 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1751050AbYEGN21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 09:28:27 -0400
Content-Disposition: inline
In-Reply-To: <4820BA72.3090903@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2008 at 01:07:14PM -0700, Rick Jones wrote:
> Anton Vorontsov wrote:
>> Hi all,
>>
>> Down here few question regarding networking throughput, I would
>> appreciate any thoughts or ideas.
>>
>> On the MPC8315E-RDB board (CPU at 400MHz, CSB at 133 MHz) I'm observing
>> relatively low TCP throughput using gianfar driver...
>
> What is the "target" of the test - is it another of those boards, or  
> something else?

I've tried in various ways (except for another of these boards, I don't
have any), for example really fast machine with gbit ethernet, but most
of the time I'm testing with MPC8315 and MPC8377 interconnected.

The other interesting thing is that when netserver is running on the
MPC8315 (slow) target, and netperf on the MPC8377 (fast), the TCP
and UDP throughput increases.

root@mpc837x_rdb:~# netperf -l 3 -H 10.0.1.2 -t TCP_STREAM -- -m 32768 -s 157344 -S 157344
TCP STREAM TEST to 10.0.1.2
#Cpu utilization 40.66
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

212992 206848  32768    3.00      309.87   

So the slow target can receive TCP packets with 300 Mb/s, but TCP
packet generation (or transmitting) is slower.

>>
>> The maximum value I've seen with the current kernels is 142 Mb/s of TCP
>> and 354 Mb/s of UDP (NAPI and interrupts coalescing enabled):
>>
>>   root@b1:~# netperf -l 10 -H 10.0.1.1 -t TCP_STREAM -- -m 32768 -s 157344 -S 157344
>>   TCP STREAM TEST to 10.0.1.1
>>   #Cpu utilization 0.10
>>   Recv   Send    Send
>>   Socket Socket  Message  Elapsed
>>   Size   Size    Size     Time     Throughput
>>   bytes  bytes   bytes    secs.    10^6bits/sec
>>
>>   206848 212992  32768    10.00     142.40
>>
>>   root@b1:~# netperf -l 10 -H 10.0.1.1 -t UDP_STREAM -- -m 32768 -s 157344 -S 157344
>>   UDP UNIDIRECTIONAL SEND TEST to 10.0.1.1
>>   #Cpu utilization 100.00
>>   Socket  Message  Elapsed      Messages
>>   Size    Size     Time         Okay Errors   Throughput
>>   bytes   bytes    secs            #      #   10^6bits/sec
>>
>>   212992   32768   10.00       13539      0     354.84
>>   206848           10.00       13539            354.84
>>
>
> I have _got_ to make CPU utilization enabled by default one of these  
> days :)  At least for mechanisms which don't require calibration.

Heh, I've skipped the calibration chapter in the netperf manual. :-D
Should revert to it.

>> Is this normal?
>
> Does gianfar do TSO?

Afaik, it doesn't. The hardware can do header recognition/verification
including checksums, and also could generate checksums for the TCP/IP.

But IP fragmentation and re-assembly on the software's shoulders.

> If not, what happens when you tell UDP_STREAM to  
> send 1472 byte messages to bypass IP fragmentation?

A bit worse throughput:

root@b1:~# netperf -l 3 -H 10.0.1.1 -t UDP_STREAM -- -m 1472 -s 157344 -S 157344
UDP UNIDIRECTIONAL SEND TEST to 10.0.1.1
#Cpu utilization 100.00
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992    1472   3.00        73377      0     287.86
206848           3.00        73377            287.86

And 32 * 1472:

root@b1:~# netperf -l 3 -H 10.0.1.1 -t UDP_STREAM -- -m 47104 -s 157344 -S 157344
UDP UNIDIRECTIONAL SEND TEST to 10.0.1.1
#Cpu utilization 100.00
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   47104   3.00         3124      0     392.13
206848           3.00         3124            392.13

So things becomes much better when the message size increases
(I think the netperf then eating less cpu, and gives some precessing
time to the kernel?).

The same for TCP packets with mlen of 1448.

> While stock netperf won't report what the socket buffer size becomes  
> when you allow autotuning to rear its head, you can take the top of  
> trunk and enable the "omni" tests (./configure --enable-omni) and those  
> versions of *_STREAM etc can report what the socket buffer size was at  
> the beginning and at the end of the test. You can let the stack autotune  
> and see if anything changes there.  You can do the same with stock  
> netperf, just it will only report the initial socket buffer sizes...

Thanks, will try.

>> netperf running in loopback gives me 329 Mb/s of TCP throughput:
>>
>>   root@b1:~# netperf -l 10 -H 127.0.0.1 -t TCP_STREAM -- -m 32768 -s 157344 -S 157344
>>   TCP STREAM TEST to 127.0.0.1
>>   #Cpu utilization 100.00
>>   #Cpu utilization 100.00
>>   Recv   Send    Send
>>   Socket Socket  Message  Elapsed
>>   Size   Size    Size     Time     Throughput
>>   bytes  bytes   bytes    secs.    10^6bits/sec
>>
>>   212992 212992  32768    10.00     329.60
>>
>>
>> May I consider this as a something that is close to the Linux'
>> theoretical maximum for this setup? Or this isn't reliable test?
>
> I'm always leery of using a loopback number.  It excercises both send  
> and receive at the same time, but without the driver.  Also, lo tends to  
> have a much larger MTU than a "standard" NIC and if that NIC doesn't to  
> TSO and LRO that can be a big difference in the number of times up and  
> down the stack per KB transferred.

I see. Will be cautious with it, too. ;-)

>> I can compare with teh MPC8377E-RDB (very similar board - exactly the same
>> ethernet phy, the same drivers are used, i.e. everything is the same from
>> the ethernet stand point), but running at 666 MHz, CSB at 333MHz:
>>
>>          |CPU MHz|BUS MHz|UDP Mb/s|TCP Mb/s|
>>   ------------------------------------------
>>   MPC8377|    666|    333|     646|     264|
>>   MPC8315|    400|    133|     354|     142|
>>   ------------------------------------------
>>   RATIO  |    1.6|    2.5|     1.8|     1.8|
>>
>> It seems that things are really dependant on the CPU/CSB speed.
>
> What is the nature of the DMA stream between the two tests?  I find it  
> interesting that the TCP Mb/s went up by more than the CPU MHz and  
> wonder how much the Bus MHz came into play there - perhaps there were  
> more DMA's to setup or across a broader memory footprint for TCP than  
> for UDP.

The gianfar indeed does a lot of dma on the "buffer descriptors", so
probably the bus speed matters a lot. And combination of CPU and Bus
gives the final result.

>>
>> I've tried to tune gianfar driver in various ways... and it gave
>> some positive results with this patch:
>>
>> diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
>> index fd487be..b5943f9 100644
>> --- a/drivers/net/gianfar.h
>> +++ b/drivers/net/gianfar.h
>> @@ -123,8 +123,8 @@ extern const char gfar_driver_version[];
>>  #define GFAR_10_TIME    25600
>>   #define DEFAULT_TX_COALESCE 1
>> -#define DEFAULT_TXCOUNT	16
>> -#define DEFAULT_TXTIME	21
>> +#define DEFAULT_TXCOUNT	80
>> +#define DEFAULT_TXTIME	105
>>   #define DEFAULT_RXTIME	21
>
> No ethtool coalescing tuning support for gianfar?-)

Heh. :-) I should have looked into gianfar_ethtool.c before editing
anything. Yes, there is.

>> Basically this raises the tx interrupts coalescing threshold (raising
>> it more didn't help, as well as didn't help raising rx thresholds).
>> Now:
>>
>> root@b1:~# netperf -l 3 -H 10.0.1.1 -t TCP_STREAM -- -m 32768 -s 157344 -S 157344
>> TCP STREAM TEST to 10.0.1.1
>> #Cpu utilization 100.00
>> Recv   Send    Send
>> Socket Socket  Message  Elapsed
>> Size   Size    Size     Time     Throughput
>> bytes  bytes   bytes    secs.    10^6bits/sec
>>
>> 206848 212992  32768    3.00      163.04
>>
>>
>> That is +21 Mb/s (14% up). Not fantastic, but good anyway.
>>
>> As expected, the latency increased too:
>>
>> Before the patch:
>>
>> --- 10.0.1.1 ping statistics ---
>> 20 packets transmitted, 20 received, 0% packet loss, time 18997ms
>> rtt min/avg/max/mdev = 0.108/0.124/0.173/0.022 ms
>>
>> After:
>>
>> --- 10.0.1.1 ping statistics ---
>> 22 packets transmitted, 22 received, 0% packet loss, time 20997ms
>> rtt min/avg/max/mdev = 0.158/0.167/0.182/0.004 ms
>>
>>
>> 34% up... heh. Should we sacrifice the latency in favour of throughput?
>> Is 34% latency growth bad thing? What is worse, lose 21 Mb/s or 34% of
>> latency? ;-)
>
> Well, I'm not always fond of that sort of trade-off:
>
> ftp://ftp.cup.hp.com/dist/networking/briefs/
>
> there should be a nic latency vs tput writeup there.

Thanks!

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
