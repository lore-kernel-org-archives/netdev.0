From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [next-queue PATCH v9 0/6] TSN: Add qdisc based config interface for CBS
Date: Mon, 16 Oct 2017 18:01:22 -0700
Message-ID: <20171017010128.22141-1-vinicius.gomes@intel.com>
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10853 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752981AbdJQBBn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 21:01:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Changes from v8:
 - Add an explicit padding field to the tc_cbs_qopt struct, as pointed
   out by David Laight;

Changes from v7:
 - Fixed comments from Eric Dumazet and Ivan Khoronzhuk;

Changes since v6:
 - Fixed compilation for 32bit arches;
 - Aligned the behaviour of .select_queue() of the mq qdisc to be the
   same as mqprio;

Changes since v5:
 - Fixed comments from Jiri Pirko;

Changes since v4:
 - Added a software implementation of the CBS algorithm;

Changes since v3:
 - None, only a clean patchset without old patches;

Changes since v2:
 - squashed the patch introducing the userspace API into the patch
   implementing CBS;

Changes since v1:
 - Solved the mqprio dependency;
 - Fixed a mqprio bug, that caused the inner qdisc to have a wrong
   dev_queue associated with it;

Changes from the RFC:
 - Fixed comments from Henrik Austad;
 - Simplified the Qdisc, using the generic implementation of callbacks
   where possible;
 - Small refactor on the driver (igb) code;

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


Testing this RFC
================

Attached to this cover letter are:
 - calculate_cbs_params.py: A Python script to calculate the
   parameters to the CBS queueing discipline;
 - tsn-talker.c: A sample C implementation of the talker side of a stream;
 - tsn-listener.c: A sample C implementation of the listener side of a
   stream;

For testing the patches of this series, you may want to use the
attached samples to this cover letter and use the 'mqprio' qdisc to
setup the priorities to Tx queues mapping, together with the 'cbs'
qdisc to configure the HW shaper of the i210 controller:

1) Setup priorities to traffic classes to hardware queues mapping
$ tc qdisc replace dev ens4 handle 100: parent root mqprio num_tc 3 \
     map 2 2 1 0 2 2 2 2 2 2 2 2 2 2 2 2 queues 1@0 1@1 2@2 hw 0

For a more detailed explanation, see mqprio(8), in short, this command
will map traffic with priority 3 to the hardware queue 0, traffic with
priority 2 to hardware queue 1, and the rest will be mapped to
hardware queues 2 and 3.

2) Check scheme. You want to get the inner qdiscs ID from the bottom up
$ tc -g class show dev ens4

Ex.:
+---(100:3) mqprio
|    +---(100:6) mqprio
|    +---(100:7) mqprio
|
+---(100:2) mqprio
|    +---(100:5) mqprio
|
+---(100:1) mqprio
     +---(100:4) mqprio

* Here '100:4' is Tx Queue #0 and '100:5' is Tx Queue #1.

3) Calculate CBS parameters for classes A and B. i.e. BW for A is 20Mbps and
   for B is 10Mbps:
$ calc_cbs_params.py -A 20000 -a 1500 -B 10000 -b 1500

4) Configure CBS for traffic class A (priority 3) as provided by the script:
$ tc qdisc replace dev ens4 parent 100:4 cbs locredit -1470 \
     hicredit 30 sendslope -980000 idleslope 20000

5) Configure CBS for traffic class B (priority 2):
$ tc qdisc replace dev ens4 parent 100:5 cbs \
     locredit -1485 hicredit 31 sendslope -990000 idleslope 10000

6) Run Listener:
$ ./tsn-listener -d 01:AA:AA:AA:AA:AA -i ens4 -s 1500

7) Run Talker for class A (prio 3 here), compiled from samples/tsn/talker.c
$ ./tsn-talker -d 01:AA:AA:AA:AA:AA -i ens4 -p 3 -s 1500

 * The bandwidth displayed on the listener output at this stage should be very
   close to the one configured for class A.

8) You can also run a Talker for class B (prio 2 here and using a
different address):
$ ./tsn-talker -d 01:BB:BB:BB:BB:BB -i ens4 -p 2 -s 1500


Authors
=======
 - Andre Guedes <andre.guedes@intel.com>
 - Ivan Briano <ivan.briano@intel.com>
 - Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
 - Vinicius Gomes <vinicius.gomes@intel.com>


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


Annex: Sample files
===================

