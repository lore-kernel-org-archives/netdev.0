From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] skge csum problems
Date: Mon, 24 Dec 2007 11:36:38 -0800
Message-ID: <20071224113638.0de0f189@speedy>
References: <20071224094352.GU8181@ftp.linux.org.uk>
	<p73sl1sp72b.fsf@bingen.suse.de>
	<20071224183950.GA5024@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:40159 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbXLXUEY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Dec 2007 15:04:24 -0500
In-Reply-To: <20071224183950.GA5024@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Dec 2007 18:39:50 +0000
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Mon, Dec 24, 2007 at 02:15:40PM +0100, Andi Kleen wrote:
> > Al Viro <viro@ftp.linux.org.uk> writes:
> > >
> > > Checksum is fixed-endian and we want it that way; IOW, what we end up
> > > storing in skb->csum should be fixed-endian as well.
> > 
> > AFAIK skb->csum is always native endian because it normally
> > needs to be manipulated further even for RX.
> 
> No.  It needs to be manipulated, but that's exactly why it can't be
> (and isn't) kept host-endian.  Large part of the reason why checksums are
> done the way they are done (operations mod 0xffff, etc.) is that
> they can be implemented via native arithmetics without any conversions;
> e.g. if you do
> 
> add(u8 a[2], u8 b[2], u8 sum[2])
> {
> 	u32 x = *(u16 *)a + *(u16 *)b;
> 	if (x > 0xffff)
> 		x -= 0xffff;
> 	*(u16 *)sum = x;
> }
> 
> you will get the same behaviour on big- and little-endian boxen, even though
> the intermediate integer values will be of course different.
> 
> skb->csum *must* be stored in the same order on l-e and b-e boxen; that
> way you don't need to convert it or raw data when updating the sucker [*].
> 
> [*] it's slightly more complicated since skb->csum is 4-byte, not 2-byte
> and the real invariant is "checksum of 4-octet array at &skb->csum must
> not depend on host" (so e.g XX YY 00 00 and 00 00 XX YY are equivalent -
> checksum doesn't change from reordering octet pairs; XX YY 00 00 and
> 00 00 YY XX are very definitely *NOT* equivalent; odd and even bytes
> can't be exchanged).

Did you test this on real hardware?
