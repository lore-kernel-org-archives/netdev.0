From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH 6/6] drivers/net/pppol2tp.c: remove null pointer dereference
Date: Mon, 12 May 2008 21:00:24 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0805122054280.20369@ask.diku.dk>
References: <Pine.LNX.4.64.0805121538510.3694@ask.diku.dk> <48287A86.1070401@katalix.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:33044 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756301AbYELTA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 15:00:28 -0400
In-Reply-To: <48287A86.1070401@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 May 2008, James Chapman wrote:

> Adding netdev to CC list.
> 
> Julia Lawall wrote:
> > From: Julia Lawall <julia@diku.dk>
> > 
> > If session is NULL, it is not possible to access its name field.  So I have
> > split apart the printing of the error message to drop the printing of the
> > name field in this case.
> 
> I suggest add a note in the patch description that this bug will only be hit
> if the driver's debug is enabled.

I don't understand the above comment.  In both the original and the new 
code, if session is NULL, the first argument to PRINTK is -1 and the 
second argument is PPPOL2TP_MSG_CONTROL, for which the only definition 
seems to be the on in include/linux/if_pppol2tp.h, where it has a non-zero 
value.  So the test in the definition of PRINTK is non-zero and the print 
occurs.  Perhaps this is not what is wanted?

julia


> > This problem was found using the following semantic match
> > (http://www.emn.fr/x-info/coccinelle/)
> > 
> > // <smpl>
> > @@
> > expression E, E1;
> > identifier f;
> > statement S1,S2,S3;
> > @@
> > 
> > * if (E == NULL)
> > {
> >   ... when != if (E == NULL) S1 else S2
> >       when != E = E1
> > * E->f
> >   ... when any
> >   return ...;
> > }
> > else S3
> > // </smpl>
> 
> Perhaps the above text should be in the additional info section of the patch
> description?
> 
> Since this is a network driver, can you resubmit the patch to netdev?
> 
> > Signed-off-by: Julia Lawall <julia@diku.dk>
> > 
> > ---
> > 
> > diff -u -p a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
> > --- linux-2.6/drivers/net/pppol2tp.c	2008-05-09 16:46:57.000000000 +0200
> > +++ linuxcopy/drivers/net/pppol2tp.c	2008-05-12 15:30:52.000000000 +0200
> > @@ -1621,9 +1621,16 @@ out_no_ppp:
> >  end:
> >   release_sock(sk);
> > 
> > -	if (error != 0)
> > -		PRINTK(session ? session->debug : -1, PPPOL2TP_MSG_CONTROL,
> > KERN_WARNING,
> > -		       "%s: connect failed: %d\n", session->name, error);
> > +	if (error != 0) {
> > +		if (session)
> > +			PRINTK(session->debug,
> > +				PPPOL2TP_MSG_CONTROL, KERN_WARNING,
> > +				"%s: connect failed: %d\n",
> > +				session->name, error);
> > +		else
> > +			PRINTK(-1, PPPOL2TP_MSG_CONTROL, KERN_WARNING,
> > +				"connect failed: %d\n", error);
> > +	}
> >  
> >  	return error;
> >  }
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
