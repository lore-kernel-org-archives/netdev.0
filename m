From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH RFC net-next v4 0/7] net: improve support for SCTP checksums
Date: Thu, 20 Apr 2017 15:38:06 +0200
Message-ID: <cover.1492692976.git.dcaratti@redhat.com>
References: <CALx6S36rem=OuN_At6qYA=se5cpuYM1N2R8efoaszvo8b8Tz5A@mail.gmail.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35370 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S946031AbdDTNib (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 09:38:31 -0400
In-Reply-To: <CALx6S36rem=OuN_At6qYA=se5cpuYM1N2R8efoaszvo8b8Tz5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello Tom,

On Fri, 2017-04-07 at 11:11 -0700, Tom Herbert wrote:
> maybe just call it csum_not_ip then. Then just do "if
> (unlikely(skb->csum_not_ip)) ..."

Ok, done. V4 uses this bit for SCTP only and leaves unmodified behavior
when offloaded FCoE frames are processed. Further work is still possible
to extend this fix for FCoE, if needed, either by using additional sk_buff
bits, or using skb->csum_not_ip and use other data (e.g. skb->csum_offset)
to distinguish SCTP from FCoE.

> the only case where this new bit is relevant is when
> CHECKSUM_PARTIAL for a CRC is being done. When it's set for offloading
> sctp crc it must be set. When CRC is resolved, in the helper for
> instance, it must be cleared.

in V4 the bit is set when SCTP packets with offloaded checksum are
generated; the bit is cleared when CRC32c is resolved for such packets
(i.e. skb->ip_summed transitions from CHECKSUM_PARTIAL to CHECKSUM_NONE).

Any feedbacks are appreciated!
thank you in advance,
--
davide


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
 include/linux/netdevice.h                        |  8 +--
 include/linux/skbuff.h                           | 58 +++++++++-------------
 net/bridge/netfilter/nft_reject_bridge.c         |  5 +-
 net/core/dev.c                                   | 63 +++++++++++++++++++++---
 net/core/skbuff.c                                | 24 +++++++++
 net/ipv4/netfilter/nf_reject_ipv4.c              |  2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c              |  3 --
 net/openvswitch/datapath.c                       |  2 +-
 net/sched/act_csum.c                             |  1 +
 net/sctp/offload.c                               |  8 +++
 net/sctp/output.c                                |  1 +
 13 files changed, 128 insertions(+), 60 deletions(-)

-- 
2.7.4
