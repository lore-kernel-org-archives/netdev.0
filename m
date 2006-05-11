From: Andy Gay <andy@andynet.net>
Subject: Re: [Bugme-new] [Bug 6530] New: MAINLINE
Date: Thu, 11 May 2006 01:51:23 -0400
Message-ID: <1147326683.29448.80.camel@tahini.andynet.net>
References: <200605100920.k4A9KC91018259@fire-2.osdl.org>
	<20060510023357.0d1260ee.akpm@osdl.org>
	<17505.49174.848331.686297@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org, xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms048pub.verizon.net ([206.46.252.48]:52475 "EHLO
	vms048pub.verizon.net") by vger.kernel.org with ESMTP
	id S1751528AbWEKFvg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 May 2006 01:51:36 -0400
Received: from andyhp.tranquilitynj.net ([70.21.209.84])
 by vms048.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
 with ESMTPA id <0IZ300MBK6XPSGUD@vms048.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 11 May 2006 00:51:30 -0500 (CDT)
In-reply-to: <17505.49174.848331.686297@cargo.ozlabs.ibm.com>
To: Paul Mackerras <paulus@samba.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-05-10 at 20:27 +1000, Paul Mackerras wrote:
> Andrew Morton writes:
> 
> > hm, a PPP fix.  We seem to need some of those lately.
> > 
> > Paul, does this look sane?
> 
> /me pages in 7 year old code...
> 
> > @@ -516,6 +516,8 @@ static void ppp_async_process(unsigned l
> >  	/* try to push more stuff out */
> >  	if (test_bit(XMIT_WAKEUP, &ap->xmit_flags) && ppp_async_push(ap))
> >  		ppp_output_wakeup(&ap->chan);
> > +	else if (test_bit(XMIT_FULL, &ap->xmit_flags))
> > +		ppp_asynctty_wakeup(ap->tty);
> 
> ppp_asynctty_wakeup is supposed to be called by the serial driver when
> it can take more output.

How does the serial driver know it has to call ppp_asynctty_wakeup()?
I'd have thought it wouldn't know or care if it's being used for ppp or
any other async traffic.

There were a bunch of changes to the serial drivers between 2.6.15 and
2.6.16, maybe that's where this problem was introduced. Do we know which
serial driver is involved in the original report?

(I'm interested in this because I need to convert an out of tree serial
driver for 2.6.16+, I'm wondering if I'll need to do anything special to
support ppp).

>   It's slightly bogus having ppp_async call it
> itself whether or not the serial driver can take more output at the
> moment, but I suppose it won't hurt.  I would really like to know the
> precise circumstances where we need this fake wakeup though.  Is the
> serial driver failing to give us a wakeup call where it should, or is
> ppp_async ignoring a wakeup for some reason?
> 
> I think the same effect could be achieved without an extra trip
> through tasklet_schedule et al. by making those lines look like this
> (untested):
> 
> 	if ((test_bit(XMIT_WAKEUP, &ap->xmit_flags) ||
>              test_bit(XMIT_FULL, &ap->xmit_flags)) && ppp_async_push(ap))
> 		ppp_output_wakeup(&ap->chan);
> 
> so that ppp_async_push gets called if either XMIT_WAKEUP or XMIT_FULL
> is set.
> 
> This is all relying on getting some input to kick off more output when
> the wakeup gets missed, though.  That's a reasonable workaround in most
> situations, I guess, but I'd really like to know why the wakeup is
> getting missed.
> 
> Paul.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

