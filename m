From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for traffic shapers
Date: Thu, 31 Aug 2017 18:26:20 -0700
Message-ID: <20170901012625.14838-1-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us,
        intel-wired-lan@lists.osuosl.org, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20239 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750952AbdIAB03 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 21:26:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset is an RFC on a proposal of how the Traffic Control subsystem can
be used to offload the configuration of traffic shapers into network devices
that provide support for them in HW. Our goal here is to start upstreaming
support for features related to the Time-Sensitive Networking (TSN) set of
standards into the kernel.

As part of this work, we've assessed previous public discussions related to TSN
enabling: patches from Henrik Austad (Cisco), the presentation from Eric Mann
at Linux Plumbers 2012, patches from Gangfeng Huang (National Instruments) and
the current state of the OpenAVNU project (https://github.com/AVnu/OpenAvnu/).

Please note that the patches provided as part of this RFC are implementing what
is needed only for 802.1Qav (FQTSS) only, but we'd like to take advantage of
this discussion and share our WIP ideas for the 802.1Qbv and 802.1Qbu interfaces
as well. The current patches are only providing support for HW offload of the
configs.


Overview
========

Time-sensitive Networking (TSN) is a set of standards that aim to address
resources availability for providing bandwidth reservation and bounded latency
on Ethernet based LANs. The proposal described here aims to cover mainly what is
needed to enable the following standards: 802.1Qat, 802.1Qav, 802.1Qbv and
802.1Qbu.

The initial target of this work is the Intel i210 NIC, but other controllers'
datasheet were also taken into account, like the Renesas RZ/A1H RZ/A1M group and
the Synopsis DesignWare Ethernet QoS controller.


Proposal
========

Feature-wise, what is covered here are configuration interfaces for HW
implementations of the Credit-Based shaper (CBS, 802.1Qav), Time-Aware shaper
(802.1Qbv) and Frame Preemption (802.1Qbu). CBS is a per-queue shaper, while
Qbv and Qbu must be configured per port, with the configuration covering all
queues. Given that these features are related to traffic shaping, and that the
traffic control subsystem already provides a queueing discipline that offloads
config into the device driver (i.e. mqprio), designing new qdiscs for the
specific purpose of offloading the config for each shaper seemed like a good
fit.

For steering traffic into the correct queues, we use the socket option
SO_PRIORITY and then a mechanism to map priority to traffic classes / Tx queues.
The qdisc mqprio is currently used in our tests.

As for the shapers config interface:

 * CBS (802.1Qav)

   This patchset is proposing a new qdisc called 'cbs'. Its 'tc' cmd line is:
   $ tc qdisc add dev IFACE parent ID cbs locredit N hicredit M sendslope S \
     idleslope I

   Note that the parameters for this qdisc are the ones defined by the
   802.1Q-2014 spec, so no hardware specific functionality is exposed here.


 * Time-aware shaper (802.1Qbv):

   The idea we are currently exploring is to add a "time-aware", priority based
   qdisc, that also exposes the Tx queues available and provides a mechanism for
   mapping priority <-> traffic class <-> Tx queues in a similar fashion as
   mqprio. We are calling this qdisc 'taprio', and its 'tc' cmd line would be:

   $ $ tc qdisc add dev ens4 parent root handle 100 taprio num_tc 4    \
     	   map 2 2 1 0 3 3 3 3 3 3 3 3 3 3 3 3                         \
	   queues 0 1 2 3                                              \
     	   sched-file gates.sched [base-time <interval>]               \
           [cycle-time <interval>] [extension-time <interval>]

   <file> is multi-line, with each line being of the following format:
   <cmd> <gate mask> <interval in nanoseconds>

   Qbv only defines one <cmd>: "S" for 'SetGates'

   For example:

   S 0x01 300
   S 0x03 500

   This means that there are two intervals, the first will have the gate
   for traffic class 0 open for 300 nanoseconds, the second will have
   both traffic classes open for 500 nanoseconds.

   Additionally, an option to set just one entry of the gate control list will
   also be provided by 'taprio':

   $ tc qdisc (...) \
        sched-row <row number> <cmd> <gate mask> <interval>  \
        [base-time <interval>] [cycle-time <interval>] \
        [extension-time <interval>]


 * Frame Preemption (802.1Qbu):

   To control even further the latency, it may prove useful to signal which
   traffic classes are marked as preemptable. For that, 'taprio' provides the
   preemption command so you set each traffic class as preemptable or not:

   $ tc qdisc (...) \
        preemption 0 1 1 1


 * Time-aware shaper + Preemption:

   As an example of how Qbv and Qbu can be used together, we may specify
   both the schedule and the preempt-mask, and this way we may also
   specify the Set-Gates-and-Hold and Set-Gates-and-Release commands as
   specified in the Qbu spec:

   $ tc qdisc add dev ens4 parent root handle 100 taprio num_tc 4 \
     	   map 2 2 1 0 3 3 3 3 3 3 3 3 3 3 3 3                    \
	   queues 0 1 2 3                                         \
     	   preemption 0 1 1 1                                     \
	   sched-file preempt_gates.sched

    <file> is multi-line, with each line being of the following format:
    <cmd> <gate mask> <interval in nanoseconds>

    For this case, two new commands are introduced:

    "H" for 'set gates and hold'
    "R" for 'set gates and release'

    H 0x01 300
    R 0x03 500



Testing this RFC
================

For testing the patches of this RFC only, you can refer to the samples and
helper script being added to samples/tsn/ and the use the 'mqprio' qdisc to
setup the priorities to Tx queues mapping, together with the 'cbs' qdisc to
configure the HW shaper of the i210 controller:

1) Setup priorities to traffic classes to hardware queues mapping
$ tc qdisc replace dev enp3s0 parent root mqprio num_tc 3 \
     map 2 2 1 0 2 2 2 2 2 2 2 2 2 2 2 2 queues 1@0 1@1 2@2 hw 0

