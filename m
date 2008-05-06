From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [RFC] gianfar: low gigabit throughput
Date: Tue, 6 May 2008 23:20:08 +0400
Message-ID: <20080506192008.GA30148@polina.dev.rtsoft.ru>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: linuxppc-dev@ozlabs.org, Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:51913 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1751765AbYEFTUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 15:20:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Down here few question regarding networking throughput, I would
appreciate any thoughts or ideas.

On the MPC8315E-RDB board (CPU at 400MHz, CSB at 133 MHz) I'm observing
relatively low TCP throughput using gianfar driver...

The maximum value I've seen with the current kernels is 142 Mb/s of TCP
and 354 Mb/s of UDP (NAPI and interrupts coalescing enabled):

  root@b1:~# netperf -l 10 -H 10.0.1.1 -t TCP_STREAM -- -m 32768 -s 157344 -S 157344
  TCP STREAM TEST to 10.0.1.1
  #Cpu utilization 0.10
  Recv   Send    Send
  Socket Socket  Message  Elapsed
  Size   Size    Size     Time     Throughput
  bytes  bytes   bytes    secs.    10^6bits/sec

  206848 212992  32768    10.00     142.40

  root@b1:~# netperf -l 10 -H 10.0.1.1 -t UDP_STREAM -- -m 32768 -s 157344 -S 157344
  UDP UNIDIRECTIONAL SEND TEST to 10.0.1.1
  #Cpu utilization 100.00
  Socket  Message  Elapsed      Messages
  Size    Size     Time         Okay Errors   Throughput
  bytes   bytes    secs            #      #   10^6bits/sec

  212992   32768   10.00       13539      0     354.84
  206848           10.00       13539            354.84


Is this normal?

netperf running in loopback gives me 329 Mb/s of TCP throughput:

  root@b1:~# netperf -l 10 -H 127.0.0.1 -t TCP_STREAM -- -m 32768 -s 157344 -S 157344
  TCP STREAM TEST to 127.0.0.1
  #Cpu utilization 100.00
  #Cpu utilization 100.00
  Recv   Send    Send
  Socket Socket  Message  Elapsed
  Size   Size    Size     Time     Throughput
  bytes  bytes   bytes    secs.    10^6bits/sec

  212992 212992  32768    10.00     329.60


May I consider this as a something that is close to the Linux'
theoretical maximum for this setup? Or this isn't reliable test?


I can compare with teh MPC8377E-RDB (very similar board - exactly the same
ethernet phy, the same drivers are used, i.e. everything is the same from
the ethernet stand point), but running at 666 MHz, CSB at 333MHz:

         |CPU MHz|BUS MHz|UDP Mb/s|TCP Mb/s|
  ------------------------------------------
  MPC8377|    666|    333|     646|     264|
  MPC8315|    400|    133|     354|     142|
  ------------------------------------------
  RATIO  |    1.6|    2.5|     1.8|     1.8|

It seems that things are really dependant on the CPU/CSB speed.

I've tried to tune gianfar driver in various ways... and it gave
some positive results with this patch:

diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index fd487be..b5943f9 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -123,8 +123,8 @@ extern const char gfar_driver_version[];
 #define GFAR_10_TIME    25600
 
 #define DEFAULT_TX_COALESCE 1
-#define DEFAULT_TXCOUNT	16
-#define DEFAULT_TXTIME	21
+#define DEFAULT_TXCOUNT	80
+#define DEFAULT_TXTIME	105
 
 #define DEFAULT_RXTIME	21


Basically this raises the tx interrupts coalescing threshold (raising
it more didn't help, as well as didn't help raising rx thresholds).
Now:

root@b1:~# netperf -l 3 -H 10.0.1.1 -t TCP_STREAM -- -m 32768 -s 157344 -S 157344
TCP STREAM TEST to 10.0.1.1
#Cpu utilization 100.00
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

206848 212992  32768    3.00      163.04


That is +21 Mb/s (14% up). Not fantastic, but good anyway.

As expected, the latency increased too:

Before the patch:

--- 10.0.1.1 ping statistics ---
20 packets transmitted, 20 received, 0% packet loss, time 18997ms
rtt min/avg/max/mdev = 0.108/0.124/0.173/0.022 ms

After:

--- 10.0.1.1 ping statistics ---
22 packets transmitted, 22 received, 0% packet loss, time 20997ms
rtt min/avg/max/mdev = 0.158/0.167/0.182/0.004 ms


34% up... heh. Should we sacrifice the latency in favour of throughput?
Is 34% latency growth bad thing? What is worse, lose 21 Mb/s or 34% of
latency? ;-)


Thanks in advance,

p.s. Btw, the patch above helps even better on the on the -rt kernels,
since on the -rt kernels the throughput is near 100 Mb/s, with the
patch the throughput is close to 140 Mb/s.

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
