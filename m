From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Mon, 7 Aug 2006 17:09:39 -0700
Message-ID: <4807377b0608071709j26da1092la20f1589c7b90df7@mail.gmail.com>
References: <20060806.232339.30184217.davem@davemloft.net>
	 <E1G9zMP-0001MO-00@gondolin.me.apana.org.au>
	 <20060807072423.GA2078@2ka.mipt.ru>
	 <20060807072816.GA5404@gondor.apana.org.au>
	 <20060807073103.GA11283@2ka.mipt.ru>
	 <20060807073919.GA5582@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	chris.leech@gmail.com,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:50395 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932450AbWHHAJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 20:09:48 -0400
Received: by nf-out-0910.google.com with SMTP id x37so22772nfc
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2006 17:09:39 -0700 (PDT)
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060807073919.GA5582@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/7/06, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Mon, Aug 07, 2006 at 11:31:03AM +0400, Evgeniy Polyakov wrote:
> >
> > Only if they form contiguous region?
> > Jesse, is it possible for every e1000 chip to split frame into several
> > page-sized chunks i.e. create some kind of receiving scatter-gather?

now you get to the meat of the problem.  Yes, all versions of e1000
can receive packets longer than the receive data area in the
descriptor.  If the data area is shorter than the packet, then the
data over flows into the next descriptor.

>
> Actually, it was Chris Leech who raised this possibility:
>
> : Yes, e1000 devices will spill over and use multiple buffers for a
> : single frame.  We've been trying to find a good way to use multiple
> : buffers to take care of these allocation problems.  The structure of
> : the sk_buff does not make it easy.  Or should I say that it's the
> : limitation that drivers are not allowed to chain together multiple
> : sk_buffs to represent a single frame that does not make it easy.
>
> Perhaps he can enlighten us.

Or since i'm here... in any case we had driver code (see driver
6.2.15) that did this at one point, but we removed it because it was
using frag_list

So here is our problem with the network driver API.
the only way to indicate multiple buffer (descriptor) receives is to
use nr_frags.  Our non split-header hardware needs power of 2
allocations *except* in the 1500 byte MTU case where we can optimize
by having the hardware drop all frames > 1522 bytes

we would like to have a method to use alloc_skb to get packets from
slab to receive into and then chain them together.  Right now that is
not possible because you can't map alloc_skb'd data areas directly to
pages to put into nr_frags.

much of this comes from the requirement that the stack free the skb we
allocated.  if we had an async callback for the driver to take care of
freeing the skb then we could
a) recycle
b) handle pages in some efficient manner.

also, eth_type_trans wants skb->data to point to header, which would
require us to memcpy data from a page back to skb->data.

We could use help to get this done and mutiple drivers would benefit.
I can't get it done by myself, as much as I would like to.

As for Evgeniy's suggestion of using the end of the e1000 receive
buffer to store something I think it is a bad idea. Our hardware deals
with powers of 2.  From the e1000 manual:
 =====
LPE controls whether long packet reception is permitted. Hardware
discards long packets if LPE is 0. A long packet is one longer than
1522 bytes. If LPE is 1, the maximum packet size that the device can
receive is 16384 bytes.
 =====
