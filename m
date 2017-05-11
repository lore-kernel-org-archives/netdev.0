From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 195713] New: TCP recv queue grows huge
Date: Thu, 11 May 2017 09:47:58 -0700
Message-ID: <20170511094758.2112b00f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35705 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756576AbdEKQsG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 12:48:06 -0400
Received: by mail-pf0-f175.google.com with SMTP id n23so11635356pfb.2
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 09:48:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 11 May 2017 13:25:23 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 195713] New: TCP recv queue grows huge


https://bugzilla.kernel.org/show_bug.cgi?id=195713

            Bug ID: 195713
           Summary: TCP recv queue grows huge
           Product: Networking
           Version: 2.5
    Kernel Version: 3.13.0 4.4.0 4.9.0
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: stephen@networkplumber.org
          Reporter: mkm@nabto.com
        Regression: No

I was testing how TCP handled advertising reductions of the window sizes
especially Window Full events. To create this setup I made a slow TCP receiver
and a fast TCP sender. To add some reality to the scenario I simulated 10ms
delay on the loopback device using the netem tc module.

Steps to reproduce:
Bevare these steps will use all the memory on your system

1. create latency on loopback
>sudo tc qdisc change dev lo root netem delay 0ms  

2. slow tcp receiver:
>nc -l 4242 | pv -L 1k  

3. fast tcp sender:
>nc 127.0.0.1 4242 < /dev/zero  

What to expect:
It is expected that the TCP recv queue is not groving unbounded e.g. the
following output from netstat:

>netstat -an | grep 4242
>tcp   5563486      0 127.0.0.1:4242          127.0.0.1:59113        
>ESTABLISHED
>tcp        0 3415559 127.0.0.1:59113         127.0.0.1:4242         
>ESTABLISHED  

What is seen:

The TCP receive queue grows until there is no more memory available on the
system.

>netstat -an | grep 4242
>tcp   223786525      0 127.0.0.1:4242          127.0.0.1:59114      
>ESTABLISHED
>tcp        0   4191037 127.0.0.1:59114         127.0.0.1:4242       
>ESTABLISHED  

Note: After the TCP recv queue reaches ~ 2^31 bytes netstat reports a 0 which
is not correct, it has probably not been created with this bug in mind.

Systems on which the bug reproducible:

  * debian testing, kernel 4.9.0
  * ubuntu 14.04, kernel 3.13.0
  * ubuntu 16.04, kernel 4.4.0

I have not testet on other systems than the above mentioned.

-- 
You are receiving this mail because:
You are the assignee for the bug.
