From: Rick Jones <rick.jones2@hp.com>
Subject: Socket buffer sizes with autotuning
Date: Tue, 22 Apr 2008 17:38:59 -0700
Message-ID: <480E8523.4030007@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:37021 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755636AbYDWAjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 20:39:03 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [16.89.104.60])
	by g5t0009.atlanta.hp.com (Postfix) with ESMTP id 3CF2A3031C
	for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 00:39:01 +0000 (UTC)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id RAA10105
	for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 17:39:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of the issues with netperf and linux is that netperf only snaps the 
socket buffer size at the beginning of the connection.  This of course 
does not catch what the socket buffer size might become over the 
lifetime of the connection.  So, in the in-development "omni" tests I've 
added code that when running on Linux will snap the socket buffer sizes 
at both the beginning and end of the data connection.  I was a triffle 
surprised at some of what I saw with a 1G connection between systems - 
when autoscaling/ranging/tuning/whatever was active (netperf taking 
defaults and not calling setsockopt()) I was seeing the socket buffer 
size at the end of the connection up at 4MB:

sut34:~/netperf2_trunk# netperf -l 1 -t omni -H oslowest -- -d 4 -o bar 
-s -1 -S -1 -m ,16K
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to oslowest.raj 
(10.208.0.1) port 0 AF_INET
Throughput,Direction,Local Release,Local Recv Socket Size 
Requested,Local Recv Socket Size Initial,Local Recv Socket Size 
Final,Remote Release,Remote Send Socket Size Requested,Remote Send 
Socket Size Initial,Remote Send Socket Size Final
940.52,Receive,2.6.25-raj,-1,87380,4194304,2.6.18-5-mckinley,-1,16384,4194304

Which was the limit of the autotuning:

net.ipv4.tcp_wmem = 16384       16384   4194304
net.ipv4.tcp_rmem = 16384       87380   4194304

The test above is basically the omni version of a TCP_MAERTS test from a 
2.6.18 system to a 2.6.25 system (kernel bits grabbed about 40 minutes 
ago from http://www.kernel.org/hg/linux-2.6.  The receiving system on 
which the 2.6.25 bits were compiled and run started life as a Debian 
Lenny/Testing system.  The sender is iirc Debian Etch.

It seemed odd to me that one would need a 4MB socket buffer to get 
link-rate on gigabit, so I ran a quick set of tests to confirm in my 
mind that indeed, a much smaller socket buffer was sufficient:

sut34:~/netperf2_trunk# HDR="-P 1"; for i in -1 32K 64K 128K 256K 512K; 
do netperf -l 20 -t omni -H oslowest $HDR -- -d 4 -o bar -s $i -S $i -m 
,16K; HDR="-P 0"; done
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to oslowest.raj 
(10.208.0.1) port 0 AF_INET
Throughput,Direction,Local Release,Local Recv Socket Size 
Requested,Local Recv Socket Size Initial,Local Recv Socket Size 
Final,Remote Release,Remote Send Socket Size Requested,Remote Send 
Socket Size Initial,Remote Send Socket Size Final
941.38,Receive,2.6.25-raj,-1,87380,4194304,2.6.18-5-mckinley,-1,16384,4194304
939.29,Receive,2.6.25-raj,32768,65536,65536,2.6.18-5-mckinley,32768,65536,65536
940.28,Receive,2.6.25-raj,65536,131072,131072,2.6.18-5-mckinley,65536,131072,131072
940.96,Receive,2.6.25-raj,131072,262142,262142,2.6.18-5-mckinley,131072,253952,253952
940.99,Receive,2.6.25-raj,262144,262142,262142,2.6.18-5-mckinley,262144,253952,253952
940.98,Receive,2.6.25-raj,524288,262142,262142,2.6.18-5-mckinley,524288,253952,253952

And then I decided to let the receiver autotune while the sender was 
either autotune or fixed (simulating something other than Linux sending 
I suppose):
sut34:~/netperf2_trunk# HDR="-P 1"; for i in -1 32K 64K 128K 256K 512K; 
do netperf -l 20 -t omni -H oslowest $HDR -- -d 4 -o bar -s -1 -S $i -m 
,16K; HDR="-P 0"; done
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to oslowest.raj 
(10.208.0.1) port 0 AF_INET
Throughput,Direction,Local Release,Local Recv Socket Size 
Requested,Local Recv Socket Size Initial,Local Recv Socket Size 
Final,Remote Release,Remote Send Socket Size Requested,Remote Send 
Socket Size Initial,Remote Send Socket Size Final
941.38,Receive,2.6.25-raj,-1,87380,4194304,2.6.18-5-mckinley,-1,16384,4194304
941.34,Receive,2.6.25-raj,-1,87380,1337056,2.6.18-5-mckinley,32768,65536,65536
941.35,Receive,2.6.25-raj,-1,87380,1814576,2.6.18-5-mckinley,65536,131072,131072
941.38,Receive,2.6.25-raj,-1,87380,2645664,2.6.18-5-mckinley,131072,253952,253952
941.39,Receive,2.6.25-raj,-1,87380,2649728,2.6.18-5-mckinley,262144,253952,253952
941.38,Receive,2.6.25-raj,-1,87380,2653792,2.6.18-5-mckinley,524288,253952,253952

Finally to see what was going on the wire (in case it was simply the 
socket buffer getting larger and not also the window) I took a packet 
trace on the sender to look at the window updates coming back, and sure 
enough, by the end of the connection (wscale = 7) the advertised window 
was huge:

17:10:00.522200 IP sut34.raj.53459 > oslowest.raj.37322: S 
3334965237:3334965237(0) win 5840 <mss 1460,sackOK,timestamp 4294921737 
0,nop,wscale 7>
17:10:00.522214 IP oslowest.raj.37322 > sut34.raj.53459: S 
962695631:962695631(0) ack 3334965238 win 5792 <mss 
1460,sackOK,timestamp 3303630187 4294921737,nop,wscale 7>

...

17:10:01.554698 IP sut34.raj.53459 > oslowest.raj.37322: . ack 121392225 
win 24576 <nop,nop,timestamp 4294921995 3303630438>
17:10:01.554706 IP sut34.raj.53459 > oslowest.raj.37322: . ack 121395121 
win 24576 <nop,nop,timestamp 4294921995 3303630438>

I also checked (during a different connection, autotuning at both ends) 
how much was actually queued at the sender, and it was indeed rather large:

oslowest:~# netstat -an | grep ESTAB
...
tcp    0 2760560 10.208.0.1:40500    10.208.0.45:42049   ESTABLISHED
...

Is this expected behaviour?

rick jones
