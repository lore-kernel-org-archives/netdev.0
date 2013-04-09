From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/4] Add packet recirculation
Date: Tue, 9 Apr 2013 16:50:27 +0900
Message-ID: <20130409075024.GG11444@verge.net.au>
References: <1365403431-18102-1-git-send-email-horms@verge.net.au>
 <1365403431-18102-2-git-send-email-horms@verge.net.au>
 <CAEP_g=9nj24hZcA-czzuz3xaweATxRxmibuFaqODTSoPmRmHsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34392 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935093Ab3DIHua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 03:50:30 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=9nj24hZcA-czzuz3xaweATxRxmibuFaqODTSoPmRmHsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 08, 2013 at 06:46:29PM -0700, Jesse Gross wrote:
> On Sun, Apr 7, 2013 at 11:43 PM, Simon Horman <horms@verge.net.au> wrote:
> > diff --git a/datapath/actions.c b/datapath/actions.c
> > index e9634fe..7b0f022 100644
> > --- a/datapath/actions.c
> > +++ b/datapath/actions.c
> > @@ -617,6 +617,9 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
> >                 case OVS_ACTION_ATTR_SAMPLE:
> >                         err = sample(dp, skb, a);
> >                         break;
> > +
> > +               case OVS_ACTION_ATTR_RECIRCULATE:
> > +                       return 1;
> 
> I think that if we've had a previous output action with the port
> stored in prev_port then this will cause the packet to not actually be
> output.

I'm not so sure.

I see something like this occurring:

1. Iteration of for loop for output action

   switch (nla_type(a)) {
   case OVS_ACTION_ATTR_OUTPUT:
	prev_port = nla_get_u32(a);
	break;
	...
   }

2. Iteration of of for loop for next action, lets say its is recirculate

   i. Output packet

   if (prev_port != -1) {
	do_output(dp, skb_clone(skb, GFP_ATOMIC), prev_port);
	prev_port = -1;
   }

   ii. Return due to recirculate
   switch (nla_type(a)) {
   ...
   case OVS_ACTION_ATTR_RECIRCULATE:
           return 1;
   }


Am I missing something?

> > diff --git a/datapath/datapath.c b/datapath/datapath.c
> > index e8be795..ab39dd7 100644
> > --- a/datapath/datapath.c
> > +++ b/datapath/datapath.c
> >  void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
> [...]
> > +               if (IS_ERR_OR_NULL(skb)) {
> > +                       break;
> > +               } else if (unlikely(!limit--)) {
> 
> Should this be a predecrement?

I will make it so.

> > +                       kfree_skb(skb);
> 
> Should we log some kind of rate limited warning here?

Sure.

> > +                       return;
> 
> In the first case we use break to exit the loop and here we use
> return.  Both should have the same effect so it might be nice to make
> them the same.
> 
> > @@ -901,6 +913,9 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
> >                         skip_copy = true;
> >                         break;
> >
> > +               case OVS_ACTION_ATTR_RECIRCULATE:
> > +                       break;
> 
> I think we might want to jump out the loop here to better model how
> the actions are actually executed.

Sure, perhaps something like this?

diff --git a/datapath/datapath.c b/datapath/datapath.c
index ab39dd7..721a52c 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -914,7 +914,7 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
 			break;
 
 		case OVS_ACTION_ATTR_RECIRCULATE:
-			break;
+			goto out;
 
 		default:
 			return -EINVAL;
@@ -926,6 +926,7 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
 		}
 	}
 
+out:
 	if (rem > 0)
 		return -EINVAL;
 

> > diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
> > index e4a2f75..31255f6 100644
> > --- a/lib/dpif-netdev.c
> > +++ b/lib/dpif-netdev.c
> >  dp_netdev_port_input(struct dp_netdev *dp, struct dp_netdev_port *port,
> >                       struct ofpbuf *packet)
> [...]
> > +        } else {
> > +            dp->n_missed++;
> > +            dp_netdev_output_userspace(dp, packet, DPIF_UC_MISS, &key, NULL);
> > +            recirculate = false;
> > +        }
> > +    } while (recirculate && limit--);
> 
> I have the same question about predecrement here.

I will change this one too.

> > @@ -1163,6 +1190,7 @@ dp_netdev_sample(struct dp_netdev *dp,
> >      const struct nlattr *subactions = NULL;
> >      const struct nlattr *a;
> >      size_t left;
> > +    uint32_t skb_mark;
> 
> I don't think it's right to have a new (and uninitialized) copy of
> skb_mark here.  We should have the same one all the way through, like
> we do in the kernel.

Sure. I will pass it as an argument to dp_netdev_sample()

> > diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
> > index 47830c1..5129da1 100644
> > --- a/ofproto/ofproto-dpif.c
> > +++ b/ofproto/ofproto-dpif.c
> 
> I'm still working on more detailed comments for this.  However, I'm
> concerned about whether the behavior for revalidation and stats is
> correct.

I am a little concerned about that too.
Perhaps Ben could look over it?