calc_cbs_params.py
--8<---------------cut here---------------start------------->8---
#!/usr/bin/env python
#
# Copyright (c) 2017, Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Intel Corporation nor the names of its contributors
#       may be used to endorse or promote products derived from this software
#       without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import argparse
import math

def print_cbs_params_for_class_a(args):
    idleslope = args.idleslope_a
    sendslope = idleslope - args.link_speed

    # According to 802.1Q-2014 spec, Annex L, hiCredit and
    # loCredit for SR class A are calculated following the
    # equations L-10 and L-12, respectively.
    hicredit = math.ceil(idleslope * args.frame_non_sr / args.link_speed)
    locredit = math.ceil(sendslope * args.frame_a / args.link_speed)

    print("tc qdisc add dev <IFNAME> parent <QDISC-ID> cbs idleslope %d sendslope %d hicredit %d locredit %d" % \
          (idleslope, sendslope, hicredit, locredit))

def print_cbs_params_for_class_b(args):
    idleslope = args.idleslope_b
    sendslope = idleslope - args.link_speed

    # Annex L doesn't present a straightforward equation to
    # calculate hiCredit for Class B so we have to derive it
    # based on generic equations presented in that Annex.
    #
    # L-3 is the primary equation to calculate hiCredit. Section
    # L.2 states that the 'maxInterferenceSize' for SR class B
    # is the maximum burst size for SR class A plus the
    # maxInterferenceSize from SR class A (which is equal to the
    # maximum frame from non-SR traffic).
    #
    # The maximum burst size for SR class A equation is shown in
    # L-16. Merging L-16 into L-3 we get the resulting equation
    # which calculates hiCredit B (refer to section L.3 in case
    # you're not familiar with the legend):
    #
    # hiCredit B = Rb * (     Mo         Ma   )
    #                     ---------- + ------
    #                      Ro - Ra       Ro
    #
    hicredit = math.ceil(idleslope * \
               ((args.frame_non_sr / (args.link_speed - args.idleslope_a)) + \
               (args.frame_a / args.link_speed)))

    # loCredit B is calculated following equation L-2.
    locredit = math.ceil(sendslope * args.frame_b / args.link_speed)

    print("tc qdisc add dev <IFNAME> parent <QDISC-ID> cbs idleslope %d sendslope %d hicredit %d locredit %d" % \
          (idleslope, sendslope, hicredit, locredit))

def main():
    parser = argparse.ArgumentParser()

    parser.add_argument('-S', dest='link_speed', default=1000000.0, type=float,
                        help='Link speed in kbps')
    parser.add_argument('-s', dest='frame_non_sr', default=1500.0, type=float,
                        help='Maximum frame size from non-SR traffic (MTU size'
                        'usually')
    parser.add_argument('-A', dest='idleslope_a', default=0, type=float,
                        help='Idleslope for SR class A in kbps')
    parser.add_argument('-a', dest='frame_a', default=0, type=float,
                        help='Maximum frame size for SR class A traffic')
    parser.add_argument('-B', dest='idleslope_b', default=0, type=float,
                        help='Idleslope for SR class B in kbps')
    parser.add_argument('-b', dest='frame_b', default=0, type=float,
                        help='Maximum frame size for SR class B traffic')

    args = parser.parse_args()

    if args.idleslope_a > 0:
        print_cbs_params_for_class_a(args)

    if args.idleslope_b > 0:
        print_cbs_params_for_class_b(args)

if __name__ == "__main__":
    main()
--8<---------------cut here---------------end--------------->8---

