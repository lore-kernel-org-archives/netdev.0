From: Hans Schillstrom <hans@schillstrom.com>
Subject: [v4 PATCH 0/2] NETFILTER new target module, HMARK
Date: Fri, 25 Nov 2011 10:36:25 +0100
Message-ID: <1322213787-25796-1-git-send-email-hans@schillstrom.com>
Cc: hans.schillstrom@ericsson.com
To: kaber@trash.net, pablo@netfilter.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

The target allows you to create rules in the "raw" and "mangle" tables
which alter the netfilter mark (nfmark) field within a given range.
First a 32 bit hash value is generated then modulus by <limit> and
finally an offset is added before it's written to nfmark.
Prior to routing, the nfmark can influence the routing method (see
"Use netfilter MARK value as routing key") and can also be used by
other subsystems to change their behavior.

The mark match can also be used to match nfmark produced by this module.
See the kernel module for more info.

REVISION
Version 4
	Split of IPv6 and IPv4, use IP_CT_IS_REPLY, as Pablo suggested.
	removed one pskb_may_pull()
	xtoption parse used in the user space part.

Version 3
        Handling of SCTP for IPv6 added.

Version 2
	NAT Added for IPv4
	IPv6 ICMP handling enhanced.
	Usage example added

Version 1
	Initial RFC


We (Ericsson) use hmark in-front of ipvs as a pre-loadbalancer and
handles up to 70 ipvs running in parallel in clusters.
However hmark is not restricted to run in front of IPVS it can also be used as
"poor mans" load balancer.
With this version is also NAT supported as an option, with very high flows
you might not want to use conntrack.

The idea is to generate a direction independent fw mark range to use as input to
the routing (i.e. ip rule add fwmark ...).
Pretty straight forward and simple.


Example:
                                      App Server (Real Server)

                                           +---------+
                                        -->| Service |
     Gateway A                             +---------+
                          /
            +----------+ /     +----+      +---------+
--- if -A---| selector |---->  |ipvs|  --->| Service |
            +----------+ \     +----+      +---------+
                          \
                               +----+      +---------+
                               |ipvs|   -->| Service |
                               +----+      +---------+
      Gateway C
            +----------+ /     +----+
--- if-B ---| selector | --->  |ipvs|
            +----------+ \     +----+      +---------+
                                           | Service |
                                           +---------+
                          /
            +----------+ /     +----+     ..
--- if-B ---| selector | --->  |ipvs|      +---------+
            +----------+ \     +----+      | Service |
                          \                +---------+
#
# Example with four ipvs loadbalancers
#
iptables -t mangle -I PREROUTING -d $IPADDR -j HMARK --hmark-mod 4 --hmark-offs 100

ip rule add fwmark 100 table 100
ip rule add fwmark 101 table 101
ip rule add fwmark 102 table 102
ip rule add fwmark 103 table 103

ip ro ad table 100 default via x.y.z.1 dev bond1
ip ro ad table 101 default via x.y.z.2 dev bond1
ip ro ad table 102 default via x.y.z.3 dev bond1
ip ro ad table 103 default via x.y.z.4 dev bond1


If conntrack doesn't handle the return path,
do the oposite with HMARK and send it back right to ipvs.

Another exmaple of usage could be if you have cluster originated connections
and want to spread the connections over a number of interfaces
(NAT will complpicate things for you in this case)



                     \  Blade 1
                      \ +----------+      +---------+
                    <-- | selector | <--- | Service |
                      / +----------+      +---------+
                     /
   +------+
-- | Gw-A |          \  Blade 2
   +------+           \ +----------+      +---------+
   +------+         <-- | selector | <--- | Service |
-- | Gw-B |           / +----------+      +---------+
   +------+          /
   +------+
-- | Gw-C |          \
   +------+           \ +----------+      +---------+
                    <-- | selector | <--- | Service |
                      / +----------+      +---------+
                     /

                     \  Blande -n
                      \ +----------+      +---------+
                    <-- | selector | <--- | Service |
                      / +----------+      +---------+
                     /

Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>

