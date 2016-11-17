From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next 6/8] ipv4: fib: Add an API to request a FIB dump
Date: Thu, 17 Nov 2016 15:10:49 +0200
Message-ID: <20161117131049.pevkla5os75h4zlc@splinter.mtl.com>
References: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
 <1479305343-13167-7-git-send-email-jiri@resnulli.us>
 <e795e6e0-a680-a2c3-7d5e-afd966104a4a@stressinduktion.org>
 <20161116151829.h6kapbjes7xxxcyi@splinter.mtl.com>
 <dcbbcefa-3ca7-c0ed-09a7-1d0e6f96e256@stressinduktion.org>
 <20161116185103.h3hio4pyrlk2xeol@splinter>
 <56d2179d-00ff-bcc5-e365-845179cbe672@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:37624 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932881AbcKQRGU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:06:20 -0500
Content-Disposition: inline
In-Reply-To: <56d2179d-00ff-bcc5-e365-845179cbe672@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

On Wed, Nov 16, 2016 at 08:43:25PM +0100, Hannes Frederic Sowa wrote:
> On 16.11.2016 19:51, Ido Schimmel wrote:
> > On Wed, Nov 16, 2016 at 06:35:45PM +0100, Hannes Frederic Sowa wrote:
> >> On 16.11.2016 16:18, Ido Schimmel wrote:
> >>> On Wed, Nov 16, 2016 at 03:51:01PM +0100, Hannes Frederic Sowa wrote:
> >>>> On 16.11.2016 15:09, Jiri Pirko wrote:
> >>>>> From: Ido Schimmel <idosch@mellanox.com>
> >>>>>
> >>>>> Commit b90eb7549499 ("fib: introduce FIB notification infrastructure")
> >>>>> introduced a new notification chain to notify listeners (f.e., switchdev
> >>>>> drivers) about addition and deletion of routes.
> >>>>>
> >>>>> However, upon registration to the chain the FIB tables can already be
> >>>>> populated, which means potential listeners will have an incomplete view
> >>>>> of the tables.
> >>>>>
> >>>>> Solve that by adding an API to request a FIB dump. The dump itself it
> >>>>> done using RCU in order not to starve consumers that need RTNL to make
> >>>>> progress.
> >>>>>
> >>>>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> >>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> >>>>
> >>>> Have you looked at potential inconsistencies resulting of RCU walking
> >>>> the table and having concurrent inserts?
> >>>
> >>> Yes. I did try to think about situations in which this approach will
> >>> fail, but I could only find problems with concurrent removals, which I
> >>> addressed in 5/8. In case of concurrent insertions, even if you missed
> >>> the node, you would still get the ENTRY_ADD event to your listener.
> >>
> >> Theoretically a node could still be installed while the deletion event
> >> fired before registering the notifier. E.g. a synchronize_net before
> >> dumping could help here?
> > 
> > If the deletion event fired for some fib alias, then by 5/8 we are
> > guaranteed that it was already unlinked from the fib alias list in the
> > leaf in which it was contained. So, while it's possible we didn't
> > register our listener in time for the deletion event, we won't traverse
> > this fib alias while dumping the trie anyway. Did I understand you
> > correctly?
> > 
> 
> Theoretically we can have the same problem for insertion:
> 
> You receive a delete event from the notifier that is queued up first but
> the dump will still see the entry in the fib due to being managed by RCU
> (the notifier running on another CPU).
> 
> The problem is that the fib_remove_alias->hlist_del_rcu->WRITE_ONCE is
> still not strongly ordered against the local fib dump trie walk.

OK, so I believe my analysis in 5/8 was wrong. Despite CPU A invoking
fib_remove_alias() in t0 for fa1, it's possible for CPU B doing the fib
dump to see fa1 in t1, which will lead to fa1 being permanently present
in the listener's table.

Given the above, I think Dave's suggestion is the only applicable
solution. Do you agree? Any other suggestions?

Thanks
