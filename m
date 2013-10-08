From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH 0/2 v2] net: alternate proposal for using macvlans
 with forwarding acceleration
Date: Mon, 7 Oct 2013 21:08:22 -0400
Message-ID: <20131008010822.GB7791@neilslaptop.think-freely.org>
References: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
 <1380917405-23801-1-git-send-email-nhorman@tuxdriver.com>
 <52533107.6060306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59487 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969Ab3JHBIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 21:08:31 -0400
Content-Disposition: inline
In-Reply-To: <52533107.6060306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 07, 2013 at 03:09:11PM -0700, John Fastabend wrote:
> On 10/04/2013 01:10 PM, Neil Horman wrote:
> >Hey all-
> >      heres the next, updated version of the vsi/macvlan integration that we've
> >been discussing.
> >
> >Some change notes:
> >
> >* Changes to the fowarding ops structure - Removed the priv_size field, and
> >added a flags field.  Removal of the priv_size field was accomplished by just
> >having the add method return a void * and using ERR_PTR and PTR_ERR checks,
> >which also allows us to allocate memory for the acceleration path in the driver,
> >which I like.  I'm not super happy still with how I'm using the flags (currenly
> >only used to indicate support for feature sets), but at least we have the flags
> >now, and they can be exposed to user space via iproute2 or ethtool if need be
> 
> For the flag why not use the existing feature flag namespace? Adding
> NETIF_F_HW_L2FW_DOFFLOAD or something equivalent to netdev_features.h
> and also doing the string updates would get the userspace support for
> free.
> 
> The one downside of a global feature flag approach like this is if
> the user wants to create some offloaded macvlan devices and some SW
> only macvlans the control sequence is a bit clumsy. But unless we add
> a new flag to the macvlan netlink message I'm not sure how to avoid
> this. Further if you have multiple control applications
> creating/deleting these macvlans the flag mechanism starts to break
> down. One app sets the flag the other deletes, you get the idea.
> 
> It might be worth adding a netlink flag to change the state of
> the HW offload. I know this goes against the 'it just gets offloaded'
> line of thought, but if you make the default to offload then it should
> be OK.
> 
Good suggestions, I should have thought to use the global flags previously. I
got hung up on the notion that for some reason our feature set should be
separated like the ops.  I really don't need to do that.

> >
> >* Changes to the Transmit path - Specifically I'm using dev_queue_xmit to send
> >frames now, which I like as it makes the macvlan subject to the lowerdevs qdisc
> >configuration.
> 
> This creates perhaps another oddity where on TX the packets will be
> visible to the lowerdev. Think tcpdump and egress qdisc. But on ingress
> the packets will be delivered directly to macvlan device. Also I was
> thinking there might be good reasons to skip the lowerdev qdisc, for
> performance reasons or QOS setups.
> 
Hmm, is that avoidable by doing an extra check in dev_queue_xmit (i.e. checking
to see if accel_data or some other pointer is set)?  Or do you think its worth
separating the tx path to an accelerated or non accelerated case?

> So it might be best the way you had it in the previous revision even if
> it was not functionally equivalent to the SW path. If you skip the lower
> dev and submit directly to the hardware then you also don't need a
> sk_buff change. The driver can do a lookup via the skb->dev field and
> additional hints from the stack are not needed.
> 
Ok, fair enough, I'll put it back the way I had it previously.

> If there is a perceived problem with not having the HW and SW completely
> equivalent functionally we could always default the feature flag to off.
> Then enabling the feature would be a single 'ethtool' command. This
> seems like a nice compromise.
> 
Yeah, I can agree with that.

> I like where this is going though!
I'm glad you think so!  I'll have another version out later this week!
Best
Neil

> 
> Thanks,
> John
> 
> -- 
> John Fastabend         Intel Corporation
> 
