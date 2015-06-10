From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem with patch "make nlmsg_end() and genlmsg_end() void"
Date: Tue, 09 Jun 2015 17:49:07 -0700
Message-ID: <1433897347.27504.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <E586D25A-9DAF-4535-A282-120F0C6EAE19@holtmann.org>
	 <CAE4R7bCWSM+SyDR830N1GmukyaMYE_DT0fd4L_x6Py5PEqMe_A@mail.gmail.com>
	 <01A82AB9-6ABD-4AD0-9CBC-628091569DB0@holtmann.org>
	 <20150118.233722.226468667930444145.davem@davemloft.net>
	 <1428494602.9010.11.camel@infradead.org>
	 <1428498482.2809.10.camel@sipsolutions.net>
	 <1433856864.19447.25.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, marcel@holtmann.org,
	sfeldma@gmail.com, netdev@vger.kernel.org, teg@jklm.no
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:35125 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbbFJAtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 20:49:11 -0400
Received: by qczw4 with SMTP id w4so12194147qcz.2
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 17:49:10 -0700 (PDT)
In-Reply-To: <1433856864.19447.25.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-09 at 14:34 +0100, David Woodhouse wrote:
> On Wed, 2015-04-08 at 15:08 +0200, Johannes Berg wrote:
> > On Wed, 2015-04-08 at 13:03 +0100, David Woodhouse wrote:
> > 
> > > I'm not sure if this is entirely fixed. In Fedora 22 (4.0.0-rc5-git4)
> > > I'm occasionally seeing glibc deadlock in __check_pf() on a netlink
> > > recvmsg(), here:
> > > https://sourceware.org/git/?p=glibc.git;a=blob;f=sysdeps/unix/sysv/linux/check_pf.c;h=162606d7;hb=glibc-2.21#l166
> > > 
> > > As I understand it, this shouldn't happen. Even if messages are
> > > dropped (which surely shouldn't happen as often as I'm seeing this),
> > > glibc should get ENOBUFS from the recvmsg() call.
> > > 
> > > https://bugzilla.redhat.com/show_bug.cgi?id=1209433
> > > 
> > > I haven't bisected and proved that it *was* this commit which
> > > introduced the problem, as it only happens after a day or two of
> > > running Evolution and I haven't managed to trigger it more reliably.
> > 
> > I don't see the connection to this change.
> > 
> > The issue with my patch was that some code for NLM_F_DUMP would have
> > this pattern:
> > 
> >  int fill_function(...)
> >  {
> >     ...
> >     return nlmsg_end(...);
> >  }
> > 
> >  loop (...) {
> >    if (fill_function() <= 0)
> >      break; /* continue in next dump */
> >  }
> > 
> > and that all had to be converted to be just "< 0" now.
> > 
> > Additionally, the failure mode of this was the process running out of
> > memory due to receiving the same results over and over again - does that
> > happen for you? It seems it was stuck in recvmsg(), but that may just be
> > a side effect of happening to interrupt at that point?
> > 
> 
> I don't think the problem was introduced by your change. At 
> https://github.com/nahi/httpclient/issues/232 it seems to have been
> observed even in November of last year.
> 
> I've added some debugging, and it seems that when it deadlocks, glibc
> doesn't get *any* response to its RTM_GETADDR request. I know we'd get
> ENOBUFS is a *response* was dropped... but what about when the request
> itself is dropped? Does userspace get any hint of that? Is this purely
> a glibc bug, for assuming its request got delivered and unconditionally
> waiting for a response?
> 
> I don't know why it suddenly started happening to me in the 4.0 kernel
> when I'd never seen it before, but it's still happening. I've put a
> poll() in the glibc code (referenced above), and made it fail after a 5
> -second timeout. That will at least prevent me from throwing my
> computer out the window for the time being...
> 

Please check that this patch fixes your issue :

http://patchwork.ozlabs.org/patch/473041/
