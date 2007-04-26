From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Unexcepted latency (order of 100-200 ms) with TCP (packet receive)
Date: Thu, 26 Apr 2007 22:18:47 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704262121120.18515@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0704241518370.28337@kivilampi-30.cs.helsinki.fi>
 <4630D58E.5020709@hp.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1554492744-1177614141=:18515"
Cc: Netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56518 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031454AbXDZTSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 15:18:49 -0400
In-Reply-To: <4630D58E.5020709@hp.com>
Content-ID: <Pine.LNX.4.64.0704262202410.18515@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1554492744-1177614141=:18515
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0704262202411.18515@kivilampi-30.cs.helsinki.fi>

On Thu, 26 Apr 2007, Rick Jones wrote:

> Ilpo Järvinen wrote:
> > 
> > ...
> > Some time ago I noticed that with 2.6.18 I occassionally get latency
> > spikes as long as 100-200ms in the TCP transfers between components
> > (I describe later how TCP was tuned during these tests to avoid
> > problems that occur with small segments). I started to investigate
> > the spikes, and here are the findings so far:
> > ...
> >  - I placed a hub to get exact timings on the wire without potential 
> >    interference from tcpdump on the emulator host (test done with 2.6.18)
> >    but to my great surprise, the problem vanished completely
> 
> Sounds like tcpdump getting in the way? 

No, tcpdump is not running on the host in question at all (that is what 
I'm trying to say but my English might betray me). I just describe there 
that I made a testing configuration when (after) I noticed that this 
100-200ms problem exists without any tcpdumps. With hub, the network was 
configured like this (I tried to avoid additional linux sender):

packet capture host ---> switch ---> hub ---> emulation host
                                      |
                                      |
                                     \ /
                              host with tcpdump

(for the record: due to the emulator nature, the sender in this case 
is called "packet capture host" even though I don't mean that I capture 
these tcpdumps at it.)

Sadle enough, the problem disappeared with it (as the hub caused eth to 
become 10mbps network...). Because of that, the tcpdump I'm showing below 
is captured with this route though another host configuration (additional 
sender is there which I tried to completely avoid by using the above hub 
setup):


                host with tcpdump, ip_forward = 1
                   (10Mbps eth on purpose)
                          / \  |
                           |   |
                           |  \ /
packet capture host ---->  switch -----> emulation host

...the reason being that tcpdump on the emulation host could get into the 
way like you're saying. I run it once there too, and it saw the packet 
delayed by the 100-130ms which probably is valid occurance of this same 
problem (too large to be due to scheduling or so, IMHO) that occurs 
without either of the tcpdump configs presented here, when traffic just 
goes directly from packet capture host through the switch to emulation 
host.

> How many CPUs do you have in the system, and have you tried some 
> explicit binding of processes to different CPUs? (taskset etc...)

One p4. What processes do you mean, I've carefully disabled most of the 
services (please read the explination in the end of the original mail), 
and the s/utimes of the remaining (from proc/<pid>/stat) processes on the 
emulation host do not increase during the test... Is it still possible 
that they could have been scheduled but did not get s/utime incremented, 
I'm not qualified to say that but perhaps you or somebody else knows if 
it's so?

Besides, I've the very same configuration (no problem => without tcpdump) 
working perfectly with 2.4 and also with 2.6 when the emulation host eth 
is set to 10Mbps instead of 100Mbps using ethtool. Could 2.6 with 100Mbps 
eth really cause 100ms latency spikes, especially, considering that my 
emulated wireless link is just 384kbps, so the amount of data that is 
going past ain't much larger than that...

> When running tcpdump are you simply sending raw traces to a file, or are you
> having the ASCII redirected to a file?
> What about name resolution (ie areyou using -n)?

I used this command:
  tcpdump -i eth0 -w tracefile host 192.168.1.3 or host 192.168.1.2

All hosts in the network should be in /etc/hosts, but I can try with -n 
tomorrow but I doubt that it will make any difference because the problem 
is there regardless of the tcpdump. The very reason of the tcpdump being 
there is I just to debug the problem between the emulation host and the 
sender to see whether the problem is in the sender end or in the receiving 
end. 

> > To prove this with 100Mbps, I setup routing so that with a host with 10/FD
> > configuration (known, based on earlier, to be unlikely to cause errors) I
> > collected all traffic between the emulator host and one of the packet
> > capture hosts. Here is one example point where a long delay occurs (EMU is
> > the emulator host, in the real log each packet is shown twice, I only leave
> > the later one here):
> > 
> > 1177577267.364596 IP CAP.35305 > EMU.52246: . 17231434:17232894(1460) ack
> > 383357 win 16293
> > 1177577267.364688 IP CAP.35305 > EMU.52246: P 17232894:17232946(52) ack
> > 383357 win 16293
> > 1177577267.366093 IP EMU.52246 > CAP.35305: . ack 17232894 win 32718
> > 1177577267.493815 IP EMU.52246 > CAP.35305: P 383357:383379(22) ack 17232894
> > win 32718

At this point the segment with seq 17232946 hasn't yet reached TCP (to 
be more precise, when this was sent) because cumulatively acks only to 
17232894! That's 129 ms later than the segment with seq 17232946 was seen 
by the tcpdump host (a quite long time)...

> > 1177577267.534252 IP CAP.35305 > EMU.52246: . ack 383379 win 16293
> 
> What is the length of the standalone ACK timer these days?

Do you mean so called delayed ack timer?

kernels/linux/include$ grep "DELACK" */*
net/tcp.h:#define TCP_DELACK_MAX        ((unsigned)(HZ/5))      /* maximal 
time to delay before sending an ACK */
net/tcp.h:#define TCP_DELACK_MIN        ((unsigned)(HZ/25))     /* minimal 
time to delay before sending an ACK */
net/tcp.h:#define TCP_DELACK_MIN        4U


I suspect that it could be so that delayed ack is related in way as it 
is the thing that wakes up the adapter first time after the delay (when 
nothing else from the network arrives before the delack timer expires).

However, I'm quite sure this problem might be below TCP level because of 
tcpdump cumulative ACK seq in segment 1177577267.493815 which does not yet 
include the latest segment thatshould have already arrived (tcpdump saw it 
forwarded 129ms earlier).

> Might tcp_abc have crept back-in?

# cat /proc/sys/net/ipv4/tcp_abc
0


Thanks anyway for the ideas.

-- 
 i.
---696243703-1554492744-1177614141=:18515--
