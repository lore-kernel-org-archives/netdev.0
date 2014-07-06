From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] vsprintf: Remove SPECIAL from pointer types
Date: Sun, 6 Jul 2014 12:44:40 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407061222270.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>         <20140702.182807.1245632778216212860.davem@davemloft.net>         <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>         <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
         <1404356734.14741.18.camel@joe-AO725>         <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>         <1404364565.14741.26.camel@joe-AO725>         <alpine.LFD.2.11.1407030637030.15455@eddie.linux-mips.org>         <1404368746.14741.36.camel@joe-AO725>
         <alpine.LFD.2.11.1407051529040.15455@eddie.linux-mips.org>         <1404576420.6384.41.camel@joe-AO725>         <alpine.LFD.2.11.1407051833400.15455@eddie.linux-mips.org>         <1404583739.6384.51.camel@joe-AO725>        
 <alpine.LFD.2.11.1407051917480.15455@eddie.linux-mips.org>         <1404585099.6384.53.camel@joe-AO725>         <alpine.LFD.2.11.1407052103130.15455@eddie.linux-mips.org> <1404593114.6384.72.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404593114.6384.72.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 5 Jul 2014, Joe Perches wrote:

> Because gcc issues a complaint about any pointer format with %#p,
> remove the use of SPECIAL to prefix 0x to various pointer types.
> 
> There are no uses in the kernel tree of %#p.
> 
> This removes the capability added by commit 725fe002d315
> ("vsprintf: correctly handle width when '#' flag used in %#p format").
> 
> There are some incidental message logging output changes of %pa
> uses with this change.  None are in seq output so there are no
> api changes.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> Fine by me, here...
> 
> On Sat, 2014-07-05 at 21:25 +0100, Maciej W. Rozycki wrote:
> > On Sat, 5 Jul 2014, Joe Perches wrote:
> > 
> > > > > I don't think %#p is valid so it
> > > > > shouldn't have been set by #.
> > > > 
> > > >  Huh?  As recently as last Wednesday you pointed me at the specific commit
> > > > from Grant that made it valid (GCC format complaints aside).
> > > 
> > > Those gcc complaints are precisely the thing
> > > that makes it invalid.
> > 
> >  So enforce that in code then, clear the SPECIAL flag where appropriate 
> > and do not try to handle it in one place while leaving other ones to 
> > behave randomly (i.e. a supposedly fixed field width varies depending on 
> > the two uppermost digits).  Please note that it's only your proposed 
> > change that introduces that randomness, right now code does what's 
> > supposed and documented to, except a bit inconsistently.
> > 
> > > I believe you're tilting at windmills.
> > > 
> > > Hey, it works sometimes.  Knock yourself out.
> > 
> >  I pointed out an inconsistency with the intent to propose a fix once a 
> > consensus have been reached, one way or another.  And I think shifting the 
> > inconsistency to a different place, which is what your proposal does, 
> > isn't really a complete solution, although I do recognise the improvement.

 Conceptually good, thanks for your effort, but you still need to clear 
SPECIAL in `pointer' and maybe elsewhere, as that'll have been set for the 
case concerned in `format_decode' by this code:

		case '#': spec->flags |= SPECIAL; break;

(that doesn't check what follows) and then respected once `number' is 
reached.  E.g.:

char *pointer(const char *fmt, char *buf, char *end, void *ptr,
	      struct printf_spec spec)
{
	int default_width = 2 * sizeof(void *);

	spec.flags &= ~SPECIAL;

or suchlike.  Sorry to have been unclear about it.

 Note that obviously GCC will only complain about `#' if the format is 
constant, there's no way for it to work through a variable format, e.g.:

{
	char *f;
	void *const p = NULL;

	printk("%#p\n", p);
	f = kstrdup("%#p\n", GFP_KERNEL);
	printk(f, p);
	kfree(f);
}

-- it'll complain only about the first `printk', not the second.

  Maciej
