From: Patrick McHardy <kaber@trash.net>
Subject: Re: Problem with GVRP on eth while having a bridge
Date: Thu, 7 Feb 2013 14:02:30 +0100
Message-ID: <20130207130227.GF13989@macbook.localnet>
References: <51138866.8000802@profihost.ag>
 <20130207112227.GE13989@macbook.localnet>
 <511396C9.2080106@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexandre DERUMIER <aderumier@odiso.com>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <511396C9.2080106@profihost.ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 07, 2013 at 12:58:01PM +0100, Stefan Priebe - Profihost AG wrote:
> Hi Patrick,
> 
> thanks for your fast response.
> 
> > So please describe the entire GVRP message exchange that's going
> > on.
> I've attached two small pcap files.
> 
> has_bridge.pcap: is where eth1 has a bridge and the dynamic vlan
> disappears after a few seconds.
> 
> no_bridge.pcap: no bridge is assigned to eth1 - the dynamic vlan stays
> as long as i remove it
> 
> > Also you probably want to add the VLAN device on top of the bridge
> > device, otherwise it will get passed to the bridge after untagging,
> > which might not work, depending on the MAC addresses used.
> 
> That's working fine in vanilla kernel 3.7.6 but it does not with RHEL 6.
> Also i looks more complicated as i need another bridge on top of the
> vlan to assign the needed tap devices. I looked at ovirt for the network
> setup:
> http://www.ovirt.org/Vdsm_Network
> 
> and they also add the vlan directly on top of the nic and then the
> bridge on top of the VLANs.

What seems to be happening is that the switch is constantly requesting
GVRP updates. Once eth0 is added to the bridge, the bridge has preference
over local protocol (LLC) delivery. Since the packet has a link local
destination and your bridge doesn't seem to have STP enabled, the
bridge decides to forward the packet. Since its a multicast destination,
the packet is finally passed up to LLC, but the receiving device is
the bridge, not eth0. When the packet reaches the GARP input handler,
no garp_port is associated to the device and the packet is dropped.
This result is that the GARP protocol doesn't notice that the switch
expects an update and the switch finally removes the VLAN.

So the solution is: put the VLAN on the bridge device.
