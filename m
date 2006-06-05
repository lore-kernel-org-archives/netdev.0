From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2.6.18 2/3] tg3: Convert to non-LLTX
Date: Mon, 05 Jun 2006 16:34:09 -0700
Message-ID: <1149550449.13155.33.camel@rh4>
References: <1149536852.13155.7.camel@rh4>
 <20060605155834.031d37a2@localhost.localdomain>
 <1149542985.13155.11.camel@rh4>
 <20060605173159.33d81d59@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:17935 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751023AbWFFBNq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 21:13:46 -0400
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060605173159.33d81d59@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-06-05 at 17:31 -0700, Stephen Hemminger wrote:
> On Mon, 05 Jun 2006 14:29:45 -0700
> "Michael Chan" <mchan@broadcom.com> wrote:
> 
> > On Mon, 2006-06-05 at 15:58 -0700, Stephen Hemminger wrote:
> > 
> > > 
> > > Since you are going more lockless, you probably need memory barriers.
> > 
> > No, we're not going more lockless. We're simply replacing the private
> > tx_lock with dev->xmit_lock by dropping the LLTX feature flag. The
> > amount of locking is exactly the same as before.
> 
> Those spin lock's were also acting as barriers.

Why is it different whether we use dev->xmit_lock right before entering
hard_start_xmit() without LLTX or a private tx_lock at the beginning of
hard_start_xmit() with LLTX? In both cases, we take one BH disabling
lock to serialize hard_start_xmit(). And in both cases, the spinlock
will provide the same barrier effect.

> Are you sure code is safe in the face of cpu reordering.
> 
Yes, hard_start_xmit() only touches the tx producer index and tx
completion handling only touches the tx consumer index.

There is actually one wrinkle but it has nothing to do with the locking
change in this patch. During the sequence of writing the tx descriptors
to memory and the MMIO write to tell the chip to DMA the new
descriptors, the MMIO can be re-ordered ahead of the writing of the tx
descriptors on the powerpc, for example. This will lead to DMAing stale
descriptor data. In earlier kernels, the ppc writel has a memory barrier
to prevent this but it was removed in recent kernels. We had a
discussion with Anton Blanchard and other folks at IBM and DaveM on this
and it was decided that the writel should provide the barrier instead of
drivers adding all kinds of barriers throughout the driver code.

