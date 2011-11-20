From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering
 support for passthru mode
Date: Sun, 20 Nov 2011 08:30:24 -0800
Message-ID: <CAEE6B20.3A9F7%roprabhu@cisco.com>
References: <1321575301.2749.51.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<chrisw@redhat.com>, <sri@us.ibm.com>, <dragos.tatulea@gmail.com>,
	<kvm@vger.kernel.org>, <arnd@arndb.de>, <mst@redhat.com>,
	<gregory.v.rose@intel.com>, <mchan@broadcom.com>,
	<dwang2@cisco.com>, <shemminger@vyatta.com>,
	<eric.dumazet@gmail.com>, <kaber@trash.net>, <benve@cisco.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1321575301.2749.51.camel@bwh-desktop>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




On 11/17/11 4:15 PM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:

> Sorry to come to this rather late.
> 
> On Tue, 2011-11-08 at 23:55 -0800, Roopa Prabhu wrote:
> [...]
>> v2 -> v3
>> - Moved set and get filter ops from rtnl_link_ops to netdev_ops
>> - Support for SRIOV VFs.
>>         [Note: The get filters msg (in the way current get rtnetlink handles
>>         it) might get too big for SRIOV vfs. This patch follows existing
>> sriov 
>>         vf get code and tries to accomodate filters for all VF's in a PF.
>>         And for the SRIOV case I have only tested the fact that the VF
>>         arguments are getting delivered to rtnetlink correctly. The code
>>         follows existing sriov vf handling code so rest of it should work
>> fine]
> [...]
> 
> This is already broken for large numbers of VFs, and increasing the
> amount of information per VF is going to make the situation worse.  I am
> no netlink expert but I think that the current approach of bundling all
> information about an interface in a single message may not be
> sustainable.

Yes agreed. I have the same concern.

> 
> Also, I'm unclear on why this interface is to be used to set filtering
> for the (PF) net device as well as for related VFs.  Doesn't that
> duplicate the functionality of ndo_set_rx_mode and
> ndo_vlan_rx_{add,kill}_vid?
> 
Yes..I have thought about this. But the reason the final version is the way
it is because its trying to accommodate sriov and non sriov cases because I
was just trying to make the netlink interface available to as many use cases
that might need it.

I just wanted to bring up the original intent of this patch.
Which was to add support for TUNSETTXFILTER to macvtap so that it can do
filtering instead of putting the lower dev (physical dev) in promiscuous
mode (This part really does not care if the lowerdev is an SRIOV VF or not).
And the focus was on macvlan passthru mode because it is the simplest case
to solve (you have to just pass the filters to lowerdev device/driver).
Now this may seem like It can be done with existing set_rx_mode/add_vlan_id
etc (which are essentially the mechanisms I am using in the macvlan driver
to send the filters to lowerdev for passthru mode), but it might not be the
case for other macvlan modes. Macvlan device might need to maintain and do a
filter lookup like the tap driver does today. And the only reason SRIOV came
up in the original patch was because PASSTHRU mode of macvlan was added for
SRIOV use case, though it really does not care if the lowerdev is an SRIOV
VF or not.


Instead of implementing TUNSETTXFILTER, michael had suggested netlink
interface instead. 
When implementing the netlink interface, I did go back and forth in deciding
whether this should be on every netdev or only virtual devices that support
rtnl link ops. And the existence of set_rx_mode and add_vlan_id netdev ops
Was the reason for confusion. So the next version implemented it as rtnl
link ops because all I really want is a mechanism like TUNSETTXFILTER which
can set/get filters for virtual devices that need to do filtering by
themselves. But restricting this interface for only virtual devices did not
make great sense so when greg pointed it out that he will need it for VF
netdevs, I was happy to move it to netdev ops.

And the only reason this patch works on both PF and VF if the final version
is because, its trying to accommodate both SRIOV and non-SRIOV devices.
So by saying PF and VF, for me it really means SRIOV VF and any other netdev
devices. So I intentionally did not put PF or VF in the name of the op.

Thanks,
Roopa

