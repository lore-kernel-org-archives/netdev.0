From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: NAPI, e100, and system performance problem
Date: Sun, 17 Apr 2005 23:11:20 -0700
Message-ID: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

_Summary_
As the part owner of the e100 driver, this issue has been nagging at me
for a while.  NAPI seems to be able to swamp a system with interrupts
and context switches.   In this case the system does not respond to
having zero cpu cycles available by polling more, as I figured it would.
This was mostly based on observation, but I included some quick data
gathering for this mail.


_Background_

I've noticed that when napi is enabled on a 10/100 (e100.c) adapter,
that if I push a lot of small packets through the 10/100 adapter that
the system begins to show interrupt lag.  In this case it is 64 bit
power processor machine.  The processors on this machine generally
execute code very quickly, while the bus is a little slow

With the current e100 driver in NAPI mode the adapter can generate
upwards of 36000 interrupts a second from only receiving 77000
packets/second (pktgen traffic)

_test 1_
I really couldn't think of a decent way to show the lag except to say
that the network and keyboard visibly lag when a 10/100 adapter is
pounding away.
*** Here is the localhost ping data first with an idle system

--- 127.0.0.1 ping statistics ---
100000 packets transmitted, 100000 received, 0% packet loss, time 4332ms
rtt min/avg/max/mdev = 0.008/0.009/0.077/0.005 ms, pipe 2, ipg/ewma
0.043/0.010 ms

*** now while receiving ~77000 packets per second of discardable traffic


--- 127.0.0.1 ping statistics ---
100000 packets transmitted, 100000 received, 0% packet loss, time
26370ms
rtt min/avg/max/mdev = 0.008/0.010/9.410/0.034 ms, pipe 2, ipg/ewma
0.263/0.010 ms

*** ping took 4.3 seconds unloaded and 26.4 seconds when receiving
traffic.

_test 2_
Run netperf with 10 threads to localhost in order to stress the cpus
netserver; netperf -l 60 -H localhost
Shows 100% cpu utilization

Start pktgen at other end, and these are the results from vmstat 2
13  0      0 3711936  95192  92932    0    0     0     0    2 41175 10
90  0  0
14  0      0 3711872  95192  92932    0    0     0     0   16 41886 11
89  0  0
13  0      0 3711824  95192  92932    0    0     0    30    3 44299 11
89  0  0
13  0      0 3711952  95192  92932    0    0     0     0    5 77821  9
91  0  0
--->>> pktgen starts
13  0      0 3711888  95192  92932    0    0     0    16 27057 74014  7
93  0  0
12  0      0 3712016  95192  92932    0    0     0     0 34001 36483  8
92  0  0
13  1      0 3711952  95192  92932    0    0     0    28 31673 35748  8
92  0  0
14  0      0 3711952  95192  92932    0    0     0     2 32145  1411  9
91  0  0
14  0      0 3711952  95192  92932    0    0     0     0 32166  1231  9
91  0  0
procs -----------memory---------- ---swap-- -----io---- --system--
----cpu----
 r  b   swpd   free   buff  cache    si   so    bi    bo    in    cs us
sy id wa
14  0      0 3712088  95192  92932    0    0     0     0 32157  2597  9
91  0  0
13  0      0 3711960  95192  92932    0    0     0     0 32130  1210  9
91  0  0
13  1      0 3711832  95192  92932    0    0     0    28 32095  1182  9
91  0  0
13  0      0 3712088  95192  92932    0    0     0    68 33023 11742  9
91  0  0
14  0      0 3711888  95192  92932    0    0     0     0 32460  1279  9
91  0  0
14  0      0 3712080  95192  92932    0    0     0    30 32126  1908  9
91  0  0
14  0      0 3711952  95192  92932    0    0     0     0 32736 22616  8
92  0  0

*** I expected a more significant drop in interrupts/sec 

_conclusion_

Is there any way we can configure how soon or often to be polled
(called)? For 100Mb speeds at worst we can get about one 64 byte packet
every 9us (if I did my math right) and since the processors don't take
that long to schedule NAPI, process a packet and handle an interrupt, we
just overload the system with interrupts going into and out of napi
mode.  In this case I only have one adapter getting scheduled.

Suggestions? Help? Want me to do more tests?

Thanks for sticking with me...
Jesse

--
Jesse Brandeburg
