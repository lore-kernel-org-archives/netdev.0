From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 1/1 v2] net: rmnet_data: Initial implementation
Date: Fri, 24 Mar 2017 18:49:17 -0600
Message-ID: <4bd7c38e551505fa8d035d5e1b209d8e@codeaurora.org>
References: <1489390989-2408-1-git-send-email-subashab@codeaurora.org>
 <1489390989-2408-2-git-send-email-subashab@codeaurora.org>
 <1490394075.3227.9.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, fengguang.wu@intel.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:34718 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753289AbdCYAtT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 20:49:19 -0400
In-Reply-To: <1490394075.3227.9.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> (re-sending from an address that's actually subscribed to netdev@...)
> 
> The first thing that jumps out at me is "why isn't this using
> rtnl_link_ops?"
> 
> To me (and perhaps I'm completely wrong) the structure here is a lot
> like VLAN interfaces.  You have a base device (whether that's a netdev
> or not) and you essentially "ip link add link cdc-wdm0 name rmnet0 type
> rmnet id 5".  Does the aggregation happen only on the downlink (eg,
> device -> host) or can the host send aggregated packets too?

Hi Dan

Yes, you are correct. We associate this driver with a physical device 
and
then create rmnet devices over it as needed for multiplexing.

Aggregation is supported both on downlink and uplink by Qualcomm
Technologies, Inc. modem hardware. This initial patchset implements only
downlink aggregation since uplink aggregation is rarely enabled or used.
I'll send a separate patchset for that.

> Using rtnl_link_ops would get rid of ASSOC_NET_DEV, UNASSOC_NET_DEV,
> NEW_VND, NEW_VND_WITH_PREFIX, and FREE_VND.  GET_NET_DEV_ASSOC goes
> away becuase you use normal 'kobject' associations and you can derive
> the rmnet parent through sysfs links.  rmnet_nl_msg_s goes away,
> because you can use nla_policy.
> 
> Just a thought; there seems to be a ton of overlap with rtnl_link_ops
> in the control plane here.

As of now, we have been using a custom netlink userspace tool for
configuring the interfaces by listening to RMNET_NETLINK_PROTO events.
Does that mean that configuration needs to be moved to ip tool by
adding a new option for rmnet (like how you have mentioned above)
and add additional options for end point configuration as well?

> Any thoughts on how this plays with net namespaces?

We have not tried it with different net namespaces since we never had
such use cases internally. We can look into this.

> Also, I'm not sure if it make sense to provide first class tracepoints
> for a specific driver, as it's not clear if they are userspace API or
> not and thus may need to be kept stable.   Or are perf probes enough
> instead?

We have some tracepoints which are in datapath and some for specific
events such as device unregistration and configuration events 
association.
Most of these devices are on ARM64 and need to support older kernels,
(from 3.10) so we had to rely on tracepoints. I believe ARM64 got trace
point support somewhat recently. I was not aware of the restriction of
tracepoints, so I can remove that.

> 
> What's RMNET_EPMODE_BRIDGE and how is it used?

RMNET_EPMODE_BRIDGE is for bridging two different physical interfaces.
An example is sending raw bytes from hardware to USB - this can be used
if a PC connected by USB would require the data in the MAP format.
