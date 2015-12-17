From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/2] Local checksum offload for VXLAN
Date: Thu, 17 Dec 2015 15:27:34 +0000
Message-ID: <5672D466.6050900@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:25611 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934373AbbLQP1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 10:27:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the inner packet checksum is offloaded, the outer UDP checksum is easy
 to calculate as it doesn't depend on the payload (because the inner checksum
 cancels out everything from the inner packet except the pseudo header).
Thus, transmit checksums for VXLAN (and in principle other encapsulations,
 but I haven't enabled it for / tested with those) can be offloaded on any
 device supporting NETIF_F_HW_CSUM.  Only the innermost checksum has to be
 offloaded, the rest are filled in by the stack.
Tested by hacking a driver to report NETIF_F_HW_CSUM, call skb_checksum_help
 before transmitting a packet, and not actually offload anything to the hw.
In principle it should also be possible to apply this technique when the
 inner packet has been checksummed by software, but only if skb->csum_start
 and skb->csum_offset have been filled in to describe the inner checksum.
 However in this case it is easier to use skb->csum and skb->csum_start, as
 gso_make_checksum() already does - a similar but simpler technique.  It's
 not clear to me where else this should be done, so this is out of scope for
 this patch series.

Edward Cree (2):
  net: udp: local checksum offload for encapsulation
  net: vxlan: enable local checksum offload on HW_CSUM devices

 drivers/net/vxlan.c |  5 ++++-
 net/ipv4/udp.c      | 34 +++++++++++++++++++++++++++++-----
 2 files changed, 33 insertions(+), 6 deletions(-)

-- 
2.4.3
