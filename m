From: Rick Jones <rick.jones2@hp.com>
Subject: Re: UDP ordering when using multiple rx queue
Date: Wed, 11 Jul 2012 10:50:29 -0700
Message-ID: <4FFDBCE5.9050201@hp.com>
References: <CAL8zT=g5nHd6FprhxFc21XTgfXeaokt4QN1fS4ekcNVkuvZE9g@mail.gmail.com> <1342004939.27284.28.camel@lb-tlvb-meravs.il.broadcom.com> <CAL8zT=jMPCv_Lc7gJYGHRhHZop9aWJfp2w1o_cD0Z8SRdtck7Q@mail.gmail.com> <CAL8zT=hi9_Y4oGw=cVSnYE=km6MZBAAie-A5RWLy=47FR8aTag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Merav Sicron <meravs@broadcom.com>, netdev <netdev@vger.kernel.org>
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:3588 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755082Ab2GKRub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 13:50:31 -0400
In-Reply-To: <CAL8zT=hi9_Y4oGw=cVSnYE=km6MZBAAie-A5RWLy=47FR8aTag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2012 06:41 AM, Jean-Michel Hautbois wrote:
> I confirm that using ethtool -L eth1 combined 1 solves my issue.

My being pedantic or not, you have kludged around your issue, which is a 
broken application.

Can you actually ass-u-me that this application is deployed with just a 
single back-to-back link between two systems?  I'm guessing that isn't 
the way it is deployed in production or there would be zero call for 
multicast.   There is *zero* guarantee of ordering with UDP, multicast 
or otherwise - certainly not between sends involving different port 
numbers, nor for that matter even between sends involving the same port 
numbers.  Once you leave the NIC (and perhaps even before) all bets are off.

Have you tested using bonded links?  Or through switches which 
themselves are joined by bonded links? Various bonding modes can even 
re-order traffic of a single flow (eg mode-rr).  As I understand it, the 
moves to "break the bottlenecks" imposed by spanning tree will mean that 
meshes of switches, even without bonded links, will send traffic of 
different flows through different paths through the switch fabric.  In 
those cases they might send traffic to the same multicast address along 
the same path each time, but you probably cannot count on that, nor them 
sending traffic to different multicast addresses along the same path. 
Some clever meshed-switch folks may go ahead and look up at the 
transport-layer port numbers when deciding on their splits - just like 
some bonding modes can.

Until you get the application re-written to handle out-of-order traffic, 
it "works" only by chance.

> Unicast traffic seems ok (I used netperf in order to check this assumption).

Netperf does nothing to check the order of datagrams.  It is perfectly 
content receiving datagrams in any order.  So you can use it to see that 
a single flow of UDP unicast is not split-up by the NIC (by looking at 
the per-queue stats) you can assume nothing about the final ordering of 
those UDP datagrams from a "successful" netperf UDP_STREAM test.

rick jones
