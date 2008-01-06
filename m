From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Sun, 6 Jan 2008 11:30:48 +0100
Message-ID: <64bb37e0801060230x6b392542la9556d72a184f306@mail.gmail.com>
References: <64bb37e0801040223q17a76565k3c7667a197403ce5@mail.gmail.com>
	 <20080104133031.GA3329@ff.dom.local>
	 <64bb37e0801040721p57ff3d54wc3de00546d1d2ff1@mail.gmail.com>
	 <20080105000700.GA3224@ami.dom.local>
	 <64bb37e0801050001x65b104bdl5a68c731b3656d17@mail.gmail.com>
	 <20080105101327.GA3103@ami.dom.local>
	 <64bb37e0801050652t7568e438uf93208601df84ef6@mail.gmail.com>
	 <20080106082740.GA3117@ami.dom.local>
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
Received: from py-out-1112.google.com ([64.233.166.183]:60474 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbYAFKat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2008 05:30:49 -0500
Received: by py-out-1112.google.com with SMTP id u52so11955516pyb.10
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2008 02:30:49 -0800 (PST)
In-Reply-To: <20080106082740.GA3117@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 6, 2008 9:27 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> On Sat, Jan 05, 2008 at 03:52:32PM +0100, Torsten Kaiser wrote:
> ...
> > So my personal conclusion would be, that someone is writing to memory
> > that he no longer owns. Most probably 0-bytes. (the complete_routine
> > got NULLed and the warning about dst->__refcnt being 0).
> >
> > Use-after-free or something else?
>
> I agree: your conclusion seems to be the most probable explanation for
> this. Then it could be really hard to solve this without bisection or
> something similar. But there is some probabability this something could
> try kfree later too, but simply this list debugging triggers earlier.

As for example in the case when it dies in ieee1394-thread the list is
so corrupted that it will die anyway.

But I might try this anyway, as I don't really have a better idee.

> > > > If you think some other slub_debug might catch it, I would try this...
>
> You can try to add "U" to these other slub_debug options. As a matter
> of fact, if your above diagnose is right, it seems you risk to damage
> your system or even the box with these tests, so if you want to
> continue, you should probably turn any possible debugging on (not in
> mm only).

I did not add U, because I thought that would only needed to trace memory leaks.
And I hoped that using P (poison) would catch any later use (after free).

> BTW, you've written that some debugging options seem to delay the bug.
> Since they often change sizes of some structures than such wrong
> writes could have some 'safer' offsets. So, this could really delay
> e.g. these list's bugs, but maybe this could also let to stay 'alive'
> to such wrong kfree?

I think this bug is highly timing dependent. Its not always the same
package that dies and as this is a SMP system I would guess two CPUs
using the same data will trigger this.
And using the poison-option will definitily slow the system down and
mess up the timings.

What also speaks against the 'safer' offsets is, that after adding my
notfreed-byte to skbuff the bug still triggered in the same way.

I'm currently looking at
http://www.mail-archive.com/linux-scsi@vger.kernel.org/msg12702.html
,trying to understand if this is relevant for me on x86_64.

Torsten
