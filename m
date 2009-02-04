From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 04 Feb 2009 01:12:28 -0800 (PST)
Message-ID: <20090204.011228.88323558.davem@davemloft.net>
References: <20090203122535.GB8633@1wt.eu>
	<20090203.164734.76871204.davem@davemloft.net>
	<20090204061947.GD20673@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, herbert@gondor.apana.org.au, jarkao2@gmail.com,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51459
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752244AbZBDJMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 04:12:31 -0500
In-Reply-To: <20090204061947.GD20673@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Wed, 4 Feb 2009 07:19:47 +0100

> On Tue, Feb 03, 2009 at 04:47:34PM -0800, David Miller wrote:
> > From: Willy Tarreau <w@1wt.eu>
> > Date: Tue, 3 Feb 2009 13:25:35 +0100
> > 
> > > Well, FWIW, I've always observed better performance with 4k MTU (4080 to
> > > be precise) than with 9K, and I think that the overhead of allocating 3
> > > contiguous pages is a major reason for this.
> > 
> > With what hardware?  If it's with myri10ge, that driver uses page
> > frags so would not be using 3 contiguous pages even for jumbo frames.
> 
> Yes myri10ge for the optimal 4080, but with e1000 too (though I don't
> remember the exact optimal value, I think it was slightly lower).
> 
> For the myri10ge, could this be caused by the cache footprint then ?
> I can also retry with various values between 4 and 9k, including
> values close to 8k. Maybe the fact that 4k is better than 9 is
> because we get better filling of all pages ?

Looking quickly, myri10ge's buffer manager is incredibly simplistic so
it wastes a lot of memory and gives terrible cache behavior.

When using JUMBO MTU it just gives whole pages to the chip.

So it looks like, assuming 4096 byte PAGE_SIZE and 9000 byte
jumbo MTU, the chip will allocate for a full size frame:

	FULL PAGE
	FULL PAGE
	FULL PAGE

and only ~1K of that last full page will be utilized.

The headers will therefore always land on the same cache lines,
and PAGE_SIZE-~1K will be wasted.

Whereas for < PAGE_SIZE mtu selections, it will give MTU sized
blocks to the chip for packet data allocation.
