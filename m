From: Roland Dreier <rdreier@cisco.com>
Subject: Re: setsockopt()
Date: Wed, 09 Jul 2008 11:10:31 -0700
Message-ID: <ada63rfrkrs.fsf@cisco.com>
References: <48725DFE.6000504@citi.umich.edu>
	<20080707142408.43aa2a2e@extreme> <48728B09.1050801@citi.umich.edu>
	<20080707.144912.76654646.davem@davemloft.net>
	<20080708045443.GA7726@2ka.mipt.ru>
	<20080708020235.388a7bd5.billfink@mindspring.com>
	<adar6a4x510.fsf@cisco.com>
	<20080708144817.3c364962.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	bfields@fieldses.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:9106 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186AbYGISKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 14:10:33 -0400
In-Reply-To: <20080708144817.3c364962.billfink@mindspring.com> (Bill Fink's
	message of "Tue, 8 Jul 2008 14:48:17 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > The other weird thing about your test is the huge difference in
 > the receiver (and server in this case) CPU utilization between the
 > autotuning and explicit setting cases (2 %RX versus 96 %RX).

I think I found another clue -- it seems that CPU affinity has something
to do with the results.  Usually I pin the adapter interrupt to CPU 0
and use "taskset 4" to pin the benchmarking process to CPU 2 (this leads
to the best performance for these particular systems in almost all
benchmarks).  But with nuttcp I see the following:

  with taskset 4:

    $ taskset 4 nuttcp -T30 192.168.145.73 
     9911.3125 MB /  30.01 sec = 2770.3202 Mbps 42 %TX 10 %RX
    $ taskset 4 nuttcp -w128k -T30 192.168.145.73 
    36241.9375 MB /  30.00 sec = 10133.8931 Mbps 89 %TX 96 %RX

  with no taskset (ie let kernel schedule as it wants to):

    $ nuttcp -T30 192.168.145.73
    36689.6875 MB /  30.00 sec = 10259.1525 Mbps 99 %TX 96 %RX
    $ nuttcp -w128k -T30 192.168.145.73
    36486.0000 MB /  30.00 sec = 10202.1870 Mbps 74 %TX 95 %RX

so somehow setting the window helps with the scheduling of
processes... I guess autotuning lets some queue get too long or
something like that.  The actual window doesn't matter too much, since
the delay of the network is low enough that even though the bandwidth is
very high, the BDP is quite small.  (With a 25 usec RTT, a 128 KB window
should be enough for 40 Gbps, well over the raw link speed of 16 Gbps
that I have)

 - R.
