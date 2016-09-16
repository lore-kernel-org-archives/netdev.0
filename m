From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v10 0/3] return offloaded stats as default and expose original sw stats
Date: Fri, 16 Sep 2016 15:05:35 +0200
Message-ID: <1474031138-2065-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
        ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36602 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1765103AbcIPNFm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 09:05:42 -0400
Received: by mail-wm0-f68.google.com with SMTP id b184so3682291wma.3
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 06:05:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

From: Jiri Pirko <jiri@mellanox.com>

The problem we try to handle is about offloaded forwarded packets
which are not seen by kernel. Let me try to draw it:

    port1                       port2 (HW stats are counted here)
      \                          /
       \                        /
        \                      /
         --(A)---- ASIC --(B)--
                    |
                   (C)
                    |
                   CPU (SW stats are counted here)


Now we have couple of flows for TX and RX (direction does not matter here):

1) port1->A->ASIC->C->CPU

   For this flow, HW and SW stats are equal.

2) port1->A->ASIC->C->CPU->C->ASIC->B->port2

   For this flow, HW and SW stats are equal.

3) port1->A->ASIC->B->port2

   For this flow, SW stats are 0.

The purpose of this patchset is to provide facility for user to
find out the difference between flows 1+2 and 3. In other words, user
will be able to see the statistics for the slow-path (through kernel).

Also note that HW stats are what someone calls "accumulated" stats.
Every packet counted by SW is also counted by HW. Not the other way around.

As a default the accumulated stats (HW) will be exposed to user
so the userspace apps can react properly.

This patchset add the SW stats (flows 1+2) under offload related stats, so
in the future we can expose other offload related stat in a similar way.

---
v9->v10:
- patch 2/3
 - removed unnecessary ()s as pointed out by Nik
v8->v9:
- patch 2/3
 - add using of idxattr and prividx
v7->v8:
- patch 2/3
 - move helping const from uapi to rtnetlink
 - cancel driver xstat nesting if it is empty
v6->v7:
- patch 1/3:
 - ndo interface changed to get the wanted stats type as an input.
 - change commit message.
- patch 2/3:
 - create a nesting for offloaded stat and put SW stats under it.
 - change the ndo call to indicate which offload stats we wants.
 - change commit message.
- patch 3/3:
 - change ndo implementation to match the changes in the previous patches.
 - change commit message.
v5->v6:
- patch 2/4 was dropped as requested by Roopa
- patch 1/3:
 - comment changed to indicate that default stats are combined stats
 - commit massage changed
- patch 2/3: (previously 3/4)
 - SW stats return nothing if there is no SW stats ndo
v4->v5:
- updated cover letter
- patch3/4:
  - using memcpy directly to copy stats as requested by DaveM
v3->v4:
- patch1/4:
  - fixed "return ()" pointed out by EricD
- patch2/4:
  - fixed if_nlmsg_size as pointed out by EricD
v2->v3:
- patch1/4:
  - added dev_have_sw_stats helper
- patch2/4:
  - avoided memcpy as requested by DaveM
- patch3/4:
  - use new dev_have_sw_stats helper
v1->v2:
- patch3/4:
  - fixed NULL initialization

Nogah Frankel (3):
  netdevice: Add offload statistics ndo
  net: core: Add offload stats to if_stats_msg
  mlxsw: spectrum: Implement offload stats ndo and expose HW stats by
    default

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 129 +++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |   5 +
 include/linux/netdevice.h                      |  12 +++
 include/uapi/linux/if_link.h                   |   9 ++
 net/core/rtnetlink.c                           | 111 ++++++++++++++++++++-
 5 files changed, 255 insertions(+), 11 deletions(-)

-- 
2.5.5
