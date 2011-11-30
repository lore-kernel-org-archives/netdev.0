From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering
 support for passthru mode
Date: Wed, 30 Nov 2011 15:19:12 -0800
Message-ID: <43F901BD926A4E43B106BF17856F075501A20AB5F2@orsmsx508.amr.corp.intel.com>
References: <1321577078.2749.58.camel@bwh-desktop>
 <4EC68EBB.3080303@intel.com> <1321638038.2883.28.camel@bwh-desktop>
 <4ECA8D50.9080603@intel.com> <1322584544.2684.20.camel@bwh-desktop>
 <1322587170.2684.26.camel@bwh-desktop> <4ED6691D.9070606@intel.com>
 <1322678890.2762.26.camel@bwh-desktop>
 <20111130210454.GC29071@x200.localdomain>
 <1322688843.2762.45.camel@bwh-desktop>
 <20111130230049.GE29071@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Roopa Prabhu <roprabhu@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sri@us.ibm.com" <sri@us.ibm.com>,
	"dragos.tatulea@gmail.com" <dragos.tatulea@gmail.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, "mst@redhat.com" <mst@redhat.com>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"dwang2@cisco.com" <dwang2@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"benve@cisco.com" <benve@cisco.com>
To: Chris Wright <chrisw@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111130230049.GE29071@x200.localdomain>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Chris Wright [mailto:chrisw@redhat.com]
> Sent: Wednesday, November 30, 2011 3:01 PM
> To: Ben Hutchings
> Cc: Chris Wright; Rose, Gregory V; Roopa Prabhu; netdev@vger.kernel.org;
> davem@davemloft.net; sri@us.ibm.com; dragos.tatulea@gmail.com;
> kvm@vger.kernel.org; arnd@arndb.de; mst@redhat.com; mchan@broadcom.com;
> dwang2@cisco.com; shemminger@vyatta.com; eric.dumazet@gmail.com;
> kaber@trash.net; benve@cisco.com
> Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering
> support for passthru mode
> 
> * Ben Hutchings (bhutchings@solarflare.com) wrote:
> > On Wed, 2011-11-30 at 13:04 -0800, Chris Wright wrote:
> > > I agree that it's confusing.  Couldn't you simplify your ascii art
> > > (hopefully removing hw assumptions about receive processing, and
> > > completely ignoring vlans for the moment) to something like:
> > >
> > >              |RX
> > >              v
> > > +------------+-------------+
> > > |     +------+--------+    |
> > > |     | RX MAC filter |    |
> > > |     |and port select|    |
> > > |     +---------------+    |
> > > |            /|\           |
> > > |           / | \   match 2|
> > > |          /  v  \         |
> > > |         /match  \        |
> > > |        /  1 |    \       |
> > > |       /     |     \      |
> > > |match /      |      \     |
> > > |  0  /       |       \    |
> > > |    v        |        v   |
> > > |    |        |        |   |
> > > +----+--------+--------+---+
> > >      |        |        |
> > >     PF       VF 1     VF 2
> > >
> > > And there's an unclear number of ways to update "RX MAC filter and
> port
> > > select" table.
> > >
> > > 1) PF ndo_set_mac_addr
> > > I expect that to be implicit to match 0.
> > >
> > > 2) PF ndo_set_rx_mode
> > > Less clear, but I'd still expect these to implicitly match 0
> > >
> > > 3) PF ndo_set_vf_mac
> > > I expect these to be an explicit match to VF N (given the interface
> > > specifices which VF's MAC is being programmed).
> >
> > I'm not sure whether this is supposed to implicitly add to the MAC
> > filter or whether that has to be changed too.  That's the main
> > difference between my models (a) and (b).
> 
> I see now.  I wasn't entirely clear on the difference before.  It's also
> going to be hw specific.  I think (Intel folks can verify) that the
> Intel SR-IOV devices have a single global unicast exact match table,
> for example.
> 
> > There's also PF ndo_set_vf_vlan.
> 
> Right, although I had mentioned I was trying to limit just to MAC
> filtering to simplify.
> 
> > > 4) VF ndo_set_mac_addr
> > > This one may or may not be allowed (setting MAC+port if the VF is
> owned
> > > by a guest is likely not allowed), but would expect an implicit VF N.
> > >
> > > 5) VF ndo_set_rx_mode
> > > Same as 4) above.
> >
> > So this is where we are today.
> 
> Cool, good that we agree there.
> 
> > > 6) PF or VF? ndo_set_rx_filter_addr
> > > The new proposal, which has an explicit VF, although when it's VF_SELF
> > > I'm not clear if this is just the same as 5) above?
> > >
> > > Have I missed anything?
> >
> > Any physical port can be bridged to a mixture of guests with and without
> > their own VFs.  Packets sent from a guest with a VF to the address of a
> > guest without a VF need to be forwarded to the PF rather than the
> > physical port, but none of the drivers currently get to know about those
> > addresses.
> 
> To clarify, do you mean something like this?
> 
>        physical port
>              |
> +------------+------------+
> |         +-----+         |
> |         | VEB |         |
> |         +-----+         |
> |        /   |   \        |
> |       /    |    \       |
> |      /     |     \      |
> +-----+------+------+-----+
>       |      |       |
>      PF    VF 1    VF 2
>      /       |       |
>  +---+---+  VM4  +---+---+
>  |  sw   |       |macvtap|
>  | switch|       +---+---+
>  +-+-+-+-+           |
>    / | \            VM5
>   /  |  \
> VM1 VM2 VM3
> 
> This has VMs 1-3 hanging of the PF via a linux bridge (traditional hv
> switching), VM4 directly owning VF1 (pci device assignement), and VM5
> indirectly owning VF2 (macvtap passthrough, that started this whole
> thing).
> 
> So, I'm understanding you saying that VM4 or VM4 sending a packet to VM1
> goes in to VEB, out PF, and into linux bridging code, rigth?  At which
> point the PF is in promiscuous mode (btw, same does not work if bridge is
> attached to VF, at least for some VFs, due to lack of promiscuous mode).
> 
> > Packets sent from a guest with a VF to the address of another guest with
> > a VF need to be forwarded similarly, but the driver should be able to
> > infer that from (3).
> 
> Right, and that works currently for the case where both guests are like
> VM4, they directly own the VF via PCI device assignement.  But for VM4
> to talk to VM5, VF3 is not in promiscuous mode and has a different MAC
> address than VM5's vNIC.  If the embedded bridge does not learn, and
> nobody programmed it to fwd frames for VM5 via VF3...
> 
> I believe this is what Roopa's patch will allow.  The question now is
> whether there's a better way to handle this?
> 
> In my mind, we'd model the NIC's embedded bridge as, well, a bridge.
> And set anti-spoofing, port mirroring, port mac/vlan filtering, etc via
> that bridge.

If there was some way to push the bridge forwarding database down to the
underlying HW so that the filters could be programmed into the HW for
non-learning VEBs that would work too.

This hole has existed for a very long time, years now.  It'd be nice to get
it fixed.  If the community direction is to extend the current bridging
interface then that's fine, we'll go that way.

- Greg

