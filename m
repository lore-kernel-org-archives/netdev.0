From: Rick Jones <rick.jones2@hp.com>
Subject: twice past the taps, thence out to net?
Date: Wed, 14 Dec 2011 11:27:00 -0800
Message-ID: <4EE8F884.1010304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:49096 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755459Ab1LNT1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 14:27:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking at "something else" with tcpdump/tcptrace, tcptrace 
emitted lots of notices about hardware duplicated packets being detected 
(same TCP sequence number and IP datagram ID).  Sure enough, if I go 
into the tcpdump trace (taken on the sender) I can find instances of 
what it was talking about, separated in time by rather less than I would 
expect to be the RTO, and often as not with few if any intervening 
arriving ACKs to trigger anything like fast retransmit.  And besides, 
those would have a different IP datagram ID no?

I did manage to reproduce the issue with plain netperf tcp_stream tests. 
I had one sending system with 30 concurrent netperf tcp_stream tests to 
30 other receiving systems.  There are "hardware duplicates" in the 
sending trace, but no duplicate segments (that I can find thus far) in 
the two receiver side traces I took.  Of course that doesn't mean 
"conclusively" there were two actual sends but it suggests there werent.

While I work through the "obtain permission" path to post the packet 
traces (don't ask...) I thought I would ask if anyone else has seen 
something similar.

In this case, all the systems are running a 2.6.38-8 Ubuntu kernel (the 
same sorts of issues which delay my just putting the traces up on 
netperf.org preclude a later kernel, and I've no other test systems :( 
), with Intel 82576 interfaces being driven by:

$ sudo ethtool -i eth0
driver: igb
version: 2.1.0-k2
firmware-version: 1.8-2
bus-info: 0000:05:00.0

All the systems were connected to the same switch.

It is projecting, but given that the interface was fully saturated, and 
there were 30 concurrent streams making 64K TSO sends, it "feels" like 
some sort of "go past the packet tap and be captured, find a 
queue/resource past the tap unavailable, get re-queued above the tap, 
get captured again when resent" sort of thing.

Where in the Linux stack does the tap used by libpcap 1.1.1 reside?

rick jones
