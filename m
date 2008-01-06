From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Sun, 6 Jan 2008 11:41:10 +0100
Message-ID: <64bb37e0801060241o2c6d8172r73b69291fce76ce1@mail.gmail.com>
References: <64bb37e0801050652t7568e438uf93208601df84ef6@mail.gmail.com>
	 <64bb37e0801051410p39746295oab4dad438943372@mail.gmail.com>
	 <20080105172524.fecb63bf.akpm@linux-foundation.org>
	 <20080106123103K.tomof@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jarkao2@gmail.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	neilb@suse.de, bfields@fieldses.org, netdev@vger.kernel.org,
	tom@opengridcomputing.com, fujita.tomonori@lab.ntt.co.jp
To: "FUJITA Tomonori" <tomof@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:7732 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbYAFKlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2008 05:41:11 -0500
Received: by py-out-1112.google.com with SMTP id u52so11957152pyb.10
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2008 02:41:10 -0800 (PST)
In-Reply-To: <20080106123103K.tomof@acm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 6, 2008 4:28 AM, FUJITA Tomonori <tomof@acm.org> wrote:
> On Sat, 5 Jan 2008 17:25:24 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Sat, 5 Jan 2008 23:10:17 +0100 "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
> > > But the cause of my mail is the following question:
> > > Regarding my "iommu-sg-merging-patches are new in -rc3-mm and could be
> > > the cause"-suspicion I looked at these patches and came across these
> > > hunks:
> > >
> > > This is removed from arch/x86/lib/bitstr_64.c:
> > > -/* Find string of zero bits in a bitmap */
> > > -unsigned long
> > > -find_next_zero_string(unsigned long *bitmap, long start, long nbits, int len)
> > > -{
> > > -       unsigned long n, end, i;
> > > -
> > > - again:
> > > -       n = find_next_zero_bit(bitmap, nbits, start);
> > > -       if (n == -1)
> > > -               return -1;
> > > -
> > > -       /* could test bitsliced, but it's hardly worth it */
> > > -       end = n+len;
> > > -       if (end > nbits)
> > > -               return -1;
> > > -       for (i = n+1; i < end; i++) {
> > > -               if (test_bit(i, bitmap)) {
> > > -                       start = i+1;
> > > -                       goto again;
> > > -               }
> > > -       }
> > > -       return n;
> > > -}
> > >
> > > This is added to lib/iommu-helper.c:
> > > +static unsigned long find_next_zero_area(unsigned long *map,
> > > +                                        unsigned long size,
> > > +                                        unsigned long start,
> > > +                                        unsigned int nr)
> > > +{
> > > +       unsigned long index, end, i;
> > > +again:
> > > +       index = find_next_zero_bit(map, size, start);
> > > +       end = index + nr;
> > > +       if (end > size)
> > > +               return -1;
> > > +       for (i = index + 1; i < end; i++) {
> > > +               if (test_bit(i, map)) {
> > > +                       start = i+1;
> > > +                       goto again;
> > > +               }
> > > +       }
> > > +       return index;
> > > +}
> > >
> > > The old version checks, if find_next_zero_bit returns -1, the new
> > > version doesn't do this.
> > > Is this intended and can find_next_zero_bit never fail?
> > > Hmm... but in the worst case it should only loop forever if I'm
> > > reading this right (index = -1 => for-loop counts from 0 to nr, if any
> > > bit is set it will jump to "again:" and if the next call to
> > > find_next_zero_bit also fails, its an endless loop)
>
> find_next_zero_bit returns -1?
>
> It seems that x86_64 doesn't.

I'm sorry. I didn't look into find_next_zero_bit, I only noted that
the old version did check for -1 and the new one didn't.
Obviously the old check was superfluous.

> POWER and SPARC64 IOMMUs use
> find_next_zero_bit too but both doesn't check if find_next_zero_bit
> returns -1. If find_next_zero_bit fails, it returns size. So it
> doesn't leads to an endless loop.

Yes, this can't happen. It was a wrong assumption on my part.

> But this patch has other bugs that break POWER IOMMUs.
>
> If you use the IOMMUs on POWER, please try the following patch:

I'm using CONFIG_GART_IOMMU=y on x86_64.

> http://www.mail-archive.com/linux-scsi@vger.kernel.org/msg12702.html

I also noted the line "index = (index + align_mask) & ~align_mask;" in
iommu_area_alloc() and didn't understand what this was trying to do
and how this should work, but as arch/x86/kernel/pci-gart_64.c always
uses 0 as align_mask I just ignored it.

I will applie your patch and see if this hunk from
find_next_zero_area() makes a difference:

       end = index + nr;
-       if (end > size)
+       if (end >= size)
                return -1;
-       for (i = index + 1; i < end; i++) {
+       for (i = index; i < end; i++) {
                if (test_bit(i, map)) {

Torsten
