From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: Re: [PATCH net v2] L2TP:Adjust intf MTU,factor underlay L3,overlay
 L2
Date: Wed, 28 Sep 2016 19:36:45 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1609281857050.17015@duvvury48.eng.vyatta.net>
References: <alpine.DEB.2.11.1609221341500.6975@duvvury30.eng.vyatta.net> <20160927.033153.1066118008027608891.davem@davemloft.net> <alpine.DEB.2.11.1609271210350.25517@duvvury48.eng.vyatta.net> <20160928.034841.997752666320557327.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: parameswaran.r7@gmail.com, kleptog@svana.org, jchapman@katalix.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        nprachan@brocade.com, rshearma@brocade.com, dfawcus@brocade.com,
        stephen@networkplumber.org, acme@redhat.com, lboccass@brocade.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160928.034841.997752666320557327.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Hi David,

Please see inline:

On Wed, 28 Sep 2016, David Miller wrote:

> From: "R. Parameswaran" <parameswaran.r7@gmail.com>
> Date: Tue, 27 Sep 2016 12:17:21 -0700 (PDT)
> 
> > Later, in vxlan_dev_configure(), called from vxlan_dev_create(), it gets 
> > adjusted to account for the headers:
> > 
> > vxlan_dev_configure():
> > ...
> >  if (!conf->mtu)
> >                         dev->mtu = lowerdev->mtu - (use_ipv6 ? 
> > VXLAN6_HEADROOM : VXLAN_HEADROOM);
> > 
> > 
> > where VXLAN_HEADROOM is defined as follows: 
> > 
> > /* IP header + UDP + VXLAN + Ethernet header */
> > #define VXLAN_HEADROOM (20 + 8 + 8 + 14)
> > /* IPv6 header + UDP + VXLAN + Ethernet header */
> > #define VXLAN6_HEADROOM (40 + 8 + 8 + 14)
> 
> Right but I don't see it going through the effort to make use of the
> PMTU like you are.
> 
> I have another strong concern related to this.  There seems to be no
> mechanism used to propagate any PMTU events into the device's MTU.
> 
> Because if there is a limiting nexthop in the route to the other end
> of the UDP tunnel, you won't learn the PMTU until you (or some other
> entity on the machine) actually starts sending traffic to the tunnel's
> endpoint.
> 
> If the PMTU events aren't propagated into the tunnel's MTU or similar
> I think this is an ad-hoc solution.
> 
> I would suggest that you either:
> 
> 1) Do what VXLAN appears to do an ignore the PMTu
> 

I'd like to point out one difference with VXLAN - in VXLAN, the 
local physical interface is directly specified at the time of 
creation of the tunnel, and the data structure seems to have the ifindex 
of the local interface with which it is able to directly pull up the 
underlay interface device. Whereas in L2TP, we only have the IP
address of the remote tunnel end-point and thus only the socket and the 
dst from which we need to derive this. 

Also, dst_mtu references dst->ops->mtu, which if I followed the pointer
chain correctly, will dereference to ipv4_mtu() (for the IPv4 case, as
an example). The code in ipv4_mtu looks like the following:

ipv4_mtu():

        unsigned int mtu = rt->rt_pmtu;

        if (!mtu || time_after_eq(jiffies, rt->dst.expires))
                mtu = dst_metric_raw(dst, RTAX_MTU);

        if (mtu)
                return mtu;

        mtu = dst->dev->mtu;

        if (unlikely(dst_metric_locked(dst, RTAX_MTU))) {
                if (rt->rt_uses_gateway && mtu > 576)
                        mtu = 576;
        }

        return min_t(unsigned int, mtu, IP_MAX_MTU);

The code above does not depend on PMTU to be working. If no PMTU 
discovered MTU exists, it eventually falls back to the local 
underlay device MTU - and this is the mode in which I tested the fix - PMTU 
was off in my testbed, but it was picking up the local device MTU correctly.

Basically, this looks better than the VXLAN handling as far as I can 
tell - at least it will pick up the existing discovered PMTU on a best 
effort basis, while falling back to the underlay device if all else fails. 

I agree that something like 2. below would be needed in the long run (it 
will need some effort and redesign -e.g. how do I lookup the parent tunnel 
from the socket when receiving a PMTU update, existing pointer chain runs 
from tunnel to socket).  

But since the existing (Ethernet over L2TP) MTU derivation is incorrect, I am 
hoping this may be acceptable as an interim solution. 

thanks,

Ramkumar


> 2) Add code to handle PMTU events that land on the UDP tunnel
>    socket.
> 
> Thanks.
> 
