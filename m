From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [Announce] New netchannels implementation. Userspace network stack.
Date: Fri, 20 Oct 2006 13:53:05 +0400
Message-ID: <20061020095304.GA22445@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="cNdxnHkX5QqsyA0e"
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:12955 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751699AbWJTJxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 05:53:01 -0400
Received: from 2ka.mipt.ru (localhost [127.0.0.1])
	by 2ka.mipt.ru (8.13.8/8.13.8) with ESMTP id k9K9r5lp008860
	for <netdev@vger.kernel.org>; Fri, 20 Oct 2006 13:53:05 +0400
Received: (from johnpol@localhost)
	by 2ka.mipt.ru (8.13.8/8.12.1/Submit) id k9K9r5EX008795
	for netdev@vger.kernel.org; Fri, 20 Oct 2006 13:53:05 +0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline

Netchannel [1] is pure bridge between low-level hardware and user, without any
special protocol processing involved between them.
Users are not limited to userspace only - I will use this netchannel
infrastructure for fast NAT implementation, which is purely kernelspace user 
(although it is possible to create NAT in userspace, but price of the 
kernelspace board crossing is too high, which only needs to change some fields 
in the header and recalculate checksum).
Userspace network stack [2] is another user of the new netchannel subsystem.

Current netchannel version supports data transfer using copy*user().

One could ask how does it differ from netfilter's queue target?
There are three differencies (read advantages):

 * it does not depend on netfilter (and thus does not introduce it's slow path)
 * it is very scalable, since it does not use neither hash tables, nor lists
 * it does not depend on netfilter (and thus does not introduce it's slow path). 
	Yes, again, since if we get into account NAT implementation, then we 
	need to add dependency on connection tracking, which is not needed for
	existing netchannels implementation.

It is also much smaller and scalable compared to tun/tap devices.

And some other small advantages: possibility to perform zero-copy sending and 
receiving using network allocator's [3] facilities (not implemented in the current 
version of netchannels), it is very small, there are no locks in the very short 
fast path (except RCU and skb queue linking lock, which is held for 5
operations) and so on...

There are also some limitations: it is only possible to get one packet per read 
from netchannel's file descriptor (it is possible to extend it to read several 
packets, but right now I leave it as is), it is ipv4 only (I'm lazy and only
implemented tree comparison functions for IPv4 addresses).

First user of the netchannel subsystem is userspace network stack [2], which
supports:
 * TCP/UDP sending and receiving.
 * Timestamp, window scaling, MSS TCP options.
 * PAWS.
 * Slow start and congestion control.
 * Route table (including startic ARP cache).
 * Socket-like interface.
 * IP and ethernet processing code.
 * complete retransmit algorithm.
 * fast retransmit support.
 * support for TCP listen state (only point-to-point mode, i.e. no new data
	channels are created, when new client is connected, instead state is changed 
	according to protocol (TCP state is changed to ESTABLISHED).
 * support for the new netchannels interface.

Speed/CPU usage graph for the socket code (which uses epoll and send/recv) is attached.
With the same 100 Mbit speed, CPU usage for netchanenls and userspace
network stack is about 2-3 times smaller than socket one with small
packet (128 bytes) sending/receiving.

There is very strange behaviour of userspace time() function, which if
being used actively results in extremely high kernel load and following
functions start to appear on the top of profiles:
 * get_offset_pmtmr() - 25%, second position, even higher than sysenter_past_esp().
 * do_gettimeofday() - 0.6%, 4'th place.
 * delay_pmtmr() - 0.29%, 11'th place.

First place is poll_idle().

Testing system, which runs either netchannel or socket tests runs 
HT-enabled Xeon:

processor       : 0
vendor_id       : GenuineIntel
cpu family      : 15
model           : 2
model name      : Intel(R) Xeon(TM) CPU 2.40GHz
stepping        : 7

with 1GB of RAM and e100 network adapter on Linux 2.6.17-rc3.

Main (vanilla) system is amd64 with 1GB of RAM and 8169 gigabit adapter
on Linux 2.6.18-1.2200.fc5, software is either netcat dumping data into 
/dev/null or sendfile based server.

All sources are available on project's homepages.

Thank you.

1. Netchannels subsystem.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel

2. Userspace network stack.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=unetstack

3. Network allocator.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=nta

If you have read upto here, then I want you to know that adverticement is
over. Thanks again.

-- 
	Evgeniy Polyakov

--cNdxnHkX5QqsyA0e
Content-Type: image/png
Content-Disposition: attachment; filename="atcp_speed.png"
Content-Transfer-Encoding: base64

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
4bKtYiZPSgAAAABJRU5ErkJggg==

--cNdxnHkX5QqsyA0e--
