From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.40 2/7] odp: Allow VLAN actions after MPLS actions
Date: Mon, 30 Sep 2013 10:10:39 +0900
Message-ID: <20130930011038.GA4768@verge.net.au>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
 <1380241116-7661-3-git-send-email-horms@verge.net.au>
 <20130927192108.GA17506@nicira.com>
 <CAOftzPg_FJoyS0oS8Ua7cpMaCh=BboWwyn8kVVoXGT9X9HQ0hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Pfaff <blp@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>
To: Joe Stringer <joe@wand.net.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:52828 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213Ab3I3BKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 21:10:47 -0400
Content-Disposition: inline
In-Reply-To: <CAOftzPg_FJoyS0oS8Ua7cpMaCh=BboWwyn8kVVoXGT9X9HQ0hg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 29, 2013 at 02:51:19PM +1300, Joe Stringer wrote:
> On Sat, Sep 28, 2013 at 7:21 AM, Ben Pfaff <blp@nicira.com> wrote:
> 
> > On Fri, Sep 27, 2013 at 09:18:31AM +0900, Simon Horman wrote:
> > > From: Joe Stringer <joe@wand.net.nz>
> > >
> > > OpenFlow 1.2 and 1.3 differ on their handling of MPLS actions in the
> > > presence of VLAN tags. To allow correct behaviour to be committed in
> > > each situation, this patch adds a second round of VLAN tag action
> > > handling to commit_odp_actions(), which occurs after MPLS actions. This
> > > is implemented with a new field in 'struct xlate_in' called 'vlan_tci'.
> > >
> > > When an push_mpls action is composed, the flow's current VLAN state is
> > > stored into xin->vlan_tci, and flow->vlan_tci is set to 0 (pop_vlan). If
> > > a VLAN tag is present, it is stripped; if not, then there is no change.
> > > Any later modifications to the VLAN state is written to xin->vlan_tci.
> > > When committing the actions, flow->vlan_tci is used before MPLS actions,
> > > and xin->vlan_tci is used afterwards. This retains the current datapath
> > > behaviour, but allows VLAN actions to be applied in a more flexible
> > > manner.
> > >
> > > Signed-off-by: Joe Stringer <joe@wand.net.nz>
> > > Signed-off-by: Simon Horman <horms@verge.net.au>
> >
> > The commit message talks about handling OpenFlow 1.2 and 1.3 both
> > properly, but I don't see how the code distinguishes between the cases.
> > Can you explain?  Maybe this is something added in a later patch, in
> > which case it would be nice to mention that in the commit message.
> >
> 
> It is added in patch #5. IIRC this patch should cause no difference in
> behaviour, but set up infrastructure to be used later.
> 
>  There seems to be a typo in the comment in vlan_tci_restore() here:
> > > +    /* If MPLS actions were executed after MPLS, copy the final
> > vlan_tci out
> > > +     * and restore the intermediate VLAN state. */
> >
> 
> Right, that should probably be "...executed after VLAN actions...".
> 
> I was a little confused by the new local variable 'vlan_tci' in
> > do_xlate_actions().  Partly this was because the fact that I didn't find
> > it obvious that sometimes it points to different VLAN tags.  I think
> > this would be easier to see if it were initially assigned just under the
> > big comment rather than in an initializer, so that one would know to
> > look at the comment.
> >
> 
> Perhaps the big comment could be rearranged and put above the initialiser,
> something like the following:-
> 
> /* VLAN actions are stored to '*vlan_tci'. This variable initially points
> to 'xin->flow->vlan_tci', so that
>  * VLAN actions are applied before any MPLS actions. When an MPLS action is
> translated,
>  * 'vlan_tci' is updated to point to 'xin->vlan_tci'. This causes later
> VLAN actions to be applied after MPLS actions.
>  * Each time through the loop, 'xin->vlan_tci' is updated to reflect the
> final VLAN state of the flow. */
> 
> Then, the place where 'xin->vlan_tci' is updated to '*vlan_tci' could have
> a simple comment to refer back:-
> 
> /* Update the final vlan state to match the current state. */
> 
> Simon, do you mind handling the change?

Not at all. I'll include this change the next time I post the series.
