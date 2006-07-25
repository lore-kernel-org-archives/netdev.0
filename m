From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RDMA will be reverted
Date: Mon, 24 Jul 2006 17:29:05 -0700
Message-ID: <44C565D1.6070202@hp.com>
References: <adasllh9kj0.fsf@cisco.com> <200607250110.25844.ak@suse.de>	<20060724.162250.55836503.davem@davemloft.net> <200607250202.02913.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rdreier@cisco.com,
	tom@opengridcomputing.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:33678 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S932356AbWGYA3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 20:29:08 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200607250202.02913.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This all sounds like the discussions we had within HP-UX between 10.20 and 11.0 
concerning Inbound Packet Scheduling vs Thread Optimized Packet Scheduling.  IPS 
was done by the 10.20 stack at the handoff between the driver and netisr.  If 
the packet was not an IP datagram fragment, parts of the transport and IP 
headers would be hashed, and the result would be the netisr queue to which the 
packet would be queued for further processing.

It worked fine and dandy for stuff like aggregate netperf TCP_RR tests because 
there was a 1-1 correspondence between a connection and a process/thread.  It 
was "OK" for the networking to dictate where the process should run.  That feels 
rather like a NIC that would hash packets and pick the MSI-X based on that.

However, as Andi discusses, when there is a process/thread doing more than one 
connection, picking a CPU based on addressing hashing will be like TweedleDee 
and TweedleDum telling Alice to go in opposite directions.  Hence TOPS in 11.X. 
  This time, when there is a "normal" lookup location in the path, where the 
application last accessed the socket is determined, and things shift-over to 
that CPU.  This then is the process (well actually the scheduler) telling 
networking where it should do its work.

That addresses the multiple connections per thread/process and still works just 
as well for 1-1.  There are still issues if you have mutiple threads/processes 
concurrently accessing the same socket/connection, but that one is much more rare.

Nirvana I suppose would be the addition of a field in the header which could be 
used for the determination of where to process. A Transport Protocol option I 
suppose, maybe the IPv6 flow id, but knuth only knows if anyone would go for 
something along those lines.  It does though mean that the "state" is per-packet 
without it having to be based on addressing information.  Almost like RDMA 
arriving saying where the data goes, but this thing says where the processing 
should happen :)

rick jones
