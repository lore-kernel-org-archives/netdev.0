From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next v2 0/2] net: Remote checksum offload for VXLAN
Date: Mon, 12 Jan 2015 17:00:36 -0800
Message-ID: <1421110838-5146-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:54749 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbbAMBA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 20:00:58 -0500
Received: by mail-ie0-f174.google.com with SMTP id at20so176380iec.5
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 17:00:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds support for remote checksum offload in VXLAN.

The remote checksum offload is generalized by creating a common
function (remcsum_adjust) that does the work of modifying the
checksum in remote checksum offload. This function can be called
from normal or GRO path. GUE was modified to use this function.

To support RCO is VXLAN we use the 9th bit in the reserved
flags to indicated remote checksum offload. The start and offset
values are encoded n a compressed form in the low order (reserved)
byte of the vni field.

Remote checksum offload is described in
https://tools.ietf.org/html/draft-herbert-remotecsumoffload-01

Changes in v2:
  - Add udp_offload_callbacks which has GRO functions that take a
    udp_offload pointer argument. This argument can be used to retrieve
    a per port structure of the encapsulation for use in gro processing
    (mostly by doing container_of on the structure).
  - Use the 10th bit in VXLAN flags for RCO which does not seem to
    conflict with other proposals at this time (ie. VXLAN-GPE and
    VXLAN-GPB)
  - Require that RCO must be explicitly enabled on the receiver
    as well as the sender.

Tested by running 200 TCP_STREAM connections with VXLAN (over IPv4).

With UDP checksums and Remote Checksum Offload
  IPv4
      Client
        11.84% CPU utilization
      Server
        12.96% CPU utilization
      9197 Mbps
  IPv6
      Client
        12.46% CPU utilization
      Server
        14.48% CPU utilization
      8963 Mbps

With UDP checksums, no remote checksum offload
  IPv4
      Client
        15.67% CPU utilization
      Server
        14.83% CPU utilization
      9094 Mbps
  IPv6
      Client
        16.21% CPU utilization
      Server
        14.32% CPU utilization
      9058 Mbps
 
No UDP checksums
  IPv4
      Client
        15.03% CPU utilization
      Server
        23.09% CPU utilization
      9089 Mbps
  IPv6
      Client
        16.18% CPU utilization
      Server
        26.57% CPU utilization
       8954 Mbps

Tom Herbert (2):
  udp: pass udp_offload struct to UDP gro callbacks
  vxlan: Remote checksum offload

 drivers/net/vxlan.c          | 198 +++++++++++++++++++++++++++++++++++++++++--
 include/linux/netdevice.h    |  15 +++-
 include/net/vxlan.h          |  11 +++
 include/uapi/linux/if_link.h |   2 +
 net/ipv4/fou.c               |  12 ++-
 net/ipv4/geneve.c            |   6 +-
 net/ipv4/udp_offload.c       |   7 +-
 7 files changed, 233 insertions(+), 18 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
