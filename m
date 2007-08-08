From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Tue, 07 Aug 2007 20:56:40 -0700
Message-ID: <adahcnar85j.fsf@cisco.com>
References: <20070805.232423.21363072.davem@davemloft.net>
	<adasl6vq8d1.fsf@cisco.com>
	<20070807.160651.98554604.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:33091 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760742AbXHHD4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 23:56:46 -0400
In-Reply-To: <20070807.160651.98554604.davem@davemloft.net> (David Miller's message of "Tue, 07 Aug 2007 16:06:51 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > >  >  		n = ib_poll_cq(priv->cq, t, priv->ibwc);
 > >  >  
 > >  > -		for (i = 0; i < n; ++i) {
 > >  > +		for (i = 0; i < n; i++) {
 > > 
 > > it might be nicer to avoid noise like this in the patch.

 > That one was just too much of an eye sore to ignore and it
 > effect my ability to audit the change I was making.
 > 
 > I mean, this is one of the first precise examples of kinds of
 > programming that lead to subtle bugs mentioned in The Practice of
 > Programming.
 > 
 > So this is staying in the patch, sorry.

This is a pretty minor point but this attitude is a little too much
for me to take.  First, there's pretty much universal agreement that
patches should only contain one idea ("separate your changes"), that
cleanups should not be mixed in with other changes, etc, etc.

Second, you know as well as I do *why* patches aren't supposed to do
this.  Adding more lines of changes into your patch is exactly what
makes it *harder* for everyone to audit.  Every single person who
reviews the ipoib part of the patch has to look at that change and
waste a few seconds realizing, "oh, I see, the only difference here is
a cleanup unrelated to the NAPI conversion."  As for "subtle bugs" --
we both know that even the most obviously safe changes always have a
chance at introducing a bug, and it's always safer to leave something
alone.

So if you want to tinker with the code here, fine, it's just a
harmless annoyance -- I can spend the tiny amount of time to check
that the change is OK.  But don't try to tell me it's good programming
practice.  I know that you know better: in commit a2fb23af, you had
the sense to leave the line

	for (i = 0; i < PCI_NUM_RESOURCES - PCI_BRIDGE_RESOURCES; ++i) {

alone when you copied it from arch/powerpc, rather than tinkering with
known-working code.

Sorry.  That's probably way too much time wasted on something so trivial.

 > > this goto back to the polling loop is a change in behavior.  When we
 > > were tuning NAPI, we found that returning in the missed event case and
 > > letting the NAPI core call the poll routine later actually performed
 > > better, because it allowed more work to pile up.

 > You weren't using your quantum, which is what you're supposed to do.
 > 
 > Sometimes using your quantum correctly won't perform optimally, but in
 > the interest of fairness and what NAPI wants, that is what you're
 > supposed to do, process work until you hit budget or there is no
 > more work.
 > 
 > Look, I'm not going to back down to every single tweak in every
 > driver.  All the drivers should handle this case consistently, and if
 > I have to edit every single driver to make this patch that is exactly
 > what I am going to do and enforce.

OK, although I think it would be better to put changes in driver
behavior into independent patches from the main NAPI change, if only
for the sake of bisectability (otherwise everything is just going to
bisect back to your mega-patch and that kind of sucks for debugging;
cf Linus's reaction to the x86-64 timer conversion patches).

I don't have a lot invested into the details of the NAPI polling here,
but I'll ask the IBM people who saw a big difference in performance
between jumping back directly or waiting for the poll to be
rescheduled to retest and report their results.

Although frankly, I have to say that your position here doesn't make
much sense.  In your earlier patches that got rid of netif_rx_reschedule(),
your suggestion on how to handle the missed event race was to ask the
hardware to trigger another event from the poll routine so it got
rescheduled.  And if the poll routine knows there's more work pending,
I don't see much difference in requesting a synthetic event from the
hardware and then exiting the poll routine versus raising the poll
softirq directly and then exiting the poll routine.

 > If you patch the ipoib driver behavior back afterwards, I will NAK
 > that patch every single time unless you make EVERY SINGLE OTHER DRIVER
 > do the same and thus retain the consistency.

At a meta level, I think it would be better for everyone's blood
pressure if you tried to keep the temperature down during technical
discussions like this.  Look back at what I wrote: "this goto ... is a
change in behavior," and then I explained the current behavior.  I
didn't threaten to NAK this NAPI patch, or even ask you to change the
patch.  I just gave you the information so that you could explain your
reasoning in case the change was intended, or so you could keep the
current behavior if the change was inadvertent.  Being treated with
the same level of collegiality that (I think) I treat you with would
be appreciated.

 - R.
