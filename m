From: Willy Tarreau <w@1wt.eu>
Subject: Major network performance regression in 3.7
Date: Sat, 5 Jan 2013 22:49:58 +0100
Message-ID: <20130105214958.GA19814@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm observing multiple apparently unrelated network performance
issues in 3.7, to the point that I'm doubting it comes from the
network stack.

My setup involves 3 machines connected point-to-point with myri
10GE NICs (the middle machine has 2 NICs). The middle machine
normally runs haproxy, the other two run either an HTTP load
generator or a dummy web server :


  [ client ] <--------> [ haproxy ] <--------> [ server ]

Usually transferring HTTP objects from the server to the client
via haproxy causes no problem at 10 Gbps for moderately large
objects.

This time I observed that it was not possible to go beyond 6.8 Gbps,
with all the chain idling a lot. I tried to change the IRQ rate, CPU
affinity, tcp_rmem/tcp_wmem, disabling flow control, etc... the usual
knobs, nothing managed to go beyond.

So I removed haproxy from the equation, and simply started the client
on the middle machine. Same issue. I thought about concurrency issues,
so I reduced to a single connection, and nothing changed (usually I
achieve 10G even with a single connection with large enough TCP windows).
I tried to start tcpdump and the transfer immediately stalled and did not
come back after I stopped tcpdump. This was reproducible several times
but not always.

So I first thought about an issue in the myri10ge driver and wanted to
confirm that everything was OK on the middle machine.

I started the server on it and aimed the client at it via the loopback.
The transfer rate was even worse : randomly oscillating between 10 and
100 MB/s ! Normally on the loop back, I get several GB/s here.

Running tcpdump on the loopback showed be several very concerning issues :

1) lots of packets are lost before reaching tcpdump. The trace shows that
   these segments are ACKed so they're correctly received, but tcpdump
   does not get them. Tcpdump stats at the end report impressive numbers,
   around 90% packet dropped from the capture!

2) ACKs seem to be immediately delivered but do not trigger sending, the
   system seems to be running with delayed ACKs, as it waits 40 or 200ms
   before restarting, and this is visible even in the first round trips :

   - connection setup :

   18:32:08.071602 IP 127.0.0.1.26792 > 127.0.0.1.8000: S 2036886615:2036886615(0) win 8030 <mss 65495,nop,nop,sackOK,nop,wscale 9>
   18:32:08.071605 IP 127.0.0.1.8000 > 127.0.0.1.26792: S 126397113:126397113(0) ack 2036886616 win 8030 <mss 65495,nop,nop,sackOK,nop,wscale 9>
   18:32:08.071614 IP 127.0.0.1.26792 > 127.0.0.1.8000: . ack 126397114 win 16

   - GET /?s=1g HTTP/1.0

   18:32:08.071649 IP 127.0.0.1.26792 > 127.0.0.1.8000: P 2036886616:2036886738(122) ack 126397114 win 16

   - HTTP/1.1 200 OK with the beginning of the response :

   18:32:08.071672 IP 127.0.0.1.8000 > 127.0.0.1.26792: . 126397114:126401210(4096) ack 2036886738 win 16
   18:32:08.071676 IP 127.0.0.1.26792 > 127.0.0.1.8000: . ack 126401210 win 250
   ==> 200ms pause here
   18:32:08.275493 IP 127.0.0.1.8000 > 127.0.0.1.26792: P 126401210:126463006(61796) ack 2036886738 win 16
   ==> 40ms pause here
   18:32:08.315493 IP 127.0.0.1.26792 > 127.0.0.1.8000: . ack 126463006 win 256
   18:32:08.315498 IP 127.0.0.1.8000 > 127.0.0.1.26792: . 126463006:126527006(64000) ack 2036886738 win 16

   ... and so on

   My server is using splice() with the SPLICE_F_MORE flag to send data.
   I noticed that not using splice and relying on send(MSG_MORE) instead
   I don't get the issue.

3) I wondered if this had something to do with the 64k MTU on the loopback
   so I lowered it to 16kB. The performance was even worse (about 5MB/s).
   Starting tcpdump managed to make my transfer stall, just like with the
   myri10ge. In this last test, I noticed that there were some real drops,
   because there were some SACKs :

   18:45:16.699951 IP 127.0.0.1.8000 > 127.0.0.1.8002: P 956153186:956169530(16344) ack 131668746 win 16
   18:45:16.699956 IP 127.0.0.1.8002 > 127.0.0.1.8000: . ack 956169530 win 64
   18:45:16.904119 IP 127.0.0.1.8000 > 127.0.0.1.8002: P 957035762:957052106(16344) ack 131668746 win 16
   18:45:16.904122 IP 127.0.0.1.8002 > 127.0.0.1.8000: . ack 957052106 win 703
   18:45:16.904124 IP 127.0.0.1.8000 > 127.0.0.1.8002: P 957052106:957099566(47460) ack 131668746 win 16
   18:45:17.108117 IP 127.0.0.1.8000 > 127.0.0.1.8002: P 957402550:957418894(16344) ack 131668746 win 16
   18:45:17.108119 IP 127.0.0.1.8002 > 127.0.0.1.8000: . ack 957418894 win 1846
   18:45:17.312115 IP 127.0.0.1.8000 > 127.0.0.1.8002: P 957672806:957689150(16344) ack 131668746 win 16
   18:45:17.312117 IP 127.0.0.1.8002 > 127.0.0.1.8000: . ack 957689150 win 2902
   18:45:17.516114 IP 127.0.0.1.8000 > 127.0.0.1.8002: P 958962966:958979310(16344) ack 131668746 win 16
   18:45:17.516116 IP 127.0.0.1.8002 > 127.0.0.1.8000: . ack 958979310 win 7941
   18:45:17.516150 IP 127.0.0.1.8002 > 127.0.0.1.8000: . ack 959503678 win 9926 <nop,nop,sack 1 {959405614:959421958}>
   18:45:17.516151 IP 127.0.0.1.8002 > 127.0.0.1.8000: . ack 959503678 win 9926 <nop,nop,sack 1 {959421958:959438302}>

Please note that the Myri card is running with the normal MTU of 1500,
jumbo frames were not used.

>From what I could test, only the Tx path seems affected, because after
rebooting the server on 3.5.7, I can transfer at 10 Gbps via the myri10ge
again to the 3.7.1 client. I tried to disable GSO, TSO, etc... but nothing
worked. Also, on 3.5.7, there are almost no drops between the kernel and
tcpdump.

I really suspect that all these issues are related. Maybe something about
send buffers recycling, I don't know. The fact that tcpdump gets very few
packets also makes me think about something about memory allocation. And
that could perhaps explain why starting it causes the traffic to stall.

Sadly, it will be hard to bisect this bug because I had a hard time running
3.7-rc up to rc5 due to several bugs that affected this workload (and were
fortunately fixed since).

I think it's better to only focus on the issue with the loopback since it's
easier to reproduce and involves less moving blocks.

I've just tried to remove the SPLICE_F_MORE flag on the sender but it does
not change anything.

If anyone has any idea of things to test to narrow the problem down, I'm
interested. I have not tried 3.8-rc2 yet, and reading the archives there
does not seem to be any similar reports. Note that I've been using 3.5.7
as a fallback, but the same lab has run 3.6.6 without any issues 2 months
ago, so I'm really confident that this is a 3.7 regression.

Regards,
Willy
