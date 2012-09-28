From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 7/7 net-next] tg3: Change default number of tx rings
 to 1.
Date: Thu, 27 Sep 2012 21:44:31 -0700
Message-ID: <1348807471.7220.138.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1348698769-760-5-git-send-email-mchan@broadcom.com>
 <1348698769-760-6-git-send-email-mchan@broadcom.com>
 <1348698769-760-7-git-send-email-mchan@broadcom.com>
 <20120927.192345.2124577537241070059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4435 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929Ab2I1Eom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 00:44:42 -0400
In-Reply-To: <20120927.192345.2124577537241070059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-27 at 19:23 -0400, David Miller wrote: 
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Wed, 26 Sep 2012 15:32:49 -0700
> 
> > Hardware tx scheduling can cause some starvation of a tx ring with small
> > packets if other tx rings have jumbo or TSO packets.  The default setting
> > of 1 TX ring gives the best overall performance in many common traffic
> > scenarios.  The user can change it using ethttol -L if desired.
> > 
> > Update version to 3.125.
> > 
> > Reviewed-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> > Reviewed-by: Benjamin Li <benli@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> This gets into an area I don't like.
> 
> Individual drivers making decisions about defaults that sound like
> system wide ones.
> 
> What makes tg3 so special that only it should have this default
> setting?

It was poor hardware design.  Other bnx2/bnx2x designs do not have this
design flaw.

> 
> I also can't see how this "one guy spamming small packets while
> another generates TSO frames" completely nullifies the SMP gains
> from using multiple TX rings and distributing traffic.

The issue was reported by a user in a RHEL bugzilla complaining about
less than 100Mbps in some common test environment.  We then root caused
it to the hardware design flaw in the multi TX ring hardware
implementation.

In the simplest case, assume you have 2 TCP streams running in opposite
directions.  The TX traffic (mostly TSO) will hash to one tx ring.  The
ACKs for the incoming data on a different TCP connection will hash to
another TX ring.  The hardware fetches one complete TSO packet from the
first ring (up to 64K data) before servicing the other TX ring.  And
when it gets to the other TX ring, it will fetch only one packet (one
64-byte ACK packet in this case) and then immediately switches back to
the 1st ring (filled with more TSO packets).  In reality, there may be
over 10 ACK packets waiting in the 2nd ring because a lot of incoming
data has been received and ACKed during this time.  Because the ACKs are
going out so slowly, the incoming throughput slows to a trickle.

Our other devices don't do this simple Round-robin tx scheduling.
Instead, there are independent DMA channels fetching and interleaving tx
data from multiple rings.

> 
> I'm not applying this patch set.
> 

I hope I have convinced you to reconsider.  Many years ago, we disabled
TSO by default on the old 5704 after we found out that the firmware
implementation was actually slower than no TSO.

At least consider patches 1 - 6 that will allow the user to disable
multiple TX rings if he runs into this scenario.  Including patch 7 will
be the best in my opinion.  Thanks.
