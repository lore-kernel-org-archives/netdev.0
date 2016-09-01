From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Thu, 1 Sep 2016 13:11:32 +0200
Message-ID: <28b67aee-56d8-747b-8516-f2d63fc392b0@redhat.com>
References: <4f1c4b38528762619fff1fa963de8971006c1234.1472460085.git.pabeni@redhat.com>
 <20160831100854.23dad2d8@redhat.com>
 <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
 <1472650688.32433.115.camel@redhat.com>
 <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831164216.2901190c@redhat.com>
 <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
 <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831214043.2f44cf08@redhat.com>
 <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831235116.33b1946b@redhat.com> <20160901130231.58355405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160901130231.58355405@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01.09.2016 13:02, Jesper Dangaard Brouer wrote:
> On Wed, 31 Aug 2016 23:51:16 +0200
> Jesper Dangaard Brouer <jbrouer@redhat.com> wrote:
> 
>> On Wed, 31 Aug 2016 13:42:30 -0700
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>>> On Wed, 2016-08-31 at 21:40 +0200, Jesper Dangaard Brouer wrote:
>>>   
>>>> I can confirm the improvement of approx 900Kpps (no wonder people have
>>>> been complaining about DoS against UDP/DNS servers).
>>>>
>>>> BUT during my extensive testing, of this patch, I also think that we
>>>> have not gotten to the bottom of this.  I was expecting to see a higher
>>>> (collective) PPS number as I add more UDP servers, but I don't.
>>>>
>>>> Running many UDP netperf's with command:
>>>>  super_netperf 4 -H 198.18.50.3 -l 120 -t UDP_STREAM -T 0,0 -- -m 1472 -n -N    
>>>
>>> Are you sure sender can send fast enough ?  
>>
>> Yes, as I can see drops (overrun UDP limit UdpRcvbufErrors). Switching
>> to pktgen and udp_sink to be sure.
>>
>>>>
>>>> With 'top' I can see ksoftirq are still getting a higher %CPU time:
>>>>
>>>>     PID   %CPU     TIME+  COMMAND
>>>>      3   36.5   2:28.98  ksoftirqd/0
>>>>  10724    9.6   0:01.05  netserver
>>>>  10722    9.3   0:01.05  netserver
>>>>  10723    9.3   0:01.05  netserver
>>>>  10725    9.3   0:01.05  netserver    
>>>
>>> Looks much better on my machine, with "udprcv -n 4" (using 4 threads,
>>> and 4 sockets using SO_REUSEPORT)
>>>
>>> 10755 root      20   0   34948      4      0 S  79.7  0.0   0:33.66 udprcv 
>>>     3 root      20   0       0      0      0 R  19.9  0.0   0:25.49 ksoftirqd/0                 
>>>
>>> Pressing 'H' in top gives :
>>>
>>>     3 root      20   0       0      0      0 R 19.9  0.0   0:47.84 ksoftirqd/0
>>> 10756 root      20   0   34948      4      0 R 19.9  0.0   0:30.76 udprcv 
>>> 10757 root      20   0   34948      4      0 R 19.9  0.0   0:30.76 udprcv 
>>> 10758 root      20   0   34948      4      0 S 19.9  0.0   0:30.76 udprcv
>>> 10759 root      20   0   34948      4      0 S 19.9  0.0   0:30.76 udprcv  
>>
>> Yes, I'm seeing the same when unning 5 instances my own udp_sink[1]:
>>  sudo taskset -c 0 ./udp_sink --port 10003 --recvmsg --reuse-port --count $((10**10))
>>
>>  PID  S  %CPU     TIME+  COMMAND
>>     3 R  21.6   2:21.33  ksoftirqd/0
>>  3838 R  15.9   0:02.18  udp_sink
>>  3856 R  15.6   0:02.16  udp_sink
>>  3862 R  15.6   0:02.16  udp_sink
>>  3844 R  15.3   0:02.15  udp_sink
>>  3850 S  15.3   0:02.15  udp_sink
>>
>> This is the expected result, that adding more userspace receivers
>> scales up.  I needed 5 udp_sink's before I don't see any drops, either
>> this says the job performed by ksoftirqd is 5 times faster or the
>> collective queue size of the programs was fast enough to absorb the
>> scheduling jitter.
> 
> I need some help from scheduler people explaining this!
> 
> In above run of udp_sink (which had expected behavior), I ran udp_sink
> in 5 different xterm/shells.  Below, I'm running all 5 udp_sink
> programs from the same bash shell (just backgrounding them).
> 
>    PID  S  %CPU     TIME+  COMMAND
>      3  R  50.0  29:02.23  ksoftirqd/0
>  10881  R  10.7   1:01.61  udp_sink
>  10837  R  10.0   1:05.20  udp_sink
>  10852  S  10.0   1:01.78  udp_sink
>  10862  R  10.0   1:05.19  udp_sink
>  10844  S   9.7   1:01.91  udp_sink

Could you enable schedstats (sysctl schedstats) and show
/proc/ksoftirq*/sched?

Thanks,
Hannes
