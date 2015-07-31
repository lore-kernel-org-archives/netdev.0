From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH for-next V7 00/10] Move RoCE GID management to IB/Core
Date: Fri, 31 Jul 2015 14:18:28 -0600
Message-ID: <20150731201828.GA28263@obsidianresearch.com>
References: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
 <CAJ3xEMh9z=LG7dW0nBP8Zdrbf0SkZ_GCxjCoowWXuw2dueN+xg@mail.gmail.com>
 <55BB6F10.5030408@redhat.com>
 <20150731163201.GA6027@obsidianresearch.com>
 <55BBB353.7020806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Somnath Kotur <Somnath.Kotur-1wcpHE2jlwO1Z/+hSey0Gg@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <55BBB353.7020806-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 31, 2015 at 01:41:39PM -0400, Doug Ledford wrote:
> Please be more specific here.  What are you objecting to?  Are you
> objecting to a flush_workqueue from a release() context?  Because I
> don't see anything in the kref documentation or the kref
> implementation that prevents or prohibits this.  Or are you
> referring to the fact that they aren't unregistering their event
> handler until well after the parent device is unregistered?

I'm talking about the basic invarient we have for our removal process:
ib_unregister_device must fence all calls into the driver, so the
driver can proceed with the low level remove on the asumption that
nothing will call into it after unregister returns.

Clients create this fence by calling things like flush_workqueue and
ib_unregister_event_handler.

If the fence is moved out of ib_unregister_device and into release
then the whole model breaks.

I've explained this all before on the v1 of these series..

> That's obviously wrong, but it's also easy to fix (the obvious fix
> is that they should be calling ib_cache_cleanup_one from the top of
> ib_unregister_device versus waiting for a kref put).

Well, no, that is not the obvious fix, that puts things back the way
they were in v6. As I explained the kfrees need to be in the release
function, the async fencing needs to remain in the remove_one or
equivalent.

> Regardless though, the reason I'm taking this (and a number of other
> things) into my tree is that waiting for things to be absolutely perfect
> on a submission is an interminable waiting game.

So, I'm confused by this..

I haven't been waiting, I've looked at every release of every one of
these three big core change patch set. And found actual problems.

What I don't understand is your timing on these.. No 'hey, could we
finish these reviews' or anything, just out of the blue, v7 merged! It
was just posted yesterday!

> Not to mention that some of these fixes are quick and easy
> to do and I'd rather quit waiting 24+ hours for a respin turnaround when
> I could just hop in and make the fix myself in 15 minutes and test it
> immediately.

It would have been a lot less work for me to just fix the various
issues than to explain them to the authors. I'm hoping that investment
means the next series around will be good at V1...

> > Looking at your for-rebase branch.. please make sure you get all the
> > attributions this cycle :|
> 
> Yet *another* reason why these v6, v7, v8 patchsets are a huge time
> drain :-/.

Sagi's recent patch set is missing several attributions too..

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
