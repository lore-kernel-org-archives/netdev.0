From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows
 with MD5SIG enabled (v2)
Date: Wed, 18 Jun 2008 02:34:46 -0400
Message-ID: <20080618023446.aba6516c.billfink@mindspring.com>
References: <396556a20805301217k293e5718h6bbf02bfe0683144@europa>
	<20080617.170718.260234361.davem@davemloft.net>
	<396556a20806171745k63bb3516s5971593ecf216bc4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:34904 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754127AbYFRGeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 02:34:50 -0400
In-Reply-To: <396556a20806171745k63bb3516s5971593ecf216bc4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Jun 2008, Adam Langley wrote:

> On Tue, Jun 17, 2008 at 5:07 PM, David Miller <davem@davemloft.net> wrote:
> > The problematic case is when all 3 of tstamps, wscale, and md5 are
> > enabled.  To be honest, tstamps are the least valuable of the 3.  The
> > only way to accurately fill in gaps is to have at least some SACK
> > information, it is much harder to guestimate than RTTs.
> 
> So, have a population of Linux hosts out there which will send corrupt
> packets when MD5+SACK is enabled. So we want to fix that problem all
> at once, hopefully.
> 
> How's this:
> 
> If we receive a SYN packet with MD5 + SACK + TS was assume that it's
> from an older kernel and reply with MD5 + TS. Not including SACK means
> that it won't send us corrupt packets and since we couldn't previously
> do SACK with these packets anyway, we're not loosing anything.
> 
> However, by default we send MD5 + SACK. If we are talking to an old
> kernel, that means that they are sending corrupt packets if they have
> > 2 SACK blocks (the current logic limits them to 4 I believe).
> Hopefully this is pretty rare (and, again, better than we are
> currently doing). It also means that we have MD5 + SACK between new
> hosts, which is optimal.

I am not particularly familiar with the TCP MD5 option, but in googling
around I found the following at the end of Section 2.2 Transmission,
of RFC 4808, "TCP-MD5 Key Change", dated March 2007:

    "Note that there is an ambiguity when an acknowledgment is received
    for a segment transmitted with two different keys.  The TCP Timestamp
    option [RFC1323] can be used for disambiguation."

This would seem to imply, that at least in some scenarios, it would be
advisable to have TS enabled in conjunction with MD5.

						-Bill
