From: Rick Jones <rick.jones2@hp.com>
Subject: Data demonstrating the CPU overhead of ACKs
Date: Mon, 07 Mar 2005 18:43:02 -0800
Message-ID: <422D1136.3060601@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Folks -

At some point in the not too distant past I believe I said I'd try to present 
some data on the CPU overhead of ACKs.  I'm afraid it took me a triffle longer 
than I anticipated, with "other" things getting in the way and having to 
track-down some TSO-capable GbE NICs (the cores on the systems I have being 
based on BCM 5701's which IIRC the tg3 driver at least does not enable TSO on)

Sooo....  The data below is from netperf TCP_STREAM tests (version 2.4.0alpha8 
for the intensely curious).  The kernel is a 2.6.11-rc5 kernel.  This happens to 
be using one port of a dual-port Intel GbE NIC.

Going from left to right we have the limit to the number of segments received 
before an ACK is emitted by the receiver (2, 3, 4, ... it was configurable, but 
could not be set to ack-every-segment - that is left as an extrapolation 
excercise for the reader) the remote's SO_RCVBUF (128KB), the local SO_SNDBUF 
(setsockopt of 128KB, getsockopt reporting 256KB), the size of the buffer in 
each send() call (32KB), the length of the test (10 seconds) the throughput in 
10^6 bits per second, the local CPU utilization (this is a 2P system), the 
remote CPU utilization (-1 not measured), the local service demand (microseconds 
of CPU time to transfer a KB of data) and the remote service demand (-1 not 
measured)

I took the numbers out a bit farther than one might just for grins.  I did not 
do any process binding or enable the netperf confidence intervals so the data is 
going to be a little bit noisy.

TSO disabled, netperf 128x32 TCP_STREAM:

2 131072 262144 32768 10.00 941.29 22.14 -1.00 3.853 -1.000
3 131072 262144 32768 10.00 941.26 20.05 -1.00 3.490 -1.000
4 131072 262144 32768 10.00 941.23 18.63 -1.00 3.243 -1.000
5 131072 262144 32768 10.00 941.22 18.21 -1.00 3.169 -1.000
6 131072 262144 32768 10.00 941.22 17.63 -1.00 3.069 -1.000
7 131072 262144 32768 10.00 941.15 17.33 -1.00 3.017 -1.000
8 131072 262144 32768 10.00 941.17 17.04 -1.00 2.966 -1.000
9 131072 262144 32768 10.00 941.04 17.06 -1.00 2.971 -1.000
10 131072 262144 32768 10.00 941.17 16.85 -1.00 2.934 -1.000
11 131072 262144 32768 10.00 940.90 16.71 -1.00 2.910 -1.000
12 131072 262144 32768 10.00 941.14 16.79 -1.00 2.923 -1.000
13 131072 262144 32768 10.00 941.03 16.12 -1.00 2.806 -1.000
14 131072 262144 32768 10.00 940.85 16.09 -1.00 2.802 -1.000
15 131072 262144 32768 10.00 941.01 16.09 -1.00 2.802 -1.000
16 131072 262144 32768 10.00 941.12 15.62 -1.00 2.719 -1.000
17 131072 262144 32768 10.00 941.08 15.87 -1.00 2.764 -1.000
18 131072 262144 32768 10.00 940.94 15.88 -1.00 2.764 -1.000
19 131072 262144 32768 10.00 940.80 15.95 -1.00 2.777 -1.000
20 131072 262144 32768 10.00 940.79 15.80 -1.00 2.752 -1.000
21 131072 262144 32768 10.00 940.90 15.90 -1.00 2.768 -1.000
22 131072 262144 32768 10.00 940.93 15.97 -1.00 2.780 -1.000
23 131072 262144 32768 10.00 941.07 15.43 -1.00 2.687 -1.000
24 131072 262144 32768 10.00 941.04 15.52 -1.00 2.702 -1.000
25 131072 262144 32768 10.00 941.05 16.36 -1.00 2.848 -1.000
26 131072 262144 32768 10.00 940.83 15.54 -1.00 2.706 -1.000
27 131072 262144 32768 10.00 940.88 15.05 -1.00 2.620 -1.000
28 131072 262144 32768 10.00 940.67 15.49 -1.00 2.698 -1.000
29 131072 262144 32768 10.00 940.68 15.53 -1.00 2.705 -1.000
30 131072 262144 32768 10.00 940.62 15.52 -1.00 2.704 -1.000
31 131072 262144 32768 10.00 940.76 15.70 -1.00 2.734 -1.000
32 131072 262144 32768 10.00 940.75 15.52 -1.00 2.703 -1.000

By the time ACKs are deferred for 8 segments rather than 2, the quantity of CPU 
per KB transfered has dropped from 3.853 usec/KB to 2.966 usec/KB, or ~23% (or 
if you prefer to look the other way, 2 segments per ACK takes ~30% more CPU than 
8). By the time we are out to 16 segments, it has dropped to 2.719 or 29% less 
(or ~42% more looking the other way)

Now, with TSO enabled and tcp_tso_win_divisor at its default of 8, still a 
128x32 TCP_STREAM test:

2 131072 262144 32768 10.00 941.37 12.02 -1.00 2.092 -1.000
3 131072 262144 32768 10.00 941.35 10.78 -1.00 1.875 -1.000
4 131072 262144 32768 10.00 941.32 10.95 -1.00 1.906 -1.000
5 131072 262144 32768 10.00 941.33 8.35 -1.00 1.454 -1.000
6 131072 262144 32768 10.00 941.28 9.53 -1.00 1.659 -1.000
7 131072 262144 32768 10.00 941.34 7.75 -1.00 1.348 -1.000
8 131072 262144 32768 10.00 941.28 7.71 -1.00 1.342 -1.000
9 131072 262144 32768 10.00 941.19 7.58 -1.00 1.319 -1.000
10 131072 262144 32768 10.00 941.24 8.36 -1.00 1.456 -1.000
11 131072 262144 32768 10.00 941.18 6.09 -1.00 1.061 -1.000
12 131072 262144 32768 10.00 848.64 8.67 -1.00 1.674 -1.000
13 131072 262144 32768 10.00 941.20 5.82 -1.00 1.013 -1.000
14 131072 262144 32768 10.00 647.50 7.80 -1.00 1.974 -1.000
15 131072 262144 32768 10.00 885.04 9.04 -1.00 1.673 -1.000
16 131072 262144 32768 10.00 740.94 10.74 -1.00 2.375 -1.000
17 131072 262144 32768 10.00 941.12 5.58 -1.00 0.971 -1.000
18 131072 262144 32768 10.00 555.61 7.06 -1.00 2.082 -1.000
19 131072 262144 32768 10.00 941.13 5.46 -1.00 0.951 -1.000
20 131072 262144 32768 10.00 612.37 7.76 -1.00 2.075 -1.000
21 131072 262144 32768 10.00 771.96 7.70 -1.00 1.634 -1.000
22 131072 262144 32768 10.00 867.43 6.87 -1.00 1.297 -1.000
23 131072 262144 32768 10.00 797.88 6.78 -1.00 1.392 -1.000
24 131072 262144 32768 10.00 935.02 5.13 -1.00 0.899 -1.000
25 131072 262144 32768 10.00 735.36 6.03 -1.00 1.344 -1.000
26 131072 262144 32768 10.00 921.27 6.58 -1.00 1.171 -1.000
27 131072 262144 32768 10.00 792.32 6.26 -1.00 1.294 -1.000
28 131072 262144 32768 10.00 935.38 6.05 -1.00 1.060 -1.000
29 131072 262144 32768 10.00 845.99 6.71 -1.00 1.300 -1.000
30 131072 262144 32768 10.00 935.51 5.01 -1.00 0.878 -1.000
31 131072 262144 32768 10.00 751.12 6.30 -1.00 1.374 -1.000
32 131072 262144 32768 10.00 934.96 4.97 -1.00 0.870 -1.000

Here we see that going from 2 to 8 segments per ACK drops the service demand 
~36% (~56% in the other direction) which is thirteen percentage points or ~>50% 
more than the delta for TSO off.  At 16 segments per ACK we see what I will call 
a "throughput anomaly" :)  This is what happens when the sender is not filling 
the congestion window.  That leads to a delayed ACK in the reciever, which 
affects the throughput and it also causes the receiver to start to "re-estimate 
the sender's cwnd, starting IIRC with an immediate ACK and building-up its 
segments per ACK.  If this happens "often enough" the receiver ends-up falling 
back on ack-every-other.  Since there is the anomaly at 16 segments, I'll take 
the data from 17 segments, which shows that the service demand has decreased 
~54% (or that service demand would increase by ~115% assuming I have done the 
math correctly).

