From: Chris Siebenmann <cks@utcc.utoronto.ca>
Subject: [IPSEC] TCP session over ESP transport stalls after a re-keying
Date: Wed, 9 Jun 2004 04:07:48 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <04Jun9.040752edt.3014@ugw.utcc.utoronto.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 I seem to be encountering a problem where a active TCP sessions
running over an IPSEC ESP transport layer stalls out immediately
after the IKE daemons involved re-key the connection.

 Environment: Fedora Core 2 and current 2.6.7-rc3 (from BitKeeper)
kernels on both sides, using the FC2 racoon for key exchange. The
SPDs are symmetric as
	<A> <B> any -P <dir> ipsec esp/transport//require ;
(straight transport; there are no tunnels involved.)

 Racoon negociates the keys on initial startup and correctly re-keys as
the key durations expire, and things like ping work throughout (although
ping seems to sometimes skip a packet when racoon removes the old keys).
However, a ssh session from one machine to the other running 'top' (or
apparently any other data generator) will usually stall out when the
racoon daemons remove the old keys after a re-keying.

 In the following discussion, let the machine running ssh be A (the
client) and the machine ssh'd to that is running top be B (the server).

 According to tcpdump, at the moment of the stall almost always the last
traffic was a packet from B to A (presumably a top update) followed
immediately by a A to B packet (presumably the ACK for same). Sometimes
this pair is in the old (still valid) keys, a few times this pair is in
the newly established keys (if it happens just after the switchover).
Once this happens, there seems to be no further transmissions either way
(even if I wait quite a while).

 On B, 'netstat --inet' shows a growing send queue. On A, send and
receive queues show as 0 bytes.

 When the stall happens, B's kernel reports:
	pmtu discovery on SA ESP/<new B->A key>/80646633
repeatedly. A's kernel shows no reports. (The ethernet MTUs are
standard on both ends.)

 If one bangs on the keyboard A will send packets to B, with B usually
sending back, but the 'top' display never updates and B appears to send
nothing but immediate replies to A's packets.

 If I kill the racoon daemons, flush the SPDs, and let things sit,
B eventually wakes up and starts sending to A (in clear, since there
are no SPDs to dictate otherwise). The tcpdump output in this situation
looks like
	B.ssh > A.40326: P 654520954:654522386(1432) ack 2913244198 win 11552 <nop,nop,timestamp 3125008 123714466>
	A.40326 > B.ssh: . ack 1432 win 62718 <nop,nop,timestamp 123769489 3125008>
	B.ssh > A.40326: . 1432:2864(1432) ack 1 win 11552 <nop,nop,timestamp 3125009 123769489>
	A.40326 > B.ssh: . ack 2864 win 62718 <nop,nop,timestamp 123769490 3125009>
(And so on). If one has banged on the keyboard on A during the hang, one
sees a similar pattern but eventually A wakes up and starts sending:
	A.40333 > B.ssh: P 1:49(48) ack 45872 win 54416 <nop,nop,timestamp 124455007 3810524>
	B.ssh > A.40333: . ack 49 win 11552 <nop,nop,timestamp 3810531 124455007>
[...]
	B.ssh > A.40333: . 51568:53000(1432) ack 49 win 11552 <nop,nop,timestamp 3810536 124455009>
	A.40333 > B.ssh: . ack 53000 win 63008 <nop,nop,timestamp 124455017 3810535>
	A.40333 > B.ssh: P 49:97(48) ack 53000 win 63008 <nop,nop,timestamp 124455017 3810535>
	B.ssh > A.40333: P 53000:54368(1368) ack 49 win 11552 <nop,nop,timestamp 3810541 124455017>
	B.ssh > A.40333: . ack 97 win 11552 <nop,nop,timestamp 3810582 124455017>
(All the A to B data was generated during the stall, despite the 
(re)transmits much later.)

 Unfortunately I have been unsuccessful in my attempts to build a
version of tcpdump that will decrypt ESP packets, so I cannot say what
is being sent & received while the SPDs are active. Please let me know
if there's a better tool for this that I should be using.

 In case it matters, A is a SMP Pentium with an Intel 82557/8/9 using
the e100 driver; B is a uniprocessor Athlon with a 3Com 3C940 using the
sk98lin driver. Both are running at 100Mbits, but they're on different
subnets.

 I would be happy to provide any further information people want.

 Many thanks in advance. My apologies if this is a FAQ (or if this is
the wrong mailing list).

	- cks
