From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge netfilter
Date: Thu,  5 Mar 2015 00:52:32 +0100
Message-ID: <1425513160-496-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org
To: <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bridge_netfilter.h contains various helpers, some only used by br_netfilter,
others however are also called in bridge or even ip stack.

Lets start untangling bridge, bridge netfilter, and the
rest of the ip stack (esp. ip_fragment).

This changes ip_fragment() so that bridge netfilter
can pass in the required information as arguments instead
of using skb->nf_bridge to pass some extra information to it.

Another problem with br_netfilter and the way its plumbed to
ip/ip6-tables (physdev match) is skb->nf_bridge.

nf_bridge is kmalloced blob with some extra information, including
the bridge in and outports (mainly for iptables' physdev match).
It also has various state bits so we know what manipulations
have been performed by bridge netfilter on the skb (e.g.
ppp header stripping).

nf_bridge also provides scratch space where br_netfilter saves
(and later restores) various things, e.g. ipv4 address for
dnat detection, mac address to fix up ip fragmented skbs, etc.

But in almost all cases we can avoid using ->data completely.

Tested, on host connected to kvm-bridge:
ping -s $bignum $ip_behind_bridge
-j REDIRECT
-j DNAT --to-destination $ip_behind_bridge

 include/linux/netfilter_bridge.h |   86 -------------------------
 include/linux/skbuff.h           |    2 
 include/net/ip.h                 |    8 +-
 net/bridge/br_device.c           |   27 +++++++-
 net/bridge/br_forward.c          |    4 -
 net/bridge/br_netfilter.c        |  131 ++++++++++++++++++++++++++++++---------
 net/ipv4/ip_output.c             |   47 ++++++++-----
 7 files changed, 161 insertions(+), 144 deletions(-)

