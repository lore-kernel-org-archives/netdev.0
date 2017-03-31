From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH net-next 1/1 v2] net: rmnet_data: Initial implementation
Date: Fri, 31 Mar 2017 17:41:20 -0500
Message-ID: <1491000080.13807.1.camel@redhat.com>
References: <1489390989-2408-1-git-send-email-subashab@codeaurora.org>
         <1489390989-2408-2-git-send-email-subashab@codeaurora.org>
         <1490394075.3227.9.camel@redhat.com>
         <4bd7c38e551505fa8d035d5e1b209d8e@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, fengguang.wu@intel.com
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61460 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933321AbdCaWlX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 18:41:23 -0400
In-Reply-To: <4bd7c38e551505fa8d035d5e1b209d8e@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-24 at 18:49 -0600, Subash Abhinov Kasiviswanathan
wrote:
> > (re-sending from an address that's actually subscribed to
> > netdev@...)
> > 
> > The first thing that jumps out at me is "why isn't this using
> > rtnl_link_ops?"
> > 
> > To me (and perhaps I'm completely wrong) the structure here is a
> > lot
> > like VLAN interfaces.  You have a base device (whether that's a
> > netdev
> > or not) and you essentially "ip link add link cdc-wdm0 name rmnet0
> > type
> > rmnet id 5".  Does the aggregation happen only on the downlink (eg,
> > device -> host) or can the host send aggregated packets too?
> 
> Hi Dan
> 
> Yes, you are correct. We associate this driver with a physical
> device 
> and
> then create rmnet devices over it as needed for multiplexing.

Yeah, seems quite a bit like VLAN (from a workflow perspective, not
quite as much from a protocol one) and I think the same workflow could
work for this too.  Would be nice to eventually get qmi_wwan onto the
same base, if possible (though we'd need to preserve the 802.3
capability somehow for devices that don't support raw-ip).

> Aggregation is supported both on downlink and uplink by Qualcomm
> Technologies, Inc. modem hardware. This initial patchset implements
> only
> downlink aggregation since uplink aggregation is rarely enabled or
> used.
> I'll send a separate patchset for that.

Does the aggregation happen at the level of the raw device, or at the
level of the MUX channels?  eg, can I aggregate packets from multiple
MUX channels into the same request, especially on USB devices?

> > Using rtnl_link_ops would get rid of ASSOC_NET_DEV,
> > UNASSOC_NET_DEV,
> > NEW_VND, NEW_VND_WITH_PREFIX, and FREE_VND.  GET_NET_DEV_ASSOC goes
> > away becuase you use normal 'kobject' associations and you can
> > derive
> > the rmnet parent through sysfs links.  rmnet_nl_msg_s goes away,
> > because you can use nla_policy.
> > 
> > Just a thought; there seems to be a ton of overlap with
> > rtnl_link_ops
> > in the control plane here.
> 
> As of now, we have been using a custom netlink userspace tool for
> configuring the interfaces by listening to RMNET_NETLINK_PROTO
> events.
> Does that mean that configuration needs to be moved to ip tool by
> adding a new option for rmnet (like how you have mentioned above)
> and add additional options for end point configuration as well?

It doesn't necessarily mean that configuration would need to move to
the IP tool.  I just used it as an example of how VLAN works and how
rmnet could work as well, quite easily with the ip tool.

Since the ip tool is based on netlink, both it and your userspace
library could use the same netlink attributes and families to do the
same thing.

Essentially, I am recommending that instead of your current custom
netlink commands, port them over to rtnetlink which will mean less code
for you, and a more standard kernel interface for everyone.

> > Any thoughts on how this plays with net namespaces?
> 
> We have not tried it with different net namespaces since we never had
> such use cases internally. We can look into this.

One use-case is to put different packet data contexts into different
namespaces.  You could then isolate different EPS/PDP contexts by
putting them into different network namespaces, and for example have
your IMS handler only be able to access its own EPS/PDP context.

We could already do this with qmi_wwan on devices that provide multiple
USB endpoints for QMI/rmnet, but I thought the point of the MUX
protocol was to allow a single endpoint for rmnet that can MUX multiple
packet data contexts.  So it would be nice to allow each rmnet netdev
to be placed into a different network namespace.

> > Also, I'm not sure if it make sense to provide first class
> > tracepoints
> > for a specific driver, as it's not clear if they are userspace API
> > or
> > not and thus may need to be kept stable.   Or are perf probes
> > enough
> > instead?
> 
> We have some tracepoints which are in datapath and some for specific
> events such as device unregistration and configuration events 
> association.
> Most of these devices are on ARM64 and need to support older kernels,
> (from 3.10) so we had to rely on tracepoints. I believe ARM64 got
> trace
> point support somewhat recently. I was not aware of the restriction
> of
> tracepoints, so I can remove that.

Yeah, best to remove that for now, you can propose to add them back
later and see what people say.

> > 
> > What's RMNET_EPMODE_BRIDGE and how is it used?
> 
> RMNET_EPMODE_BRIDGE is for bridging two different physical
> interfaces.
> An example is sending raw bytes from hardware to USB - this can be
> used
> if a PC connected by USB would require the data in the MAP format.

Like a usb gadget rmnet interface for debugging?

Dan
