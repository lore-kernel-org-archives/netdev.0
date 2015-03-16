From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: Re: [PATCH v3] ixgbe: make VLAN filter conditional
Date: Mon, 16 Mar 2015 12:33:19 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E5F0CA@BPXM14GP.gisp.nec.co.jp>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E555F3@BPXM14GP.gisp.nec.co.jp>
	<54FFABE7.4090704@redhat.com>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E5765D@BPXM14GP.gisp.nec.co.jp>
	<5501B60D.6030304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <5501B60D.6030304@redhat.com>
Content-Language: ja-JP
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> On 03/11/2015 10:58 PM, Hiroshi Shimamoto wrote:
> >> On 03/10/2015 05:59 PM, Hiroshi Shimamoto wrote:
> >>> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> >>>
> >>> Disable hardware VLAN filtering if netdev->features VLAN flag is dropped.
> >>>
> >>> In SR-IOV case, there is a use case which needs to disable VLAN filter.
> >>> For example, we need to make a network function with VF in virtualized
> >>> environment. That network function may be a software switch, a router
> >>> or etc. It means that that network function will be an end point which
> >>> terminates many VLANs.
> >>>
> >>> In the current implementation, VLAN filtering always be turned on and
> >>> VF can receive only 63 VLANs. It means that only 63 VLANs can be terminated
> >>> in one NIC.
> >> Technically it is 4096 VLANs that can be terminated in one NIC, only 63
> >> VLANs can be routed to VFs/VMDq pools though.  The PF receives all VLAN
> >> traffic that isn't routed to a specific VF, but does pass the VFTA
> >> registers.
> > Right, my explanation was not accurate.
> > >From the hardware limitation, there are 64 entries in the shared VLAN filter.
> > That means that only 64 VLANs can be used per port.
> >
> > Our requirement is that we want to use VLANs without limitation in VF.
> > Currently there is only this way, disabling VLAN filter, I could find.
> 
> The problem is that unlike multicast promiscuous option that was
> supported by the hardware there is nothing to limit this to any one VF.
> So if you enable this feature you are not only allowing that one VF to
> ignore the VLAN filter rules, but you are disabling them for the PF and
> all VFs at once.

I'm afraid that I could not explain what we want.
We want to use 4k VLANs in a VM which has VF.

I understand that when HW VLAN filter is disabled, all VFs and the PF loses
this functionality.

> 
> >>> On the other hand disabling HW VLAN filtering causes a SECURITY issue
> >>> that each VF can receive all VLAN packets. That means that a VF can see
> >>> any packet which is sent to other VF.
> >> It is worse than that.  Now you also receive all broadcast packets on
> >> all VFs.  It means that any of your systems could be buried in traffic
> >> with a simple ping flood since it will multiply each frame by the number
> >> of VFs you have enabled.
> > Is that VLAN filtering specific?
> > I understood that broadcast/multicast packets copied to VFs.
> > But I couldn't imagine the case each VF has and uses different VLAN.
> 
> VLANs are used for isolation, that is kind of the point of a VLAN. So
> for example if you had a multi-tenant data center you might use VLANs to
> separate the systems that belong to each tenant.  This way it appears
> that they are off in their own little cloud and not affecting one
> another.  With VLANs disabled you strip that option away and as a result
> you end up with each VF being able to see all of the broadcast/multicast
> traffic from every other VF.

On the other hand, ixgbe chip can only have 64 VLANs and 64 VFs at most.
That means I think few number of VLANs can be used in each VF and some VLANs
or untagged VLAN may be shared among VFs, then there is broadcast/multicast
storm possibility already, that is just my feeling.

By the way, I think, there is another possibility of DoS by requesting much
number of VLANs from VF. That causes that later VFs cannot have their VLAN
because there are only 64 VLAN entries.
The first VM creates 64 VLANs that id 1-64, then start the second VM and the
second one fails to have requesting VLAN id 65 because there is no room.

