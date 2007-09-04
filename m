From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 1/2]: [NET_SCHED]: Make all rate based scheduler work
 with TSO.
Date: Mon, 3 Sep 2007 23:34:56 -0400
Message-ID: <20070903233456.0e738183.billfink@mindspring.com>
References: <1188562975.18622.11.camel@localhost.localdomain>
	<46D9103B.7090905@trash.net>
	<Pine.LNX.4.61.0709012325080.29796@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, jdb@comx.dk,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:35718
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751537AbXIDDfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 23:35:10 -0400
In-Reply-To: <Pine.LNX.4.61.0709012325080.29796@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 1 Sep 2007, Jesper Dangaard Brouer wrote:

> On Sat, 1 Sep 2007, Patrick McHardy wrote:
> 
> > Jesper Dangaard Brouer wrote:
> >> commit 6fdc0f061be94f5e297650961360fb7a9d1cc85d
> >> Author: Jesper Dangaard Brouer <hawk@comx.dk>
> >> Date:   Thu Aug 30 17:53:42 2007 +0200
> >> 
> >> [NET_SCHED]: Make all rate based scheduler work with TSO.
> >> 
> >> Change L2T (length to time) macros, in all rate based schedulers, to
> >> call a common function qdisc_l2t() that does the rate table lookup.
> >> This function handles if the packet size lookup is larger than the
> >> rate table, which often occurs with TSO enabled.
> >
> >
> > It still won't work properly with TSO (TBF for example already drops
> > oversized packets during ->enqueue), but its a good cleanup anyway.
> 
> Then lets call it a cleanup of the L2T macros.  In the next step we will 
> fix the different schedulers, to use the ability to lookup larger sized 
> packets. (I did notice the TBF scheduler would drop oversized packets).

Hmmm.  I guess this is also why TBF doesn't seem to work with 9000 byte
jumbo frames.

[root@lang4 ~]# tc qdisc add dev eth2 root tbf rate 2gbit buffer 5000000 limit 18000
[root@lang4 ~]# tc qdisc show                                                   qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc tbf 8002: dev eth2 rate 2000Mbit burst 5000000b lat 4.3s

With 9000 byte jumbo frames:

[root@lang4 ~]# ./nuttcp-5.5.5 -w10m 192.168.88.14
    0.0000 MB /   5.00 sec =    0.0000 Mbps 0 %TX 0 %RX

But reducing the MSS to 1460 to emulate a standard 1500 byte Ethernet MTU:

[root@lang4 ~]# ./nuttcp-5.5.5 -M1460 -w10m 192.168.88.14
 2335.7048 MB /  10.05 sec = 1950.3419 Mbps 62 %TX 22 %RX

This is on a 2.6.20.7 kernel.

						-Bill
