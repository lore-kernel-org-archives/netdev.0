From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 0/6][pull request] 1GbE Intel Wired LAN Driver Updates 2017-10-27
Date: Fri, 27 Oct 2017 09:57:00 -0700
Message-ID: <20171027165706.85527-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18784 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751770AbdJ0Q53 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 12:57:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is a proposal of how the Traffic Control subsystem can
be used to offload the configuration of the Credit Based Shaper
(defined in the IEEE 802.1Q-2014 Section 8.6.8.2) into supported
network devices.

As part of this work, we've assessed previous public discussions
related to TSN enabling: patches from Henrik Austad (Cisco), the
presentation from Eric Mann at Linux Plumbers 2012, patches from
Gangfeng Huang (National Instruments) and the current state of the
OpenAVNU project (https://github.com/AVnu/OpenAvnu/).

Overview
========

Time-sensitive Networking (TSN) is a set of standards that aim to
address resources availability for providing bandwidth reservation and
bounded latency on Ethernet based LANs. The proposal described here
aims to cover mainly what is needed to enable the following standards:
802.1Qat and 802.1Qav.

The initial target of this work is the Intel i210 NIC, but other
controllers' datasheet were also taken into account, like the Renesas
RZ/A1H RZ/A1M group and the Synopsis DesignWare Ethernet QoS
controller.


Proposal
========

Feature-wise, what is covered here is the configuration interfaces for
HW implementations of the Credit-Based shaper (CBS, 802.1Qav). CBS is
a per-queue shaper. Given that this feature is related to traffic
shaping, and that the traffic control subsystem already provides a
queueing discipline that offloads config into the device driver (i.e.
mqprio), designing a new qdisc for the specific purpose of offloading
the config for the CBS shaper seemed like a good fit.

For steering traffic into the correct queues, we use the socket option
SO_PRIORITY and then a mechanism to map priority to traffic classes /
Tx queues. The qdisc mqprio is currently used in our tests.

As for the CBS config interface, this patchset is proposing a new
qdisc called 'cbs'. Its 'tc' cmd line is:

$ tc qdisc add dev IFACE parent ID cbs locredit N hicredit M sendslope S \
     idleslope I

   Note that the parameters for this qdisc are the ones defined by the
   802.1Q-2014 spec, so no hardware specific functionality is exposed here.

Per-stream shaping, as defined by IEEE 802.1Q-2014 Section 34.6.1, is
not yet covered by this proposal.

v2: Merged patch 6 of the original series into patch 4 based on feedback
    from David Miller.

The following are changes since commit c859e21a35ce5604dde0b618169680aa3c7e3bdb:
  liquidio: xmit_more support
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Andre Guedes (1):
  igb: Add support for CBS offload

Jesus Sanchez-Palencia (3):
  net/sched: Check for null dev_queue on create flow
  net/sched: Change behavior of mq select_queue()
  net/sched: Add select_queue() class_ops for mqprio

Vinicius Costa Gomes (2):
  net/sched: Introduce Credit Based Shaper (CBS) qdisc
  net/sched: Add support for HW offloading for CBS

 drivers/net/ethernet/intel/igb/e1000_defines.h |  23 ++
 drivers/net/ethernet/intel/igb/e1000_regs.h    |   8 +
 drivers/net/ethernet/intel/igb/igb.h           |   6 +
 drivers/net/ethernet/intel/igb/igb_main.c      | 347 +++++++++++++++++++++++
 include/linux/netdevice.h                      |   1 +
 include/net/pkt_sched.h                        |   9 +
 include/uapi/linux/pkt_sched.h                 |  19 ++
 net/sched/Kconfig                              |  11 +
 net/sched/Makefile                             |   1 +
 net/sched/sch_cbs.c                            | 373 +++++++++++++++++++++++++
 net/sched/sch_generic.c                        |   8 +-
 net/sched/sch_mq.c                             |  10 +-
 net/sched/sch_mqprio.c                         |   7 +
 13 files changed, 813 insertions(+), 10 deletions(-)
 create mode 100644 net/sched/sch_cbs.c

-- 
2.14.2
