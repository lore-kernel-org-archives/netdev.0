From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Unexcepted latency (order of 100-200 ms) with TCP (packet receive)
Date: Thu, 26 Apr 2007 13:20:17 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704241518370.28337@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54455 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030505AbXDZKUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 06:20:21 -0400
Received: from localhost (localhost [127.0.0.1])
	by kivilampi-30.cs.helsinki.fi (Postfix) with ESMTP id 409D8EAC4E
	for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 13:20:19 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


I've been trying to figure out unexcepted delay spikes that seem to occur 
for TCP flows with 2.6 (tested 2.6.18.8 + a punch of own modifications and 
also with 2.6.20.7 with a single additional changeset only that enables me 
to TCP's control initial window at will). I'll first describe the problem 
and then give a more complete description of the workload on the host.

Less than year ago, my test network kernels where upgraded from 2.4.22 to 
2.6.18. With 2.4.22 I was able to achieve very good timings in transfers 
between components. Some time ago I noticed that with 2.6.18 I 
occassionally get latency spikes as long as 100-200ms in the TCP 
transfers between components (I describe later how TCP was tuned during 
these tests to avoid problems that occur with small segments). I started 
to investigate the spikes, and here are the findings so far:

 - Problem is very well reproducable with the workload but I haven't been
   able to come up with simple client + server to cause the same with it.
 - Downgrading the emulator host to 2.4.22 removes the problem
 - Moving the emulator to another host in the network does not remove 
   the problem. It had different ethernet hw (and not the same driver).
 - I placed a hub to get exact timings on the wire without potential 
   interference from tcpdump on the emulator host (test done with 2.6.18) 
   but to my great surprise, the problem vanished completely
 - Due to the hub test result, I tested 10/100/duplex settings and found 
   out that if the emulator host has 10fd, the problem does not occur with
   2.6 either?!? This could be due to luck but I cannot say for sure, yet
   the couple of tests I've run with 10fd, did not show this...
 - Tried to change cable & switch that connect hosts together, no effect


To prove this with 100Mbps, I setup routing so that with a host with 10/FD 
configuration (known, based on earlier, to be unlikely to cause errors) I 
collected all traffic between the emulator host and one of the packet 
capture hosts. Here is one example point where a long delay occurs 
(EMU is the emulator host, in the real log each packet is shown twice, I 
only leave the later one here):

1177577267.364596 IP CAP.35305 > EMU.52246: . 17231434:17232894(1460) ack 383357 win 16293
1177577267.364688 IP CAP.35305 > EMU.52246: P 17232894:17232946(52) ack 383357 win 16293
1177577267.366093 IP EMU.52246 > CAP.35305: . ack 17232894 win 32718
1177577267.493815 IP EMU.52246 > CAP.35305: P 383357:383379(22) ack 17232894 win 32718
1177577267.534252 IP CAP.35305 > EMU.52246: . ack 383379 win 16293
1177577267.534517 IP EMU.59050 > CAP.58452: P 624496:624528(32) ack 328 win 365
1177577267.534730 IP CAP.58452 > EMU.59050: . ack 624528 win 16293
1177577267.536267 IP CAP.35305 > EMU.52246: . 17232946:17234406(1460) ack 383379 win 16293
1177577267.536360 IP CAP.35305 > EMU.52246: P 17234406:17234458(52) ack 383379 win 16293
1177577267.537764 IP EMU.52246 > CAP.35305: . ack 17234406 win 32718

In the receiving emulator process I have, at the same time, this debug 
output (select calls while in busywait are not printed to avoid 
performance and huge log problems):

To select 1177577267.362959 timeout: 0.011148 trackfd: 4 (in set)
Out select 1177577267.365923 trackfd: 4 (in set)
Read at 1177577267.365936 fromfd: 4 (had 0, tried 2048, got more 1460), while in busywait: 0
To select 1177577267.365949 timeout: 0.008158 trackfd: 4 (in set)
Out select 1177577267.377752 trackfd: 4 (not in set)
  567.177960: DL: delayed: [...emulation event...]
To select 1177577267.394121 timeout: 0.079489 trackfd: 4 (in set)
Out select 1177577267.473751 trackfd: 4 (not in set)
  567.277465: UL: delayed: [...emulation event...]
  567.277494: UL: sent   : [...emulation event...]
  567.297236: DL: delayed: [...emulation event...]
To select 1177577267.513401 timeout: 0.014452 trackfd: 4 (in set)
Out select 1177577267.513406 trackfd: 4 (not in set)
  567.297268: DL: sent   : [...emulation event...]
To select 1177577267.513431 timeout: 0.014422 trackfd: 4 (in set)
Out select 1177577267.529751 trackfd: 4 (not in set)
Read at 1177577267.534294 fromfd: 4 (had 0, tried 2048, got more 52), while in busywait: 1
  567.318147: DL: pktinfo: [...full 1460+52 bytes finally received...]


The first part of the 1460+52 bytes is received by the emulator process at 
1177577267.365936 while the 52 bytes is enourmously delayed and arrives at 
1177577267.534294 (=168ms later!?!). During this time the emulator process 
is able to sleep in select 11.8 + 79.6 + 16.3 ms + does tons of calls to 
select during busy-wait with timeout being set to zero (not shown) and the 
packet just does not arrive?!? Also the tcpdump above shows the delay, the 
ack field at 1177577267.493815 does not yet show the latest segment though 
it already had more than 120 ms to reach TCP, that should be plenty of 
time, shouldn't it? :-)

I've tried once to run tcpdump on the emulator host too and the delay was 
also in there (tcpdump shows the received packet with long delay, it was
something above 100ms that time too).


...I'm unsure how to continue the investigation from this point onward 
and asking for ideas/suggestions or how to rule out more possibilities... 
Or is there some knob which I don't know of that should be toggled or 
something, is 2.6 network stack expected to behave this way?



About the workload & TCP configuration:

The host in question runs an wireless emulator process, other services are
carefully shutdown to avoid any interference. During tests s/utimes of the 
other, remaining, unrelated processes do not increase (I'm not qualified 
to say that this proves that they did not run at all, anyone can verify 
this? Nor that nothing else was running). Also sshd was started only from 
inetd because it would periodically recreate its keys causing latency 
spikes. The emulator uses select + busy-wait combination to achieve less 
than millisecond accuracy in timing (since wireless links I don't have 
very large data rates, the small inaccuracies that obviously will occur 
are known to exist and are under monitoring). The host is p4 (ht enabled). 
Other emulator components are connected to the emulator using a 
bidirectional TCP flow (basically the packet capture + forward to the 
emulator host process). The packet flow to (but not from) the emulator has 
a flow control that sends credits using another TCP flow (32 bytes / flow 
control ack). All things use TCP_NODELAY. The network is isolated so that 
no other traffic can cause unexcepted effects. The emulator does collect 
log only to a mem buffer that is flushed through TCP only between tests 
(and thus does not cause timing problems).

Achieving a good timing between components required some tuning since flow 
control acks (on TCP level) and a part of the captured packets are less 
than full-sized as delayed acks would cause problems. To circumvent 
delayed ACK related issues, TCP initial windows on the emulator host and 
on the packet capture hosts are set to a large value to avoid cwnd limit. 
In addition, slow start after idle & application limited transfer things 
had to be disabled (2.6.18 changes include a sysctl similar to the commit 
15d33c070ddde99f7368e6b17b71d22c866f97d9 that is also included in the 
tested 2.6.20). This worked well with 2.4 but no longer with 2.6, I've no 
idea where the time during a latency spike is wasted with 2.6...


--
 i.

