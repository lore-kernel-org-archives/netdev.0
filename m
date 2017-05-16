From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net-next v2 0/7] fix CRC32c in the forwarding path
Date: Tue, 16 May 2017 18:27:44 +0200
Message-ID: <cover.1494946940.git.dcaratti@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "David S. Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38072 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753158AbdEPQ30 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 12:29:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current kernel allows offloading CRC32c computation when SCTP packets
are generated, setting skb->ip_summed to CHECKSUM_PARTIAL, if the
underlying device features have NETIF_F_SCTP_CRC set. However, after these
packets are forwarded, they may land on a device where CRC32c offloading is
not available: as a consequence, transmission is done with wrong CRC32c.
It's not possible to use sctp_compte_cksum() in the forwarding path
and in most drivers, because it needs symbols exported by libcrc32c module.

Patch 1 and 2 of this series try to solve this problem, introducing a new
helper function, namely skb_crc32c_csum_help(), that can be used to resolve
CHECKSUM_PARTIAL when crc32c is needed instead of Internet Checksum.

Currently, we need to parse the packet headers to understand what algorithm
is needed to resolve CHECKSUM_PARTIAL. We can speedup things by storing
this information in the skb metadata, and use it to call an appropriate
helper (skb_checksum_help or skb_crc32c_csum_help), or leave the packet
unmodified when the NIC is able to offload the checksum computation.

Patch 3 deprecates skb->csum_bad to free one bit in skb metadata; patch 4
introduces skb->csum_not_inet, providing skb with an indication on the
algorithm needed to resolve CHECKSUM_PARTIAL.
Patch 5 and 6 fix the kernel forwarding path and openvswitch datapath,
where skb_checksum_help was unconditionally called to resolve CHECKSUM_PARTIAL,
thus generating wrong CRC32c in forwarded SCTP packets.
Finally, patch 7 updates documentation to provide a better description of
possible values of skb->ip_summed.

Some further work is still possible:
* drivers that parse the packet header to correctly resolve CHECKSUM_PARTIAL
(e.g. ixgbe_tx_csum()) can benefit from testing skb->csum_not_inet to avoid
calling ip_hdr(skb)->protocol or ixgbe_ipv6_csum_is_sctp(skb).

* drivers that call skb_checksum_help() to resolve CHECKSUM_PARTIAL can
call skb_csum_hwoffload_help to avoid corrupting SCTP packets.


changes since RFCv4:
- patch 2/7: use WARN_ON_ONCE() instead of BUG_ON(), and avoid computing
CRC32c on the error path.
- patch 3/7: don't invert tests on the values of same_flow and
NAPI_GRO_CB(skb)->flush in dev_gro_receive(), it's useless and it breaks
GRO functionality as reported by kernel test robot.

Davide Caratti (7):
  skbuff: add stub to help computing crc32c on SCTP packets
  net: introduce skb_crc32c_csum_help
  sk_buff: remove support for csum_bad in sk_buff
  net: use skb->csum_not_inet to identify packets needing crc32c
  net: more accurate checksumming in validate_xmit_skb()
  openvswitch: more accurate checksumming in queue_userspace_packet()
  sk_buff.h: improve description of CHECKSUM_{COMPLETE,UNNECESSARY}

 Documentation/networking/checksum-offloads.txt   | 11 +++--
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c |  2 +-
 include/linux/netdevice.h                        |  8 ++--
 include/linux/skbuff.h                           | 58 +++++++++--------------
 net/bridge/netfilter/nft_reject_bridge.c         |  5 +-
 net/core/dev.c                                   | 59 ++++++++++++++++++++++--
 net/core/skbuff.c                                | 24 ++++++++++
 net/ipv4/netfilter/nf_reject_ipv4.c              |  2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c              |  3 --
 net/openvswitch/datapath.c                       |  2 +-
 net/sched/act_csum.c                             |  1 +
 net/sctp/offload.c                               |  8 ++++
 net/sctp/output.c                                |  1 +
 13 files changed, 126 insertions(+), 58 deletions(-)

-- 
2.7.4
