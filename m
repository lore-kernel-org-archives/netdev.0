From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Thu, 09 Feb 2012 16:39:09 -0800
Message-ID: <1328834349.14661.3.camel@oc1677441337.ibm.com>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
	 <1328811287.19664.9.camel@oc1677441337.ibm.com>
	 <4F342CEC.8080104@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com,
	shemminger@vyatta.com, kvm@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4F342CEC.8080104@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-02-09 at 12:30 -0800, John Fastabend wrote:
> On 2/9/2012 10:14 AM, Sridhar Samudrala wrote:
> > On Wed, 2012-02-08 at 19:22 -0800, John Fastabend wrote:
> >> Propagate software FDB table into hardware uc, mc lists when
> >> the NETIF_F_HW_FDB is set.
> >>
> >> This resolves the case below where an embedded switch is used
> >> in hardware to do inter-VF or VF-PF switching. This patch
> >> pushes the FDB entry (specifically the MAC address) into the
> >> embedded switch with dev_add_uc and dev_add_mc so the switch
> >> "learns" about the software bridge.
> >>
> >>
> >>           veth0  veth2
> >>             |      |
> >>           ------------
> >>           |  bridge0 |   <---- software bridging
> >>           ------------
> >>                /
> >>                /
> >>   ethx.y      ethx
> >>     VF         PF
> >>      \         \          <---- propagate FDB entries to HW
> >>      \         \
> >>   --------------------
> >>   |  Embedded Bridge |    <---- hardware offloaded switching
> >>   --------------------
> >>
> > 
> > This scenario works now as adding an interface to a bridge puts it in
> > promiscuous mode. So adding a PF to a software bridge should not be
> > a problem as it supports promiscuous mode. But adding a VF will not
> > work.
> 
> It shouldn't work because the embedded bridge will lookup the address
> in its FDB and when it doesn't match any unicast filters it will forward
> the packet onto the wire. Because the veth0 and veth2 above never get
> inserted into the embedded brdige's FDB the packets will _never_ get
> routed there.
> 
> That said the current 'ixgbe' driver is doing something broken in that
> it is always setting the unicast hash table and mirroring bits to 1. So
> if you think this is working your seeing a bug where packets are being
> sent onto the wire AND upto the PF. Packets with destination addresses
> matching veth1 should not end up on the wire and vice versa. This is
> specific to ixgbe and is not the case for other SR-IOV devices.

OK. Is this behavior going to be fixed.

> 
> This causes some issues (a) has some very real performance implications,
> (b) at this point you have some strange behavior from my point of view.
> The embedded bridge is not a learning bridge nor is it acting like an
> 802.1Q VEB or VEPA.
> 
> > 
> > Are you trying to avoid the requirement of having to put the interface 
> > in promiscuous mode when adding to a bridge?
> > 
> 
> I think the bridge being in promiscuous mode is correct.

The interface that is added to the bridge is put in promiscuous mode,
not the bridge itself.  In this example, i assumed that setting
promiscuous on PF is putting the embedded bridge in learning mode.

Thanks
Sridhar

> 
> Hope that helps sorry its a bit long winded.
> John
> 
> 
> 


