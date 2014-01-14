From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 3/5] net: mvneta: do not schedule in mvneta_tx_timeout
Date: Tue, 14 Jan 2014 16:33:42 +0100
Message-ID: <20140114153342.GC32193@1wt.eu>
References: <1389519069-1619-1-git-send-email-w@1wt.eu> <1389519069-1619-4-git-send-email-w@1wt.eu> <1389545391.3720.56.camel@deadeye.wl.decadent.org.uk> <20140112165548.GC16576@1wt.eu> <1389548333.3720.73.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55371 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318AbaANPdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 10:33:49 -0500
Content-Disposition: inline
In-Reply-To: <1389548333.3720.73.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Sun, Jan 12, 2014 at 05:38:53PM +0000, Ben Hutchings wrote:
> I think this will DTRT, but it's compile-tested only.  I have been given
> an OpenBlocks AX3 but haven't set it up yet.

OK I just managed to test your patch. I managed to force a Tx timeout by
forcing the link to 100/half and transfering 1000 concurrent streams.

Unfortunately for now the patch doesn't manage to recover, and the system
randomly panics one or two seconds after the link is brought up. Twice the
system did not panic but I lost all communications until a down/up cycle,
after which a panic happened during transfers.

However I could verify that the scheduled function is correctly called. I
suspect that something else might be wrong in the driver's reset sequence
(eg: unmapping pages still in use by the NIC or I don't know what), but
your patch does exactly what it's supposed to do.

At least, if the restart function does not do anything, everything works
fine. I see that the function is called (I added printk there) and the
transfer is not perturbated at all anymore.

So now I'm wondering whether the right thing should not be to just keep
your scheduled function and make it only log that a timeout was caught.

Another point which bothers me is that I suspect we're triggering Tx
timeouts too fast, because I regularly get these on 100 Mbps during
regular traffic (which ended up in immediate panics with previous code).

Thanks,
Willy
