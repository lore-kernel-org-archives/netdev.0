From: Michael Riepe <michael.riepe@googlemail.com>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sat, 23 May 2009 18:12:22 +0200
Message-ID: <4A182066.9030201@googlemail.com>
References: <200903041828.49972.m.bueker@berlin.de>	 <4A0C7443.1010000@googlemail.com>	 <1243042174.3580.23.camel@obelisk.thedillows.org>	 <200905231124.28925.mb@bu3sch.de>  <4A1809B0.3030109@googlemail.com> <1243090308.4217.6.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	=?ISO-8859-15?Q?Michael_B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755805AbZEWQMg@vger.kernel.org>
In-Reply-To: <1243090308.4217.6.camel@obelisk.thedillows.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

David Dillow wrote:

> I wonder if that is the TCP sawtooth pattern -- run up until we drop
> packets, drop off, repeat. I thought newer congestion algorithms would
> help with that, but I've not kept up, this may be another red-herring --
> like the bisection into genirq.

Actually, I just found out that things are much stranger. A freshly
booted system (I'm using 2.6.29.2 + the r8169 patch sent by Michael
Buesch, by the way) behaves like this:

[  3] local 192.168.178.206 port 44090 connected with 192.168.178.204
port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec    483 MBytes    405 Mbits/sec
[  3] 10.0-20.0 sec    472 MBytes    396 Mbits/sec
[  3] 20.0-30.0 sec    482 MBytes    404 Mbits/sec
[  3] 30.0-40.0 sec    483 MBytes    405 Mbits/sec
[  3] 40.0-50.0 sec    480 MBytes    402 Mbits/sec
[  3] 50.0-60.0 sec    479 MBytes    402 Mbits/sec
[  3]  0.0-60.0 sec  2.81 GBytes    402 Mbits/sec

Then I've been running another test, something along the lines of

	for dest in host1 host1 host2 host2
	do ssh $dest dd of=/dev/null bs=8k count=10240000 </dev/zero &
	done

After a while, I killed the ssh processes and ran iperf again. And this
time, I got:

[  3] local 192.168.178.206 port 58029 connected with 192.168.178.204
port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec    634 MBytes    531 Mbits/sec
[  3] 10.0-20.0 sec    740 MBytes    621 Mbits/sec
[  3] 20.0-30.0 sec    641 MBytes    538 Mbits/sec
[  3] 30.0-40.0 sec    738 MBytes    619 Mbits/sec
[  3] 40.0-50.0 sec    742 MBytes    622 Mbits/sec
[  3] 50.0-60.0 sec    743 MBytes    623 Mbits/sec
[  3]  0.0-60.0 sec  4.14 GBytes    592 Mbits/sec

Obviously, the high-load ssh test (which would kill the device within a
few seconds without the patch) triggers something here.

A few observations later, however, I was convinced that it's not a TCP
congestion or driver issue. Actually, the throughput depends on the CPU
the benchmark is running on. You can see that in gkrellm - whenever the
process jumps to another CPU, the throughput changes. On the four
(virtual) CPUs of the Atom 330, I get these results:

CPU 0:  0.0-60.0 sec  2.65 GBytes    380 Mbits/sec
CPU 1:  0.0-60.0 sec  4.12 GBytes    590 Mbits/sec
CPU 2:  0.0-60.0 sec  3.79 GBytes    543 Mbits/sec
CPU 3:  0.0-60.0 sec  4.13 GBytes    592 Mbits/sec

CPU 0+2 are on the first core, 1+3 on the second.

If I use two connections (iperf -P2) and nail iperf to both threads of a
single core with taskset (the program is multi-threaded, just in case
you wonder), I get this:

CPU 0+2:  0.0-60.0 sec  4.65 GBytes    665 Mbits/sec
CPU 1+3:  0.0-60.0 sec  6.43 GBytes    920 Mbits/sec

That's quite a difference, isn't it?

Now I wonder what CPU 0 is doing...

-- 
Michael "Tired" Riepe <michael.riepe@googlemail.com>
X-Tired: Each morning I get up I die a little