Now, if we set tcp_tso_win_divisor to 1 we get even more of those throughput 
anomalies but here is the data from segments per ACK == 2

2 131072 262144 32768 10.00 940.14 9.59 -1.00 1.671 -1.000

which shows service demand even lower than the default case, and I suspect that 
were the throughput anomalies not present a curve similar to those above would 
be seen.

So, we can see that as sending has become more efficient, going from non-TSO to 
TSO, we have a greater percentage of the CPU time in the sender being consumed 
by ACK processing.

If the changes coming in TSO manage to maintain the "keep the cwnd full" 
behaviour of TSO off things should be pretty nice.

Naturally, the subject of burstiness will come-up.  Related to that, the data 
below is a tcpdump trace of a netperf TCP_RR test over that same link 
"simulating" what one might see with a persistent HTTP connection asking for a 
16KB "thing" from the server. Just to keep things simple and the tcpdumps easier 
to read, I've disabled TSO.  16K was pulled from the ether to demonstrate the point.

With the Linux system as the server, trace from the server:

(sorry about wrap)  the port 12865 port stuff is the netperf control connection. 
You can ignore that.  The port 32970 is the data connection.

000000 192.168.1.213.58582 > 192.168.1.212.12865: S 1870881128:1870881128(0) win 
32768 <mss 1460,wscale 0,nop> (DF)
000005 192.168.1.212.12865 > 192.168.1.213.58582: S 3776130675:3776130675(0) ack 
1870881129 win 5840 <mss 1460,nop,wscale 2> (DF)
000537 192.168.1.213.58582 > 192.168.1.212.12865: P 1:257(256) ack 1 win 32768 (DF)
000039 192.168.1.212.12865 > 192.168.1.213.58582: . ack 257 win 1728 (DF)
002299 192.168.1.212.12865 > 192.168.1.213.58582: P 1:257(256) ack 257 win 1728 (DF)
000169 192.168.1.213.58583 > 192.168.1.212.32970: S 1870933516:1870933516(0) win 
32768 <mss 1460,wscale 0,nop> (DF)
000022 192.168.1.212.32970 > 192.168.1.213.58583: S 3760261556:3760261556(0) ack 
1870933517 win 5840 <mss 1460,nop,wscale 2> (DF)
000219 192.168.1.213.58583 > 192.168.1.212.32970: P 1:129(128) ack 1 win 32768 (DF)

