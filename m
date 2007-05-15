From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Tue, 15 May 2007 14:28:21 -0700 (PDT)
Message-ID: <20070515.142821.42775365.davem@davemloft.net>
References: <1179265719.25622.40.camel@dell>
	<adaps51pzg8.fsf@cisco.com>
	<1179266728.25622.46.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56176
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754467AbXEOV2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 17:28:15 -0400
In-Reply-To: <1179266728.25622.46.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 15 May 2007 15:05:28 -0700

> On Tue, 2007-05-15 at 14:08 -0700, Roland Dreier wrote:
> >  > > Well, IPoIB doesn't do netif_wake_queue() until half the device's TX
> >  > > queue is free, so we should get batching.  However, I'm not sure that
> >  > > I can count on a fudge factor ensuring that there's enough space to
> >  > > handle everything skb_gso_segment() gives me -- is there any reliable
> >  > > way to get an upper bound on how many segments a given gso skb will
> >  > > use when it's segmented?
> >  > 
> >  > Take a look at tg3.c.  I use (gso_segs * 3) as the upper bound.
> > 
> > Thanks for the pointer... I noticed that code, but could you tell me
> > where the "* 3" comes from?
> > 
> For each gso_seg, there will be a header and the payload may span 2
> pages for 1500-byte packets.  We always assume 1500-byte packets because
> the buggy chips do not support jumbo frames.

Correct.

I think there may be a case where you could see up to 4 segments.
If the user corks the TCP socket, does a sendmsg() (which puts
the data in the per-socket page) then does a sendfile() you'll
see something like:

skb->data	IP, TCP, ethernet headers, etc.
page0		sendmsg() data
page1		sendfile
page2		sendfile

Ie. this can happen if the sendfile() part starts near the
end of a page, so it would get split even for a 1500 MTU
frame.

Even more complex variants are possible if the user does
tiny sendfile() requests to different pages within the file.

So in fact it can span up to N pages.

But there is an upper limit defined by the original GSO
frame, and that is controlled by MAX_SKB_FRAGS, so at most
you would see MAX_SKB_FRAGS plus some small constant.
