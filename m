From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/3] net: Remote checksum offload for VXLAN
Date: Mon, 24 Nov 2014 15:52:27 -0800
Message-ID: <1416873150-12260-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:33328 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbaKXXwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 18:52:54 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn15so4099085igb.15
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 15:52:53 -0800 (PST)
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

Tom Herbert (3):
  net: Add remcsum_adjust as common function for remote checksum offload
  gue: Call remcsum_adjust
  vxlan: Remote checksum offload

 drivers/net/vxlan.c          | 188 +++++++++++++++++++++++++++++++++++++++++--
 include/net/checksum.h       |  16 ++++
 include/net/vxlan.h          |   2 +
 include/uapi/linux/if_link.h |   1 +
 net/ipv4/fou.c               |  84 ++++---------------
 5 files changed, 216 insertions(+), 75 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5