the request arrives above and we see the usual slow-start stuff below, mised-in 
with the receiver learning the cwnd for its ACK avoidance:

000018 192.168.1.212.32970 > 192.168.1.213.58583: . ack 129 win 1460 (DF)
000060 192.168.1.212.32970 > 192.168.1.213.58583: . 1:1461(1460) ack 129 win 
1460 (DF)
000019 192.168.1.212.32970 > 192.168.1.213.58583: . 1461:2921(1460) ack 129 win 
1460 (DF)
000007 192.168.1.212.32970 > 192.168.1.213.58583: . 2921:4381(1460) ack 129 win 
1460 (DF)
000146 192.168.1.213.58583 > 192.168.1.212.32970: . ack 1461 win 32768 (DF)
000017 192.168.1.212.32970 > 192.168.1.213.58583: . 4381:5841(1460) ack 129 win 
1460 (DF)
000004 192.168.1.212.32970 > 192.168.1.213.58583: . 5841:7301(1460) ack 129 win 
1460 (DF)
000004 192.168.1.213.58583 > 192.168.1.212.32970: . ack 4381 win 32768 (DF)
000006 192.168.1.212.32970 > 192.168.1.213.58583: . 7301:8761(1460) ack 129 win 
1460 (DF)
000003 192.168.1.212.32970 > 192.168.1.213.58583: . 8761:10221(1460) ack 129 win 
1460 (DF)
000003 192.168.1.212.32970 > 192.168.1.213.58583: . 10221:11681(1460) ack 129 
win 1460 (DF)
000090 192.168.1.213.58583 > 192.168.1.212.32970: . ack 8761 win 32768 (DF)
000007 192.168.1.212.32970 > 192.168.1.213.58583: P 11681:13141(1460) ack 129 
win 1460 (DF)
000017 192.168.1.212.32970 > 192.168.1.213.58583: . 13141:14601(1460) ack 129 
win 1460 (DF)
000024 192.168.1.212.32970 > 192.168.1.213.58583: . 14601:16061(1460) ack 129 
win 1460 (DF)
000015 192.168.1.212.32970 > 192.168.1.213.58583: P 16061:16385(324) ack 129 win 
1460 (DF)
000064 192.168.1.213.58583 > 192.168.1.212.32970: . ack 14601 win 32768 (DF)

