From: Robert Olsson <robert@herjulf.net>
Subject: Re: RCU problems in fib_table_insert
Date: Wed, 7 Apr 2010 08:10:13 +0200
Message-ID: <19388.8645.99295.495371@gargle.gargle.HOWL>
References: <20100321202525.GA966@basil.fritz.box>
	<19367.3002.324694.563877@gargle.gargle.HOWL>
	<20100322065133.GG2517@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <robert@herjulf.net>,
	Andi Kleen <andi@firstfloor.org>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org, Jens.Laas@its.uu.se
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from av10-1-sn2.hy.skanova.net ([81.228.8.181]:43373 "EHLO
	av10-1-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963Ab0DGGIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 02:08:16 -0400
In-Reply-To: <20100322065133.GG2517@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Paul E. McKenney writes:
 > On Mon, Mar 22, 2010 at 07:18:34AM +0100, Robert Olsson wrote:
 > > 
 > > Seems like Paul and Eric fixed this problem... We use fib_trie with 
 > > major infrastructure but always disable preempt. It was unsafe w.
 > > preempt at least before Jareks P. patches about a year ago. I havn't
 > > tested w. preempt after that but maybe someone else have...


 > Though I must admit that I would be surprised if there wasn't
 > more adjustment required in net/ipv4/fib_trie.c -- lots of
 > rcu_dereference()s in there.

 Hi, a follow on this thread. 

 Maybe I was to pessimistic... we've setup  for stress test running during 
 easter vacation

 Testing the fib_trie with preempt enabled. Continuesly loading/flushing  
 "full BGP" via a test script, while routing without the route cache 
 to further stress locking. Average load about 300 kpps. Some more test 
 details below.

 The test was manually stopped after 6 days. So it seems like preempt/rcu 
 has been improved with fib_trie.
 
 Thanks
					--ro

HW
--
CPU  Opteron 2 * 6174, TYAN S8230. Intel 82599

Kernel from net-next-2.6
------------------------
Version 2.6.34-rc1bifrost-x86_64 (gcc version 4.3.2 (GCC) ) #4 SMP PREEMPT
CONFIG_PREEMPT=y
CONFIG_DEBUG_PREEMPT=y
CONFIG_IP_FIB_TRIE=y
CONFIG_FIB_RULES=y
CONFIG_TREE_RCU=y
CONFIG_RCU_FANOUT=64

IP table
--------
"BGP" 279 k routes

Test duration
-------------
09:34:14 up 6 days, 20:57,  4 users,  load average: 5.28, 5.87, 5.53

Test script
-----------
#! /bin/bash
while(true) do
  ip -batch /etc/inet_route_add.bat; 
  ip route list | wc -l;  ( 279 k routes )
  ifconfig eth1 down 
  ifconfig eth1 10.10.11.1 netmask 255.255.255.0
  ip route list | wc -l;  ( 3 routes )
done;

/proc/net/softnet_stat

0000d503 00000000 00000014 00000000 00000000 00000000 00000000 00000000 00000000 00000000
4cc1ecfb 00000000 02bb1bcb 00000000 00000000 00000000 00000000 00000000 00000000 00000000
4cb95da1 00000000 02cc6574 00000000 00000000 00000000 00000000 00000000 00000000 00000000
4cb17932 00000000 02e1abdf 00000000 00000000 00000000 00000000 00000000 00000000 00000000
4cc40ad9 00000000 02f53db0 00000000 00000000 00000000 00000000 00000000 00000000 00000000
4cbfe34f 00000000 0306a88d 00000000 00000000 00000000 00000000 00000000 00000000 00000000
4ccb10e9 00000000 03d3a11d 00000000 00000000 00000000 00000000 00000000 00000000 00000000
4ca84c29 00000000 03be0ca1 00000000 00000000 00000000 00000000 00000000 00000000 00000000
4cb710f8 00000000 04070289 00000000 00000000 00000000 00000000 00000000 00000000 00000000
0b505d55 00000000 038a9bc0 00000000 00000000 00000000 00000000 00000000 00000000 00000000
0b54a7be 00000000 03a5de6d 00000000 00000000 00000000 00000000 00000000 00000000 00000000
0b5be81f 00000000 03be018c 00000000 00000000 00000000 00000000 00000000 00000000 00000000
0b51fdd0 00000000 0559fdd6 00000000 00000000 00000000 00000000 00000000 00000000 00000000
0b4fa6fd 00000000 056311dc 00000000 00000000 00000000 00000000 00000000 00000000 00000000
0b4a61d3 00000000 056a9276 00000000 00000000 00000000 00000000 00000000 00000000 00000000
0b454970 00000000 0572add1 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000

FYI. CPU0 is resvered for BGP/ssh/stats etc
