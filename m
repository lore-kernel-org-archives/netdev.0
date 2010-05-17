From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6 2/2] bonding: allow user-controlled output slave selection
Date: Mon, 17 May 2010 12:25:41 -0700
Message-ID: <17188.1274124341@death.nxdomain.ibm.com>
References: <20100511003245.GB7497@gospo.rdu.redhat.com> <17897.1273608579@death.nxdomain.ibm.com> <20100512002725.GA2460@localhost.localdomain> <25238.1273693314@death.nxdomain.ibm.com> <20100512221408.GI7497@gospo.rdu.redhat.com> <20100513171504.GD21535@shamino.rdu.redhat.com> <20100517184508.GD17419@hmsreliant.think-freely.org>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:42703 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754967Ab0EQTZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 15:25:53 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o4HJJSCj006948
	for <netdev@vger.kernel.org>; Mon, 17 May 2010 13:19:28 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4HJPitC114460
	for <netdev@vger.kernel.org>; Mon, 17 May 2010 13:25:48 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4HCPhck018544
	for <netdev@vger.kernel.org>; Mon, 17 May 2010 06:25:43 -0600
In-reply-to: <20100517184508.GD17419@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> wrote:
>Neil Horman <nhorman@tuxdriver.com> wrote:
>> So, its sounding to me like everyone is leaning toward a new mode approach here.
>> Before we go ahead and start coding, I hear the bullet points for this approach
>> as:
>> 
>> 1) Implement a new bond mode where queue ids are used to steer frames to output
>> interfaces
>> 
>> 2) Use said mode to imply universal frame reception (i.e. remove the keep_all
>> knob, and turn on that behavior when this new mode is selected)
>> 
>> 3) use John F.'s skb_should_drop changes to implement the keep_all feature.
>> 
>> Does that sound about right?
>> 
>> Regards
>> Neil
>> 
>Ping, Jay, any feedback on these bullet points.  I'd like to keep working on
>this while we have the time, but I'd rather not play guess & check on the list
>here any more than we need to.

	I've been thinking on this and trying some variations.

	After further discussion with John Fastabend, I don't think a
new mode is warranted for this particular work, largely because the FCOE
case wants to run under essentially any mode (the magic FCOE switches
don't care, they just divert the FC traffic regardless of the switch
port settings).  Perhaps some specific multi-queue gizmo will become a
new mode down the road.  

	Part of my thinking for originally wanting a new mode was that
your changes didn't expose the slave device queues, but after further
discussion, that isn't actually the case.

	I thought about removing the whole special case for "deliver to
direct bindings" and have a switch instead to always deliver to
everybody.  In the end, I don't think that would end up making things
much simpler, because the special cases have to stay for the "normal"
inactive slave behavior to pass the ARP, ARP-over-VLAN, ETH_P_SLOW, etc
traffic.  It also would come at the cost of disabling the duplicate
suppressor for the FCOE case, and I don't think that's what they want.

	I'm thinking right now to go with more or less the three patch
series that John Fastabend posted last week, along with a variant of
your patch.  As much as I'd like to do both things as a unified patch,
doing so just doesn't seem to simplify the existing code, and ends up
being less than optimal for both cases.

	For John's patches, a few minor changes, but that basic idea
(flag in the skb); I'm still chewing on the "VLAN don't copy IFF_MASTER
or SLAVE flag" patch though, just to make sure it won't break anything,
but I don't think it's a critical change.

	For your patch, I'm exploring the idea of not setting
IFF_SLAVE_INACTIVE on "inactive" slaves for an "all_slaves_active"
option (I think that's a more descriptive name than "keep_all") instead
of adding a new KEEP_ALL flag bit to priv_flags.  Did you consider this
methodology and exclude it for some reason?

	Hopefully there won't be any pushback against using a flag bit
in the skb.  I haven't thought of a way to do what's desired in an
efficient manner without storing state in the skb somewhere.  The
skb->skb_iif does hold the original device receiving the skb, but I have
to believe that converting that to a struct net_device * (for the
"direct bind to original slave" case) in __netif_receive_skb is more
expensive that stashing a flag in the skb.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
