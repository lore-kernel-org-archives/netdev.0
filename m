From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: Re: [PATCH v3] ixgbe: make VLAN filter conditional
Date: Fri, 20 Mar 2015 07:35:51 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E6593F@BPXM14GP.gisp.nec.co.jp>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E555F3@BPXM14GP.gisp.nec.co.jp>
	<54FFABE7.4090704@redhat.com>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E5765D@BPXM14GP.gisp.nec.co.jp>
	<5501B60D.6030304@redhat.com>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E5F0CA@BPXM14GP.gisp.nec.co.jp>
	<5506F745.3010206@redhat.com>
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
In-Reply-To: <5506F745.3010206@redhat.com>
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

> On 03/16/2015 05:33 AM, Hiroshi Shimamoto wrote:
> >> On 03/11/2015 10:58 PM, Hiroshi Shimamoto wrote:
> >>>> On 03/10/2015 05:59 PM, Hiroshi Shimamoto wrote:
> >>>>> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> >>>>>
> >>>>> Disable hardware VLAN filtering if netdev->features VLAN flag is dropped.
> >>>>>
> >>>>> In SR-IOV case, there is a use case which needs to disable VLAN filter.
> >>>>> For example, we need to make a network function with VF in virtualized
> >>>>> environment. That network function may be a software switch, a router
> >>>>> or etc. It means that that network function will be an end point which
> >>>>> terminates many VLANs.
> >>>>>
> >>>>> In the current implementation, VLAN filtering always be turned on and
> >>>>> VF can receive only 63 VLANs. It means that only 63 VLANs can be terminated
> >>>>> in one NIC.
> >>>> Technically it is 4096 VLANs that can be terminated in one NIC, only 63
> >>>> VLANs can be routed to VFs/VMDq pools though.  The PF receives all VLAN
> >>>> traffic that isn't routed to a specific VF, but does pass the VFTA
> >>>> registers.
> >>> Right, my explanation was not accurate.
> >>> >From the hardware limitation, there are 64 entries in the shared VLAN filter.
> >>> That means that only 64 VLANs can be used per port.
> >>>
> >>> Our requirement is that we want to use VLANs without limitation in VF.
> >>> Currently there is only this way, disabling VLAN filter, I could find.
> >> The problem is that unlike multicast promiscuous option that was
> >> supported by the hardware there is nothing to limit this to any one VF.
> >> So if you enable this feature you are not only allowing that one VF to
> >> ignore the VLAN filter rules, but you are disabling them for the PF and
> >> all VFs at once.
> > I'm afraid that I could not explain what we want.
> > We want to use 4k VLANs in a VM which has VF.
> >
> > I understand that when HW VLAN filter is disabled, all VFs and the PF loses
> > this functionality.
> >
> >>>>> On the other hand disabling HW VLAN filtering causes a SECURITY issue
> >>>>> that each VF can receive all VLAN packets. That means that a VF can see
> >>>>> any packet which is sent to other VF.
> >>>> It is worse than that.  Now you also receive all broadcast packets on
> >>>> all VFs.  It means that any of your systems could be buried in traffic
> >>>> with a simple ping flood since it will multiply each frame by the number
> >>>> of VFs you have enabled.
> >>> Is that VLAN filtering specific?
> >>> I understood that broadcast/multicast packets copied to VFs.
> >>> But I couldn't imagine the case each VF has and uses different VLAN.
> >> VLANs are used for isolation, that is kind of the point of a VLAN. So
> >> for example if you had a multi-tenant data center you might use VLANs to
> >> separate the systems that belong to each tenant.  This way it appears
> >> that they are off in their own little cloud and not affecting one
> >> another.  With VLANs disabled you strip that option away and as a result
> >> you end up with each VF being able to see all of the broadcast/multicast
> >> traffic from every other VF.
> > On the other hand, ixgbe chip can only have 64 VLANs and 64 VFs at most.
> > That means I think few number of VLANs can be used in each VF and some VLANs
> > or untagged VLAN may be shared among VFs, then there is broadcast/multicast
> > storm possibility already, that is just my feeling.
> 
> The idea is to only share VLANs between any given customer.  So for
> example if you have 63 VFs (upper limit for ixgbe as I recall), and 5
> customers you would typically break this up into 5 VLANs where each
> customer is assigned one VLAN to isolate their network from the others.
> As a result one customer couldn't send a broadcast storm to the others.
> 
> > By the way, I think, there is another possibility of DoS by requesting much
> > number of VLANs from VF. That causes that later VFs cannot have their VLAN
> > because there are only 64 VLAN entries.
> > The first VM creates 64 VLANs that id 1-64, then start the second VM and the
> > second one fails to have requesting VLAN id 65 because there is no room.
> 
> This isn't really a DoS, this is a configuration problem.  I would
> classify that as a "don't shoot yourself in the foot" type scenerio.
> You could also argue that only supporting 63 VFs is a DoS using that
> same style of logic.
> 
> The 64 VLANs can be shared between the PF and all VFs so if the
> administrator wants to assign 63 VLANs to the first VF, and have the
> rest use some variation on those 63 VLANs that is also an option. The
> admin has control over the VF ability to request VLANs, if they assign
> an administrative VLAN (one of the things you disabled and didn't return
> an error for in your patch) then the VF can no longer request its own VLANs.

