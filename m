From: "pradeep singh" <pradeep.rautela@gmail.com>
Subject: Re: Socket Buffers and Memory Managment
Date: Thu, 19 Jul 2007 12:34:46 +0530
Message-ID: <a901b49a0707190004q26d4b064pf7b5450b9890c907@mail.gmail.com>
References: <20070717204129.79e7fe0d@oldman>
	 <261750.43078.qm@web82911.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: "vinay ravuri" <vinaynyc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:51266 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755721AbXGSHEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 03:04:47 -0400
Received: by py-out-1112.google.com with SMTP id d32so881427pye
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 00:04:46 -0700 (PDT)
In-Reply-To: <261750.43078.qm@web82911.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/19/07, vinay ravuri <vinaynyc@yahoo.com> wrote:
> How about the following approach:
>
> I allocate an skb of 0 bytes and replace data element
> of skb struct (i.e. skb.data = addr_given_by_hw) when
> the h/w interrupts me with a packet.  I register for a
> destructor for this skb and when the kernel is ready
> to free the skb, I make sure that my free is invoked -
> Ofcourse this is assuming that their is a facility in
> linux socket buffers to be able to do destructors.  Is
> this approach a viable, if so, are any gottcha's?

I wonder if passing a zero size will work correctly with
alloc_skb/__alloc_skb as you still have just skb frag list to work
with in this case.
And as Stephen pointed out, if i understand correctly that would be
still a problem.

yes/no?

thanks
--pradeep
>
> -Vinay
>
>
> --- Stephen Hemminger
> <shemminger@linux-foundation.org> wrote:
>
> > On Tue, 17 Jul 2007 10:20:58 -0700 (PDT)
> > vinay ravuri <vinaynyc@yahoo.com> wrote:
> >
> > > Hi,
> > >
> > > I am fairly new to linux socket buffers and have
> > the
> > > following questions!
> > >
> > > I am working with a custom ethernet MAC that does
> > not
> > > allow me to specify a particular memory location
> > for
> > > the h/w to DMA the packet into (Rx side).
> > Instead, it
> > > has a pool of fixed size buffers with some h/w
> > > specific headers around each buffer that are
> > managed
> > > by h/w and will pick a free buffer and DMA the
> > packet.
> >
> > Sounds like sucky hardware...
> > You need to copy to a newly allocated skb, see
> > 8139too.c
> >
> > >  It appears dev_alloc_skb() actually allocates the
> > > physical memory and doesn't allow the user to
> > specify
> > > the skb.data to something specific to what I want
> > > which is a problem for me.  First is my assumption
> > > correct that I am cannot pick an arbitrary
> > skb.data
> > > location in struct sk_buff?  I want to avoid
> > copying
> > > the dma'ed data into a new socket buffer as it is
> > > expense.  Is there any ways around this problem?
> >
> > You could play tricks with skb frags but it would be
> > fragile
> > and not worth the trouble. The problem is that the
> > receive
> > skb can stay in the system for a really long time
> > (until the application
> > reads the data) so your fixed size buffer pool in
> > hardware
> > would get exhausted.
> >
> > > Also, if the h/w gives me a single packet in
> > multiple
> > > locations (i.e. non-contiguous chunks of memory),
> > can
> > > socket buffers handle chains of buffers?  I am
> > looking
> > > for a facility like mbuf's in netbsd where one can
> > > chain multiple buffers together to make construct
> > a
> > > single packet.
> >
> > Yes, skb frag list could be used for that but you
> > don't
> > want to do that. See above. Copy the data into an
> > new
> > skb and reserve any necessary bytes so IP header is
> > aligned.  I.e. if using ethernet header (14 bytes),
> > do
> > skb_reserve(skb, 2) before copying the data.
> >
>
>
>
>
> ____________________________________________________________________________________
> Looking for a deal? Find great prices on flights and hotels with Yahoo! FareChase.
> http://farechase.yahoo.com/
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Pradeep
