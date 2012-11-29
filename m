From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Thu, 29 Nov 2012 11:11:22 -0500
Message-ID: <20121129111122.0c3698e1@thirdoffive.cmf.nrl.navy.mil>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
	<1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
	<1354036592.2534.6.camel@shinybook.infradead.org>
	<20121127173906.GA11390@shrek.podlesie.net>
	<1354039349.2534.11.camel@shinybook.infradead.org>
	<20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
	<AE90C24D6B3A694183C094C60CF0A2F6026B70C9@saturn3.aculab.com>
	<1354141115.21562.101.camel@shinybook.infradead.org>
	<20121129103744.38149dc6@thirdoffive.cmf.nrl.navy.mil>
	<1354204748.21562.180.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Krzysztof Mazur <krzysiek@podlesie.net>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354204748.21562.180.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Nov 2012 15:59:08 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> On Thu, 2012-11-29 at 10:37 -0500, chas williams - CONTRACTOR wrote:
> > you shouldnt clear ATM_VF_ADDR until the vpi/vci is actually closed and
> > ready for reuse.  at this point, it isnt.
> 
> So I should always wait for the completion of my PKT_CLOSE and only
> clear ATM_VF_ADDR when it's actually done?
> 
> But can you define 'ready for reuse'? From the moment I clear
> ATM_VF_ADDR, another CPU may enter my popen() function to set up another
> VCC with the same parameters, and everything should work fine. The
> PKT_POPEN will end up on the queue *after* my PKT_PCLOSE for the old
> VCC. Any received packets will be dropped until the new VCC gets
> ATM_VF_READY set (by the popen function).
> 
> What's the actual failure mode, caused by me clearing ATM_VF_ADDR "too
> early"?

there may not be one (due to serialization from other parts of the
atm stack) but you "shouldn't" clear ATM_VF_ADDR until the vpi/vci pair
is ready for reuse.  by reuse, i mean that any previous rx/tx data in
the vpi/vci segmentation hardware has been removed/cleared.

> >  ATM_VF_READY should already be clear at this point but you should set
> > it before you queue your PKT_CLOSE. 
> 
> I should *set* it? Do you mean clear it? Yes, I see it's cleared by

sorry, i did mean clear it.

> vcc_destroy_socket()... but all the other ATM drivers also seem to clear
> it for themselves, and that would appear to be harmless.

yeah, like i said, it is spuriously cleared in the drivers and should
probably just be moved to under the control of the next layer up
completely.  drivers/atm should just handle the hardware side, not the
software side.

> > checking for ATM_VF_READY in find_vcc() is probably going to give you
> > grief as well since ATM_VF_READY isnt entirely under your control. 
> 
> That's fine. If *anyone* has cleared ATM_VF_READY, I stop sending
> packets up it. Or, more to the point, I stop using the damn thing at
> all. See commit 1f6ea6e511e5ec730d8e88651da1b7b6e8fd1333.
> 
> >  you need to be able to find the vcc until after pclose() is finished since
> > your tasklet might have a few packets it is still processing?
> 
> The whole point of that check is that the tasklet *won't* be able to
> find it any more, and it'll just discard incoming packets for the
> obsolescent VCC.

that's fine as long as you understand this.  in the case of the he, i
needed to be able to find the vcc until close() is finished so that i
can wakeup the sleeper in the close() routine that is waiting for the
reassembly queue to be cleared/reset.  also, i still needed to find the
vcc for the tx side during close() since i still might need to pop()
skb's that are being sent during the close() while i am still trying to
get the hardware to shutdown the transmit dma engine.
