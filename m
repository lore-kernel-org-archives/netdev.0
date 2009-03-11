From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH 2/3] bnx2x: Casting page alignment
Date: Wed, 11 Mar 2009 05:51:39 -0700
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AAD81502A0DED@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1236595937.11030.13.camel@lb-tlvb-eliezer>
 <200903102148.15826.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Alex Chiang" <achiang@hp.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eilon Greenstein" <eilong@broadcom.com>,
	"Bjorn Helgaas" <bjorn.helgaas@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4788 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981AbZCKMv4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 08:51:56 -0400
In-Reply-To: <200903102148.15826.bjorn.helgaas@hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

See below. 

> > diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
> > index 15a5cf0..3cf2b92 100644
> > --- a/drivers/net/bnx2x.h
> > +++ b/drivers/net/bnx2x.h
> > @@ -152,7 +152,7 @@ struct sw_rx_page {
> >  #define PAGES_PER_SGE			(1 << 
PAGES_PER_SGE_SHIFT)
> >  #define SGE_PAGE_SIZE			PAGE_SIZE
> >  #define SGE_PAGE_SHIFT			PAGE_SHIFT
> > -#define SGE_PAGE_ALIGN(addr)		PAGE_ALIGN(addr)
> > +#define SGE_PAGE_ALIGN(addr)		PAGE_ALIGN((typeof(PAGE_SIZE))addr)
> 
> For one thing, we started with SGE_PAGE_SIZE,SHIFT,ALIGN being
> exact duplicates of PAGE_SIZE,SHIFT,ALIGN, which makes me wonder
> why we need the SGE_ variety.

SGE_X macros represent the interface to our microcode, which currently
works with native page sizes, however this may change in the future (and
it was different in the past). So, as long as it doesn't harm the performance,
adds readability and is a better programming style (as long as it
implements specific functionality) I'd prefer to leave it the way it is. 

But thanks for reviewing, Bjorn.

> 
> But more importantly, the patch adds a cast in SGE_PAGE_ALIGN to
> ensure that its argument doesn't get truncated in the process of
> being rounded up.  This could happen anywhere, not just in bnx2x,
> so my question is whether the cast should be done in PAGE_ALIGN
> itself so we don't trip over this again somewhere else.
> 

Frankly speaking I thought of it too, when I found the "bug" and I was quite pissed off
with the change in PAGE_ALIGN macro introduced in 2.6.27 (http://lkml.org/lkml/2008/6/15/85).
It's always pissing off when u have to change your code... ;)
But then I gave it another look and agreed that it's only the mater of semantics.

To recall, the change in general was to perform the alignment inside the range of the type
of the argument, which means, for example, when u have something like:

/* e.g. ppc64 with 64K page size */
#define PAGE_SIZE 65536  /* 64KB */

u16 k = 10;
u32 n = PAGE_ALIGN(k); /* This will give u 0 and not 64K as u might expect */

/* End of example */

The semantics had been changed to implement the following sentence:
"PAGE_ALIGN(k) is a value that k would have if aligned to the PAGE_SIZE"
rather than "PAGE_ALIGN(k) is the smallest multiple of PAGE_SIZE larger than k".
There were reasons for that - see the comments for the Andrea's patch.

So, as I said, when I was going to submit a patch fixing PAGE_ALIGN
macro:
 - PAGE_SIZE should be of the integer type having the same size as void*.
 - PAGE_ALIGN(x) should be defined as (((x)+PAGE_SIZE-1) & PAGE_MASK).

I understood that there is no actually important reason not to use ALIGN(x,a) macro for
PAGE_ALIGN and redefine it.

Right, there is this "feature" that I've described above but it's quite fair: aligned value stays inside
the boundaries of the value u r going to align, and if u expect it to the larger - do the proper cast.
This is exactly what my patch is doing.

Once again, thanks for reviewing and sorry if I talked to much... :)

Regards,
vlad
