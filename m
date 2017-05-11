From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 195713] New: TCP recv queue grows huge
Date: Thu, 11 May 2017 10:06:19 -0700
Message-ID: <1494522379.7796.112.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170511094758.2112b00f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        mkm@nabto.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33276 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932311AbdEKRGY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 13:06:24 -0400
Received: by mail-pf0-f176.google.com with SMTP id e193so16812308pfh.0
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 10:06:24 -0700 (PDT)
In-Reply-To: <20170511094758.2112b00f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-05-11 at 09:47 -0700, Stephen Hemminger wrote:
> 
> Begin forwarded message:
> 
> Date: Thu, 11 May 2017 13:25:23 +0000
> From: bugzilla-daemon@bugzilla.kernel.org
> To: stephen@networkplumber.org
> Subject: [Bug 195713] New: TCP recv queue grows huge
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=195713
> 
>             Bug ID: 195713
>            Summary: TCP recv queue grows huge
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.13.0 4.4.0 4.9.0
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>           Assignee: stephen@networkplumber.org
>           Reporter: mkm@nabto.com
>         Regression: No
> 
> I was testing how TCP handled advertising reductions of the window sizes
> especially Window Full events. To create this setup I made a slow TCP receiver
> and a fast TCP sender. To add some reality to the scenario I simulated 10ms
> delay on the loopback device using the netem tc module.
> 
> Steps to reproduce:
> Bevare these steps will use all the memory on your system
> 
> 1. create latency on loopback
> >sudo tc qdisc change dev lo root netem delay 0ms  
> 
> 2. slow tcp receiver:
> >nc -l 4242 | pv -L 1k  
> 
> 3. fast tcp sender:
> >nc 127.0.0.1 4242 < /dev/zero  
> 
> What to expect:
> It is expected that the TCP recv queue is not groving unbounded e.g. the
> following output from netstat:
> 
> >netstat -an | grep 4242
> >tcp   5563486      0 127.0.0.1:4242          127.0.0.1:59113        
> >ESTABLISHED
> >tcp        0 3415559 127.0.0.1:59113         127.0.0.1:4242         
> >ESTABLISHED  
> 
> What is seen:
> 
> The TCP receive queue grows until there is no more memory available on the
> system.
> 
> >netstat -an | grep 4242
> >tcp   223786525      0 127.0.0.1:4242          127.0.0.1:59114      
> >ESTABLISHED
> >tcp        0   4191037 127.0.0.1:59114         127.0.0.1:4242       
> >ESTABLISHED  
> 
> Note: After the TCP recv queue reaches ~ 2^31 bytes netstat reports a 0 which
> is not correct, it has probably not been created with this bug in mind.
> 
> Systems on which the bug reproducible:
> 
>   * debian testing, kernel 4.9.0
>   * ubuntu 14.04, kernel 3.13.0
>   * ubuntu 16.04, kernel 4.4.0
> 
> I have not testet on other systems than the above mentioned.
> 


Not reproducible on my test machine.

Somehow some sysctl must have been set to an insane value by
mkm@nabto.com ?

Please use/report ss -temoi instead of old netstat which does not
provide info.

lpaa23:~# tc -s -d qd sh dev lo
qdisc netem 8002: root refcnt 2 limit 1000
 Sent 1153017 bytes 388 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 

lpaa23:~# ss -temoi dst :4242 or src :4242
State      Recv-Q Send-Q Local Address:Port                 Peer
Address:Port                
ESTAB      0      3255206 127.0.0.1:35672                127.0.0.1:4242
timer:(persist,15sec,0) ino:3740676 sk:1 <->
	 skmem:(r0,rb1060272,t0,tb4194304,f2650,w3319206,o0,bl0,d0) ts sack
cubic wscale:8,8 rto:230 backoff:7 rtt:20.879/26.142 mss:65483
rcvmss:536 advmss:65483 cwnd:19 ssthresh:19 bytes_acked:3258385
segs_out:86 segs_in:50 data_segs_out:68 send 476.7Mbps lastsnd:43940
lastrcv:163390 lastack:13500 pacing_rate 572.0Mbps delivery_rate
11146.0Mbps busy:163390ms rwnd_limited:163380ms(100.0%) retrans:0/1
rcv_space:43690 notsent:3255206 minrtt:0.002
ESTAB      3022864 0      127.0.0.1:4242                 127.0.0.1:35672
ino:3703653 sk:2 <->
	 skmem:(r3259664,rb3406910,t0,tb2626560,f752,w0,o0,bl0,d17) ts sack
cubic wscale:8,8 rto:210 rtt:0.019/0.009 ato:120 mss:21888 rcvmss:65483
advmss:65483 cwnd:10 bytes_received:3258384 segs_out:49 segs_in:86
data_segs_in:68 send 92160.0Mbps lastsnd:163390 lastrcv:43940
lastack:43940 rcv_rtt:0.239 rcv_space:61440 minrtt:0.019


lpaa23:~# uname -a
Linux lpaa23 4.11.0-smp-DEV #197 SMP @1494476384 x86_64 GNU/Linux
