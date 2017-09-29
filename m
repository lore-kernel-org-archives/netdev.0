From: Rodney Cummings <rodney.cummings@ni.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Fri, 29 Sep 2017 20:44:38 +0000
Message-ID: <DM2PR0401MB1389A950EAC6FB54D4186B9C927E0@DM2PR0401MB1389.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00010702.pphosted.com ([148.163.158.57]:32853 "EHLO
        mx0b-00010702.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752123AbdI2VPJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 17:15:09 -0400
Received: from pps.filterd (m0098778.ppops.net [127.0.0.1])
        by mx0b-00010702.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8TKfT69014700
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 15:44:41 -0500
Received: from nam03-co1-obe.outbound.protection.outlook.com (mail-co1nam03lp0017.outbound.protection.outlook.com [216.32.181.17])
        by mx0b-00010702.pphosted.com with ESMTP id 2d8a0ufxck-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 15:44:41 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am posting my reply to this thread after subscribing, so I apologize
if the archive happens to attach it to the wrong thread.

First, I'd like to say that I strongly support this RFC.=20
We need Linux interfaces for IEEE 802.1 TSN features.

Although I haven't looked in detail, the proposal for CBS looks good.=20
My questions/concerns are more related to future work, such for 802.1Qbv
(scheduled traffic).

1. Question: From an 802.1 perspective, is this RFC intended to support=20
end-station (e.g. NIC in host), bridges (i.e. DSA), or both?

This is very important to clarify, because the usage of this interface
will be very different for one or the other.=20

For a bridge, the user code typically represents a remote management=20
protocol (e.g. SNMP, NETCONF, RESTCONF), and this interface is=20
expected to align with the specifications of 802.1Q clause 12,=20
which serves as the information model for management. Historically,
a standard kernel interface for management hasn't been viewed as
essential, but I suppose it wouldn't hurt.

For an end station, the user code can be an implementation of SRP
(802.1Q clause 35), or it can be an application-specific=20
protocol (e.g. industrial fieldbus) that exchanges data according
to P802.1Qcc clause 46. Either way, the top-level user interface
is designed for individual streams, not queues and shapers. That
implies some translation code between that top-level interface=20
and this sort of kernel interface.

As a specific end-station example, for CBS, 802.1Q-2014 subclause=20
34.6.1 requires "per-stream queues" in the Talker end-station.
I don't see 34.6.1 represented in the proposed RFC, but that's
okay... maybe per-stream queues are implemented in user code.
Nevertheless, if that is the assumption, I think we need to=20
clarify, especially in examples.

2. Suggestion: Do not assume that a time-aware (i.e. scheduled)=20
end-station will always use 802.1Qbv.

For those who are subscribed to the 802.1 mailing list,=20
I'd suggest a read of draft P802.1Qcc/D1.6, subclause U.1=20
of Annex U. Subclause U.1 assumes that bridges in the network use=20
802.1Qbv, and then it poses the question of what an end-station
Talker should do. If the end-station also uses 802.1Qbv,=20
and that end-station transmits multiple streams, 802.1Qbv is
a bad implementation. The reason is that the scheduling
(i.e. order in time) of each stream cannot be controlled, which
in turn means that the CNC (network manager) cannot optimize
the 802.1Qbv schedules in bridges. The preferred technique
is to use "per-stream scheduling" in each Talker, so that
the CNC can create an optimal schedules (i.e. best determinism).

I'm aware of a small number of proprietary CNC implementations for=20
802.1Qbv in bridges, and they are generally assuming per-stream
scheduling in end-stations (Talkers).

The i210 NIC's LaunchTime can be used to implement per-stream=20
scheduling. I haven't looked at SO_TXTIME in detail, but it sounds
like per-stream scheduling. If so, then we already have the
fundamental building blocks for a complete implementation
of a time-aware end-station.

If we answer the preceding question #1 as "end-station only",
I would recommend avoiding 802.1Qbv in this interface. There
isn't really anything wrong with it per-se, but it would lead
developers down the wrong path.

Rodney Cummings (National Instruments)
Editor, IEEE P802.1Qcc

---
Hi,

This patchset is an RFC on a proposal of how the Traffic Control subsystem =
can
be used to offload the configuration of traffic shapers into network device=
s
that provide support for them in HW. Our goal here is to start upstreaming
support for features related to the Time-Sensitive Networking (TSN) set of
standards into the kernel.

As part of this work, we've assessed previous public discussions related to=
 TSN
enabling: patches from Henrik Austad (Cisco), the presentation from Eric Ma=
nn
at Linux Plumbers 2012, patches from Gangfeng Huang (National Instruments) =
and
the current state of the OpenAVNU project (https://github.com/AVnu/OpenAvnu=
/).

Please note that the patches provided as part of this RFC are implementing =
what
is needed only for 802.1Qav (FQTSS) only, but we'd like to take advantage o=
f
this discussion and share our WIP ideas for the 802.1Qbv and 802.1Qbu inter=
faces
as well. The current patches are only providing support for HW offload of t=
he
configs.


Overview
=3D=3D=3D=3D=3D=3D=3D=3D

Time-sensitive Networking (TSN) is a set of standards that aim to address
resources availability for providing bandwidth reservation and bounded late=
ncy
on Ethernet based LANs. The proposal described here aims to cover mainly wh=
at is
needed to enable the following standards: 802.1Qat, 802.1Qav, 802.1Qbv and
802.1Qbu.

The initial target of this work is the Intel i210 NIC, but other controller=
s'
datasheet were also taken into account, like the Renesas RZ/A1H RZ/A1M grou=
p and
the Synopsis DesignWare Ethernet QoS controller.


Proposal
=3D=3D=3D=3D=3D=3D=3D=3D

Feature-wise, what is covered here are configuration interfaces for HW
implementations of the Credit-Based shaper (CBS, 802.1Qav), Time-Aware shap=
er
(802.1Qbv) and Frame Preemption (802.1Qbu). CBS is a per-queue shaper, whil=
e
Qbv and Qbu must be configured per port, with the configuration covering al=
l
queues. Given that these features are related to traffic shaping, and that =
the
traffic control subsystem already provides a queueing discipline that offlo=
ads
config into the device driver (i.e. mqprio), designing new qdiscs for the
specific purpose of offloading the config for each shaper seemed like a goo=
d
fit.

For steering traffic into the correct queues, we use the socket option
SO_PRIORITY and then a mechanism to map priority to traffic classes / Tx qu=
eues.
The qdisc mqprio is currently used in our tests.

As for the shapers config interface:

 * CBS (802.1Qav)

   This patchset is proposing a new qdisc called 'cbs'. Its 'tc' cmd line i=
s:
   $ tc qdisc add dev IFACE parent ID cbs locredit N hicredit M sendslope S=
 \
     idleslope I

   Note that the parameters for this qdisc are the ones defined by the
   802.1Q-2014 spec, so no hardware specific functionality is exposed here.


 * Time-aware shaper (802.1Qbv):

   The idea we are currently exploring is to add a "time-aware", priority b=
ased
   qdisc, that also exposes the Tx queues available and provides a mechanis=
m for
   mapping priority <-> traffic class <-> Tx queues in a similar fashion as
   mqprio. We are calling this qdisc 'taprio', and its 'tc' cmd line would =
be:

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

   Additionally, an option to set just one entry of the gate control list w=
ill
   also be provided by 'taprio':

   $ tc qdisc (...) \
        sched-row <row number> <cmd> <gate mask> <interval>  \
        [base-time <interval>] [cycle-time <interval>] \
        [extension-time <interval>]


 * Frame Preemption (802.1Qbu):

   To control even further the latency, it may prove useful to signal which
   traffic classes are marked as preemptable. For that, 'taprio' provides t=
he
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
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

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

3) Calculate CBS parameters for classes A and B. i.e. BW for A is 20Mbps an=
d
   for B is 10Mbps:
