From: FUJITA Tomonori <tomof@acm.org>
Subject: Re: 2.6.24-rc6-mm1
Date: Sun, 6 Jan 2008 12:28:00 +0900
Message-ID: <20080106123103K.tomof@acm.org>
References: <64bb37e0801050652t7568e438uf93208601df84ef6@mail.gmail.com>
	<64bb37e0801051410p39746295oab4dad438943372@mail.gmail.com>
	<20080105172524.fecb63bf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: just.for.lkml@googlemail.com, jarkao2@gmail.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	neilb@suse.de, bfields@fieldses.org, netdev@vger.kernel.org,
	tom@opengridcomputing.com, tomof@acm.org
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755874AbYAFD2j@vger.kernel.org>
Cc: fujita.tomonori@lab.ntt.co.jp
In-Reply-To: <20080105172524.fecb63bf.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 5 Jan 2008 17:25:24 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Sat, 5 Jan 2008 23:10:17 +0100 "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
> 
> > On Jan 5, 2008 3:52 PM, Torsten Kaiser <just.for.lkml@googlemail.com> wrote:
> > > On Jan 5, 2008 11:13 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > > > On Sat, Jan 05, 2008 at 09:01:02AM +0100, Torsten Kaiser wrote:
> > > > > On Jan 5, 2008 1:07 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > > > > > I think it would be easier just to start with this working -rc6 and
> > > > > > simply check if we have 'right' suspects, so: git-net.patch and
> > > > > > git-nfsd.patch from -mm1-broken-out, as suggested by Herbert (I hope,
> > > > > > can compile - otherwise you could try the other way: add the whole -mm
> > > > > > and revert these two). Using current gits could complicate this
> > > > > > "investigation".
> > > > >
> > > > > OK, I will try this...
> > >
> > > still on the todo-list, I had no time to try this yet...
> > 
> > working on it...
> > 2.6.24-rc6 + mm-patches up to git.battery (includes git-net and
> > git-netdev-all) worked for 110 packages, then I proclaimed it good.
> > 2.6.24-rc6 + mm-patches up to (including) git.nfsd is currently
> > getting testet (9 packages done...)
> > 
> > But the cause of my mail is the following question:
> > Regarding my "iommu-sg-merging-patches are new in -rc3-mm and could be
> > the cause"-suspicion I looked at these patches and came across these
> > hunks:
> > 
> > This is removed from arch/x86/lib/bitstr_64.c:
> > -/* Find string of zero bits in a bitmap */
> > -unsigned long
> > -find_next_zero_string(unsigned long *bitmap, long start, long nbits, int len)
> > -{
> > -       unsigned long n, end, i;
> > -
> > - again:
> > -       n = find_next_zero_bit(bitmap, nbits, start);
> > -       if (n == -1)
> > -               return -1;
> > -
> > -       /* could test bitsliced, but it's hardly worth it */
> > -       end = n+len;
> > -       if (end > nbits)
> > -               return -1;
> > -       for (i = n+1; i < end; i++) {
> > -               if (test_bit(i, bitmap)) {
> > -                       start = i+1;
> > -                       goto again;
> > -               }
> > -       }
> > -       return n;
> > -}
> > 
> > This is added to lib/iommu-helper.c:
> > +static unsigned long find_next_zero_area(unsigned long *map,
> > +                                        unsigned long size,
> > +                                        unsigned long start,
> > +                                        unsigned int nr)
> > +{
> > +       unsigned long index, end, i;
> > +again:
> > +       index = find_next_zero_bit(map, size, start);
> > +       end = index + nr;
> > +       if (end > size)
> > +               return -1;
> > +       for (i = index + 1; i < end; i++) {
> > +               if (test_bit(i, map)) {
> > +                       start = i+1;
> > +                       goto again;
> > +               }
> > +       }
> > +       return index;
> > +}
> > 
> > The old version checks, if find_next_zero_bit returns -1, the new
> > version doesn't do this.
> > Is this intended and can find_next_zero_bit never fail?
> > Hmm... but in the worst case it should only loop forever if I'm
> > reading this right (index = -1 => for-loop counts from 0 to nr, if any
> > bit is set it will jump to "again:" and if the next call to
> > find_next_zero_bit also fails, its an endless loop)

find_next_zero_bit returns -1?

It seems that x86_64 doesn't. POWER and SPARC64 IOMMUs use
find_next_zero_bit too but both doesn't check if find_next_zero_bit
returns -1. If find_next_zero_bit fails, it returns size. So it
doesn't leads to an endless loop.

But this patch has other bugs that break POWER IOMMUs.

If you use the IOMMUs on POWER, please try the following patch:

http://www.mail-archive.com/linux-scsi@vger.kernel.org/msg12702.html

> 
> I susect these are doing different things. 
> iommu-sg-kill-__clear_bit_string-and-find_next_zero_string.patch says:
> 
>   This kills unused __clear_bit_string and find_next_zero_string (they
>   were used by only gart and calgary IOMMUs).
> 
> iommu-sg-add-iommu-helper-functions-for-the-free-area-management.patch says:
> 
>   This adds IOMMU helper functions for the free area management.  These
>   functions take care of LLD's segment boundary limit for IOMMUs.  They
>   would be useful for IOMMUs that use bitmap for the free area management.
> 
> > So even if this can not explain my bug, could somebody check if this
> > is a real bug or not?
> 
> Let's cc the author of those changes.
> 
> Thanks for persisting with this bug.
