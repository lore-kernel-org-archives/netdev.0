From: David Dillow <dave@thedillows.org>
Subject: Re: [RFC 2.6.10 1/22] xfrm: Add direction information to xfrm_state
Date: Wed, 26 Jan 2005 16:14:52 -0500
Message-ID: <1106774092.9845.16.camel@ori.thedillows.org>
References: <20041230035000.01@ori.thedillows.org>
	 <20041230035000.10@ori.thedillows.org>
	 <20050121143857.69282605.davem@davemloft.net>
	 <1106373022.3691.36.camel@ori.thedillows.org>
	 <20050125221726.73d4b7ab.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050125221726.73d4b7ab.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-01-25 at 22:17 -0800, David S. Miller wrote:
> On Sat, 22 Jan 2005 00:50:22 -0500
> David Dillow <dave@thedillows.org> wrote:
> 
> > Hmm, I can see having netdev->xfrm_bundle_add() assume a outbound state,
> > since it's only called for Tx.
> > 
> > Rx offloading could be interesting, but it looks like I could hook into
> > net/xfrm/xfrm_policy.c:__xfrm_policy_check(), and add the xfrm_states
> > seen there to a work queue for offloading. netdev->xfrm_state_add()
> > would then only see inbound states.
> > 
> > Sound sane?
> 
> You really can't get at the policies at these places somehow?
> Even by passing down the xfrm_policy pointer into these
> call chains?

By these places, you mean xfrm_lookup() and __xfrm_policy_check()?

There I absolutely have access to the policy, but even better, I only
get to those places for one purpose -- xfrm_lookup() on output,
__xfrm_policy_check() on input.

Even in the first versions of the offload code, netdev->xfrm_state_add()
and netdev->xfrm_bundle_add() were solely called for inbound and
outbound xfrm_states, respectively. The problem was that I had no access
to the policy at xfrm_state.c::xfrm_state_add(), since it wouldn't be
called in the context of a policy. 

By moving the offload calls/queuing to __xfrm_policy_check(), I have the
policy available, and I *know* it is inbound. If I offload SAs there, I
can use that knowledge, and I get the benefit of lazy offload -- I'll
only be offloading inbound SAs to netdev's that they've actually been
received on, rather than to all capable devices, as the first version
did.

And, by making the decision to offload at the policy check means I get
more info to use in that decision -- I'll probably change netdev-
>xfrm_state_add() into netdev->xfrm_secpath_add(), and have it take the
inbound secpath as an argument. This will let the driver see a more
complete picture of the inbound xfrms, and allow it to not offload
problematic combinations (the typhoon firmware has issues with certain
combinations.)

Now I'm working on a nice cheap way to decide if the inbound packet is a
candidate for offloading, and avoid trying the same SA stack over and
over and over...
-- 
David Dillow <dave@thedillows.org>
