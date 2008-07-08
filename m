From: Bill Fink <billfink@mindspring.com>
Subject: Re: setsockopt()
Date: Tue, 8 Jul 2008 14:48:17 -0400
Message-ID: <20080708144817.3c364962.billfink@mindspring.com>
References: <48725DFE.6000504@citi.umich.edu>
	<20080707142408.43aa2a2e@extreme>
	<48728B09.1050801@citi.umich.edu>
	<20080707.144912.76654646.davem@davemloft.net>
	<20080708045443.GA7726@2ka.mipt.ru>
	<20080708020235.388a7bd5.billfink@mindspring.com>
	<adar6a4x510.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	bfields@fieldses.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:60019 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752019AbYGHSse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 14:48:34 -0400
In-Reply-To: <adar6a4x510.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roland,

I think you set a new nuttcp speed record.  :-)
I've merely had 10-GigE networks to play with.

On Mon, 07 Jul 2008, Roland Dreier wrote:

> Interesting... I'd not tried nuttcp before, and on my testbed, which is
> a very high-bandwidth, low-RTT network (IP-over-InfiniBand with DDR IB,
> so the network is capable of 16 Gbps, and the RTT is ~25 microseconds),
> the difference between autotuning and not for nuttcp is huge (testing
> with 2.6.26-rc8 plus some pending 2.6.27 patches that add checksum
> offload, LSO and LRO to the IP-over-IB driver):
> 
> nuttcp -T30 -i1 ends up with:
> 
> 14465.0625 MB /  30.01 sec = 4043.6073 Mbps 82 %TX 2 %RX
> 
> while setting the window even to 128 KB with
> nuttcp -w128k -T30 -i1 ends up with:
> 
> 36416.8125 MB /  30.00 sec = 10182.8137 Mbps 90 %TX 96 %RX
> 
> so it's a factor of 2.5 with nuttcp.  I've never seen other apps behave
> like that -- for example NPtcp (netpipe) only gets slower when
> explicitly setting the window size.
> 
> Strange...

It is strange.  The first case just uses the TCP autotuning, since
as you discovered, nuttcp doesn't make any SO_SNDBUF/SO_RCVBUF
setsockopt() calls unless you explicitly set the "-w" option.
Perhaps the maximum value for tcp_rmem/tcp_wmem is smallish on
your systems (check both client and server).

On my system:

# cat /proc/sys/net/ipv4/tcp_rmem
4096    524288  104857600
# cat /proc/sys/net/ipv4/tcp_wmem
4096    524288  104857600

IIRC the explicit setting of SO_SNDBUF/SO_RCVBUF is instead governed
by rmem_max/wmem_max.

# cat /proc/sys/net/core/rmem_max
104857600
# cat /proc/sys/net/core/wmem_max
104857600

The other weird thing about your test is the huge difference in
the receiver (and server in this case) CPU utilization between the
autotuning and explicit setting cases (2 %RX versus 96 %RX).

						-Bill
