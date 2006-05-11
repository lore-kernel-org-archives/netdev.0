From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6530] New: MAINLINE
Date: Wed, 10 May 2006 20:29:43 -0700
Message-ID: <20060510202943.35f548db.akpm@osdl.org>
References: <200605100920.k4A9KC91018259@fire-2.osdl.org>
	<20060510023357.0d1260ee.akpm@osdl.org>
	<17505.49174.848331.686297@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16349 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965120AbWEKDcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 23:32:39 -0400
To: Paul Mackerras <paulus@samba.org>
In-Reply-To: <17505.49174.848331.686297@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Mackerras <paulus@samba.org> wrote:
>
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
> it can take more output.  It's slightly bogus having ppp_async call it
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

(xeb, on this bug please respond via email using reply-to-all rather than
via the bugzilla web form).

xeb has said:

in this construction:

          if ((test_bit(XMIT_WAKEUP, &ap->xmit_flags) ||
             test_bit(XMIT_FULL, &ap->xmit_flags)) && ppp_async_push(ap))
                  ppp_output_wakeup(&ap->chan);

if ppp_async_push() doesn't send any data i.e.  XMIT_FULL is set then all
(transfer) hangs up while somebody push again, for instance lcp-echo.  
