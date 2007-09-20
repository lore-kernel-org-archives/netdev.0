From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc6-mm1
Date: Thu, 20 Sep 2007 12:44:20 -0700
Message-ID: <20070920124420.2a57ea7b.akpm@linux-foundation.org>
References: <20070918011841.2381bd93.akpm@linux-foundation.org>
	<20070919235828.GA31759@nineveh.local>
	<20070919170934.84f44e05.akpm@linux-foundation.org>
	<f86d6cc00709200721h6e8f7cf8xa2264e9d1f88883b@mail.gmail.com>
	<f86d6cc00709200912j37a3218boa882a044c0610779@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Joseph Fannin" <jfannin@gmail.com>, linux-kernel@vger.kernel.org,
	"Mike Travis" <travis@sgi.com>, netdev@vger.kernel.org
To: "Kamalesh Babulal" <kamalesh.babulal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55646 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751334AbXITToc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 15:44:32 -0400
In-Reply-To: <f86d6cc00709200912j37a3218boa882a044c0610779@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Sep 2007 21:42:44 +0530
"Kamalesh Babulal" <kamalesh.babulal@gmail.com> wrote:

> ...
>
> > i have tested the change with cross compiler for power405 with the same
> > .config
> > with which the build problem is solved, but the build fails with another
> > error
> >
> >   CC [M]  drivers/net/mace.o
> > drivers/net/mace.c: In function 'mace_handle_misc_intrs':
> > drivers/net/mace.c:642: error: 'dev' undeclared (first use in this
> > function)
> > drivers/net/mace.c:642: error: (Each undeclared identifier is reported
> > only once
> > drivers/net/mace.c:642: error: for each function it appears in.)
> > make[2]: *** [drivers/net/mace.o] Error 1
> > make[1]: *** [drivers/net] Error 2
> > make: *** [drivers] Error 2
> >
> > This patch fixes the build failure
> >
> > Signed-off-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
> > ---
> > --- linux-2.6.23-rc6 /drivers/net/mace.c 2007-09-20 17:16:50.000000000+0530
> > +++ linux-2.6.23-rc6/drivers/net/~mace.c        2007-09-20 17:12:
> > 47.000000000 +0530
> > @@ -633,7 +633,7 @@ static void mace_set_multicast(struct ne
> >      spin_unlock_irqrestore(&mp->lock, flags);
> >  }
> >
> > -static void mace_handle_misc_intrs(struct mace_data *mp, int intr)
> > +static void mace_handle_misc_intrs(struct mace_data *mp, int intr, struct
> > net_device *dev)
> >  {
> >      volatile struct mace __iomem *mb = mp->mace;
> >      static int mace_babbles, mace_jabbers;
> > @@ -669,7 +669,7 @@ static irqreturn_t mace_interrupt(int ir
> >      spin_lock_irqsave(&mp->lock, flags);
> >      intr = in_8(&mb->ir);              /* read interrupt register */
> >      in_8(&mb->xmtrc);                  /* get retries */
> > -    mace_handle_misc_intrs(mp, intr);
> > +    mace_handle_misc_intrs(mp, intr, dev);
> >
> >      i = mp->tx_empty;
> >      while (in_8(&mb->pr) & XMTSV) {
> > @@ -682,7 +682,7 @@ static irqreturn_t mace_interrupt(int ir
> >          */
> >         intr = in_8(&mb->ir);
> >         if (intr != 0)
> > -           mace_handle_misc_intrs(mp, intr);
> > +           mace_handle_misc_intrs(mp, intr, dev);
> >         if (mp->tx_bad_runt) {
> >             fs = in_8(&mb->xmtfs);
> >             mp->tx_bad_runt = 0;
> > @@ -817,7 +817,7 @@ static void mace_tx_timeout(unsigned lon
> >         goto out;
> >
> >      /* update various counters */
> > -    mace_handle_misc_intrs(mp, in_8(&mb->ir));
> > +    mace_handle_misc_intrs(mp, in_8(&mb->ir), dev);
> >
> >      cp = mp->tx_cmds + NCMDS_TX * mp->tx_empty;

Thanks, I will fix the wordwrapping in your patch and shall send it in to
David. 

> 
> Hi,
> 
> The build fails when compiling with the same .config over cross compiler for
> powerpc405
> 
> drivers/net/mv643xx_eth.c: In function 'mv643xx_eth_int_handler':
> drivers/net/mv643xx_eth.c:564: error: 'bp' undeclared (first use in this
> function)
> drivers/net/mv643xx_eth.c:564: error: (Each undeclared identifier is
> reported only once
> drivers/net/mv643xx_eth.c:564: error: for each function it appears in.)
> drivers/net/mv643xx_eth.c: At top level:
> drivers/net/mv643xx_eth.c:1010: error: conflicting types for 'mv643xx_poll'
> drivers/net/mv643xx_eth.c:68: error: previous declaration of 'mv643xx_poll'
> was here
> make[2]: *** [drivers/net/mv643xx_eth.o] Error 1
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2

Yes, rather a lot of net drivers got broken in easy-to-fix ways.
