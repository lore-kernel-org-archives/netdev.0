From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [v4.12 regression] netns: NULL deref in fib_sync_down_dev()
Date: Fri, 28 Jul 2017 22:08:53 +0300
Message-ID: <20170728190853.GA20495@splinter>
References: <20170728160047.7tzapklj7zrgxktq@qmqm.qmqm.pl>
 <20170728164331.GA5268@splinter>
 <CAM_iQpXmUfdUzsu7Xpc2EjkePQCEjcP+irMkpc4bTDaWfAOVLw@mail.gmail.com>
 <20170728173602.GA30482@splinter>
 <20170728180437.s4pwdyguihmgjrjp@qmqm.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:53387 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752450AbdG1TI5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 15:08:57 -0400
Content-Disposition: inline
In-Reply-To: <20170728180437.s4pwdyguihmgjrjp@qmqm.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 08:04:37PM +0200, Michał Mirosław wrote:
> On Fri, Jul 28, 2017 at 08:36:02PM +0300, Ido Schimmel wrote:
> > On Fri, Jul 28, 2017 at 10:28:16AM -0700, Cong Wang wrote:
> > > On Fri, Jul 28, 2017 at 9:43 AM, Ido Schimmel <idosch@idosch.org> wrote:
> > > > On Fri, Jul 28, 2017 at 06:00:47PM +0200, Michał Mirosław wrote:
> > > >> Dear NetDevs,
> > > >>
> > > >> Before I go to bisecting, have you seen a following NULL dereference,
> > > >> yet?  Where should I start looking?  It is triggered by deleting netns
> > > >> (cut-down script attached - triggers every time).  This was working
> > > >> correctly under v4.11.x.
> > > > Thanks for the report. I just reproduced this on my system. I believe
> > > > the problem is a missing NULL check for 'in_dev' in
> > > > call_fib_nh_notifiers(). I'll test a fix.
> > > But your commit 982acb97560c8118c2109504a22b0d78a580547d
> > > is merged in v4.11-rc1. How could 4.11.x work correctly?
> > It doesn't. I just reproduced this on v4.11.
> 
> Thanks for looking into this.  I was sure that I ran v4.11.7 last time,
> but it turns out I worked on this earlier than that.  I'll be glad to
> test patches for this issue when you have it.

I've a working patch, but I tried to understand why we didn't see it
until now. I believe the problem is the fact that you have an interface
with no IP address and a route pointing to it.

When it goes down, inetdev_destroy() is called, which sets dev->ip_ptr to
NULL. Then the netdev notification block in the FIB is called and the
NULL dereference occurs.

If an IP address was assigned, then before NULLing dev->ip_ptr, all the
IP addresses would be flushed and the inetaddr notification block in the
FIB would be called, which in turn would flush all the routes. Since all
the routes were already flushed, no NULL dereference would occur when
the FIB's netdev notification block is called.

I'll post the patch shortly.

Thanks again.
