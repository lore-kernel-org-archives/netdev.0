From: Bill Fink <billfink@mindspring.com>
Subject: Re: vnet problem (bug? feature?)
Date: Mon, 16 Feb 2015 16:51:04 -0500
Message-ID: <20150216165104.52804f0df58251fa0196fc38@mindspring.com>
References: <20150213114113.GA10559@faui40p.informatik.uni-erlangen.de>
	<CAHA+R7NUojPsLY9LOC94S0uussbwKsGRdcbazNmGGLbXvxCk-A@mail.gmail.com>
	<20150214101547.GA9335@faui40p.informatik.uni-erlangen.de>
	<20150214131744.051b90fc8dfdbf4e1bfe6bfb@mindspring.com>
	<20150215190008.GA25792@faui40p.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>, netdev <netdev@vger.kernel.org>
To: Toerless Eckert <tte@cs.fau.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:40850 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751158AbbBPVvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 16:51:09 -0500
In-Reply-To: <20150215190008.GA25792@faui40p.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 Feb 2015, Toerless Eckert wrote:

> *Bingo* rp_filter did the trick.
> 
> nstat is fairly useless to figrue this out, no RPF counters.

In theory, I believe it should show up:

wizard% nstat -az | grep IPReversePathFilter
TcpExtIPReversePathFilter       0                  0.0

Strange it shows up under TcpExt rather than IpExt.

The Linux MIB counter is LINUX_MIB_IPRPFILTER, set in
ip_rcv_finish().

The initial commit by Eric Dumazet introducing LINUX_MIB_IPRPFILTER
indicated it was only tested for unicast, so perhaps there could
be an issue with multicast reception in some cases, but if not
you should see that MIB counter increasing when you run your tests.

					-Bill



> Quite strange to see rp_filter. Especilly for multicast. But i haven't
> followed linux for many years in this level of detail. I thought
> Linux was always weak host model. But even for strong host model,
> i can't remember that RPF checking was done in the past (for hosts,
> not routers obviously).
> 
> Cheers
>      Toerless
> 
> On Sat, Feb 14, 2015 at 01:17:44PM -0500, Bill Fink wrote:
> > > ip link add name veth1 type veth peer name veth2
> > > ip addr add 10.0.0.1/24 dev veth1
> > > ip addr add 10.0.0.2/24 dev veth2
> > > ip link set dev veth1 up
> > > ip link set dev veth2 up
> > 
> > Did you try disabling reverse path filtering:
> > 
> > echo 0 > /proc/sys/net/ipv4/conf/veth1/rp_filter
> > echo 0 > /proc/sys/net/ipv4/conf/veth2/rp_filter
> > 
> > Both veth1 and veth2 are in the same subnet, but only one
> > (presumably veth1) is the expected source for packets coming
> > from net 10, so when the muticast packets from a net 10
> > source arrive on veth2, they are rejected for arriving
> > on the wrong interface.
> > 
> > You could check this with "nstat -z | grep -i filter".
> > 
> > The above is an educated guess on my part, and could
> > be something completely different.
> > 
> > 					-Bill
> > 
> > 
> > 
> > > Receiver socket, eg: on veth2:
> > >    socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
> > >    setsockopt(SO_REUSEADDR, 1)
> > >    bind(0.0.0.0/<port>)
> > >    setsockopt(IP_ADD_MEMBERSHIP, 224.0.0.33/10.0.0.2)
> > > 
> > >    check wih "netstat -gn" that there is IGMP membership on veth2:
> > >    veth2           1      224.0.0.33
> > > 
> > > Sender socket, eg: on veth1:
> > >    socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
> > >    setsockopt(SO_REUSEADDR, 1)
> > >    bind(10.0.0.1/7000)
> > >    connect(224.0.0.33/<port>)
> > > 
> > > Sending packet, check how they're transmitted:
> > >    - TX countes on veth1 go up (ifconfig output)
> > >    - RX counters on veth2 go up (ifconfig output)
> > >    - tcpdump -i veth2 -P in shows packets being received
> > >    - tcpdump -i veth1 -P out shows packets being sent
> > > 
> > > Played around with lots of parameters:
> > >    - same behavior for non-link-local-scope multicast, TTL > 1 doesn't elp.
> > >    - same behavior if setting "multicast, "allmulticast", "promiscuous" on the veth
> > >    - same behavior when setting IP_MULTICAST_LOOP on sender.
> > > 
> > > Routing table:
> > > netstat -r -n
> > > Kernel IP routing table
> > > Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
> > > 0.0.0.0         192.168.1.254   0.0.0.0         UG        0 0          0 eth1
> > > 10.0.0.0        0.0.0.0         255.255.255.0   U         0 0          0 veth1
> > > 10.0.0.0        0.0.0.0         255.255.255.0   U         0 0          0 veth2
> > > 192.168.1.0     0.0.0.0         255.255.255.0   U         0 0          0 eth1
> > > 
> > > And of course it works if one side is put into a separate namespace,
> > > but that doesn't help me.
> > > 
> > > But: it really seems to be a problem with the kernel/sockets, not with veth.
> > > Just replaced the veth pair with a pair of ethernets with a loopback cable and
> > > pretty much exactly the same result (except that receiver side does not see
> > > packets in RX unless it's promiscuous or has a real receiver socket, but that's
> > > perfect). But not being a veth problem but other kernel network stack "feature"
> > > doesn't make it right IMHO. I can't see by which "logic" the receiver socket
> > > seemingly does not care about these packets even though it's explicitly bound
> > > to the interface and the multicast group. "Gimme the darn packets, socket,
> > > they are received on the interface"! ;-))
> > > 
> > > I can play around with the receiver side socket API call details, but i really
> > > don't see why those should be different if the packets happen to be looped
> > > than if they're not.
> > > 
> > > Cheers
> > >     Toerless
