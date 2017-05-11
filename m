From: Michael Madsen <mkm@nabto.com>
Subject: Re: Fw: [Bug 195713] New: TCP recv queue grows huge
Date: Thu, 11 May 2017 21:29:18 +0200
Message-ID: <c5a4858f-1559-7c75-b224-99391e6bb6c4@nabto.com>
References: <20170511094758.2112b00f@xeon-e3>
 <1494522379.7796.112.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nabto.com ([194.192.21.149]:49995 "EHLO mail.nabto.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756370AbdEKTvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 11 May 2017 15:51:25 -0400
In-Reply-To: <1494522379.7796.112.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/11/2017 07:06 PM, Eric Dumazet wrote:
> On Thu, 2017-05-11 at 09:47 -0700, Stephen Hemminger wrote:
>> Begin forwarded message:
>>
>> Date: Thu, 11 May 2017 13:25:23 +0000
>> From: bugzilla-daemon@bugzilla.kernel.org
>> To: stephen@networkplumber.org
>> Subject: [Bug 195713] New: TCP recv queue grows huge
>>
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=195713
>>
>>              Bug ID: 195713
>>             Summary: TCP recv queue grows huge
>>             Product: Networking
>>             Version: 2.5
>>      Kernel Version: 3.13.0 4.4.0 4.9.0
>>            Hardware: All
>>                  OS: Linux
>>                Tree: Mainline
>>              Status: NEW
>>            Severity: normal
>>            Priority: P1
>>           Component: IPV4
>>            Assignee: stephen@networkplumber.org
>>            Reporter: mkm@nabto.com
>>          Regression: No
>>
>> I was testing how TCP handled advertising reductions of the window sizes
>> especially Window Full events. To create this setup I made a slow TCP receiver
>> and a fast TCP sender. To add some reality to the scenario I simulated 10ms
>> delay on the loopback device using the netem tc module.
>>
>> Steps to reproduce:
>> Bevare these steps will use all the memory on your system
>>
>> 1. create latency on loopback
>>> sudo tc qdisc change dev lo root netem delay 0ms
>> 2. slow tcp receiver:
>>> nc -l 4242 | pv -L 1k
>> 3. fast tcp sender:
>>> nc 127.0.0.1 4242 < /dev/zero
>> What to expect:
>> It is expected that the TCP recv queue is not groving unbounded e.g. the
>> following output from netstat:
>>
>>> netstat -an | grep 4242
>>> tcp   5563486      0 127.0.0.1:4242          127.0.0.1:59113
>>> ESTABLISHED
>>> tcp        0 3415559 127.0.0.1:59113         127.0.0.1:4242
>>> ESTABLISHED
>> What is seen:
>>
>> The TCP receive queue grows until there is no more memory available on the
>> system.
>>
>>> netstat -an | grep 4242
>>> tcp   223786525      0 127.0.0.1:4242          127.0.0.1:59114
>>> ESTABLISHED
>>> tcp        0   4191037 127.0.0.1:59114         127.0.0.1:4242
>>> ESTABLISHED
>> Note: After the TCP recv queue reaches ~ 2^31 bytes netstat reports a 0 which
>> is not correct, it has probably not been created with this bug in mind.
>>
>> Systems on which the bug reproducible:
>>
>>    * debian testing, kernel 4.9.0
>>    * ubuntu 14.04, kernel 3.13.0
>>    * ubuntu 16.04, kernel 4.4.0
>>
>> I have not testet on other systems than the above mentioned.
>>
>
> Not reproducible on my test machine.
>
> Somehow some sysctl must have been set to an insane value by
> mkm@nabto.com ?
>
> Please use/report ss -temoi instead of old netstat which does not
> provide info.
>
> lpaa23:~# tc -s -d qd sh dev lo
> qdisc netem 8002: root refcnt 2 limit 1000
>   Sent 1153017 bytes 388 pkt (dropped 0, overlimits 0 requeues 0)
>   backlog 0b 0p requeues 0
>
> lpaa23:~# ss -temoi dst :4242 or src :4242
> State      Recv-Q Send-Q Local Address:Port                 Peer
> Address:Port
> ESTAB      0      3255206 127.0.0.1:35672                127.0.0.1:4242
> timer:(persist,15sec,0) ino:3740676 sk:1 <->
> 	 skmem:(r0,rb1060272,t0,tb4194304,f2650,w3319206,o0,bl0,d0) ts sack
> cubic wscale:8,8 rto:230 backoff:7 rtt:20.879/26.142 mss:65483
> rcvmss:536 advmss:65483 cwnd:19 ssthresh:19 bytes_acked:3258385
> segs_out:86 segs_in:50 data_segs_out:68 send 476.7Mbps lastsnd:43940
> lastrcv:163390 lastack:13500 pacing_rate 572.0Mbps delivery_rate
> 11146.0Mbps busy:163390ms rwnd_limited:163380ms(100.0%) retrans:0/1
> rcv_space:43690 notsent:3255206 minrtt:0.002
> ESTAB      3022864 0      127.0.0.1:4242                 127.0.0.1:35672
> ino:3703653 sk:2 <->
> 	 skmem:(r3259664,rb3406910,t0,tb2626560,f752,w0,o0,bl0,d17) ts sack
> cubic wscale:8,8 rto:210 rtt:0.019/0.009 ato:120 mss:21888 rcvmss:65483
> advmss:65483 cwnd:10 bytes_received:3258384 segs_out:49 segs_in:86
> data_segs_in:68 send 92160.0Mbps lastsnd:163390 lastrcv:43940
> lastack:43940 rcv_rtt:0.239 rcv_space:61440 minrtt:0.019
>
>
> lpaa23:~# uname -a
> Linux lpaa23 4.11.0-smp-DEV #197 SMP @1494476384 x86_64 GNU/Linux
>
>
>

I've made an error in the bugreport, sorry, the tc step should set a 
nonzero delay e.g.
tc qdisc change dev lo root netem delay 100ms

tc -s -d qd sh dev lo
qdisc netem 8001: root refcnt 2 limit 1000 delay 100.0ms
  Sent 2310729789 bytes 56051 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0

netstat -an | grep 4242
tcp   1737737598      0 127.0.0.1:4242 127.0.0.1:47724         ESTABLISHED
tcp        0 3734810 127.0.0.1:47724         127.0.0.1:4242 ESTABLISHED

ss -temoi dst :4242 or src :4242
State      Recv-Q Send-Q Local Address:Port                 Peer 
Address:Port
ESTAB      1771226600 0      127.0.0.1:4242 
127.0.0.1:47724                 uid:1000 ino:248318 sk:21 <->
skmem:(r4292138050,rb5633129,t40,tb2626560,f3006,w0,o0,bl0,d0) ts sack 
cubic wscale:7,7 rto:600 rtt:200.15/100.075 ato:40 mss:21888 cwnd:10 
bytes_received:1771576125 segs_out:13932 segs_in:27728 
data_segs_in:27726 send 8.7Mbps lastsnd:132144 lastrcv:4 lastack:4852 
pacing_rate 17.5Mbps rcv_rtt:202 rcv_space:188413 minrtt:200.15
ESTAB      0      3866200 127.0.0.1:47724 
127.0.0.1:4242                  timer:(on,372ms,0) uid:1000 ino:246613 
sk:22 <->
skmem:(r0,rb1061808,t4,tb4194304,f267688,w3943000,o0,bl0,d0) ts sack 
cubic wscale:7,7 rto:404 rtt:200.112/0.058 mss:65483 cwnd:89 
bytes_acked:1769019586 segs_out:27732 segs_in:13913 data_segs_out:27730 
send 233.0Mbps lastsnd:32 lastrcv:26247708 lastack:32 pacing_rate 
466.0Mbps unacked:44 rcv_space:43690 notsent:1047728 minrtt:200.011

uname -a
Linux mkm 4.9.0-2-amd64 #1 SMP Debian 4.9.18-1 (2017-03-30) x86_64 GNU/Linux
