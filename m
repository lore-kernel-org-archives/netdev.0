From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Sat, 5 Jan 2008 23:10:17 +0100
Message-ID: <64bb37e0801051410p39746295oab4dad438943372@mail.gmail.com>
References: <64bb37e0801040223q17a76565k3c7667a197403ce5@mail.gmail.com>
	 <20080104133031.GA3329@ff.dom.local>
	 <64bb37e0801040721p57ff3d54wc3de00546d1d2ff1@mail.gmail.com>
	 <20080105000700.GA3224@ami.dom.local>
	 <64bb37e0801050001x65b104bdl5a68c731b3656d17@mail.gmail.com>
	 <20080105101327.GA3103@ami.dom.local>
	 <64bb37e0801050652t7568e438uf93208601df84ef6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, "Neil Brown" <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	"Tom Tucker" <tom@opengridcomputing.com>
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:32425 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756710AbYAEWKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 17:10:19 -0500
Received: by py-out-1112.google.com with SMTP id u52so11790879pyb.10
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2008 14:10:18 -0800 (PST)
In-Reply-To: <64bb37e0801050652t7568e438uf93208601df84ef6@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 5, 2008 3:52 PM, Torsten Kaiser <just.for.lkml@googlemail.com> wrote:
> On Jan 5, 2008 11:13 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > On Sat, Jan 05, 2008 at 09:01:02AM +0100, Torsten Kaiser wrote:
> > > On Jan 5, 2008 1:07 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > > > I think it would be easier just to start with this working -rc6 and
> > > > simply check if we have 'right' suspects, so: git-net.patch and
> > > > git-nfsd.patch from -mm1-broken-out, as suggested by Herbert (I hope,
> > > > can compile - otherwise you could try the other way: add the whole -mm
> > > > and revert these two). Using current gits could complicate this
> > > > "investigation".
> > >
> > > OK, I will try this...
>
> still on the todo-list, I had no time to try this yet...

working on it...
2.6.24-rc6 + mm-patches up to git.battery (includes git-net and
git-netdev-all) worked for 110 packages, then I proclaimed it good.
2.6.24-rc6 + mm-patches up to (including) git.nfsd is currently
getting testet (9 packages done...)

But the cause of my mail is the following question:
Regarding my "iommu-sg-merging-patches are new in -rc3-mm and could be
the cause"-suspicion I looked at these patches and came across these
hunks:

This is removed from arch/x86/lib/bitstr_64.c:
-/* Find string of zero bits in a bitmap */
-unsigned long
-find_next_zero_string(unsigned long *bitmap, long start, long nbits, int len)
-{
-       unsigned long n, end, i;
-
- again:
-       n = find_next_zero_bit(bitmap, nbits, start);
-       if (n == -1)
-               return -1;
-
-       /* could test bitsliced, but it's hardly worth it */
-       end = n+len;
-       if (end > nbits)
-               return -1;
-       for (i = n+1; i < end; i++) {
-               if (test_bit(i, bitmap)) {
-                       start = i+1;
-                       goto again;
-               }
-       }
-       return n;
-}

This is added to lib/iommu-helper.c:
+static unsigned long find_next_zero_area(unsigned long *map,
+                                        unsigned long size,
+                                        unsigned long start,
+                                        unsigned int nr)
+{
+       unsigned long index, end, i;
+again:
+       index = find_next_zero_bit(map, size, start);
+       end = index + nr;
+       if (end > size)
+               return -1;
+       for (i = index + 1; i < end; i++) {
+               if (test_bit(i, map)) {
+                       start = i+1;
+                       goto again;
+               }
+       }
+       return index;
+}

The old version checks, if find_next_zero_bit returns -1, the new
version doesn't do this.
Is this intended and can find_next_zero_bit never fail?
Hmm... but in the worst case it should only loop forever if I'm
reading this right (index = -1 => for-loop counts from 0 to nr, if any
bit is set it will jump to "again:" and if the next call to
find_next_zero_bit also fails, its an endless loop)

So even if this can not explain my bug, could somebody check if this
is a real bug or not?

Torsten
