From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next] vxlan: Provide means for obtaining port information
Date: Thu, 28 Mar 2013 08:57:37 -0700
Message-ID: <51546871.1060808@intel.com>
References: <20130327212842.13367.68803.stgit@ahduyck-cp1.jf.intel.com> <20130327143849.29afdbdc@nehalam.linuxnetplumber.net> <51536929.9090109@intel.com> <OF67C23F4E.05FEE247-ON85257B3C.0045D89E-85257B3C.00498794@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com, jesse@nicira.com,
	joseph.gasparakis@intel.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, pshelar@nicira.com,
	shemminger@vyatta.com,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24488 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756014Ab3C1P5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 11:57:38 -0400
In-Reply-To: <OF67C23F4E.05FEE247-ON85257B3C.0045D89E-85257B3C.00498794@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2013 06:23 AM, David Stevens wrote:
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>  
>> Yes this will break if we ended up supporting a different port per
>> VXLAN.  The problem is a port per VXLAN is going to be much more
>> difficult to support for any sort of hardware offload as well.  What we
>> end up having to do is add a significant number of filters just to
>> identify all of the possible ports that may be used. 
>         I assume this would only be an issue if you actually have lots
> of ports. If you're using only one, or a couple, which I'd expect to
> be the common case, your filtering needs should be the same, right?

The stuff I was looking at only supported one port for VXLAN
identification.  However I might be able to influence the design so I
plan to see if maybe I can push back a bit to come up with a more
flexible solution. 

>> In addition it
>> will mean having to add some sort of notifier as I mentioned in the
>> patch description since we will have VXLANs going into and out of
>> existence, each one with their own port number..
>         I don't know the context in which you're planning to call this,
> but regardless of the port or ports in use by VXLAN, the devices will
> come and go and the module may be unloaded, so I don't see how what
> you've said here applies to one case and not the other.

In the current setup or in a setup with a fixed IANA port number we
wouldn't need the notifier since the module can only be unloaded if
there are no dependencies and any driver that used the provided function
would be dependent on the module preventing it from being unloaded.

As is, the notifier idea has already been dropped as well.  What we will
probably look at doing once a port-per-vxlan type solution is
implemented is maybe look at adding a pair of add/remove VXLAN port ndo
ops.  It would be something similar to what is already out there for
VLAN since that way the VXLAN itself would then be expected to request
the offloads, instead of us trying to anticipate them.

>> This was essentially a "good enough for now" fix to address the fact
>> that I needed the port number for offload testing, but I will sit back
>> and wait for the port per VXLAN stuff to be pushed in before I take any
>> steps to try to sort that out.
>         What I was suggesting "for now" is that you create an interface
> that need not change to support multiple ports. For example:
>
> int vxlan_get_ports(struct net_device *dev, int *ports, int portcount)
> {
>         if (portcount <= 0 || vxlan_port == 0)
>                 return 0;
>         if (ports)
>                 ports[0] = vxlan_port;
>         return 1;
> }
>
> The return value would be the count of ports in use, and we'd fill up to a 
> maximum
> of portcount in the "ports" array. If you don't have a "dev" you're 
> interested in,
> pass it as NULL and in the future this code would match dev only if it is 
> non-NULL;
> otherwise it would go through the vxlan device list adding ports not in 
> the list to it.
>
> And for the right functionality now, change the VXLAN driver to leave 
> vxlan_port
> zero until a device is instantiated, so you can detect no ports at the 
> moment,
> and set it to zero again when the last one is deleted.
>
> You need a mechanism to delete your filters if there are no VXLAN devices,
> whether or not multiple ports are supported, because "0" is a legal count
> now too. If I haven't created any vxlan devices, I can use port 8472 for
> something else and your loading of the vxlan driver as a side-effect of
> checking the port shouldn't prevent that. That's especially true in a
> distro release where, while I might be able to change the port, I'd have
> to burn one regardless if your driver were loaded, if it can't go without
> a binding when there are no vxlan devices on the system.
>
>                                                                 +-DLS
>

The patch I have now is good enough to get the job done for hardware
testing.  The bit of work I did was more of a "free time" thing and that
has pretty much been used up.

I'll just hold off on submitting any further patches for this until
after the whole port numbering thing is sorted out.

Thanks,

Alex
