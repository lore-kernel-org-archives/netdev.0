From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 0/2] net: alternate proposal for using macvlans with
 forwarding acceleration
Date: Tue, 01 Oct 2013 23:31:29 -0700
Message-ID: <524BBDC1.6040000@gmail.com>
References: <20130911184441.26914.10336.stgit@nitbit.x32> <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:37861 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753098Ab3JBGbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 02:31:47 -0400
Received: by mail-oa0-f54.google.com with SMTP id n5so367749oag.13
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 23:31:46 -0700 (PDT)
In-Reply-To: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2013 01:16 PM, Neil Horman wrote:
> John, et al. -
>       As promised, heres my (very rough) first pass at an alternate propsal for
> what you're trying to do with virtual station interfaces here.  Its completely
> untested, but it builds, and I'll be trying to run it over the next few days
> (though I'm sure I got part of the hardware manipulation wrong).  I wanted to
> post it early though so you could get a look at it to see what you did and
> didn't like about it.  Some notes:

Sorry for the delay. I like the idea one nice win here is my macvlan
kvm setup would use the offloads without having to reconfigure.

>
> 1) As discussed, the major effort here is to tie in macvlans with l2 forwarding
> acceleration, rather than creating a new vsi link type.  That should make
> management easier for admins (be it via ovs or some other mechanism).  It
> basically exposes a bit less to the user, which I think is good.
>

The trick here is the offload path may be functionally different from
the non-offload path. The user needs some visibility into this. For
example any qdiscs running on the lowerdev will not be visible from the
accelerated path.

When a new link type was being used I was able to convince myself that
it was a property of the link type. But if we reuse macvlan I think we
need some way to either automatically disable the offload path when this
occurs or provide the user visibility. Maybe a feature flag and a
netif_can_hw_offload() routine is needed?

> 2) I've separated out the l2 forwarding acceleration operations from the
> net_device_operations structure.  I'm not sure I like that yet, but I'm kind on
> leaning that way.  Since a limited set of hardare supports forwarding
> acceleration, it makes for a nice easy way to group functionality without
> polluting the net_device_operations structure.  It also lets us group simmilar
> functions together nicely (I can see a future l3_accel_ops structure if we can
> do l3 flows in hardware).  Anywho, its a divergence from what we've been doing
> so I thought I would call attention to it.
>
> 3) I've included a l2_accel_xmit method in the accel_ops structure for fast path
> forwarding, but I'm not sure I like that.  It seems we should be able to use
> ndo_start_xmit and key off some data to recognize that we should be doing
> hardware forwarding.  I'm not quite sure how to do that yet though.  Something
> to think about.

Without a specific xmit routine though you will be adding operations in
the common case for a special case. Having a new op fixes this.

>
> 4) I've borrowed heavily from your vsi work of course just to get this building.
> I think theres probbaly alot of consolidation that can be done in the code that
> I added to ixgbe_main.c to make it smaller.  Again, I just wanted to post this
> so you could speak up if you though this was all crap before I wen't too far
> down the rabbit hole.

There was some consolidation needed in my original RFC as well. I can
help clean some of this stuff up if you want.

.John

-- 
John Fastabend         Intel Corporation
