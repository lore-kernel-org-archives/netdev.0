From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [RFC net-next 4/5] sample: Add TSN Talker and Listener examples
Date: Thu, 31 Aug 2017 18:26:24 -0700
Message-ID: <20170901012625.14838-5-vinicius.gomes@intel.com>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        intel-wired-lan@lists.osuosl.org, andre.guedes@intel.com,
        ivan.briano@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54382 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750952AbdIAB0a (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 21:26:30 -0400
In-Reply-To: <20170901012625.14838-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>

Add two examples so one can easily test a 'TSN distributed system'
running with standard kernel interfaces. Both 'talker' and 'listener'
sides are provided, and use a AF_PACKET for Tx / Rx of frames.

Running the examples is rather simple.
For the talker, just the interface and SO_PRIORITY are expected as
parameters:

$ ./talker -i enp3s0 -p 3

For the listener, only the interface is needed:

$ ./listener -i enp3s0

The multicast MAC address being used is currently hardcoded on both
examples for simplicity.

Note that the listener side uses a BPF filter so only frames sent to
the correct "stream" destination address are received by the socket.
If you modify the address used by the talker, you must also adapt
the BPF filter otherwise no frames will be received by the socket.

The listener example will print the rate of packets reception after
every 1 second. This makes it easier to verify if the bandwidth
configured for a traffic class is being respected or not.

Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Signed-off-by: Andre Guedes <andre.guedes@intel.com>
Signed-off-by: Iván Briano <ivan.briano@intel.com>
---
 samples/tsn/listener.c | 254 +++++++++++++++++++++++++++++++++++++++++++++++++
 samples/tsn/talker.c   | 136 ++++++++++++++++++++++++++
 2 files changed, 390 insertions(+)
 create mode 100644 samples/tsn/listener.c
 create mode 100644 samples/tsn/talker.c

diff --git a/samples/tsn/listener.c b/samples/tsn/listener.c
new file mode 100644
index 000000000000..2d17bdfbea99
--- /dev/null
+++ b/samples/tsn/listener.c
@@ -0,0 +1,254 @@
+/*
+ * Copyright (c) 2017, Intel Corporation
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ *     * Redistributions of source code must retain the above copyright notice,
+ *       this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Intel Corporation nor the names of its contributors
+ *       may be used to endorse or promote products derived from this software
+ *       without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
+ * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
+ * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
+ * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
+ * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
+ * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
+ * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
+ * OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <alloca.h>
+#include <argp.h>
+#include <arpa/inet.h>
+#include <inttypes.h>
+#include <linux/filter.h>
+#include <linux/if.h>
+#include <linux/if_ether.h>
+#include <linux/if_packet.h>
+#include <poll.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <sys/timerfd.h>
+#include <unistd.h>
+
+#define MAX_FRAME_SIZE 1500
+
+/* XXX: If this address is changed, the BPF filter must be adjusted. */
+static uint8_t multicast_macaddr[] = { 0xBB, 0xAA, 0xBB, 0xAA, 0xBB, 0xAA };
+static char ifname[IFNAMSIZ];
+static uint64_t data_count;
+static int arg_count;
+
+/*
+ * BPF Filter so we only receive frames from the destination MAC address of our
+ * SRP stream. This is hardcoded in multicast_macaddr[].
+ */
+static struct sock_filter dst_addr_filter[] = {
+	{ 0x20,  0,  0, 0000000000 }, /* Load DST address: first 32bits only */
+	{ 0x15,  0,  3, 0xbbaabbaa }, /* Compare with first 32bits from MAC */
+	{ 0x28,  0,  0, 0x00000004 }, /* Load DST address: remaining 16bits */
+	{ 0x15,  0,  1, 0x0000bbaa }, /* Compare with last 16bits from MAC */
+	{ 0x06,  0,  0, 0xffffffff },
+	{ 0x06,  0,  0, 0000000000 }, /* Ret 0. Jump here if any mismatches. */
+};
+
+/* BPF program */
+static struct sock_fprog bpf = {
+	.len = 6, /* Number of instructions on BPF filter */
+	.filter = dst_addr_filter,
+};
+
+static struct argp_option options[] = {
+	{"ifname", 'i', "IFNAME", 0, "Network Interface" },
+	{ 0 }
+};
+
+static error_t parser(int key, char *arg, struct argp_state *s)
+{
+	switch (key) {
+	case 'i':
+		strncpy(ifname, arg, sizeof(ifname) - 1);
+		arg_count++;
+		break;
+	case ARGP_KEY_END:
+		if (arg_count < 1)
+			argp_failure(s, 1, 0, "Options missing. Check --help");
+		break;
+	}
+
+	return 0;
+}
+
+static struct argp argp = { options, parser };
+
+static int setup_1s_timer(void)
+{
+	struct itimerspec tspec = { 0 };
+	int fd, res;
+
+	fd = timerfd_create(CLOCK_MONOTONIC, 0);
+	if (fd < 0) {
+		perror("Couldn't create timer");
+		return -1;
+	}
+
+	tspec.it_value.tv_sec = 1;
+	tspec.it_interval.tv_sec = 1;
+
+	res = timerfd_settime(fd, 0, &tspec, NULL);
+	if (res < 0) {
+		perror("Couldn't set timer");
+		close(fd);
+		return -1;
+	}
+
+	return fd;
+}
+
+static int setup_socket(void)
+{
+	struct sockaddr_ll sk_addr = {
+		.sll_family = AF_PACKET,
+		.sll_protocol = htons(ETH_P_TSN),
+	};
+	struct packet_mreq mreq;
+	struct ifreq req;
+	int fd, res;
+
+	fd = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_TSN));
+	if (fd < 0) {
+		perror("Couldn't open socket");
+		return -1;
+	}
+
+	res = setsockopt(fd, SOL_SOCKET, SO_ATTACH_FILTER, &bpf, sizeof(bpf));
+	if (res < 0) {
+		perror("Couldn't attach bpf filter");
+		goto err;
+	}
+
+	strncpy(req.ifr_name, ifname, sizeof(req.ifr_name));
+	res = ioctl(fd, SIOCGIFINDEX, &req);
+	if (res < 0) {
+		perror("Couldn't get interface index");
+		goto err;
+	}
+
+	sk_addr.sll_ifindex = req.ifr_ifindex;
+	res = bind(fd, (struct sockaddr *) &sk_addr, sizeof(sk_addr));
+	if (res < 0) {
+		perror("Couldn't bind() to interface");
+		goto err;
+	}
+
+	/* Use PACKET_ADD_MEMBERSHIP to add a binding to the Multicast Addr */
+	mreq.mr_ifindex = sk_addr.sll_ifindex;
+	mreq.mr_type = PACKET_MR_MULTICAST;
+	mreq.mr_alen = ETH_ALEN;
+	memcpy(&mreq.mr_address, multicast_macaddr, ETH_ALEN);
+
+	res = setsockopt(fd, SOL_PACKET, PACKET_ADD_MEMBERSHIP,
+				&mreq, sizeof(struct packet_mreq));
+	if (res < 0) {
+		perror("Couldn't set PACKET_ADD_MEMBERSHIP");
+		goto err;
+	}
+
+	return fd;
+
+err:
+	close(fd);
+	return -1;
+}
+
+static void recv_packet(int fd)
+{
+	uint8_t *data = alloca(MAX_FRAME_SIZE);
+	ssize_t n = recv(fd, data, MAX_FRAME_SIZE, 0);
+
+	if (n < 0) {
+		perror("Failed to receive data");
+		return;
+	}
+
+	if (n != MAX_FRAME_SIZE)
+		printf("Size mismatch: expected %d, got %zd\n",
+		       MAX_FRAME_SIZE, n);
+
+	data_count += n;
+}
+
+static void report_bw(int fd)
+{
+	uint64_t expirations;
+	ssize_t n = read(fd, &expirations, sizeof(uint64_t));
+
+	if (n < 0) {
+		perror("Couldn't read timerfd");
+		return;
+	}
+
+	if (expirations != 1)
+		printf("Something went wrong with timerfd\n");
+
+	/* Report how much data was received in 1s. */
+	printf("Data rate: %zu kbps\n", (data_count * 8) / 1000);
+
+	data_count = 0;
+}
+
+int main(int argc, char *argv[])
+{
+	int sk_fd, timer_fd, res;
+	struct pollfd fds[2];
+
+	argp_parse(&argp, argc, argv, 0, NULL, NULL);
+
+	sk_fd = setup_socket();
+	if (sk_fd < 0)
+		return 1;
+
+	timer_fd = setup_1s_timer();
+	if (timer_fd < 0) {
+		close(sk_fd);
+		return 1;
+	}
+
+	fds[0].fd = sk_fd;
+	fds[0].events = POLLIN;
+	fds[1].fd = timer_fd;
+	fds[1].events = POLLIN;
+
+	printf("Waiting for packets...\n");
+
+	while (1) {
+		res = poll(fds, 2, -1);
+		if (res < 0) {
+			perror("Error on poll()");
+			goto err;
+		}
+
+		if (fds[0].revents & POLLIN)
+			recv_packet(fds[0].fd);
+
+		if (fds[1].revents & POLLIN)
+			report_bw(fds[1].fd);
+	}
+
+err:
+	close(timer_fd);
+	close(sk_fd);
+	return 1;
+}
diff --git a/samples/tsn/talker.c b/samples/tsn/talker.c
new file mode 100644
index 000000000000..35e6f99b48f6
--- /dev/null
+++ b/samples/tsn/talker.c
@@ -0,0 +1,136 @@
+/*
+ * Copyright (c) 2017, Intel Corporation
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ *     * Redistributions of source code must retain the above copyright notice,
+ *       this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Intel Corporation nor the names of its contributors
+ *       may be used to endorse or promote products derived from this software
+ *       without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
+ * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
+ * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
+ * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
+ * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
+ * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
+ * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
+ * OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <alloca.h>
+#include <argp.h>
+#include <arpa/inet.h>
+#include <inttypes.h>
+#include <linux/if.h>
+#include <linux/if_ether.h>
+#include <linux/if_packet.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <unistd.h>
+
+#define MAX_FRAME_SIZE 1500
+
+static uint8_t multicast_macaddr[] = { 0xBB, 0xAA, 0xBB, 0xAA, 0xBB, 0xAA };
+static char ifname[IFNAMSIZ];
+static int prio = -1;
+static int arg_count;
+
+static struct argp_option options[] = {
+	{"ifname", 'i', "IFNAME", 0, "Network Interface" },
+	{"prio", 'p', "NUM", 0, "SO_PRIORITY to be set in socket" },
+	{ 0 }
+};
+
+static error_t parser(int key, char *arg, struct argp_state *s)
+{
+	switch (key) {
+	case 'i':
+		strncpy(ifname, arg, sizeof(ifname) - 1);
+		arg_count++;
+		break;
+	case 'p':
+		prio = atoi(arg);
+		if (prio < 0)
+			argp_failure(s, 1, 0, "Priority must be >=0\n");
+		arg_count++;
+		break;
+	case ARGP_KEY_END:
+		if (arg_count < 2)
+			argp_failure(s, 1, 0,
+				     "Options missing. Check --help\n");
+		break;
+	}
+
+	return 0;
+}
+
+static struct argp argp = { options, parser };
+
+int main(int argc, char *argv[])
+{
+	struct sockaddr_ll dst_ll_addr = {
+		.sll_family = AF_PACKET,
+		.sll_protocol = htons(ETH_P_TSN),
+		.sll_halen = ETH_ALEN,
+	};
+	struct ifreq req;
+	uint8_t *payload;
+	int fd, res;
+
+	argp_parse(&argp, argc, argv, 0, NULL, NULL);
+
+	fd = socket(AF_PACKET, SOCK_DGRAM, htons(ETH_P_TSN));
+	if (fd < 0) {
+		perror("Couldn't open socket");
+		return 1;
+	}
+
+	strncpy(req.ifr_name, ifname, sizeof(req.ifr_name));
+	res = ioctl(fd, SIOCGIFINDEX, &req);
+	if (res < 0) {
+		perror("Couldn't get interface index");
+		goto err;
+	}
+
+	dst_ll_addr.sll_ifindex = req.ifr_ifindex;
+	memcpy(&dst_ll_addr.sll_addr, multicast_macaddr, ETH_ALEN);
+
+	res = setsockopt(fd, SOL_SOCKET, SO_PRIORITY, &prio, sizeof(prio));
+	if (res < 0) {
+		perror("Couldn't set priority");
+		goto err;
+	}
+
+	payload = alloca(MAX_FRAME_SIZE);
+	memset(payload, 0xBE, MAX_FRAME_SIZE);
+
+	printf("Sending packets...\n");
+
+	while (1) {
+		ssize_t n = sendto(fd, payload, MAX_FRAME_SIZE, 0,
+				(struct sockaddr *) &dst_ll_addr,
+				sizeof(dst_ll_addr));
+
+		if (n < 0)
+			perror("Failed to send data");
+
+		/* Sleep for 500us to avoid starvation from a 20Mbps stream. */
+		usleep(500);
+	}
+
+err:
+	close(fd);
+	return 1;
+}
-- 
2.14.1
