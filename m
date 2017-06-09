From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH net] Fix an intermittent pr_emerg warning about lo
 becoming free.
Date: Fri, 9 Jun 2017 11:43:03 -0700
Message-ID: <20170609184303.GC2766@templeofstupid.com>
References: <20170608201238.GC2553@templeofstupid.com>
 <CAM_iQpUaenZa0o-eyt91sAE6SF+qk6Thh5vpKqPLXSc6xpjPqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krister Johansen <kjlx@templeofstupid.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kaiwen Xu <kaiwen.xu@hulu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:43050 "EHLO
        homiemail-a47.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751781AbdFISnD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 14:43:03 -0400
Received: from homiemail-a47.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a47.g.dreamhost.com (Postfix) with ESMTP id 0A9443B10
        for <netdev@vger.kernel.org>; Fri,  9 Jun 2017 11:43:03 -0700 (PDT)
Received: from kmjvbox (c-174-62-91-145.hsd1.ca.comcast.net [174.62.91.145])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a47.g.dreamhost.com (Postfix) with ESMTPSA id BA8FD3B18
        for <netdev@vger.kernel.org>; Fri,  9 Jun 2017 11:43:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpUaenZa0o-eyt91sAE6SF+qk6Thh5vpKqPLXSc6xpjPqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 09, 2017 at 11:18:44AM -0700, Cong Wang wrote:
> On Thu, Jun 8, 2017 at 1:12 PM, Krister Johansen
> <kjlx@templeofstupid.com> wrote:
> > The way this works is that if there's still a reference on the dst entry
> > at the time we try to free it, it gets placed in the gc list by
> > __dst_free and the dst_destroy() call is invoked by the gc task once the
> > refcount is 0.  If the gc task processes a 10th or less of its entries
> > on a single pass, it inreases the amount of time it waits between gc
> > intervals.
> >
> > Looking at the gc_task intervals, they started at 663ms when we invoked
> > __dst_free().  After that, they increased to 1663, 3136, 5567, 8191,
> > 10751, and 14848.  The release that set the refcnt to 0 on our dst entry
> > occurred after the gc_task was enqueued for 14 second interval so we had
> > to wait longer than the warning time in wait_allrefs in order for the
> > dst entry to get free'd and the hold on 'lo' to be released.
> >
> 
> I am glad to see you don't have a dst leak here.
> 
> But from my experience of a similar bug (refcnt wait on lo), this goes
> infinitely rather than just 14sec, so it looked more like a real leak than
> just a gc delay. So in your case, this annoying warning eventually
> disappears, right?

That's correct.  The problem occurs intermittently, and the warnings are
less frequent than the interval in netdev_wait_allrefs().  At least when
I observed it, it tended to conincide with our controlplane canary
issuing an API call that lead to a network namespace teardown on the
dataplane.

Sometimes, the message would look like this:

  unregister_netdevice: waiting for lo to become free. Usage count = 0

The dst entries were getting released, it's just that often our dst
cache gc interval was longer than the warning interval in wait_allrefs.

The other concern was that because the wait_allrefs happens in the
netdev_todo path, a long gc interval can cause the rtnl_lock hold times
to be much longer than necessary if this bug is encountered.

-K
