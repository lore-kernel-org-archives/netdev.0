From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCHv5 1/4] modem_shm: Add Modem Access Framework
Date: Wed, 17 Oct 2012 12:15:49 -0700
Message-ID: <20121017191549.GA18374@kroah.com>
References: <1350278920-25510-1-git-send-email-arun.murthy@stericsson.com>
 <1350278920-25510-2-git-send-email-arun.murthy@stericsson.com>
 <20121015212943.GA12540@kroah.com>
 <F45880696056844FA6A73F415B568C695B9C5CECE3@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>
To: Arun MURTHY <arun.murthy@stericsson.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F45880696056844FA6A73F415B568C695B9C5CECE3@EXDCVYMBSTM006.EQ1STM.local>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 17, 2012 at 10:00:10AM +0200, Arun MURTHY wrote:
> > On Mon, Oct 15, 2012 at 10:58:37AM +0530, Arun Murthy wrote:
> > 
> > I'm going to ignore your .c logic, as there are things in it that I don't think is
> > correct.  But it all comes down to your data structures, if you fix them, then
> > the .c logic will become correct:

You still aren't understanding what I am trying to say here.

So, one final try...

> > > +
> > > +#include <linux/device.h>
> > > +
> > > +struct clients {
> > > +	struct device *dev;
> > 
> > Why is this a pointer?  It should be embedded in the structure.
> 
> This is the pointer to the clients's device structure. There will be a
> single entity for a modem but multiple clients. Hence this struct is 
> specific for each client.

But each "client" should be a device, so embed it in the structure.

> > > +	atomic_t cnt;
> > 
> > Why is this needed at all?  And if it's needed, why is it an atomic?
> > (hint, your use of atomic_t really isn't correct at all in this patch, it's not doing
> > what you think it is doing...)
> 
> Basically the operation done by this, i.e modem access/release has a lot of
> affect on the clients. Since we are accesing some modem registers without
> this modem request it might lead to system freeze. Hence such cross over
> scenarios are considered and the counter is increased/decreased after the
> operation(modem access/release). And reading of these variable are done
> especially during system suspend, where decision is taken based on the value
> of the counter read, hence any modification done should preside over read.
> Moreover since there are multiple clients, using atomic for a simple locking
> mechanism.

Hint, if you _ever_ say, "I'll use an atomic_t as a simple lock", you
are usually wrong.  But sometimes it can be done right.  So I went and
re-read your implementation.

You got it wrong.

So don't do this.

Seriously, an atomic value is not a lock, and, as you used it, it
doesn't even work properly.  So don't try to roll your own lock, either
use a lock, or use the built-in-reference-counting of the driver core,
which is what I keep saying here.

I'll say it again, don't do this.  Use the build-in reference count of
the struct device, that the kernel can manage for you, to handle this.
It will do it correctly, simply, and make your life a whole lot easier,
and better yet, will allow me to accept this code.

As it is, it is broken and wrong and quite buggy.

Please use the driver core properly.  I know it can be difficult, and
isn't the best documented body of code.  But it works, and works well,
and when people try to work around it thinking they don't need it, or
will just roll their own logic instead, they get it wrong and it causes
problems.  Just like this implementation shows.

So please, go back, consult with others on your team about how to do
this right.

If you have specific questions about the driver core that I can answer,
after you have read a few users of it (look at the bus code from
something "simple" for how to do this, don't look at USB) I will be glad
to help out.  But I feel that the previous review comments I have made
in this area, have been totally ignored, so I'm loath to try to do the
design work for you here.  You need to work it out so you feel
comfortable with it, not me.

good luck,

greg k-h

p.s. I'm sure your company/team/coworkers can help review your patches,
right?  Please run them by someone else first, that would have caught
the locking/atomic_t issue immediately.
