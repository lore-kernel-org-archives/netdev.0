From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [5.3] ucc_geth: Fix to avoid IS_ERR_VALUE abuses and dead code
 on 64bit systems.
Date: Mon, 8 Aug 2016 15:49:22 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F50C532@AcuExch.aculab.com>
References: <1470386442-7208-1-git-send-email-arvind.yadav.cs@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D5F50C493@AcuExch.aculab.com>
 <2862487.guU7g5Qkfj@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Arvind Yadav' <arvind.yadav.cs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org" <leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"qiang.zhao-KZfg59tc24xl57MIdRCFDg@public.gmane.org" <qiang.zhao-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org" <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org" <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
To: 'Arnd Bergmann' <arnd-r2nGTMty4D4@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2862487.guU7g5Qkfj@wuerfel>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann
> Sent: 08 August 2016 16:13
> 
> On Monday, August 8, 2016 2:49:11 PM CEST David Laight wrote:
> >
> > > If qe_muram_alloc will return any error, Then IS_ERR_VALUE will always
> > > return 0. it'll not call ucc_fast_free for any failure. Inside 'if code'
> > > will be a dead code on 64bit. Even qe_muram_addr will return wrong
> > > virtual address. Which can cause an error.
> > >
> > >  kfree((void *)ugeth->tx_bd_ring_offset[i]);
> >
> > Erm, kfree() isn't the right function for things allocated by qe_muram_alloc().
> >
> > I still thing you need to stop this code using IS_ERR_VALUE() at all.
> 
> Those are two separate issues:
> 
> a) The ucc_geth driver mixing kmalloc() memory with muram, and assigning
>    the result to "u32" and "void __iomem *" variables, both of which
>    are wrong at least half of the time.
> 
> b) calling conventions of qe_muram_alloc() being defined in a way that
>    requires the use of IS_ERR_VALUE(), because '0' is a valid address
>    here.

Yep, it is all a big bag of worms...
'0' being valid is going to make tidying up after failure 'problematic'.

> The first one can be solved by updating the network driver, ideally
> by getting rid of the casts and using proper types and accessors,
> while the second would require updating all users of that interface.

It might be worth (at least as a compilation option) of embedding the
'muram offset' in a structure (passed and returned by value).

The compiler can then check that the driver code is never be looking
directly at the value.

For 'b' zero can be made invalid by changing the places where the
offset is added/subtracted.
It could even be used to offset the saved physical and virtual
addresses of the area - so not needing any extra code when the values
are converted to physical/virtual addresses.

	David

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