> 
> >>> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> >>> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> >>> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> >>> ---
> >>>    drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 26 ++++++++++++++++++++++++++
> >>>    drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  4 ++++
> >>>    2 files changed, 30 insertions(+)
> >>>
> >>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> >>> index cd5a2c5..2f7bbb2 100644
> >>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> >>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> >>> @@ -4079,6 +4079,10 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
> >>>    		hw->addr_ctrl.user_set_promisc = false;
> >>>    	}
> >>>
> >>> +	/* Disable hardware VLAN filter if the feature flag is dropped */
> >>> +	if (!(netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER))
> >>> +		vlnctrl &= ~(IXGBE_VLNCTRL_VFE | IXGBE_VLNCTRL_CFIEN);
> >>> +
> >>>    	/*
> >>>    	 * Write addresses to available RAR registers, if there is not
> >>>    	 * sufficient space to store all the addresses then enable
> >> This is outright dangerous for end user configuration.  In addition
> >> there are other features such as FCoE and DCB that don't function if the
> >> VLAN filtering is disabled.  Have you even looked into those
> > Actually I didn't take care about those features.
> > I'll try to take care about other features in next time.
> 
> Yes, please do.  I also suspect there may still be a few bugs and corner
> cases lurking around out there related to enabling multiple features at
> once.
> 
> >>>    	/* Make sure RSC matches LRO, reset if change */
> >>>    	if (!(features & NETIF_F_LRO)) {
> >>>    		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
> >>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> >>> index 2d98ecd..f3a315c 100644
> >>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> >>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> >>> @@ -787,6 +787,10 @@ static int ixgbe_set_vf_vlan_msg(struct ixgbe_adapter *adapter,
> >>>    	u32 bits;
> >>>    	u8 tcs = netdev_get_num_tc(adapter->netdev);
> >>>
> >>> +	/* Ignore if VLAN filter is disabled */
> >>> +	if (!(adapter->netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER))
> >>> +		return 0;
> >>> +
> >>>    	if (adapter->vfinfo[vf].pf_vlan || tcs) {
> >>>    		e_warn(drv,
> >>>    		       "VF %d attempted to override administratively set VLAN configuration\n"
> >> What is the point of this?  You are blocking the PF from assigning a
> >> VLAN to untagged traffic?  This should at least be returning an error if
> >> you aren't going to actually do what the end user requested.
> >>
> >> ---
> >>
> >> Between this patch and your multicast ones I can only assume you must
> >> have your network completely locked down because this just seems to open
> >> you up to so many security holes and floods so much traffic that it
> >> would be easy to bring your network to a grinding halt with the flags
> >> you have added.  Disabling VLANs on this hardware is not going to be an
> >> easy thing to do.  Yes you did it here, but in the process I can think
> >> of probably a half dozen other features you have likely broken within
> >> the NIC.
> >>
> >> To give you an idea of the scale of what you are getting into it took me
> >> 6 months to get DCB, Flow Director, SR-IOV, FCoE and VMDq all working
> >> together correctly in the parts supported by this driver.  I suspect you
> >> would be looking at another 6 months of implementation, testing, and bug
> >> fixing to try to make all of these work with VLANs being able to be
> >> toggled in and out on the fly and work reliably.  Odds are in many cases
> >> you would probably have to just shut off the features since some such as
> >> DCB and FCoE I am fairly certain won't even work when VLAN filtering is
> >> disabled, and then there are also all the corner cases to consider.
> >>
> >> I am going to submit a patch to fix the original bug here, which is the
> >> fact that NETIF_F_HW_VLAN_CTAG_FILTER can be toggled since the driver
> >> wasn't actually checking that flag. If you still want to go down this
> >> path of disabling VLAN filtering feel free to, but I would suggest
> >> looking much more closely at how your changes will interact with all of
> >> the other features of the adapter other than SR-IOV.
> > Now I see the complication of features in ixgbe.
> 
> Yes, if you choose to go head you are going to be seeing up quite a bit
> of work for yourself and likely the folks at Intel as the features can
> tend to get very tangled when you start working on things such as VLANs
> so this will likely need a good deal of testing and review.
> 
> > By the way, I wonder there is no one who is worried about this VLAN limitation.
> >
> >
> > thanks,
> > Hiroshi
> 
> I believe that your use case if very unique.  Specifically things like
> VLANs are supposed to be in place to allow for isolation of networks.

I'm not sure why our use case is so unique.
Implementing router function, gateway and etc. could use much VLANs.
64 VLANs must be too small for those applications.
I just bring such application into VM and want to use SR-IOV for performance.

Usually an administrator of VM can use VLANs and ixgbevf seems to allow to
use VLAN as the administrator wants. But the hardware limitation of VLAN
filtering makes us to use VLAN harder in virtualized environment.

thanks,
Hiroshi

> When you tear that out you end up with all the VFs all seeing the same
> traffic and that can result in significant performance penalties as the
> VFs have to discard packets in their stack instead of at the device.  It
> also opens you up to large security risks as now one VM has to just
> start sending a broadcast storm and it will take down the entire adapter
> since each packet would be replicated for each of the virtual functions
> and likely overrun the Rx FIFO.
> 
> I am fairly certain that most customers opted to either just stick to
> other technologies such as VMDq to avoid the broadcast/multicast
> replication or they are just not using VMs the same way you are.  In
> either case I would strongly recommend reviewing your use case as I am
> not sure SR-IOV is the right solution for your needs since you are
> having to disable most of the features that make it what it is.
> 
> - Alex

------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