tsn-talker.c
--8<---------------cut here---------------start------------->8---
/*
 * Copyright (c) 2017, Intel Corporation
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Intel Corporation nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <alloca.h>
#include <argp.h>
#include <arpa/inet.h>
#include <inttypes.h>
#include <linux/if.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

#define MAGIC 0xCC

static uint8_t ifname[IFNAMSIZ];
static uint8_t macaddr[ETH_ALEN];
static int priority = -1;
static size_t size = 1500;
static uint64_t seq;
static int delay = -1;

static struct argp_option options[] = {
	{"dst-addr", 'd', "MACADDR", 0, "Stream Destination MAC address" },
	{"delay", 'D', "NUM", 0, "Delay (in us) between packet transmission" },
	{"ifname", 'i', "IFNAME", 0, "Network Interface" },
	{"prio", 'p', "NUM", 0, "SO_PRIORITY to be set in socket" },
	{"packet-size", 's', "NUM", 0, "Size of packets to be transmitted" },
	{ 0 }
};

static error_t parser(int key, char *arg, struct argp_state *state)
{
	int res;

	switch (key) {
	case 'd':
		res = sscanf(arg, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
					&macaddr[0], &macaddr[1], &macaddr[2],
					&macaddr[3], &macaddr[4], &macaddr[5]);
		if (res != 6) {
			printf("Invalid address\n");
			exit(EXIT_FAILURE);
		}

		break;
	case 'D':
		delay = atoi(arg);
		break;
	case 'i':
		strncpy(ifname, arg, sizeof(ifname) - 1);
		break;
	case 'p':
		priority = atoi(arg);
		break;
	case 's':
		size = atoi(arg);
		break;
	}

	return 0;
}

static struct argp argp = { options, parser };

int main(int argc, char *argv[])
{
	int fd, res;
	struct ifreq req;
	uint8_t *data;
	struct sockaddr_ll sk_addr = {
		.sll_family = AF_PACKET,
		.sll_protocol = htons(ETH_P_TSN),
		.sll_halen = ETH_ALEN,
	};

	argp_parse(&argp, argc, argv, 0, NULL, NULL);

	fd = socket(AF_PACKET, SOCK_DGRAM, htons(ETH_P_TSN));
	if (fd < 0) {
		perror("Couldn't open socket");
		return 1;
	}

	strncpy(req.ifr_name, ifname, sizeof(req.ifr_name));
	res = ioctl(fd, SIOCGIFINDEX, &req);
	if (res < 0) {
		perror("Couldn't get interface index");
		goto err;
	}

	sk_addr.sll_ifindex = req.ifr_ifindex;
	memcpy(&sk_addr.sll_addr, macaddr, ETH_ALEN);

	if (priority != -1) {
		res = setsockopt(fd, SOL_SOCKET, SO_PRIORITY, &priority,
							sizeof(priority));
		if (res < 0) {
			perror("Couldn't set priority");
			goto err;
		}

	}

	data = alloca(size);
	memset(data, MAGIC, size);

	printf("Sending packets...\n");

	while (1) {
		uint64_t *seq_ptr = (uint64_t *) &data[0];
		ssize_t n;

		*seq_ptr = seq++;

		n = sendto(fd, data, size, 0, (struct sockaddr *) &sk_addr,
							sizeof(sk_addr));
		if (n < 0)
			perror("Failed to send data");

		if (delay > 0)
			usleep(delay);
	}

	close(fd);
	return 0;

err:
	close(fd);
	return 1;
}
--8<---------------cut here---------------end--------------->8---

tsn-listener.c
--8<---------------cut here---------------start------------->8---
/*
 * Copyright (c) 2017, Intel Corporation
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Intel Corporation nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <alloca.h>
#include <argp.h>
#include <arpa/inet.h>
#include <inttypes.h>
#include <linux/if.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <poll.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/timerfd.h>
#include <unistd.h>

static uint8_t ifname[IFNAMSIZ];
static uint8_t macaddr[ETH_ALEN];
static uint64_t data_count;
static int size = 1500;
static time_t interval = 1;
static bool check_seq = false;
static uint64_t expected_seq;

static struct argp_option options[] = {
	{"check-seq", 'c', NULL, 0, "Check sequence number within packet" },
	{"dst-addr", 'd', "MACADDR", 0, "Stream Destination MAC address" },
	{"ifname", 'i', "IFNAME", 0, "Network Interface" },
	{"interval", 'I', "SEC", 0, "Interval between bandwidth reports" },
	{"packet-size", 's', "NUM", 0, "Expected packet size" },
	{ 0 }
};

static error_t parser(int key, char *arg, struct argp_state *state)
{
	int res;

	switch (key) {
	case 'c':
		check_seq = true;
		break;
	case 'd':
		res = sscanf(arg, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
					&macaddr[0], &macaddr[1], &macaddr[2],
					&macaddr[3], &macaddr[4], &macaddr[5]);
		if (res != 6) {
			printf("Invalid address\n");
			exit(EXIT_FAILURE);
		}

		break;
	case 'i':
		strncpy(ifname, arg, sizeof(ifname) - 1);
		break;
	case 'I':
		interval = atoi(arg);
		break;
	case 's':
		size = atoi(arg);
		break;
	}

	return 0;
}

static struct argp argp = { options, parser };

static int setup_timer(void)
{
	int fd, res;
	struct itimerspec tspec = { 0 };

	fd = timerfd_create(CLOCK_MONOTONIC, 0);
	if (fd < 0) {
		perror("Couldn't create timer");
		return -1;
	}

	tspec.it_value.tv_sec = interval;
	tspec.it_interval.tv_sec = interval;

	res = timerfd_settime(fd, 0, &tspec, NULL);
	if (res < 0) {
		perror("Couldn't set timer");
		close(fd);
		return -1;
	}

	return fd;
}

static int setup_socket(void)
{
	int fd, res;
	struct sockaddr_ll sk_addr = {
		.sll_family = AF_PACKET,
		.sll_protocol = htons(ETH_P_TSN),
	};

	fd = socket(AF_PACKET, SOCK_DGRAM, htons(ETH_P_TSN));
	if (fd < 0) {
		perror("Couldn't open socket");
		return -1;
	}

	/* If user provided a network interface, bind() to it. */
	if (ifname[0] != '\0') {
		struct ifreq req;

		strncpy(req.ifr_name, ifname, sizeof(req.ifr_name));
		res = ioctl(fd, SIOCGIFINDEX, &req);
		if (res < 0) {
			perror("Couldn't get interface index");
			goto err;
		}

		sk_addr.sll_ifindex = req.ifr_ifindex;

		res = bind(fd, (struct sockaddr *) &sk_addr, sizeof(sk_addr));
		if (res < 0) {
			perror("Couldn't bind() to interface");
			goto err;
		}
	}

	/* If user provided the stream destination address, set it as multicast
	 * address.
	 */
	if (macaddr[0] != '\0') {
		struct packet_mreq mreq;

		mreq.mr_ifindex = sk_addr.sll_ifindex;
		mreq.mr_type = PACKET_MR_MULTICAST;
		mreq.mr_alen = ETH_ALEN;
		memcpy(&mreq.mr_address, macaddr, ETH_ALEN);

		res = setsockopt(fd, SOL_PACKET, PACKET_ADD_MEMBERSHIP,
					&mreq, sizeof(struct packet_mreq));
		if (res < 0) {
			perror("Couldn't set PACKET_ADD_MEMBERSHIP");
			goto err;
		}
	}

	return fd;