There was the last of the 16KB response to the first request.  Now we have the 
next request:

000121 192.168.1.213.58583 > 192.168.1.212.32970: P 129:257(128) ack 16385 win 
32768 (DF)
000026 192.168.1.212.32970 > 192.168.1.213.58583: . 16385:17845(1460) ack 257 
win 1460 (DF)
000010 192.168.1.212.32970 > 192.168.1.213.58583: . 17845:19305(1460) ack 257 
win 1460 (DF)
000005 192.168.1.212.32970 > 192.168.1.213.58583: . 19305:20765(1460) ack 257 
win 1460 (DF)
000006 192.168.1.212.32970 > 192.168.1.213.58583: . 20765:22225(1460) ack 257 
win 1460 (DF)
000007 192.168.1.212.32970 > 192.168.1.213.58583: . 22225:23685(1460) ack 257 
win 1460 (DF)
000018 192.168.1.212.32970 > 192.168.1.213.58583: . 23685:25145(1460) ack 257 
win 1460 (DF)
000007 192.168.1.212.32970 > 192.168.1.213.58583: . 25145:26605(1460) ack 257 
win 1460 (DF)

Notice how a 7 segment burst was emitted by the sender.  That same seven segment 
burst would have been emitted even if the receiver was doing ack-every-other.

000171 192.168.1.213.58583 > 192.168.1.212.32970: . ack 23685 win 32768 (DF)
000017 192.168.1.212.32970 > 192.168.1.213.58583: . 26605:28065(1460) ack 257 
win 1460 (DF)
000013 192.168.1.212.32970 > 192.168.1.213.58583: . 28065:29525(1460) ack 257 
win 1460 (DF)
000004 192.168.1.212.32970 > 192.168.1.213.58583: . 29525:30985(1460) ack 257 
win 1460 (DF)
000004 192.168.1.212.32970 > 192.168.1.213.58583: . 30985:32445(1460) ack 257 
win 1460 (DF)
000004 192.168.1.212.32970 > 192.168.1.213.58583: P 32445:32769(324) ack 257 win 
1460 (DF)
000207 192.168.1.213.58583 > 192.168.1.212.32970: . ack 32445 win 32768 (DF)

Finish that request, here comes #3.  This time it is an 8 segment burst as the 
cwnd grows:

000009 192.168.1.213.58583 > 192.168.1.212.32970: P 257:385(128) ack 32769 win 
32768 (DF)
000016 192.168.1.212.32970 > 192.168.1.213.58583: . 32769:34229(1460) ack 385 
win 1460 (DF)
000011 192.168.1.212.32970 > 192.168.1.213.58583: . 34229:35689(1460) ack 385 
win 1460 (DF)
000005 192.168.1.212.32970 > 192.168.1.213.58583: . 35689:37149(1460) ack 385 
win 1460 (DF)
000006 192.168.1.212.32970 > 192.168.1.213.58583: . 37149:38609(1460) ack 385 
win 1460 (DF)
000006 192.168.1.212.32970 > 192.168.1.213.58583: . 38609:40069(1460) ack 385 
win 1460 (DF)
000024 192.168.1.212.32970 > 192.168.1.213.58583: . 40069:41529(1460) ack 385 
win 1460 (DF)
000006 192.168.1.212.32970 > 192.168.1.213.58583: . 41529:42989(1460) ack 385 
win 1460 (DF)
000008 192.168.1.212.32970 > 192.168.1.213.58583: . 42989:44449(1460) ack 385 
win 1460 (DF)
000159 192.168.1.213.58583 > 192.168.1.212.32970: . ack 42989 win 32768 (DF)
000017 192.168.1.212.32970 > 192.168.1.213.58583: . 44449:45909(1460) ack 385 
win 1460 (DF)
000013 192.168.1.212.32970 > 192.168.1.213.58583: . 45909:47369(1460) ack 385 
win 1460 (DF)
000003 192.168.1.212.32970 > 192.168.1.213.58583: . 47369:48829(1460) ack 385 
win 1460 (DF)
000004 192.168.1.212.32970 > 192.168.1.213.58583: P 48829:49153(324) ack 385 win 
1460 (DF)

