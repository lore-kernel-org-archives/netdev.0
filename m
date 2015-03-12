From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: RE: [E1000-devel] [PATCH v3] ixgbe: make VLAN filter conditional
Date: Thu, 12 Mar 2015 05:58:50 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E5765D@BPXM14GP.gisp.nec.co.jp>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E555F3@BPXM14GP.gisp.nec.co.jp>
 <54FFABE7.4090704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([210.143.35.52]:52288 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbbCLF7i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 01:59:38 -0400
In-Reply-To: <54FFABE7.4090704@redhat.com>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 03/10/2015 05:59 PM, Hiroshi Shimamoto wrote:
> > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> >
> > Disable hardware VLAN filtering if netdev->features VLAN flag is dropped.
> >
> > In SR-IOV case, there is a use case which needs to disable VLAN filter.
> > For example, we need to make a network function with VF in virtualized
> > environment. That network function may be a software switch, a router
> > or etc. It means that that network function will be an end point which
> > terminates many VLANs.
> >
> > In the current implementation, VLAN filtering always be turned on and
> > VF can receive only 63 VLANs. It means that only 63 VLANs can be terminated
> > in one NIC.
> 
> Technically it is 4096 VLANs that can be terminated in one NIC, only 63
> VLANs can be routed to VFs/VMDq pools though.  The PF receives all VLAN
> traffic that isn't routed to a specific VF, but does pass the VFTA
> registers.

Right, my explanation was not accurate.
>From the hardware limitation, there are 64 entries in the shared VLAN filter.
That means that only 64 VLANs can be used per port.

Our requirement is that we want to use VLANs without limitation in VF.
Currently there is only this way, disabling VLAN filter, I could find.

> 
> > On the other hand disabling HW VLAN filtering causes a SECURITY issue
> > that each VF can receive all VLAN packets. That means that a VF can see
> > any packet which is sent to other VF.
> 
> It is worse than that.  Now you also receive all broadcast packets on
> all VFs.  It means that any of your systems could be buried in traffic
> with a simple ping flood since it will multiply each frame by the number
> of VFs you have enabled.

Is that VLAN filtering specific?
I understood that broadcast/multicast packets copied to VFs.
But I couldn't imagine the case each VF has and uses different VLAN.

> 
> > This VLAN filtering can be turned off when SR-IOV is disabled, if not
> > the operation is rejected, to prevent unexpected behavior.
> 
> Yes, but you neglect to mention you allow enabling SR-IOV after it has
> been disabled.  In addition you neglected to address DCB and FCoE which
> are two other features that require VLAN support that are supported on
> these adapters.
> 
> > Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> > CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> > ---
> >   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 26 ++++++++++++++++++++++++++
> >   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  4 ++++
> >   2 files changed, 30 insertions(+)
> >
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > index cd5a2c5..2f7bbb2 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > @@ -4079,6 +4079,10 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
> >   		hw->addr_ctrl.user_set_promisc = false;
> >   	}
> >
> > +	/* Disable hardware VLAN filter if the feature flag is dropped */
> > +	if (!(netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER))
> > +		vlnctrl &= ~(IXGBE_VLNCTRL_VFE | IXGBE_VLNCTRL_CFIEN);
> > +
> >   	/*
> >   	 * Write addresses to available RAR registers, if there is not
> >   	 * sufficient space to store all the addresses then enable
> 
> This is outright dangerous for end user configuration.  In addition
> there are other features such as FCoE and DCB that don't function if the
> VLAN filtering is disabled.  Have you even looked into those

Actually I didn't take care about those features.
I'll try to take care about other features in next time.

> complications?  I am pretty certain that the fact tha
> NETIF_F_HW_VLAN_CTAG_FILTER can even be toggled by the user is a bug
> since last I knew the only way to do VLAN promiscuous mode on ixgbe
> parts was to populate the entire VLAN table to all 1s.
> 
> > @@ -7736,6 +7740,28 @@ static int ixgbe_set_features(struct net_device *netdev,
> >   	netdev_features_t changed = netdev->features ^ features;
> >   	bool need_reset = false;
> >
> > +	if (changed & NETIF_F_HW_VLAN_CTAG_FILTER) {
> > +		int vlan_filter = features & NETIF_F_HW_VLAN_CTAG_FILTER;
> > +
> > +		/* Prevent controlling VLAN filter if VFs exist */
> > +		if (adapter->num_vfs > 0) {
> > +			e_dev_info("%s HW VLAN filter is not allowed when "
> > +				   "SR-IOV enabled.\n",
> > +				   vlan_filter ? "Enabling" : "Disabling");
> > +			return -EINVAL;
> > +		}
> > +		if (!vlan_filter) {
> > +			e_dev_warn("Disabling HW VLAN filter. This cause "
> > +				   "SERIOUS SECURITY issues.\n");
> > +			e_dev_warn("Every VF users can receive a packet to "
> > +				   "other VFs.\n");
> > +			e_dev_warn("You cannot turn it on again if you are "
> > +				   "using SR-IOV.\n");
> > +		}
> > +		/* reset if HW VLAN filter is changed */
> > +		need_reset = true;
> > +	}
> > +
> 
> This whole section makes no sense and is exceedingly deceptive.  You
> open a blatant security hole, and then hide it behind the fact that
> SR-IOV wasn't enabled at the time you opened it, but when you do then
> you are totally open to all VLANs on all VFs and there is no warning.
> 
> At this point I seriously wonder if you shouldn't start to go the
> switchdev route since it seems like you are wanting to enable
> promiscuous mode VFs.  At least with something like switchdev it should
> be much more obvious that you are disabling all of the filtering on the
> internal L2 switch.
> 
> >   	/* Make sure RSC matches LRO, reset if change */
> >   	if (!(features & NETIF_F_LRO)) {
> >   		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> > index 2d98ecd..f3a315c 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> > @@ -787,6 +787,10 @@ static int ixgbe_set_vf_vlan_msg(struct ixgbe_adapter *adapter,
> >   	u32 bits;
> >   	u8 tcs = netdev_get_num_tc(adapter->netdev);
> >
> > +	/* Ignore if VLAN filter is disabled */
> > +	if (!(adapter->netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER))
> > +		return 0;
> > +
> >   	if (adapter->vfinfo[vf].pf_vlan || tcs) {
> >   		e_warn(drv,
> >   		       "VF %d attempted to override administratively set VLAN configuration\n"
> 
> What is the point of this?  You are blocking the PF from assigning a
> VLAN to untagged traffic?  This should at least be returning an error if
> you aren't going to actually do what the end user requested.
> 
> ---
> 
> Between this patch and your multicast ones I can only assume you must
> have your network completely locked down because this just seems to open
> you up to so many security holes and floods so much traffic that it
> would be easy to bring your network to a grinding halt with the flags
> you have added.  Disabling VLANs on this hardware is not going to be an
> easy thing to do.  Yes you did it here, but in the process I can think
> of probably a half dozen other features you have likely broken within
> the NIC.
> 
> To give you an idea of the scale of what you are getting into it took me
> 6 months to get DCB, Flow Director, SR-IOV, FCoE and VMDq all working
> together correctly in the parts supported by this driver.  I suspect you
> would be looking at another 6 months of implementation, testing, and bug
> fixing to try to make all of these work with VLANs being able to be
> toggled in and out on the fly and work reliably.  Odds are in many cases
> you would probably have to just shut off the features since some such as
> DCB and FCoE I am fairly certain won't even work when VLAN filtering is
> disabled, and then there are also all the corner cases to consider.
> 
> I am going to submit a patch to fix the original bug here, which is the
> fact that NETIF_F_HW_VLAN_CTAG_FILTER can be toggled since the driver
> wasn't actually checking that flag. If you still want to go down this
> path of disabling VLAN filtering feel free to, but I would suggest
> looking much more closely at how your changes will interact with all of
> the other features of the adapter other than SR-IOV.

Now I see the complication of features in ixgbe.

By the way, I wonder there is no one who is worried about this VLAN limitation.


thanks,
Hiroshi

> 
> - Alex
