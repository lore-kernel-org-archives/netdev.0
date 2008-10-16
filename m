From: David Miller <davem@davemloft.net>
Subject: tbench wrt. loopback TSO
Date: Wed, 15 Oct 2008 17:14:08 -0700 (PDT)
Message-ID: <20081015.171408.193701292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, efault@gmx.de, mingo@elte.hu,
	a.p.zijlstra@chello.nl, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42197
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753902AbYJPAOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 20:14:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I got curious about this aspect of the investigation so I wanted
to see it first-hand :-)

To be honest, this reported effect of disabling TSO in the loopback
driver surprised me because:

1) If the benchmark is doing small writes, TSO should have zero
   effect.  The TSO logic won't kick in.

2) If larger than MTU writes are being done, TSO should help,
   and this is supported by other benchmarks :-)

So I ran some tbench cases both with and without the NETIF_F_TSO
setting in drivers/net/loopback.c

On my 64-cpu 1.2GHz Niagara-2 box I obtained these results:

1) For a simpler 2 thread run (tbench 2 localhost) the results
   stayed the same both with and without TSO enabled on loopback.
   About 77MB/sec

2) For a large 64 thread run (tbench 64 localhost) the results
   improved with TSO enabled in the loopback driver.

   Without TSO I got 1.5 GB/sec and with TSO I got 1.75 GB/sec
   throughput.

I double checked this on a more traditional style processor, on
my workstation, with has 2 UltraSPARC-IIIi chips running at 1.5GHZ

This setup matched case #1 above, for "tbench 2 localhost" I got
the same result, 138 MB/sec, both with and without TSO enabled.

And these results all make total sense to me.  tbench does mostly
small transfers (for which TSO should make absolutely no difference),
but it does a small number of large ones as well.  And as you
up the thread count, the large transfer cases factor more and more
into the results.

If this TSO setting is causing some performance decrease on some
systems we should find out why.  I'll try some of my x86 systems here
to see if I can reproduce.  It just doesn't make any sense that TSO
can make any kind of negative difference, it can only help or have no
effect at all!
