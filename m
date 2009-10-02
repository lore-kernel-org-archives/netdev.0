From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: Performance questions using bridge and macvlan
Date: Fri, 2 Oct 2009 14:11:52 -0700
Message-ID: <20091002211152.GA31316@ovro.caltech.edu>
References: <20091001212133.GD28963@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:57697 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbZJBVLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 17:11:49 -0400
Content-Disposition: inline
In-Reply-To: <20091001212133.GD28963@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 01, 2009 at 02:21:33PM -0700, Ira W. Snyder wrote:
> Hello all,
> 
> I've got an "interesting" network setup (using bridge), and I wonder if
> macvlan might help me get some more performance. Unfortunately, there
> isn't much documentation for macvlan, so I'm asking here.
> 
> I have a computer acting as an ethernet bridge. NIC A is on a network
> with a 1500 byte mtu. NIC B is a point-to-point ethernet device with a
> 64K mtu.
> 
> Adding both devices to a bridge using brctl works as expected. The
> computer attached to NIC B can send/recv normal ethernet traffic onto
> the outside network through NIC A.
> 
> Unfortunately, the bridge code does not fragment packets, and so the 64K
> mtu is reduced to a 1500 byte mtu. This kills performance by a factor of
> about 5x on the point-to-point device. All of my tests were using
> netperf/netserver running on the machine doing the bridging.
> 
> Without bridge, using full 64K mtu packets, netperf gives ~600mbit/sec.
> With brigde, using 1500 byte mtu packets, netperf gives ~120mbit/sec.
> 
> My question is this: is it possible to setup routing or macvlans such
> that any traffic from the bridge machine itself travels across the
> point-to-point link (at full 64K mtu), but any other traffic goes
> through the bridge (using 1500 byte mtu).
> 
> I'm aware that either running NAT or routing will fragment packets and
> solve my problem, but this introduces some complexity in my network
> setup that I would like to avoid.
> 

I have solved my problem using a veth pair device instead of macvlan. My
solution is described below to help anyone else who comes across this
problem.

eth0: physical ethernet, 1500 byte mtu
eth2: point-to-point ethernet, 65522 byte mtu
veth0, veth1: a veth pair device
br0, br1: ethernet bridges

# create the veth devices, increase mtu
ip link add link eth0 type veth
ip link set veth0 mtu 65522
ip link set veth1 mtu 65522

# create the bridges
brctl addbr br0
brctl addbr br1

# setup bridge 0
brctl addif br0 eth0
brctl addif br0 veth0

# setup bridge 1
brctl addif br1 eth2
brctl addif br1 veth1

# bring everything up
ip link set eth0 up
ip link set eth2 up
ip link set veth0 up
ip link set veth1 up
ip link set br0 up
ip link set br1 up

At this point, I use dhcpcd on the br0 interface to get an address. In
order for routing to work properly, I had to get an address for the br1
interface as well. Without an address for br1, everything was still
slow.

My routing table now looks like this:
[root@mybox ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
192.168.17.0    0.0.0.0         255.255.255.0   U     0      0        0 br1
192.168.17.0    0.0.0.0         255.255.255.0   U     204    0        0 br0
0.0.0.0         192.168.17.1    0.0.0.0         UG    204    0        0 br0

I'm curious if I could run dhcpcd on br1 and still have everything work
correctly. I think the answer is yes, but it will take more testing to
confirm this.

Ira