And now this one is a 9 segment burst:

000213 192.168.1.213.58583 > 192.168.1.212.32970: P 385:513(128) ack 49153 win 
32768 (DF)
000025 192.168.1.212.32970 > 192.168.1.213.58583: . 49153:50613(1460) ack 513 
win 1460 (DF)
000014 192.168.1.212.32970 > 192.168.1.213.58583: . 50613:52073(1460) ack 513 
win 1460 (DF)
000006 192.168.1.212.32970 > 192.168.1.213.58583: . 52073:53533(1460) ack 513 
win 1460 (DF)
000006 192.168.1.212.32970 > 192.168.1.213.58583: . 53533:54993(1460) ack 513 
win 1460 (DF)
000007 192.168.1.212.32970 > 192.168.1.213.58583: . 54993:56453(1460) ack 513 
win 1460 (DF)
000023 192.168.1.212.32970 > 192.168.1.213.58583: . 56453:57913(1460) ack 513 
win 1460 (DF)
000008 192.168.1.212.32970 > 192.168.1.213.58583: . 57913:59373(1460) ack 513 
win 1460 (DF)
000015 192.168.1.212.32970 > 192.168.1.213.58583: . 59373:60833(1460) ack 513 
win 1460 (DF)
000005 192.168.1.212.32970 > 192.168.1.213.58583: . 60833:62293(1460) ack 513 
win 1460 (DF)
000141 192.168.1.213.58583 > 192.168.1.212.32970: . ack 60833 win 32768 (DF)
000022 192.168.1.212.32970 > 192.168.1.213.58583: . 62293:63753(1460) ack 513 
win 1460 (DF)
000013 192.168.1.212.32970 > 192.168.1.213.58583: . 63753:65213(1460) ack 513 
win 1460 (DF)
000004 192.168.1.212.32970 > 192.168.1.213.58583: P 65213:65537(324) ack 513 win 
1460 (DF)

Now, when the receiver is doing ack-every-other, starting with the second and 
third transactions to keep this from being heinously long...

We still get a 6 segment burst onto the wire for the second transaction before 
the first ACK arives, and I suspect the sender was not stuck waiting for that ACK:

000003 192.168.1.213.58596 > 192.168.1.212.32971: P 129:257(128) ack 16385 win 
32768 (DF)
000017 192.168.1.212.32971 > 192.168.1.213.58596: . 16385:17845(1460) ack 257 
win 1460 (DF)
000011 192.168.1.212.32971 > 192.168.1.213.58596: . 17845:19305(1460) ack 257 
win 1460 (DF)
000005 192.168.1.212.32971 > 192.168.1.213.58596: . 19305:20765(1460) ack 257 
win 1460 (DF)
000007 192.168.1.212.32971 > 192.168.1.213.58596: . 20765:22225(1460) ack 257 
win 1460 (DF)
000018 192.168.1.212.32971 > 192.168.1.213.58596: . 22225:23685(1460) ack 257 
win 1460 (DF)
000006 192.168.1.212.32971 > 192.168.1.213.58596: . 23685:25145(1460) ack 257 
win 1460 (DF)
000046 192.168.1.213.58596 > 192.168.1.212.32971: . ack 19305 win 32768 (DF)
000008 192.168.1.212.32971 > 192.168.1.213.58596: . 25145:26605(1460) ack 257 
win 1460 (DF)
000004 192.168.1.212.32971 > 192.168.1.213.58596: . 26605:28065(1460) ack 257 
win 1460 (DF)
000004 192.168.1.212.32971 > 192.168.1.213.58596: . 28065:29525(1460) ack 257 
win 1460 (DF)
000105 192.168.1.213.58596 > 192.168.1.212.32971: . ack 22225 win 32768 (DF)
000007 192.168.1.212.32971 > 192.168.1.213.58596: P 29525:30985(1460) ack 257 
win 1460 (DF)
000005 192.168.1.213.58596 > 192.168.1.212.32971: . ack 25145 win 32768 (DF)
000003 192.168.1.213.58596 > 192.168.1.212.32971: . ack 28065 win 32768 (DF)
000006 192.168.1.212.32971 > 192.168.1.213.58596: . 30985:32445(1460) ack 257 
win 1460 (DF)
000007 192.168.1.212.32971 > 192.168.1.213.58596: P 32445:32769(324) ack 257 win 
1460 (DF)
000099 192.168.1.213.58596 > 192.168.1.212.32971: . ack 30985 win 32768 (DF)

