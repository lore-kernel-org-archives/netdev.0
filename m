From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/18] Netfilter/IPVS/OVS updates for net-next
Date: Tue, 15 Mar 2016 02:27:44 +0100
Message-ID: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter/IPVS fixes and OVS NAT
support, more specifically this batch is composed of:

1) Fix a crash in ipset when performing a parallel flush/dump with
   set:list type, from Jozsef Kadlecsik.

2) Make sure NFACCT_FILTER_* netlink attributes are in place before
   accessing them, from Phil Turnbull.

3) Check return error code from ip_vs_fill_iph_skb_off() in IPVS SIP
   helper, from Arnd Bergmann.

4) Add workaround to IPVS to reschedule existing connections to new
   destination server by dropping the packet and wait for retransmission
   of TCP syn packet, from Julian Anastasov.

5) Allow connection rescheduling in IPVS when in CLOSE state, also
   from Julian.

6) Fix wrong offset of SIP Call-ID in IPVS helper, from Marco Angaroni.

7) Validate IPSET_ATTR_ETHER netlink attribute length, from Jozsef.

8) Check match/targetinfo netlink attribute size in nft_compat,
   patch from Florian Westphal.

9) Check for integer overflow on 32-bit systems in x_tables, from
   Florian Westphal.

Several patches from Jarno Rajahalme to prepare the introduction of
NAT support to OVS based on the Netfilter infrastructure:

10) Schedule IP_CT_NEW_REPLY definition for removal in
    nf_conntrack_common.h.

11) Simplify checksumming recalculation in nf_nat.

12) Add comments to the openvswitch conntrack code, from Jarno.

13) Update the CT state key only after successful nf_conntrack_in()
    invocation.

14) Find existing conntrack entry after upcall.

15) Handle NF_REPEAT case due to templates in nf_conntrack_in().

16) Call the conntrack helper functions once the conntrack has been
    confirmed.

17) And finally, add the NAT interface to OVS.

The batch closes with:

18) Cleanup to use spin_unlock_wait() instead of
    spin_lock()/spin_unlock(), from Nicholas Mc Guire.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 3b8377dca1fd1974d245b2a04a708fc434761c65:

  Merge branch 'variable-length-ll-headers' (2016-03-09 22:13:01 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to e39365be031e37b229f745ea49db0b25e82436fa:

  netfilter: nf_conntrack: consolidate lock/unlock into unlock_wait (2016-03-15 01:10:42 +0100)

----------------------------------------------------------------
Arnd Bergmann (1):
      ipvs: handle ip_vs_fill_iph_skb_off failure

Florian Westphal (2):
      netfilter: nft_compat: check match/targetinfo attr size
      netfilter: x_tables: check for size overflow

Jarno Rajahalme (8):
      netfilter: Remove IP_CT_NEW_REPLY definition.
      netfilter: Allow calling into nat helper without skb_dst.
      openvswitch: Add commentary to conntrack.c
      openvswitch: Update the CT state key only after nf_conntrack_in().
      openvswitch: Find existing conntrack entry after upcall.
      openvswitch: Handle NF_REPEAT in conntrack action.
      openvswitch: Delay conntrack helper call for new connections.
      openvswitch: Interface with NAT.

Jozsef Kadlecsik (2):
      netfilter: ipset: Fix set:list type crash when flush/dump set in parallel
      netfilter: ipset: Check IPSET_ATTR_ETHER netlink attribute length

Julian Anastasov (2):
      ipvs: drop first packet to redirect conntrack
      ipvs: allow rescheduling after RST

Marco Angaroni (1):
      ipvs: correct initial offset of Call-ID header search in SIP persistence engine

Nicholas Mc Guire (1):
      netfilter: nf_conntrack: consolidate lock/unlock into unlock_wait

Pablo Neira Ayuso (2):
      Merge branch 'master' of git://blackhole.kfki.hu/nf
      Merge tag 'ipvs-fixes-for-v4.5' of https://git.kernel.org/.../horms/ipvs

Phil Turnbull (1):
      netfilter: nfnetlink_acct: validate NFACCT_FILTER parameters

 include/net/ip_vs.h                                |  17 +
 include/uapi/linux/netfilter/nf_conntrack_common.h |  12 +-
 include/uapi/linux/openvswitch.h                   |  49 ++
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c           |  30 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c           |  30 +-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c          |   2 +
 net/netfilter/ipset/ip_set_core.c                  |   3 +
 net/netfilter/ipset/ip_set_hash_mac.c              |   3 +-
 net/netfilter/ipset/ip_set_list_set.c              |  55 +-
 net/netfilter/ipvs/ip_vs_core.c                    |  38 +-
 net/netfilter/ipvs/ip_vs_pe_sip.c                  |   6 +-
 net/netfilter/nf_conntrack_core.c                  |   6 +-
 net/netfilter/nfnetlink_acct.c                     |   3 +
 net/netfilter/nft_compat.c                         |   6 +
 net/netfilter/x_tables.c                           |   3 +
 net/openvswitch/Kconfig                            |   3 +-
 net/openvswitch/conntrack.c                        | 660 +++++++++++++++++++--
 net/openvswitch/conntrack.h                        |   3 +-
 18 files changed, 795 insertions(+), 134 deletions(-)
