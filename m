From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 0/4] return offloaded stats as default and expose original sw stats
Date: Tue, 21 Jun 2016 17:15:52 +0200
Message-ID: <1466522156-4795-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:36836 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbcFUPQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 11:16:02 -0400
Received: by mail-lb0-f193.google.com with SMTP id ur4so2251611lbc.3
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 08:16:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

---
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

Nogah Frankel (4):
  netdevice: add SW statistics ndo
  rtnetlink: add HW/SW stats distinction in rtnl_fill_stats
  net: core: add SW stats to if_stats_msg
  mlxsw: spectrum: Implement SW stats ndo and expose HW stats by default

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 110 +++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |   5 ++
 include/linux/netdevice.h                      |  13 +++
 include/uapi/linux/if_link.h                   |   2 +
 net/core/dev.c                                 |  31 +++++++
 net/core/rtnetlink.c                           |  49 +++++++++--
 6 files changed, 195 insertions(+), 15 deletions(-)

-- 
2.5.5
