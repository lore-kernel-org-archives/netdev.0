From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] netfilter/ipvs fixes for net
Date: Fri, 31 Oct 2014 13:18:26 +0100
Message-ID: <1414757912-29150-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains fixes for netfilter/ipvs. This round of
fixes is larger than usual at this stage, specifically because of the
nf_tables bridge reject fixes that I would like to see in 3.18. The
patches are:

1) Fix a null-pointer dereference that may occur when logging
   errors. This problem was introduced by 4a4739d56b0 ("ipvs: Pull
   out crosses_local_route_boundary logic") in v3.17-rc5.

2) Update hook mask in nft_reject_bridge so we can also filter out
   packets from there. This fixes 36d2af5 ("netfilter: nf_tables: allow
   to filter from prerouting and postrouting"), which needs this chunk
   to work.

3) Two patches to refactor common code to forge the IPv4 and IPv6
   reject packets from the bridge. These are required by the nf_tables
   reject bridge fix.

4) Fix nft_reject_bridge by avoiding the use of the IP stack to reject
   packets from the bridge. The idea is to forge the reject packets and
   inject them to the original port via br_deliver() which is now
   exported for that purpose.

5) Restrict nft_reject_bridge to bridge prerouting and input hooks.
   the original skbuff may cloned after prerouting when the bridge stack
   needs to flood it to several bridge ports, it is too late to reject
   the traffic.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 7965ee93719921ea5978f331da653dfa2d7b99f5:

  netfilter: nft_compat: fix wrong target lookup in nft_target_select_ops() (2014-10-27 22:17:46 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 127917c29a432c3b798e014a1714e9c1af0f87fe:

  netfilter: nft_reject_bridge: restrict reject to prerouting and input (2014-10-31 12:50:09 +0100)

----------------------------------------------------------------
Alex Gartrell (1):
      ipvs: Avoid null-pointer deref in debug code

Pablo Neira Ayuso (5):
      netfilter: nf_tables_bridge: update hook_mask to allow {pre,post}routing
      netfilter: nf_reject_ipv4: split nf_send_reset() in smaller functions
      netfilter: nf_reject_ipv6: split nf_send_reset6() in smaller functions
      netfilter: nft_reject_bridge: don't use IP stack to reject traffic
      netfilter: nft_reject_bridge: restrict reject to prerouting and input

 include/net/netfilter/ipv4/nf_reject.h   |   10 +
 include/net/netfilter/ipv6/nf_reject.h   |   10 +
 net/bridge/br_forward.c		  |    1 +
 net/bridge/netfilter/nf_tables_bridge.c  |    6 +-
 net/bridge/netfilter/nft_reject_bridge.c |  296 ++++++++++++++++++++++++++++--
 net/ipv4/netfilter/nf_reject_ipv4.c	  |   88 ++++++---
 net/ipv6/netfilter/nf_reject_ipv6.c	  |  175 +++++++++++-------
 net/netfilter/ipvs/ip_vs_xmit.c	  |    4 +-
 8 files changed, 483 insertions(+), 107 deletions(-)
