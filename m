From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v3 PATCH 0/2] NETFILTER new target module, HMARK
Date: Thu, 20 Oct 2011 10:54:11 +0200
Message-ID: <20111020085411.GA19050@1984>
References: <1318532530-29446-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans@schillstrom.com
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1318532530-29446-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hans,

On Thu, Oct 13, 2011 at 09:02:08PM +0200, Hans Schillstrom wrote:
> The target allows you to create rules in the "raw" and "mangle" tables
> which alter the netfilter mark (nfmark) field within a given range.
> First a 32 bit hash value is generated then modulus by <limit> and
> finally an offset is added before it's written to nfmark.
> Prior to routing, the nfmark can influence the routing method (see
> "Use netfilter MARK value as routing key") and can also be used by
> other subsystems to change their behaviour.
> 
> The mark match can also be used to match nfmark produced by this module.
> See the kernel module for more info.
> 
> REVISION
> Version 3
>         Handling of SCTP for IPv6 added.
> 
> Version 2
> 	NAT Added for IPv4
> 	IPv6 ICMP handling enhanced.
> 	Usage example added
> 
> Version 1
> 	Initial RFC
> 
> 
> We (Ericsson) use hmark in-front of ipvs as a pre-loadbalancer and
> handles up to 70 ipvs running in parallel in clusters.
> However hmark is not restricted to run infront of IPVS it can also be used as
> "poor mans" load balancer.
> With this version is also NAT supported as an option, with very high flows
> you might not want to use conntrack.
> 
> The idea is to generate a direction independent fw mark range to use as input to
> the routing (i.e. ip rule add fwmark ...).
> Pretty straight forward and simple.
> 
> 
> Example:
>                                       App Server (Real Server)
> 
>                                            +---------+
>                                         -->| Service |
>      Gateway A                             +---------+
>                           /
>             +----------+ /     +----+      +---------+
> --- if -A---| selector |---->  |ipvs|  --->| Service |
>             +----------+ \     +----+      +---------+
>                           \
>                                +----+      +---------+
>                                |ipvs|   -->| Service |
>                                +----+      +---------+
>       Gateway C
>             +----------+ /     +----+
> --- if-B ---| selector | --->  |ipvs|
>             +----------+ \     +----+      +---------+
>                                            | Service |
>                                            +---------+
>                           /
>             +----------+ /     +----+     ..
> --- if-B ---| selector | --->  |ipvs|      +---------+
>             +----------+ \     +----+      | Service |
>                           \                +---------+
> #
> # Example with four ipvs loadbalancers
> #
> iptables -t mangle -I PREROUTING -d $IPADDR -j HMARK --hmark-mod 4 --hmark-offs 100

I think you can replace this rule by:

iptables -t mangle -I PREROUTING -d $IPADDR -m cluster \
        --cluster-total-nodes 4 --cluster-local-node 1
        --cluster-hash-seed 0xdeadbeef -j MARK --set-mark 100
iptables -t mangle -I PREROUTING -d $IPADDR -m cluster \
        --cluster-total-nodes 4 --cluster-local-node 2
        --cluster-hash-seed 0xdeadbeef -j MARK --set-mark 101
iptables -t mangle -I PREROUTING -d $IPADDR -m cluster \
        --cluster-total-nodes 4 --cluster-local-node 3
        --cluster-hash-seed 0xdeadbeef -j MARK --set-mark 103
iptables -t mangle -I PREROUTING -d $IPADDR -m cluster \
        --cluster-total-nodes 4 --cluster-local-node 4
        --cluster-hash-seed 0xdeadbeef -j MARK --set-mark 104

The hashing is done by the cluster match, which is currently based on
the source address.

This match currently depends on the connection tracking system, so you
could save the ctmark with CONNMARK. Thus, you only has to hash the
first packet of the flow, instead of hashing every single packet.

> ip rule add fwmark 100 table 100
> ip rule add fwmark 101 table 101
> ip rule add fwmark 102 table 102
> ip rule add fwmark 103 table 103
> 
> ip ro ad table 100 default via x.y.z.1 dev bond1
> ip ro ad table 101 default via x.y.z.2 dev bond1
> ip ro ad table 102 default via x.y.z.3 dev bond1
> ip ro ad table 103 default via x.y.z.4 dev bond1
>
> If conntrack doesn't handle the return path,
> do the oposite with HMARK and send it back right to ipvs.
> 
> Another exmaple of usage could be if you have cluster originated connections
> and want to spread the connections over a number of interfaces
> (NAT will complpicate things for you in this case)
> 
> 
> 
>                      \  Blade 1
>                       \ +----------+      +---------+
>                     <-- | selector | <--- | Service |
>                       / +----------+      +---------+
>                      /
>    +------+
> -- | Gw-A |          \  Blade 2
>    +------+           \ +----------+      +---------+
>    +------+         <-- | selector | <--- | Service |
> -- | Gw-B |           / +----------+      +---------+
>    +------+          /
>    +------+
> -- | Gw-C |          \
>    +------+           \ +----------+      +---------+
>                     <-- | selector | <--- | Service |
>                       / +----------+      +---------+
>                      /
> 
>                      \  Blande -n
>                       \ +----------+      +---------+
>                     <-- | selector | <--- | Service |
>                       / +----------+      +---------+
>                      /

Unless I'm missing something, I think this can be done with the
cluster match as well.
