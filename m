From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/8] Add support for offloading packet-sampling
Date: Thu, 10 Nov 2016 12:23:00 +0100
Message-ID: <1478776988-5400-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35026 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755383AbcKJLXV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 06:23:21 -0500
Received: by mail-wm0-f67.google.com with SMTP id a20so2466557wme.2
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 03:23:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add the sample tc action, which allows to sample packet matching
a classifier. The sample action peeks randomly packets, duplicates them,
truncates them and adds informative metadata on the packet, for example,
the input interface and the original packet length. The sampled packets
are marked to allow matching them and redirecting them to a specific
collector device.

The sampled packets metadata is packed using ife encapsulation. To do
that, this patch-set extracts ife logics from the tc_ife action into an
independent ife module, and uses that functionality to pack the metadata.
To include all the needed metadata, this patch-set introduces some new
IFE_META tlv types.

In addition, Add the support for offloading the macthall-sample tc command
in the Mellanox mlxsw driver, for ingress qdiscs.

Userspace examples for that code can be found in:
 - https://github.com/yotamgi/host-sflow: sflow client that uses the sample
   with combination of tap device to sample packets and send to a
   centralized sflow collector.
 - https://github.com/yotamgi/libife: a library for manipulating ife
   packets in userspace. The library is used in the host-sflow program to
   parse the sampled packets.

---
rfc1->v1:
 - Change ifindex sampled packets metadatum to in_ifindex and out_ifindex
 - Add sequence number metadatum to sampled packets
 - Add sampler_id metadatum to sampled packets
 - Make the user kernel interface extensible
 - Move the sampling helper function to the ife module
 - Fix ife header to be safe when CONFIG_NET_IFE is not set
 - Made the sampled packets eth_type field mandatory other then optional
 - Change the IFE_META* fields to be enum
 - Remove the ife_packet_info struct and pass the parameters directly to
   the ife_packet_ifo_pack function
 - Couple of more styling and cosmetic issues

Yotam Gigi (8):
  Introduce ife encapsulation module
  act_ife: Change to use ife module
  net: ife: Introduce new metadata tlv types
  net: ife: Introduce packet info packing method
  Introduce sample tc action
  tc: sample: Add sequence number and sampler_id fields
  mlxsw: reg: add the Monitoring Packet Sampling Configuration Register
  mlxsw: packet sample: Add packet sample offloading support

 MAINTAINERS                                    |   7 +
 drivers/net/ethernet/mellanox/mlxsw/reg.h      |  38 ++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 120 +++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  12 +
 drivers/net/ethernet/mellanox/mlxsw/trap.h     |   1 +
 include/net/ife.h                              |  63 ++++++
 include/net/tc_act/tc_ife.h                    |   3 -
 include/net/tc_act/tc_sample.h                 |  74 +++++++
 include/uapi/linux/Kbuild                      |   1 +
 include/uapi/linux/ife.h                       |  24 ++
 include/uapi/linux/tc_act/Kbuild               |   1 +
 include/uapi/linux/tc_act/tc_ife.h             |  10 +-
 include/uapi/linux/tc_act/tc_sample.h          |  29 +++
 net/Kconfig                                    |   1 +
 net/Makefile                                   |   1 +
 net/ife/Kconfig                                |  16 ++
 net/ife/Makefile                               |   5 +
 net/ife/ife.c                                  | 199 +++++++++++++++++
 net/sched/Kconfig                              |  14 ++
 net/sched/Makefile                             |   1 +
 net/sched/act_ife.c                            | 109 +++------
 net/sched/act_sample.c                         | 291 +++++++++++++++++++++++++
 22 files changed, 923 insertions(+), 97 deletions(-)
 create mode 100644 include/net/ife.h
 create mode 100644 include/net/tc_act/tc_sample.h
 create mode 100644 include/uapi/linux/ife.h
 create mode 100644 include/uapi/linux/tc_act/tc_sample.h
 create mode 100644 net/ife/Kconfig
 create mode 100644 net/ife/Makefile
 create mode 100644 net/ife/ife.c
 create mode 100644 net/sched/act_sample.c

-- 
2.7.4
