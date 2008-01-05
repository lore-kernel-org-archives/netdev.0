From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Sat, 5 Jan 2008 09:01:02 +0100
Message-ID: <64bb37e0801050001x65b104bdl5a68c731b3656d17@mail.gmail.com>
References: <64bb37e0801040223q17a76565k3c7667a197403ce5@mail.gmail.com>
	 <20080104133031.GA3329@ff.dom.local>
	 <64bb37e0801040721p57ff3d54wc3de00546d1d2ff1@mail.gmail.com>
	 <20080105000700.GA3224@ami.dom.local>
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
Received: from py-out-1112.google.com ([64.233.166.176]:44892 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbYAEIBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 03:01:04 -0500
Received: by py-out-1112.google.com with SMTP id u52so11501969pyb.10
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2008 00:01:03 -0800 (PST)
In-Reply-To: <20080105000700.GA3224@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 5, 2008 1:07 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> On Fri, Jan 04, 2008 at 04:21:26PM +0100, Torsten Kaiser wrote:
> > On Jan 4, 2008 2:30 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > The only thing that is sadly not practical is bisecting the borkenout
> > mm-patches, as triggering this error is to unreliable /
> > time-consuming.
>
> Right, but it seems there are these 2 main suspects here...
>
> > > - is it still vanilla -rc6-mm1; I've seen on kernel list you tried
> > > some fixes around raid?
> >
> > Yes, without these fixes I can't boot.
> > But they should only be run during starting the arrays, so I doubt
> > that this is that cause.
> > (Also -rc3-mm2 did not need this fix)
>
> You've written vanilla -rc6 is OK. Does it mean -rc6 with these fixes?

vanilla -rc6 is fine without these fixes.
The raid-bugs from -rc6-mm1 are probably introduced by
md-allow-devices-to-be-shared-between-md-arrays.patch and that patch
is new in this mm-release.

> I think it would be easier just to start with this working -rc6 and
> simply check if we have 'right' suspects, so: git-net.patch and
> git-nfsd.patch from -mm1-broken-out, as suggested by Herbert (I hope,
> can compile - otherwise you could try the other way: add the whole -mm
> and revert these two). Using current gits could complicate this
> "investigation".

OK, I will try this...

> > My skbuff-double-free-detector is still in there, but was never triggered.
> >
> > > - could you remind this lockdep warning; is it always and the same,
> > > always before crash, or no rules?
> >
> > ???
> > I see no lockdep warning before the crashes.
> > I have seen a warning about the dst->__refcnt in dst_release and
> > different warnings about list operations.
> >
> > I think I have always posted everything I have seen before the
> > crashes. (captured via serial console)
>
> So, you mean there are no more of these?:
>
> "looked into the log in question and the only other warning was a
>  circular locking dependency that lockdep detected around 1.5 hour
>  before this warning."
> ...
> "[ 7620.845168] INFO: lockdep is turned off."

Aha, I had forgotten about that one.
Looking at all the crashlogs, I do not find another one of this lockdep warning.
The only other lockdep related output was the bootup problem in vanilla -rc6.

> > (If you mean the lockdep-problem in -rc6: That is more or less a
> > missing annotation during early bootup. The only problem with that is,
> > that it will causes lockdep to be turned off and so it can not be used
> > to find any real problem. A fix for that is in -mm so I do have
> > lockdep on the mm-kernels)
> >
> > > - I've seen you looked after double freeing, but this last debug list
> > > warning could suggest locking problems during list modification too.
> >
> > Yes, but Herbert mentioned double freeing a skb explicit and so I
> > tried to catch this.
> > I do not know enough about the network core to verify the locking of
> > the involved lists.
>
> Right, the list corruption could be because of use after freeing too.

I had hoped that I could catch use-after-freeing by using
slub_debug=FZP, but that did not help.
(first oops in http://lkml.org/lkml/2007/12/28/159 )

I think that the main skb structs come from slub and should be
poisoned by this, so it might be some other data structure that is
allocated differently...

> > > - above git-nfsd and git-net tests should be probably repeated with
> > > -rc6-mm1 git versions: so vanilla rc6 plus both these -mm patches
> > > only, and if bug triggers, with one reversed; btw., since in previous
> > > message you mentioned that 50 packages could be not enough to trigger
> > > this, these 54 above could make too little margin yet.
> >
> > Yes, I think I really need to redo the git-nfsd-test.
> > With IOMMU_DEBUG enabled rc6-mm1worked for 52 packages, only a secound
> > run of kde-packages triggered it after only 5 packages.
> > I don't know what this bug hates about kdeartwork-wallpaper (triggered
> > it this time) or kdeartwork-styles.
>
> I didn't read all this thread, so probably I miss many points, but are
> you sure there are no problems with filesystem corruption around these
> packets or where you compile(?) them (e.g. after these raid problems)?

For my setup: It's a gentoo system, so compiling packages is the
normal way of installing something.
The compile itself is done on a tmpfs so a filesystem corruption there
should be rather impossible. ;)
(The system has 4Gb RAM, so it doesn't even need to swap)
The sources are taken from a nfsv4 share that is served from a
different system. Also gentoo checksums all sources it will use.

After the crashes I also did a checksum of the last installed
packages. Only in one instance there was corruption, all new files
where completely empty. Obviously XFS did not have the time to write
them back to disk before the system crashed.
Also as all crashes show network related traces and the system is
working fine otherwise, I doubt any permanent filesystem problems.

For the raid problems: I was just unable to even start the raid that
has / on it, because of a wrong check in the raid-autostart code.
( http://lkml.org/lkml/2007/12/27/45 )

> > Output from the crash with IOMMU_DEBUG (lockdep was enabled, but did
> > not trigger):
> > [15593.236374] Unable to handle kernel NULL pointer
> > dereference<3>list_add corruption. prev->next should be next
>
> Fine! I'll try to look at this. BTW, I guess/hope DEBUG_SLAB etc. are
> also on...

DEBUG_SLAB is off, because of:
 CONFIG_SLUB_DEBUG=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y

But I'm currently did not have the slub_debug-option in my kernel
commandline, because:
a) slub_debug=FZP did not prevent the bug in -rc3-mm2
b) but it took a much longer time to trigger it
c) its a serious slowdown for these compiles

If you think some other slub_debug might catch it, I would try this...

Torsten
