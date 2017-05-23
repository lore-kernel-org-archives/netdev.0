From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V2 net 0/3] Fix checksum issues with Q-in-Q vlans
Date: Tue, 23 May 2017 12:53:09 -0400
Message-ID: <1495558392-1238-1-git-send-email-vyasevic@redhat.com>
Cc: alexander.duyck@gmail.com, makita.toshiaki@lab.ntt.co.jp,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33480 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753586AbdEWQxU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 12:53:20 -0400
Received: by mail-qk0-f194.google.com with SMTP id o85so23516055qkh.0
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 09:53:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP checksum appear broken on a lot of devices that
advertise NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM.  This problem
becomes very visible/reproducable since the series
commit afb0bc972b526 ("Merge branch 'stacked_vlan_tso'").

In particular, the issue appeared consistently on bnx2 and be2net
drivers (not all drivers were tested).

This short series corrects this by disabling checksum offload
support on packets sent through Q-in-Q vlans if the underlying HW only
enables IP specific checksum features.  We currently 'assume' that
any drivers setting NETIF_F_HW_CSUM can correclty pass checksum offsets
to HW.  It is up to individual drivers to enable it properly through
ndo_features_check if they have some support for Q-in-Q vlans.

Additionally, be2net driver was fixed to make the proper call.

While looking at the drivers, it was also found that virtio-net ended
up disabling accelerations, which is unnecessary.  

V2: Instead of disabling checksuming for all devices, only devices using
    NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM are now affected by this change.
    For drivers using NETIF_F_HW_CSUM, we will continue to use checksum
    offloading.  If any drivers are found to be broken, they would need
    be fixed individually.

Vladislav Yasevich (3):
  vlan: Fix tcp checksum offloads in Q-in-Q vlans
  be2net: Fix offload features for Q-in-Q packets
  virtio-net: enable TSO/checksum offloads for Q-in-Q vlans

 drivers/net/ethernet/emulex/benet/be_main.c |  4 +++-
 drivers/net/virtio_net.c                    |  1 +
 include/linux/if_vlan.h                     | 10 ++++++++--
 3 files changed, 12 insertions(+), 3 deletions(-)

-- 
2.7.4
