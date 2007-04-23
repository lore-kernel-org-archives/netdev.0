From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net-2.6.22 UDP stalls/hangs
Date: Mon, 23 Apr 2007 15:37:14 -0700
Message-ID: <20070423153714.71b9d99e.akpm@linux-foundation.org>
References: <20070423.141706.92341313.davem@davemloft.net>
	<20070423144557.8c74c4b0.akpm@linux-foundation.org>
	<20070423151240.0e8cabed.akpm@linux-foundation.org>
	<20070423.151531.70219647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:42945 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754390AbXDWWhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 18:37:17 -0400
In-Reply-To: <20070423.151531.70219647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Apr 2007 15:15:31 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Mon, 23 Apr 2007 15:12:40 -0700
> 
> > which is just stupid.  The rtnl_lock() is right there in ip_mc_join_group().
> > And this is a different architecture and config and compiler from yesterday's
> > fun.  And no scheduler patches involved here.
> 
> Perhaps something on another cpu is dropping the rtnl semaphore one
> times too many.
> 
> Recently a bug of this nature was discovered in the wireless stack.
> But unless you have a wireless device in this box too, it's probably
> unrelated.

Could be.  But I'd expect the mutex code to whine about the extra unlock. 
And about from an unlock from a different thread.  If I have that option
turned on.

Oh well, one thing at a time.  The good news is that I can reproduce the
problem with netperf.

kpm:/usr/src/netperf-2.4.3> netperf -H akpm2 -t UDP_RR
UDP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to akpm2 (172.18.116.155) port 0 AF_INET
netperf: receive_response: no response received. errno 0 counter 0

That's running netserver on the test machine.

The machine running netperf is 172.18.116.160 and the test machine running
netserver is 172.18.116.155

tcpdump from the test machine:

15:24:37.924210 802.1d config 8000.00:18:74:5d:04:66.80ae root 0066.00:15:c7:20:57:c0 pathcost 4 age 1 max 20 hello 2 fdelay 15 
15:24:38.859309 IP 172.18.119.252.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=standby group=1 addr=172.18.119.254
15:24:39.078273 IP 172.18.119.253.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=active group=1 addr=172.18.119.254
15:24:39.924074 802.1d config 8000.00:18:74:5d:04:66.80ae root 0066.00:15:c7:20:57:c0 pathcost 4 age 1 max 20 hello 2 fdelay 15 
15:24:40.017081 IP 172.24.0.7.domain > 172.18.116.57.37456:  59635 4/7/6 CNAME[|domain]
15:24:41.383433 IP 172.18.116.160.33137 > 172.18.116.155.12865: S 2760291763:2760291763(0) win 5840 <mss 1460,sackOK,timestamp 1967355840 0,nop,wscale 8>
15:24:41.383479 IP 172.18.116.155.12865 > 172.18.116.160.33137: S 1640262480:1640262480(0) ack 2760291764 win 5792 <mss 1460,sackOK,timestamp 7714 1967355840,nop,wscale 7>
15:24:41.383683 IP 172.18.116.160.33137 > 172.18.116.155.12865: . ack 1 win 23 <nop,nop,timestamp 1967355840 7714>
15:24:41.383883 IP 172.18.116.160.33137 > 172.18.116.155.12865: P 1:257(256) ack 1 win 23 <nop,nop,timestamp 1967355840 7714>
15:24:41.383902 IP 172.18.116.155.12865 > 172.18.116.160.33137: . ack 257 win 54 <nop,nop,timestamp 7714 1967355840>
15:24:41.384065 IP 172.18.116.155.12865 > 172.18.116.160.33137: P 1:257(256) ack 257 win 54 <nop,nop,timestamp 7714 1967355840>
15:24:41.587266 IP 172.18.116.155.12865 > 172.18.116.160.33137: P 1:257(256) ack 257 win 54 <nop,nop,timestamp 7765 1967355840>
15:24:41.839234 IP 172.18.119.252.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=standby group=1 addr=172.18.119.254
15:24:41.924303 802.1d config 8000.00:18:74:5d:04:66.80ae root 0066.00:15:c7:20:57:c0 pathcost 4 age 1 max 20 hello 2 fdelay 15 
15:24:41.995285 IP 172.18.116.155.12865 > 172.18.116.160.33137: P 1:257(256) ack 257 win 54 <nop,nop,timestamp 7867 1967355840>
15:24:42.030341 IP 172.18.119.253.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=active group=1 addr=172.18.119.254
15:24:42.811330 IP 172.18.116.155.12865 > 172.18.116.160.33137: P 1:257(256) ack 257 win 54 <nop,nop,timestamp 8071 1967355840>
15:24:43.924183 802.1d config 8000.00:18:74:5d:04:66.80ae root 0066.00:15:c7:20:57:c0 pathcost 4 age 1 max 20 hello 2 fdelay 15 
15:24:44.121880 IP 172.24.0.7.domain > 172.18.116.22.46700:  52073* 1/4/4 A[|domain]
15:24:44.443419 IP 172.18.116.155.12865 > 172.18.116.160.33137: P 1:257(256) ack 257 win 54 <nop,nop,timestamp 8479 1967355840>
15:24:44.723257 IP 172.18.119.252.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=standby group=1 addr=172.18.119.254
15:24:44.886356 IP 172.18.119.253.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=active group=1 addr=172.18.119.254
15:24:45.924263 802.1d config 8000.00:18:74:5d:04:66.80ae root 0066.00:15:c7:20:57:c0 pathcost 4 age 1 max 20 hello 2 fdelay 15 
15:24:47.659300 IP 172.18.119.252.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=standby group=1 addr=172.18.119.254
15:24:47.707599 IP 172.18.116.155.12865 > 172.18.116.160.33137: P 1:257(256) ack 257 win 54 <nop,nop,timestamp 9295 1967355840>
15:24:47.874419 IP 172.18.119.253.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=active group=1 addr=172.18.119.254
15:24:47.952350 802.1d config 8000.00:18:74:5d:04:66.80ae root 0066.00:15:c7:20:57:c0 pathcost 4 age 1 max 20 hello 2 fdelay 15 
15:24:48.037569 IP 172.24.0.7.domain > 172.18.117.18.46665:  59092 2/7/6 CNAME[|domain]

So I think we did a bit of TCP chatter then no UDP at all?

It's interesting that the test machine can see other people's DNS queries
go past.