err:
	close(fd);
	return -1;
}

static void recv_packet(int fd)
{
	uint8_t *data = alloca(size);
	ssize_t n = recv(fd, data, size, 0);

	if (n < 0) {
		perror("Failed to receive data");
		return;
	}

	if (n != size)
		printf("Size mismatch: expected %d, got %d\n", size, n);

	if (check_seq) {
		uint64_t *seq = (uint64_t *) &data[0];

		/* If 'expected_seq' is equal to zero, it means this is the
		 * first packet we received so we don't know what sequence
		 * number to expect.
		 */
		if (expected_seq == 0)
			expected_seq = *seq;

		if (*seq != expected_seq) {
			printf("Sequence mismatch: expected %llu, got %llu\n",
					expected_seq, *seq);

			expected_seq = *seq;
		}

		expected_seq++;
	}

	data_count += n;
}

static void report_bw(int fd)
{
	uint64_t expirations;
	ssize_t n = read(fd, &expirations, sizeof(uint64_t));

	if (n < 0) {
		perror("Couldn't read timerfd");
		return;
	}

	if (expirations != 1)
		printf("Some went wrong with timerfd\n");

	printf("Receiving data rate: %llu kbps\n", (data_count * 8) / (1000 * interval));

	data_count = 0;
}

int main(int argc, char *argv[])
{
	int sk_fd, timer_fd, res;
	struct pollfd fds[2];

	argp_parse(&argp, argc, argv, 0, NULL, NULL);

	sk_fd = setup_socket();
	if (sk_fd < 0)
		return 1;

	timer_fd = setup_timer();
	if (timer_fd < 0) {
		close(sk_fd);
		return 1;
	}

	fds[0].fd = sk_fd;
	fds[0].events = POLLIN;
	fds[1].fd = timer_fd;
	fds[1].events = POLLIN;

	printf("Waiting for packets...\n");

	while (1) {
		res = poll(fds, 2, -1);
		if (res < 0) {
			perror("Error on poll()");
			goto err;
		}

		if (fds[0].revents & POLLIN)
			recv_packet(fds[0].fd);

		if (fds[1].revents & POLLIN) {
			report_bw(fds[1].fd);
		}
	}

	close(timer_fd);
	close(sk_fd);
	return 0;

err:
	close(timer_fd);
	close(sk_fd);
	return 1;
}
--8<---------------cut here---------------end--------------->8---