It looks we have to manage the network and trust a guest.
If we can do that, I think we can also manage VLAN filter turned off network.
Prevent to make broadcast storm by operation same as prevent to use VLANs.
freely in guest

I know I have to take care not to break existing functionality.

> 
> >>> By the way, I wonder there is no one who is worried about this VLAN limitation.
> >>>
> >>>
> >>> thanks,
> >>> Hiroshi
> >> I believe that your use case if very unique.  Specifically things like
> >> VLANs are supposed to be in place to allow for isolation of networks.
> > I'm not sure why our use case is so unique.
> > Implementing router function, gateway and etc. could use much VLANs.
> > 64 VLANs must be too small for those applications.
> > I just bring such application into VM and want to use SR-IOV for performance.
> 
> This gets at the heart of the issue.  Few would ever advice using a VF
> for a router function, and even then they would likely keep it within
> the confines of a few VLANs.  The issue is that the resources for a VF
> are limited an you only have a few queues to work with unless you are
> using something such as DPDK.  Same thing goes for a bridge/switch since
> a VF cannot really support promiscuous mode. This is functionality that
> should really only be handled by the PF, or within the switching
> function of the NIC.  What you may want to do instead would be to direct
> assign the PF function of the NIC, not a VF.  The problem is that the
> way you are using it will make the PF and all of the other VFs pretty
> much unusable since you will likely be seeing frames duplicated to all
> of the devices.

I understand the limitation of hardware. But I'd like to enable such functionality
by disabling HW VLAN filter. With strictly managed the network, it should work.

> 
> > Usually an administrator of VM can use VLANs and ixgbevf seems to allow to
> > use VLAN as the administrator wants. But the hardware limitation of VLAN
> > filtering makes us to use VLAN harder in virtualized environment.
> >
> > thanks,
> > Hiroshi
> 
> The issue is that you are using SR-IOV in a case where it is likely not
> a good solution.  By enabling the features you have, you have made it so
> that you won't be able to use any of the other VFs without completely
> disregarding security and/or performance.  The solution doesn't really
> scale.
> 
> I would recommend testing your patches with small (64B)
> multicast/broadcast packets if you need to see for yourself.  The
> problem is you are going to end up saturating the entire PCIe link with
> just one port and it shouldn't take very much to do it.  For example if
> you have the PF and 7 VF functions enabled I would suspect you won't be
> able to get past 1Gb/s per function just because the frame replication
> will be so great.

I guess it's better to see what does happen in such a scenario.
In current our case and testing, it works well enough.

thanks,
Hiroshi

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
