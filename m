From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 0/3] net: Add driver helper function to determine if checksum is offloadable
Date: Mon, 5 Oct 2015 16:39:21 -0700
Message-ID: <1444088364-2839440-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <dwmw2@infradead.org>,
	<ogerlitz@mellanox.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:3693 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750866AbbJEXjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 19:39:53 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t95Nb7kZ012093
	for <netdev@vger.kernel.org>; Mon, 5 Oct 2015 16:39:52 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1xc2r6r2fj-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 16:39:52 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 5ee44ace6bba11e58e6a24be05956610-edbfa240 for <netdev@vger.kernel.org>;	Mon,
 05 Oct 2015 16:39:50 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When drivers have support for offloading transport IP checksums, they
will indicate this in the features for the device. As described in
skbuff.h, a driver will usually advertise NETIF_F_HW_CSUM,
NETIF_F_IP_CSUM, and/or NETIF_F_IPV6_CSUM. The first of these
(NETIF_F_HW_CSUM) is the preferred method since this implies that the
device has implemented a generic checksum offload feature that should
work under arbitrary scenarios (e.g. for different protocols, with or
without encapsulation).

For narrow features support (NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM
for offload of TCP/UDP), the features flags may not be sufficient to
deduce whether a packet may be offloaded. Some devices will not be able
to offload encapsulated checksums, some cannot offload transport
checksums in packet with IPv6 extension headers, etc. In these cases
a driver will need to perform additional packet inspection to determine
if a packet's checksum can be offloaded to a device.

This patch defines a helper function that drivers can call to check if
it is able to offload the checksum for a particular packet. In an
argument to the function, the driver specifies what type of packets it
is able to offload to a device. The function is intended to check for
the most common restrictions of devices (like by IP version, transport
protocol, encapsulation, extension headers). Since the function includes
checks for IP version and transport protocol, the driver is able
to advertise NETIF_F_HW_CSUM instead of protocol specific support.
This should put us on a path to deprecate NETIF_F_IP_CSUM and
NETIF_F_IPV6_CSUM.

The helper function may be called from ndo_features_check or the xmit
routine of the driver. The csum_help argument does not need to be set
when the function is called from ndo_features_check.

Note that the helper function is intended to verify checksum
offloadability in the non-LSO case. Checksum offload as part of LSO
should be validated as part of GSO offload checks (through NETIF_F_GSO_*
flags and work done in ndo_features_check).

In this patch set:
- Added skb_csum_offload_chk function
- Call skb_csum_offload_chk from mlx4

Testing:

Ran 200 netperf TCP_RR to see impact of calling skb_csum_offload_chk
for every packet. Did not observe any noticeable regression. Perf shows
that the function was 0.20% utilization which puts it pretty far down
the list.

Tom Herbert (3):
  net: Add skb_inner_transport_offset function
  net: Add driver helper function to determine checksum offloadability
  mlx4: Call skb_csum_offload_check to check offloadability

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   6 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |  20 +++-
 include/linux/netdevice.h                      |  47 +++++++++
 include/linux/skbuff.h                         |   5 +
 net/core/dev.c                                 | 129 +++++++++++++++++++++++++
 5 files changed, 199 insertions(+), 8 deletions(-)

-- 
2.4.6