$ ./samples/tsn/calculate_cbs_params.py -A 20000 -a 1500 -B 10000 -b 1500

4) Configure CBS for traffic class A (priority 3) as provided by the script=
:
$ tc qdisc replace dev enp3s0 parent 802a:4 cbs locredit -1470 \
     hicredit 30 sendslope -980000 idleslope 20000

5) Configure CBS for traffic class B (priority 2):
$ tc qdisc replace dev enp3s0 parent 802a:5 cbs \
     locredit -1485 hicredit 31 sendslope -990000 idleslope 10000

6) Run Listener, compiled from samples/tsn/listener.c
$ ./listener -i enp3s0

7) Run Talker for class A (prio 3 here), compiled from samples/tsn/talker.c
$ ./talker -i enp3s0 -p 3

 * The bandwidth displayed on the listener output at this stage should be v=
ery
   close to the one configured for class A.

8) You can also run a Talker for class B (prio 2 here)
$ ./talker -i enp3s0 -p 2

 * The bandwidth displayed on the listener output now should increase to ve=
ry
   close to the one configured for class A + class B.

Authors
=3D=3D=3D=3D=3D=3D=3D
 - Andre Guedes <andre.guedes@xxxxxxxxx>
 - Ivan Briano <ivan.briano@xxxxxxxxx>
 - Jesus Sanchez-Palencia <jesus.sanchez-palencia@xxxxxxxxx>
 - Vinicius Gomes <vinicius.gomes@xxxxxxxxx>


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
 drivers/net/ethernet/intel/igb/igb_main.c      | 349 +++++++++++++++++++++=
++++
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
