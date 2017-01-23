From: Davide Caratti <dcaratti@redhat.com>
Subject: [RFC PATCH net-next 0/5] net: improve support for SCTP checksums
Date: Mon, 23 Jan 2017 17:52:41 +0100
Message-ID: <cover.1485177252.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35970 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751407AbdAWQ7W (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 11:59:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When NETIF_F_CSUM_MASK bits are all 0 on netdev features, validate_xmit_skb
uses skb_checksum_help to compute 16-bit, 2-complement checksum on non-GSO
skbs having ip_summed equal to CHECKSUM_PARTIAL.
This results in a systematic corruption of SCTP packets, since they need
to be checksummed with crc32c. Moreover, this is done regardless the value
of NETIF_F_SCTP_CRC, so any chance to offload crc32c computation on the 
NIC is lost. Finally, even when at least one bit in NETIF_F_CSUM_MASK is
set on netdev features, validate_xmit_skb skips checksum computation - but
then most NIC drivers can only call skb_checksum_help if their HW can't
offload the checksum computation. Depending on the driver code, this
results in wrong handling of SCTP, leading to:

- packet being dropped
- packet being transmitted with identically-zero checksum
- packet being transmitted with 2-complement checksum instead of crc32c

This series tries to address the above issue, by providing:
- the possibility to compute crc32c on skbs in Linux net core [patch 1]
- skb_sctp_csum_help, a function sharing common code with the original
  skb_checksum_help, that performs SW checksumming for skbs using crc32c
  [patch 2 and patch 3]
- skb_csum_hwoffload_help, called by validate xmit skb to perform SW
  checksumming using the correct algorithm based on the value of IP
  protocol number and netdev features bitmask [patch 4]
- an update to Linux documentation [patch 5]

Davide Caratti (5):
  skbuff: add stub to help computing crc32c on SCTP packets
  net: split skb_checksum_help
  net: introduce skb_sctp_csum_help
  net: more accurate checksumming in validate_xmit_skb
  Documentation: add description of skb_sctp_csum_help

 Documentation/networking/checksum-offloads.txt |   9 +-
 include/linux/netdevice.h                      |   1 +
 include/linux/skbuff.h                         |   5 +-
 net/core/dev.c                                 | 132 +++++++++++++++++++++----
 net/core/skbuff.c                              |  20 ++++
 net/sctp/offload.c                             |   7 ++
 6 files changed, 151 insertions(+), 23 deletions(-)

-- 
2.7.4