2) Check scheme. You want to get the inner qdiscs ID from the bottom up
$ tc -g  class show dev enp3s0

Ex.:
+---(802a:3) mqprio
|    +---(802a:6) mqprio
|    +---(802a:7) mqprio
|
+---(802a:2) mqprio
|    +---(802a:5) mqprio
|
+---(802a:1) mqprio
     +---(802a:4) mqprio

 * Here '802a:4' is Tx Queue #0 and '802a:5' is Tx Queue #1.

3) Calculate CBS parameters for classes A and B. i.e. BW for A is 20Mbps and
   for B is 10Mbps:
$ ./samples/tsn/calculate_cbs_params.py -A 20000 -a 1500 -B 10000 -b 1500

4) Configure CBS for traffic class A (priority 3) as provided by the script:
$ tc qdisc replace dev enp3s0 parent 802a:4 cbs locredit -1470 \
     hicredit 30 sendslope -980000 idleslope 20000

5) Configure CBS for traffic class B (priority 2):
$ tc qdisc replace dev enp3s0 parent 802a:5 cbs \
     locredit -1485 hicredit 31 sendslope -990000 idleslope 10000

6) Run Listener, compiled from samples/tsn/listener.c
$ ./listener -i enp3s0

7) Run Talker for class A (prio 3 here), compiled from samples/tsn/talker.c
$ ./talker -i enp3s0 -p 3

 * The bandwidth displayed on the listener output at this stage should be very
   close to the one configured for class A.

8) You can also run a Talker for class B (prio 2 here)
$ ./talker -i enp3s0 -p 2

 * The bandwidth displayed on the listener output now should increase to very
   close to the one configured for class A + class B.

Authors
=======
 - Andre Guedes <andre.guedes@intel.com>
 - Ivan Briano <ivan.briano@intel.com>
 - Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
 - Vinicius Gomes <vinicius.gomes@intel.com>


Andre Guedes (2):
  igb: Add support for CBS offload
  samples/tsn: Add script for calculating CBS config

Jesus Sanchez-Palencia (1):
  sample: Add TSN Talker and Listener examples

Vinicius Costa Gomes (2):
  net/sched: Introduce the user API for the CBS shaper
  net/sched: Introduce Credit Based Shaper (CBS) qdisc

 drivers/net/ethernet/intel/igb/e1000_defines.h |  23 ++
 drivers/net/ethernet/intel/igb/e1000_regs.h    |   8 +
 drivers/net/ethernet/intel/igb/igb.h           |   6 +
 drivers/net/ethernet/intel/igb/igb_main.c      | 349 +++++++++++++++++++++++++
 include/linux/netdevice.h                      |   1 +
 include/uapi/linux/pkt_sched.h                 |  29 ++
 net/sched/Kconfig                              |  11 +
 net/sched/Makefile                             |   1 +
 net/sched/sch_cbs.c                            | 286 ++++++++++++++++++++
 samples/tsn/calculate_cbs_params.py            | 112 ++++++++
 samples/tsn/listener.c                         | 254 ++++++++++++++++++
 samples/tsn/talker.c                           | 136 ++++++++++
 12 files changed, 1216 insertions(+)
 create mode 100644 net/sched/sch_cbs.c
 create mode 100755 samples/tsn/calculate_cbs_params.py
 create mode 100644 samples/tsn/listener.c
 create mode 100644 samples/tsn/talker.c
