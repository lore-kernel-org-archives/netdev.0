From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [RFC net-next 3/3] rcv path changes for vrf traffic
Date: Mon, 08 Jun 2015 22:00:54 +0200
Message-ID: <1433793654.4616.5.camel@redhat.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
	 <87eae7a7a03708bda5560a5ea43b0fcac705c80d.1433561681.git.shm@cumulusnetworks.com>
	 <1433793517.4616.4.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, dsahern@gmail.com,
	ebiederm@xmission.com, hadi@mojatatu.com, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178AbbFHUBB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2015 16:01:01 -0400
In-Reply-To: <1433793517.4616.4.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2015-06-08 at 21:58 +0200, Hannes Frederic Sowa wrote:
> Hi Shrijeet,
> 
> On Mo, 2015-06-08 at 11:35 -0700, Shrijeet Mukherjee wrote:
> > From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
> > 
> > Incoming frames for IP protocol stacks need the IIF to be changed
> > from the actual interface to the VRF device. This allows the IIF
> > rule to be used to select tables (or do regular PBR)
> > 
> > This change selects the iif to be the VRF device if it exists and
> > the incoming iif is enslaved to the VRF device.
> > 
> > Since VRF aware sockets are always bound to the VRF device this
> > system allows return traffic to find the socket of origin.
> > 
> > changes are in the arp_rcv, icmp_rcv and ip_rcv paths
> > 
> > Question : I did not wrap the rcv modifications, in CONFIG_NET_VRF
> > as it would create code variations and the vrf_ptr check is there
> > I can make that whole thing modular.
> 
> From an architectural level I think the output path looks good. For 
> the
> input path I would also to propose my (I think) more flexible 
> solution:
> 
> For rx layer I want to also propose my try:
> 
> [PATCH net-next RFC] net: ipv4: arp: strong end system model 
> semantics by per-interface local table override
> 
> By allowing to direct routing table lookups to a specific table based
> on the incoming interface for IPv4 and ARP, we start to behave like a
> strong end host system without tweaking arp_* sysctl settings.
> 
> The main motivation behind this patch was input and forwarding 
> support
> in a VRF like model. Maybe it also helps for hardware offloading by
> allowing reducing rule complexity.
> 
> An example:
> 
> $ ip rule flush
> $ ip rule del
> $ ip rule del
> $ ip rule add inherit-table
> 0:      from all inherit-table
> 
> This by default still uses RT_TABLE_LOCAL until we set up per 
> interface
> route tables:
> 
> $ ip link set dev enp0s25 ipv4-rt-table-id 100
> $ ip -d link ls dev enp0s25
> 2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel 
> state UP mode DEFAULT group default qlen 1000
>     link/ether e4:7f:b2:1b:4c:61 brd ff:ff:ff:ff:ff:ff promiscuity 0 
> ipv4-rt-table-id 100 addrgenmode none
> 
> This let's incoming and arp requests use routing table 100. The 
> system
> will stop responding to arp requests as we don't have any entries in
> this routing table.
> 
> $ ip address add 192.168.88.223/24 dev enp0s25 table 100
> $ ip -d address ls
> 2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel 
> state UP group default qlen 1000
>     link/ether e4:7f:b2:1b:4c:61 brd ff:ff:ff:ff:ff:ff promiscuity 0
>     inet 192.168.88.223/24 scope global enp0s25 table 100
>        valid_lft forever preferred_lft forever
> $ ip route add 192.168.88.0/24 dev enp0s25 table 100
> $ ip route add default via 192.168.88.1 table 100
> $ ip route ls dev table 100
> local 192.168.88.223 dev enp0s25  proto kernel  scope host  src 
> 192.168.88.223
> 192.168.88.0/24 dev enp0s25  scope link
> default via 192.168.88.1 dev enp0s25 proto static metric 600
> 
> Those changes direct arp lookups towards table 100 and the input 
> route,
> too. The local address is used for icmp source addresses and arp
> replies. The connected route to steer icmp packets out of that 
> interface.
> 
> This patch covers only the forwarding path.

The iproute2 patch is currently here:

https://github.com/hannes/iproute2/commits/vrf

Bye,
Hannes
