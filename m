From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: Re: [PATCH net v2] L2TP:Adjust intf MTU,factor underlay L3,overlay
 L2
Date: Tue, 27 Sep 2016 12:17:21 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1609271210350.25517@duvvury48.eng.vyatta.net>
References: <alpine.DEB.2.11.1609221341500.6975@duvvury30.eng.vyatta.net> <20160927.033153.1066118008027608891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: parameswaran.r7@gmail.com, kleptog@svana.org, jchapman@katalix.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        nprachan@brocade.com, rshearma@brocade.com, dfawcus@brocade.com,
        stephen@networkplumber.org, acme@redhat.com, lboccass@brocade.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160927.033153.1066118008027608891.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi David,

Thanks for the reply, please see inline:

On Tue, 27 Sep 2016, David Miller wrote:

> From: "R. Parameswaran" <parameswaran.r7@gmail.com>
> Date: Thu, 22 Sep 2016 13:52:43 -0700 (PDT)
> 
> > From ed585bdd6d3d2b3dec58d414f514cd764d89159d Mon Sep 17 00:00:00 2001
> > From: "R. Parameswaran" <rparames@brocade.com>
> > Date: Thu, 22 Sep 2016 13:19:25 -0700
> > Subject: [PATCH] L2TP:Adjust intf MTU,factor underlay L3,overlay L2
> > 
> > Take into account all of the tunnel encapsulation headers when setting
> > up the MTU on the L2TP logical interface device. Otherwise, packets
> > created by the applications on top of the L2TP layer are larger
> > than they ought to be, relative to the underlay MTU, leading to
> > needless fragmentation once the outer IP encap is added.
> > 
> > Specifically, take into account the (outer, underlay) IP header
> > imposed on the encapsulated L2TP packet, and the Layer 2 header
> > imposed on the inner IP packet prior to L2TP encapsulation.
> > 
> > Do not assume an Ethernet (non-jumbo) underlay. Use the PMTU mechanism
> > and the dst entry in the L2TP tunnel socket to directly pull up
> > the underlay MTU (as the baseline number on top of which the
> > encapsulation headers are factored in).  Fall back to Ethernet MTU
> > if this fails.
> > 
> > Signed-off-by: R. Parameswaran <rparames@brocade.com>
> > 
> > Reviewed-by: "N. Prachanda" <nprachan@brocade.com>,
> > Reviewed-by: "R. Shearman" <rshearma@brocade.com>,
> > Reviewed-by: "D. Fawcus" <dfawcus@brocade.com>
> 
> I have to ask, how do other tunnels over UDP such as VXLAN handle
> this problem?
> 

Specific to Vxlan, it appears to behave similarly.  I haven't functionally 
tested fragmentation on vxlan interfaces, but looking at the
code, it seems to account for the headers involved:


When the vxlan interface is created, from vxlan_dev_create(), in 
vxlan_setup(), it initially starts off with an ethernet MTU:

vxlan_setup(struct net_device *dev)
{
...
...
        ether_setup(dev); <<<<<<< Will set device MTU to 1500


Later, in vxlan_dev_configure(), called from vxlan_dev_create(), it gets 
adjusted to account for the headers:

vxlan_dev_configure():
...
 if (!conf->mtu)
                        dev->mtu = lowerdev->mtu - (use_ipv6 ? 
VXLAN6_HEADROOM : VXLAN_HEADROOM);


where VXLAN_HEADROOM is defined as follows: 

/* IP header + UDP + VXLAN + Ethernet header */
#define VXLAN_HEADROOM (20 + 8 + 8 + 14)
/* IPv6 header + UDP + VXLAN + Ethernet header */
#define VXLAN6_HEADROOM (40 + 8 + 8 + 14)


This seems to match what I see with hand config:

sudo ip link add vxlan0 type vxlan id 42 group 239.1.1.1 dev eth0 dstport 
4789 <<<< (eth0 has an MTU of 1500)


sudo ip -d link show vxlan0
36: vxlan0: <BROADCAST,MULTICAST> mtu 1450 qdisc noop state DOWN mode 
DEFAULT group default <<<< (1450 = 1500 -50)
    link/ether e2:b8:2d:f4:f7:ae brd ff:ff:ff:ff:ff:ff promiscuity 0
    vxlan id 42 group 239.1.1.1 dev eth0 srcport 32768 61000 dstport 4789 
ageing 300

thanks,

Ramkumar
