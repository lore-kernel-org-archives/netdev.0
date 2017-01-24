From: Rajasekar Kumar <sekraj@gmail.com>
Subject: Re: [RFC] net: ipv6: return the first matched rt6_info for multicast
 packets in find_rr_leaf()
Date: Tue, 24 Jan 2017 21:40:03 +0530
Message-ID: <20170124161002.snor2aolycnjlvag@extreme-Latitude-E4310>
References: <20170118151337.mcub5vyjszy5ltyn@extreme-Latitude-E4310>
 <20170120.115804.2161107773230365505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170120.115804.2161107773230365505.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 20, 2017 at 11:58:04AM -0500, David Miller wrote:
> From: Rajasekar Kumar <sekraj@gmail.com>
> Date: Wed, 18 Jan 2017 20:43:37 +0530
> 
> > There is a performance issue when large number of interfaces are
> > enabled with VRRP protocol in 2 router nodes which are connected
> > to each other. When VRRP hello is received (which is multicast
> > packet with DIP: ff02::18), a rt6_info node is added to fib6_node
> >  of address ff02::18. This happens for each interface on which
> > VRRP is enabled. For 2000 interfaces with VRRP enabled, 2000
> > rt6_info nodes are added to the same fib6_node. As of today,
> > find_rr_leaf() goes further to find better match, even after first
> > successful match based on interface key. In this case, it walks
> > 2000 nodes for every incoming packet/outgoing packet, which is
> > expensive and not needed. rt6_info match based on supplied
> > interface match should be sufficient. The first match occurs
> > when there is interface match, and after that there can not be
> > another match for multicast packets. So, first match should be
> > returned for multicast packets.
> > 
> > find_rr_leaf() tries to find best available gateway, mainly based on
> > interface match and gateway's reachablity info.When this is required
> > for unicast packets, multicast packets do not need either gateway's
> > reachability status or gateway's Layer2 address as it is derived
> > from Destination IP (group address). rt6_info match based on supplied
> > interface match should be sufficient.
> > 
> > This fix helps in scenario wherein multicast packets arrive in some
> > interfaces frequently than other interfaces. rt6_info is added to
> > beginning of list for former cases. Verified this case.
> > 
> > Signed-off-by: Rajasekar Kumar <sekraj@gmail.com>
> 
> So the only thing different in each rt6_info in the list is the
> interface, right?
> 
> Well, that's a part of the lookup key, multicast or not.  If the user
> binds a socket to a specific interface, they want the route lookup to
> return the rt6_info node with that device.
> 
> So I think your change introduces a regression, therefore another
> solution will need to be found for your performance problem.

Thanks for the review. Below are my thoughts.
The meaningful difference between rt6_infos is interface,
which is true for multicast. For unicast routes, nexthop's
reachability status, route's preference values also are important.
For unicast destinations, there will not be so many rt6_info's
for the same prefix even with multipath support, unlike multicast
case described above. In general for unicast routes, finding better
route/nexthop match involves gateway's reachability status, route's
preference values, in addition to interface match. This code is
present already. Also, it does not look like, IPv4 implementation
does any specific check for bind-to-device case in the area of
route lookup, but it does interface match like anyother case by
walking all nexthops in fib_info within check_leaf(). So, I am
not sure, if a fix is needed right now for non-multicast.

Comparing with IPv4 implementation with respect to IP packet
reception/transmission, multicast was handled specially in multiple
occurrences. This fix attempted to do something similar. If any
specific problem identified for non-multicast, can be addressed in
future. Please post your thoughts.

Sorry, I didnot understand your comment regarding regression. 
Is the fix already creating regression issue?
