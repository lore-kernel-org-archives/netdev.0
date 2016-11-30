From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Wed, 30 Nov 2016 11:43:39 +0100
Message-ID: <20161130114339.78c6d4fa@redhat.com>
References: <20140903165943.372b897b@redhat.com>
        <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
        <20161116131609.4e5726b4@redhat.com>
        <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
        <20161116234022.2bad179b@redhat.com>
        <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117091638.5fab8494@redhat.com>
        <20730b37-d218-a1bb-d0fb-0f838e2a77b5@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        brouer@redhat.com
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41074 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932758AbcK3Knn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 05:43:43 -0500
In-Reply-To: <20730b37-d218-a1bb-d0fb-0f838e2a77b5@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 28 Nov 2016 10:33:49 -0800 Rick Jones <rick.jones2@hpe.com> wrote:

> On 11/17/2016 12:16 AM, Jesper Dangaard Brouer wrote:
> >> time to try IP_MTU_DISCOVER ;)  
> >
> > To Rick, maybe you can find a good solution or option with Eric's hint,
> > to send appropriate sized UDP packets with Don't Fragment (DF).  
> 
> Jesper -
> 
> Top of trunk has a change adding an omni, test-specific -f option which 
> will set IP_MTU_DISCOVER:IP_PMTUDISC_DO on the data socket.  Is that 
> sufficient to your needs?

The "-- -f" option makes the __ip_select_ident lookup go away.  So,
confirming your new option works.

Notice the "fib_lookup" cost is still present, even when I use
option "-- -n -N" to create a connected socket.  As Eric taught us,
this is because we should use syscalls "send" or "write" on a connected
socket.

My udp_flood tool[1] cycle through the different syscalls:

taskset -c 2 ~/git/network-testing/src/udp_flood 198.18.50.1 --count $((10**7)) --pmtu 2
             	ns/pkt	pps		cycles/pkt
send      	473.08	2113816.28	1891
sendto    	558.58	1790265.84	2233
sendmsg   	587.24	1702873.80	2348
sendMmsg/32  	547.57	1826265.90	2189
write     	518.36	1929175.52	2072

Using "send" seems to be the fastest option.

Some notes on test: I've forced TX completions to happen on another CPU0
and pinned the udp_flood program (to CPU2) as I want to avoid the CPU
scheduler to move udp_flood around as this cause fluctuations in the
results (as it stress the memory allocations more).

My udp_flood --pmtu option is documented in the --help usage text (see below signature)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

$ uname -a
Linux canyon 4.9.0-rc6-page_pool07-baseline+ #185 SMP PREEMPT Wed Nov 30 10:07:51 CET 2016 x86_64

[1] udp_flood tool:
 https://github.com/netoptimizer/network-testing/blob/master/src/udp_flood.c

Quick command used for verifying  __ip_select_ident is removed:

 # First run benchmark
 sudo perf record -g -a ~/tools/netperf2-svn/src/netperf -H 198.18.50.1 \
  -t UDP_STREAM -l 3 -- -m 1472 -f

 # Second grep in perf output for functions
 sudo perf report --no-children --call-graph none --stdio |\
  egrep -e '__ip_select_ident|fib_table_lookup'


$ ./udp_flood --help

DOCUMENTATION:
 This tool is a UDP flood that measures the outgoing packet rate.
 Default cycles through tests with different send system calls.
 What function-call to invoke can also be specified as a command
 line option (see below).

 Default transmit 1000000 packets per test, adjust via --count

 Usage: ./udp_flood (options-see-below) IPADDR
 Listing options:
 --help         short-option: -h
 --ipv4         short-option: -4
 --ipv6         short-option: -6
 --sendmsg      short-option: -u
 --sendmmsg     short-option: -U
 --sendto       short-option: -t
 --write        short-option: -T
 --send         short-option: -S
 --batch        short-option: -b
 --count        short-option: -c
 --port         short-option: -p
 --payload      short-option: -m
 --pmtu         short-option: -d
 --verbose      short-option: -v

 Multiple tests can be selected:
     default: all tests
     -u -U -t -T -S: run any combination of sendmsg/sendmmsg/sendto/write/send

Option --pmtu <N>  for Path MTU discover socket option IP_MTU_DISCOVER
 This affects the DF(Don't-Fragment) bit setting.
 Following values are selectable:
  0 = IP_PMTUDISC_DONT
  1 = IP_PMTUDISC_WANT
  2 = IP_PMTUDISC_DO
  3 = IP_PMTUDISC_PROBE
  4 = IP_PMTUDISC_INTERFACE
  5 = IP_PMTUDISC_OMIT
 Documentation see under IP_MTU_DISCOVER in 'man 7 ip'
