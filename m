From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 00/13]: Netfilter IPsec support
Date: Sun, 20 Nov 2005 17:31:28 +0100
Message-ID: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

This is the latest netfilter/IPsec patchset. Its purpose is to make
IPsec look as much as a normal tunnel device to netfilter as possible
and to enable NAT support.

It consists of basically five parts:

- output hooks:

Currently on the output path netfilter sees the plain text packet in
LOCAL_OUT and FORWARD and the encapsulated packet in POST_ROUTING.
For connection tracking and NAT the plain text packets need to be
visible on POST_ROUTING and the encapsulated packets on LOCAL_OUT as
well. The patchset adds two new functions, ip_dst_output and
ip6_dst_output that call the appropriate netfilter hooks for the
plain text packet before encapsulation and for the encapsulated
packets once for each tunnel mode transform.

- input hooks:

The input path is already mostly symetrical to the output path with
the new output hooks, except for one case, if the innermost transform
uses transport mode the decapsulated packets will not hit netfilter
again. New hooks are added to xfrm{4,6}_input to handle this case.
The hooks are only called if the _last_ transform is transport mode,
otherwise decapsulated transport mode packets are not visible to
netfilter.

- policy lookups after NAT:

When NAT changes a packet it already calls ip_route_me_harder, which
reroutes the packet and does a new policy lookup. It only looks at
the IP addresses however, changing the port numbers require a new
policy lookup as well. It also doesn't reroute in POST_ROUTING, since
the packet has already been routed. To behave more like a regular
tunnel device a policy lookup is now also done after SNAT and the
packet is passed to dst_output again if the lookup yielded a new
policy.

- policy checks after NAT:

Policy checks look up the policy of the decapsulated packet and check
that all decapsulations match what has been specified by the policy.
If the packet has been NATed before policy checks the policy lookup
might return a different policy from what was actually used. To handle
this a new function nf_nat_decode_session reconstructs a struct flowi
for the original packet which is then used for policy lookups.

- policy match:

To allow matching on the policy or the decapsulations done on the input
path a new match is added. It can be used to replace rules like
"-i ipsec0" or "-o ipsec0" which were commonly used with KLIPS, but can
also be used for more fine-grained filtering.


Changes this last post:

- updated to apply to latest kernel
- the defered fragmentation patch has been replaced by a new patch
  which moves the POST_ROUTING hook before fragmentation
- added missing EXPORT_SYMBOL(xfrm_decode_session) for IPv6
- moving nf_reset from ip_local_deliver_finish to the upper protocols
  has been split into a seperate patch, unnecessary nf_reset's on
  paths were the packet is dropped have been removed and a missing
  nf_reset before icmp_send in ip_local_deliver_finish has been added.


The patches are now in a state in which I think they could be merged in
the net-2.6.16 tree. Unfortunately cloning the tree fails for me, so
they are still based on Linus's tree, but I don't think there are any
changes in net-2.6.16 yet which conflict.

The patches are also available in a git-tree:

http://people.netfilter.org/kaber/nf-2.6-xfrm.git/


[NETFILTER]: Remove okfn usage in ip_vs_core.c
[NETFILTER]: Call POST_ROUTING hook before fragmentation
[IPV4]: Replace dst_output by ip_dst_output
[IPV6]: Replace dst_output by ip6_dst_output
[IPV4/6]: Netfilter IPsec output hooks
[IPV4/6]: Netfilter IPsec input hooks
[NETFILTER]: Fix xfrm lookup in ip_route_me_harder/ip6_route_me_harder
[NETFILTER]: Use conntrack information to determine if packet was NATed
[NETFILTER]: Redo policy lookups after NAT when neccessary
[NETFILTER]: Keep the conntrack reference until after policy checks
[NETFILTER]: Handle NAT in IPsec policy checks
[NETFILTER]: Export ip6_masked_addrcmp, don't pass IPv6 addresses on stack
[NETFILTER]: Add ipt_policy/ip6t_policy matches
