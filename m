From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netconsole: release the spinlock before
 __netpoll_cleanup()
Date: Mon, 11 Mar 2013 13:58:19 -0400
Message-ID: <20130311175819.GE12682@hmsreliant.think-freely.org>
References: <1362581203-8994-1-git-send-email-vfalico@redhat.com>
 <20130307000824.GA5702@neilslaptop.think-freely.org>
 <20130307100325.GA31105@redhat.com>
 <20130307.161438.396456319050281566.davem@davemloft.net>
 <20130310152546.GA4897@redhat.com>
 <CAE3RKN=ix96skUHw3j5snbue-r8SOnSovw4_zh4RX4t-uDW2Cw@mail.gmail.com>
 <20130311113024.GB12682@hmsreliant.think-freely.org>
 <20130311113914.GE1806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Veaceslav Falico <darkmag@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	amwang@redhat.com
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44045 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871Ab3CKR6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 13:58:47 -0400
Content-Disposition: inline
In-Reply-To: <20130311113914.GE1806@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 11, 2013 at 12:39:14PM +0100, Veaceslav Falico wrote:
> On Mon, Mar 11, 2013 at 07:30:24AM -0400, Neil Horman wrote:
> >On Mon, Mar 11, 2013 at 11:08:02AM +0100, Veaceslav Falico wrote:
> >>On Sun, Mar 10, 2013 at 4:25 PM, Veaceslav Falico <vfalico@redhat.com> wrote:
> >>> On Thu, Mar 07, 2013 at 04:14:38PM -0500, David Miller wrote:
> >>>>
> >>...snip...
> >>>> Quite a bit of email corruption of this patch.
> >>>
> >>>
> >>> Sorry, somehow messed it.
> >>>
> >>>
> >>>>
> >>>> Also, this code block is probably too deeply indented to be sane,
> >>>> consider creating a small helper function to call instead.
> >>>
> >>>
> >>> It gets quite ugly if I try to move it to another function. However, maybe
> >>> something like that will work - it's effectively the same code, just that
> >>> I've moved the long part out of the if () { } block. Looks a lot more
> >>> readable, though one line still breaks 80chars limit. I've reworked the
> >>> subject/commit message too.
> >>>
> >>> Subject: [PATCH] netconsole: don't call __netpoll_cleanup() while atomic
> >>>
> >>> __netpoll_cleanup() is called in netconsole_netdev_event() while holding a
> >>> spinlock. Release/acquire the spinlock before/after it and restart the
> >>>
> >>> loop.
> >>>
> >>> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> >>> ---
> >>>    drivers/net/netconsole.c |   22 +++++++++++++++-------
> >>>    1 files changed, 15 insertions(+), 7 deletions(-)
> >>>
> >>> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> >>> index 37add21..38eaa8c 100644
> >>>
> >>> --- a/drivers/net/netconsole.c
> >>> +++ b/drivers/net/netconsole.c
> >>> @@ -666,6 +666,7 @@ static int netconsole_netdev_event(struct notifier_block
> >>> *this,
> >>>                 goto done;
> >>>         spin_lock_irqsave(&target_list_lock, flags);
> >>> +restart:
> >>>         list_for_each_entry(nt, &target_list, list) {
> >>>                 netconsole_target_get(nt);
> >>>                 if (nt->np.dev == dev) {
> >>> @@ -679,14 +680,21 @@ static int netconsole_netdev_event(struct
> >>> notifier_block *this,
> >>>                                 /*
> >>>
> >>>                                  * rtnl_lock already held
> >>>                                  */
> >>> -                               if (nt->np.dev) {
> >>> -                                       __netpoll_cleanup(&nt->np);
> >>> -                                       dev_put(nt->np.dev);
> >>> -                                       nt->np.dev = NULL;
> >>> +                               if (!nt->np.dev) {
> >>> +                                       nt->enabled = 0;
> >>> +                                       stopped = true;
> >>> +                                       break;
> >>>                                 }
> >>> -                               nt->enabled = 0;
> >>> -                               stopped = true;
> >>> -                               break;
> >>> +                               /*
> >>> +                                * we might sleep in __netpoll_cleanup()
> >>> +                                */
> >>> +                               spin_unlock_irqrestore(&target_list_lock,
> >>> flags);
> >>> +                               __netpoll_cleanup(&nt->np);
> >>> +                               spin_lock_irqsave(&target_list_lock, flags);
> >>> +                               dev_put(nt->np.dev);
> >>> +                               nt->np.dev = NULL;
> >>>
> >>> +                               netconsole_target_put(nt);
> >>> +                               goto restart;
> >>>                         }
> >>>                 }
> >>>                 netconsole_target_put(nt);
> >>> --
> >>> 1.7.1
> >>
> >>Self-NAK this patch, I've triggered another kernel panic with it. Will
> >>send another one shortly. Basicly, the whole if (!nt->np.dev) is not
> >>needed and nt->enabled=0 should always be set, otherwise we
> >>end up with nt->np.dev == NULL and nt->enabled == 1, thus
> >>triggering panics in places like write_msg(), where it verifies only
> >>if the nt->enabled is true.
> >>
> >Yup, I think you want to make the nt->enabled and stopped statements
> >unconditional, and precedede the whole block with a if(!nt->np.dev) { continue;}
> >statement.
> 
> I don't see why the statement is needed at all, if we verify it beforehand:
> 
> 669         list_for_each_entry(nt, &target_list, list) {
> 670                 netconsole_target_get(nt);
> 671                 if (nt->np.dev == dev) {
> 
> so that effectively it can be null only in case the dev, delivered via
> netconsole_netdev_event() is null, which is a bug by itself. Or am I
> missing something?
> 
Honestly, I'm not sure.  After I sent this, I took a look at the history to
refresh my memory, and I think your right, its not needed.
Neil

> >Neil
> >
> >>--
> >>Best regards,
> >>Veaceslav Falico
> >>
> 