And one instance of a twoACK "burst" arriving above.  For transaction three, we 
see a 9 segment burst going-out and it may have simply been a matter of timing 
keeping it from being any larger in this trace:

000013 192.168.1.213.58596 > 192.168.1.212.32971: P 257:385(128) ack 32769 win 
32768 (DF)
000014 192.168.1.212.32971 > 192.168.1.213.58596: . 32769:34229(1460) ack 385 
win 1460 (DF)
000012 192.168.1.212.32971 > 192.168.1.213.58596: . 34229:35689(1460) ack 385 
win 1460 (DF)
000006 192.168.1.212.32971 > 192.168.1.213.58596: . 35689:37149(1460) ack 385 
win 1460 (DF)
000006 192.168.1.212.32971 > 192.168.1.213.58596: . 37149:38609(1460) ack 385 
win 1460 (DF)
000006 192.168.1.212.32971 > 192.168.1.213.58596: . 38609:40069(1460) ack 385 
win 1460 (DF)
000021 192.168.1.212.32971 > 192.168.1.213.58596: . 40069:41529(1460) ack 385 
win 1460 (DF)
000015 192.168.1.212.32971 > 192.168.1.213.58596: . 41529:42989(1460) ack 385 
win 1460 (DF)
000006 192.168.1.212.32971 > 192.168.1.213.58596: . 42989:44449(1460) ack 385 
win 1460 (DF)
000011 192.168.1.212.32971 > 192.168.1.213.58596: . 44449:45909(1460) ack 385 
win 1460 (DF)
000020 192.168.1.213.58596 > 192.168.1.212.32971: . ack 35689 win 32768 (DF)
000013 192.168.1.213.58596 > 192.168.1.212.32971: . ack 38609 win 32768 (DF)
000008 192.168.1.212.32971 > 192.168.1.213.58596: . 45909:47369(1460) ack 385 
win 1460 (DF)
000005 192.168.1.212.32971 > 192.168.1.213.58596: . 47369:48829(1460) ack 385 
win 1460 (DF)
000005 192.168.1.212.32971 > 192.168.1.213.58596: P 48829:49153(324) ack 385 win 
1460 (DF)
000089 192.168.1.213.58596 > 192.168.1.212.32971: . ack 41529 win 32768 (DF)
000008 192.168.1.213.58596 > 192.168.1.212.32971: . ack 44449 win 32768 (DF)
000004 192.168.1.213.58596 > 192.168.1.212.32971: . ack 47369 win 32768 (DF)

and we get a three ACK burst coming in.  It gets burstier the longer we look in 
the trace.

Had the systems been separated by longer pipes (I didn't take time to setup a 
delay simulator) and/or a greater number of transactions on the connection, the 
bursts of both data segments and ACKs would have been even greater for 
request/response traffic.

My point?  Basically this - that unless we require every user send to go through 
  slow-start..., there will be bursty traffic - and traffic with bursts of a 
non-trivial number of segments.  That behavour is happening today, and the 
network does not seem to have come to a crashing halt.

And those bursts of ACKs aren't really doing us all that much good (modulo the 
contemporary requirement of cwnd growth per-ACK rather than per byte ACKed). 
Certainly they aren't causing data to be paced onto the network.

Perhaps paradoxically, the burstiness of the arriving ACKs is actually reduced 
by an ACK avoiding reciever :)

Anyhow, I hope this data is interesting, useful and thought provoking.  I'm 
ready with my nomex :) and am sure I'll learn something from the responses.

sincerely,

rick jones
