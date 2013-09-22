From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to kernel
Date: Sun, 22 Sep 2013 14:34:25 +0900
Message-ID: <20130922053156.GA4849@verge.net.au>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <1378711207-29890-8-git-send-email-horms@verge.net.au>
 <CAEP_g=8FBQPZ=C6G39YdHRzG57m5MqfXSZFAX2S_KLHRwfzc2w@mail.gmail.com>
 <20130919155732.GC24919@verge.net.au>
 <CAEP_g=_Eds_XvPLUOhAAMZbxkzmBJEtSR9vVG2kkuRLehrfbDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Pfaff <blp@nicira.com>, Pravin Shelar <pshelar@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34923 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890Ab3IVLYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 07:24:07 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=_Eds_XvPLUOhAAMZbxkzmBJEtSR9vVG2kkuRLehrfbDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 19, 2013 at 12:21:33PM -0500, Jesse Gross wrote:
> On Thu, Sep 19, 2013 at 10:57 AM, Simon Horman <horms@verge.net.au> wrote:
> > On Mon, Sep 16, 2013 at 03:38:21PM -0500, Jesse Gross wrote:
> >> On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms@verge.net.au> wrote:
> >> > @@ -616,6 +736,13 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
> >> >                 goto out_loop;
> >> >         }
> >> >
> >> > +       /* Needed to initialise inner protocol on kernels older
> >> > +        * than v3.11 where skb->inner_protocol is not present
> >> > +        * and compatibility code uses the OVS_CB(skb) to store
> >> > +        * the inner protocol.
> >> > +        */
> >> > +       ovs_skb_set_inner_protocol(skb, skb->protocol);
> >>
> >> The comment makes it sound like this code should just be deleted when
> >> upstreaming. However, I believe that we still need to initialize this
> >> field, right? Is this the best place do it or should it be conditional
> >> on adding a first MPLS header? (i.e. what happens if inner_protocol is
> >> already set and the packet simply passes through OVS?)
> >
> > I believe there are several problems here.
> >
> > The first one, which my comment was written around is that I think that if
> > inner_protocol is a field of struct sk_buff then we can rely on it already
> > being initialised.  However, if we are using compatibility code, where
> > inner_protcol is called in the callback field of struct sk_buff then I
> > think that OVS needs to initialise it.
> 
> I'm not sure that it's true that inner_protocol is already initialized
> - I grepped the tree and the only assignment that I found is in
> skbuff.c in __copy_skb_header().

My assumption was that it would be initialised to zero,
primarily due to the behaviour of __alloc_skb_head().
Perhaps the core code should be fixed to make my assumption true?

> > A second problem is one that you raise which I had not considered
> > which is how to handle things if inner_protocol is already set.
> >
> > I believe this should only occur in the case where inner_protocol
> > is a field of struct sk_buff and I think it would be most convenient
> > to set it conditionally in ovs_skb_reset_inner_protocol().
> > I think that if it is not set it should be zero but it should be
> > safe to check for values less than ETH_P_802_3_MIN.
> 
> It's probably OK to check for values less than ETH_P_802_3_MIN but I'm
> not sure that it's the most correct thing to do since skb->protocol
> could contain these values (such as ETH_P_802_2). It's unlikely that
> they will be GSO packets but it seems better to use the more strict
> check against zero.

Sure, a strict check against zero is fine my me.

> One other consideration in the OVS case - with recirculation we may
> hit this code multiple times and the difference in behavior could be
> surprising. However, on the other hand, we need to be careful because
> skb->cb is not guaranteed to be initialized to zero.

Thanks, that is also not something that I had considered.

I'm not sure, but I think that we can rely on skb->cb
not being clobbered between rounds of recirculation.
Or at the very least I think we could save and restore it
as necessary.

So I think if we could be careful to make sure that inner_protocol
is in a sane state the first time we see the skb but not
each time it is recirculated then I think things should work out.

In my current implementation of recirculation the datapath
side is driven ovs_dp_process_received_packet(). So by my reasoning
above I think it would make sense to reset the inner_protocol there
and in ovs_packet_cmd_execute() rather than in ovs_execute_actions()
which each of those functions call.
