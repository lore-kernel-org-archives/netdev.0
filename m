From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 3/3 v11] drivers: net: ethernet: qualcomm: rmnet:
 Initial implementation
Date: Wed, 30 Aug 2017 15:19:19 -0600
Message-ID: <c64415aa8d1184303f5916bdd2fd6ce3@codeaurora.org>
References: <1504068258-16982-1-git-send-email-subashab@codeaurora.org>
 <1504068258-16982-4-git-send-email-subashab@codeaurora.org>
 <1504103947.21231.5.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@aculab.com,
        marcel@holtmann.org, andrew@lunn.ch
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:60012 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750824AbdH3VTU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 17:19:20 -0400
In-Reply-To: <1504103947.21231.5.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> General comment; other drivers that do similar things (macvlan, ipvlan)
> use the term "port" to refer to what I think you're calling a
> "rmnet_real_dev_info".  Maybe that's a shorter or less confusing term.
> Could be renamed later too, if you wanted to do so.
> 

Hi Dan

I'll rename it to rmnet_port.

> Maybe this got elided during the revisions, but now I can't find
> anywhere that sets RMNET_LOCAL_LOGICAL_ENDPOINT.  Looking at the
> callchain, there are two places that LOCAL_LOGICAL_ENDPOINT matters:
> 
> rmnet_get_endpoint(): only ever called by __rmnet_set_endpoint_config()
> 
> __rmnet_set_endpoint_config(): only called from
> rmnet_set_endpoint_config(); which itself is only called from
> rmnet_newlink().
> 
> So the only place that 'config_id' is set, and thus that it could be
> LOCAL_LOGICAL_ENDPOINT, is rmnet_newlink() via 'mux_id'.  But
> IFLA_VLAN_ID is a u16, and so I don't see anywhere that
> config_id/mux_id will ever be < 0, and thus anywhere that it could be
> LOCAL_LOGICAL_ENDPOINT.
> 
> I could well just not be seeing it though...
> 
> This function (__rmnet_set_endpoint_config) seems to only be called
> from rmnet_set_endpoint_config().  Perhaps just combine them?
> 
> But that brings up another point; can the rmnet "mode" or egress_dev
> change at runtime, after the rmnet child has been created?  I forget if
> that was possible with your original patchset that used ioctls.
> 

The original series with IOCTL was able to change it.
With the current netlink based configuration, we are using a fixed 
config
of muxing and the egress dev is fixed for its lifetime. Practically, 
these
should never change for a set of rmnet devices attached to a real dev.
I will remove LOCAL_LOGICAL_ENDPOINT since it is unused.

> Why not set the mux_id in rmnet_vnd_newlink()?
> 
> Also, bigger problem.  r->rmnet_devices[] is only 32 items in size.
> But mux_id (which is used as an index into rmnet_devices in a few
> places) can be up to 255 (RMNET_MAX_LOGICAL_EP).
> 
> So if you try to create an rmnet for mux ID 32, you panic the kernel.
> See below my comments about rmnet_real_dev_info...
> 

I'll fix this.

> I can't see anywhere that the egress/ingress data get set except for
> this function, so perhaps you could just skip these functions and
> (since you already have 'r' from above) set r-
>> [egress|ingress]_data_format directly?
> 

Yes, till this is made configurable, this need not be set separately.

> This means that the first time you add an rmnet dev to a netdev, it'll
> create a structure that's quite large (at least 255 * 6, but more due
> to padding), when in most cases few of these items will be used.  Most
> of the time you'd have only a couple PDNs active, but this will
> allocate memory for MAX_LOGICAL_EP of them, no?
> 
> ipvlan uses a list to track the child devices attached to a physical
> device so that it doesn't have to allocate them all at once and waste
> memory; that technique could replace the 'rmnet_devices' member below.
> 
> It also uses a hash to find the actual ipvlan upperdev from the
> rx_handler of the lowerdev, which is probably what would replace
> muxed_ep[] here.
> 
> Is the relationship between rmnet "child"/upper devs and mux_ids 1:1?
> Or can you have multiple rmnet devs for the same mux_id?
> 
> Dan

We can have multiple rmnet devices having the same mux_id. They will
need to be attached to different real_dev though. I'll look into the
creation of hash for the lookup. Once I have the hash up, I should
be able to get rid of some of the structures.

The other main functionality which I am unsure is the
bridge handling - passing on MAP data from one real_dev to another.
Is there some to achieve this using any existing netlink attributes?
Any suggestions would be appreciated.

> Please implement ndo_get_iflink as well, so that it's easy to find out
> what the "parent"/lowerdev for a given rmnet interface is.
> 
> That might mean adding a "phy_dev" member to rmnet_priv, but that might
> help you clean up a lot of other stuff too
> 

Sure, I'll implement this. Let me know if you have more comments.
