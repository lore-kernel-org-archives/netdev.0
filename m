From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 10/10] test: add sendmsg zerocopy tests
Date: Thu, 20 Aug 2015 11:39:09 -0400
Message-ID: <1440085149-14742-1-git-send-email-willemb@google.com>
Cc: mst@redhat.com, jasowang@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:35963 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbbHTPjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 11:39:13 -0400
Received: by qgeb6 with SMTP id b6so30295229qge.3
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 08:39:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Introduce the tests uses to verify MSG_ZEROCOPY behavior:

snd_zerocopy:
  send zerocopy fragments out over the default route.

snd_zerocopy_lo:
  send data between a pair of local sockets and report throughput.

These tests are not suitable for inclusion in /tools/testing/selftest
as is, as they do not return a pass/fail verdict. Including them in
this RFC for demonstration, only.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 tools/testing/selftests/net/Makefile          |   2 +-
 tools/testing/selftests/net/snd_zerocopy.c    | 354 +++++++++++++++++
 tools/testing/selftests/net/snd_zerocopy_lo.c | 543 ++++++++++++++++++++++++++
 3 files changed, 898 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/net/snd_zerocopy.c
 create mode 100644 tools/testing/selftests/net/snd_zerocopy_lo.c

diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index fac4782..401a534 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -4,7 +4,7 @@ CFLAGS = -Wall -O2 -g
 
 CFLAGS += -I../../../../usr/include/
 
-NET_PROGS = socket psock_fanout psock_tpacket
+NET_PROGS = socket psock_fanout psock_tpacket snd_zerocopy snd_zerocopy_lo
 
 all: $(NET_PROGS)
 %: %.c
diff --git a/tools/testing/selftests/net/snd_zerocopy.c b/tools/testing/selftests/net/snd_zerocopy.c
new file mode 100644
index 0000000..da4647f
--- /dev/null
+++ b/tools/testing/selftests/net/snd_zerocopy.c
@@ -0,0 +1,354 @@
+#define _GNU_SOURCE
+
+#include <arpa/inet.h>
+#include <error.h>
+#include <errno.h>
+#include <limits.h>
+#include <linux/errqueue.h>
+#include <poll.h>
+#include <stdbool.h>
+#include <stdio.h>
+#include <stdint.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/socket.h>
+#include <sys/stat.h>
+#include <sys/time.h>
+#include <sys/types.h>
+#include <unistd.h>
+
+#define MSG_ZEROCOPY	0x4000000
+
+#define SK_FUDGE_FACTOR	2		/* allow for overhead in SNDBUF */
+#define BUFLEN		(400 * 1000)	/* max length of send call */
+#define DEST_PORT	9000
+
+uint16_t sent = 0xFFFF, acked = 0xFFFF;
+
+int cfg_batch_notify = 10;
+int cfg_num_runs = 16;
+size_t cfg_socksize = 1 << 20;
+int cfg_stress_sec;
+int cfg_verbose;
+bool cfg_zerocopy = false;
+
+static unsigned long gettime_now_ms(void)
+{
+	struct timeval tv;
+
+	gettimeofday(&tv, NULL);
+	return (tv.tv_sec * 1000) + (tv.tv_usec / 1000);
+}
+
+static void do_set_socksize(int fd)
+{
+	if (setsockopt(fd, SOL_SOCKET, SO_SNDBUFFORCE,
+		       &cfg_socksize, sizeof(cfg_socksize)))
+		error(1, 0, "setsockopt sndbufforce");
+
+	if (setsockopt(fd, SOL_SOCKET, SO_RCVBUFFORCE,
+		       &cfg_socksize, sizeof(cfg_socksize)))
+		error(1, 0, "setsockopt sndbufforce");
+}
+
+static bool do_read_notification(int fd)
+{
+	struct sock_extended_err *serr;
+	struct cmsghdr *cm;
+	struct msghdr msg = {};
+	char control[100];
+	uint16_t hi, lo;
+	int ret;
+
+	msg.msg_control = control;
+	msg.msg_controllen = sizeof(control);
+
+	ret = recvmsg(fd, &msg, MSG_DONTWAIT | MSG_ERRQUEUE);
+	if (ret == -1 && errno == EAGAIN)
+		return false;
+	if (ret == -1)
+		error(1, errno, "recvmsg notification");
+	if (msg.msg_flags & MSG_CTRUNC)
+		error(1, errno, "recvmsg notification: truncated");
+
+	cm = CMSG_FIRSTHDR(&msg);
+	if (!cm || cm->cmsg_level != SOL_IP ||
+	    (cm->cmsg_type != IP_RECVERR && cm->cmsg_type != IPV6_RECVERR))
+		error(1, 0, "cmsg: wrong type");
+
+	serr = (void *) CMSG_DATA(cm);
+	if (serr->ee_errno != 0 || serr->ee_origin != SO_EE_ORIGIN_ZEROCOPY)
+		error(1, 0, "serr: wrong type");
+
+	hi = serr->ee_data >> 16;
+	lo = serr->ee_data & 0xFFFF;
+
+	if (lo != ((acked + 1) & 0xFFFF))
+		error(1, 0, "notify: %u..%u, expected %u\n",
+		      lo, hi, (acked + 1) & 0xFFFF);
+	acked = hi;
+
+	if (cfg_verbose)
+		fprintf(stderr, "completed: %u..%u\n", lo, hi);
+
+	return true;
+}
+
+static void do_poll(int fd, int events, int timeout)
+{
+	struct pollfd pfd;
+	int ret;
+
+	pfd.fd = fd;
+	pfd.events = events;
+	pfd.revents = 0;
+
+	ret = poll(&pfd, 1, timeout);
+	if (ret == -1)
+		error(1, errno, "poll");
+	if (ret != 1)
+		error(1, 0, "poll timeout. events=0x%x acked=%u sent=%u",
+		      pfd.events, acked, sent);
+
+	if (cfg_verbose >= 2)
+		fprintf(stderr, "poll ok. events=0x%x revents=0x%x\n",
+			pfd.events, pfd.revents);
+}
+
+static void do_send(int fd, int len, int flags)
+{
+	static char data[BUFLEN];
+	struct msghdr msg = {};
+	struct iovec iov = {};
+	int ret;
+
+	if (len > BUFLEN)
+		error(1, 0, "write out of bounds");
+
+	iov.iov_base = data;
+	iov.iov_len = len;
+	msg.msg_iov = &iov;
+	msg.msg_iovlen = 1;
+
+	ret = sendmsg(fd, &msg, flags);
+	if (ret == -1)
+		error(1, errno, "sendmsg");
+	if (ret != len)
+		error(1, errno, "sendmsg: %u < %u", ret, len);
+
+	if (cfg_verbose >= 2)
+		fprintf(stderr, "  sent %6u B\n", len);
+
+	if (flags & MSG_ZEROCOPY && len) {
+		if (cfg_verbose)
+			fprintf(stderr, "    add %u\n", ++sent);
+		do_read_notification(fd);
+	}
+}
+
+/* wait for all outstanding notifications to arrive */
+static void wait_for_notifications(int fd)
+{
+	unsigned long tstop, tnow;
+
+	if (acked == sent)
+		return;
+
+	tnow = gettime_now_ms();
+	tstop = tnow + 10000;
+	do {
+		do_poll(fd, 0 /* POLLERR is always reported */, tstop - tnow);
+
+		while (do_read_notification(fd)) {}
+		if (acked == sent)
+			return;
+
+		tnow = gettime_now_ms();
+	} while (tnow < tstop);
+
+	error(1, 0, "notify timeout. acked=%u sent=%u", acked, sent);
+}
+
+static void run_test(int fd, int len_cp, int len_zc, int batch)
+{
+	int i;
+
+	fprintf(stderr, "\ncp=%u zc=%u batch=%u\n", len_cp, len_zc, batch);
+
+	if (acked != sent)
+		error(1, 0, "not empty when expected");
+
+	if (batch * BUFLEN * SK_FUDGE_FACTOR > cfg_socksize) {
+		batch = cfg_socksize / BUFLEN / SK_FUDGE_FACTOR;
+		if (!batch)
+			error(1, 0, "cannot batch: increase socksize ('-s')");
+	}
+
+	for (i = 0; i < cfg_num_runs; i++) {
+		if (len_cp) {
+			do_poll(fd, POLLOUT, 1000);
+			do_send(fd, len_cp, 0);
+		}
+
+		do_poll(fd, POLLOUT, 1000);
+		do_send(fd, len_zc, cfg_zerocopy ? MSG_ZEROCOPY : 0);
+
+		if (i % batch == 0)
+			wait_for_notifications(fd);
+	}
+
+	wait_for_notifications(fd);
+}
+
+static void run_single(int fd, int len, int batch)
+{
+	run_test(fd, 0, len, batch);
+}
+
+/* combine zerocopy fragments with regular fragments */
+static void run_mix_zerocopy(int fd, int len_cp, int len_zc)
+{
+	run_test(fd, len_cp, len_zc, 1);
+}
+
+static void run_tests(int fd)
+{
+	/* test basic use */
+	run_single(fd, 4096, 1);
+	run_single(fd, 1500, 1);
+	run_single(fd, 1472, 1);
+	run_single(fd, 32000, 1);
+	run_single(fd, 65000, 1);
+	run_single(fd, BUFLEN, 1);
+
+	/* test notification on copybreak: data fits in skb head, no frags */
+	run_single(fd, 1, 1);
+
+	/* test coalescing */
+	run_single(fd, 32000, 4);
+	run_single(fd, 3000, 10);
+	run_single(fd, 100, 100);
+
+	run_mix_zerocopy(fd, 2000, 2000);
+	run_mix_zerocopy(fd, 100, 100);
+	run_mix_zerocopy(fd, 100, 1500);	/* fits coalesce in skb head */
+	run_mix_zerocopy(fd, 100, BUFLEN - 100);
+	run_mix_zerocopy(fd, 2000, 2000);
+
+	run_mix_zerocopy(fd, 1000, 12000);
+	run_mix_zerocopy(fd, 12000, 1000);
+	run_mix_zerocopy(fd, 12000, 12000);
+	run_mix_zerocopy(fd, 16000, 16000);
+
+	/* test more realistic async notifications */
+	run_single(fd, 1472, cfg_batch_notify);
+	run_single(fd, 1, cfg_batch_notify);
+	run_single(fd, BUFLEN, cfg_batch_notify);
+}
+
+static void run_stress_test(int fd, int runtime_sec)
+{
+	const int max_batch = 32;
+	unsigned long tstop, i = 0;
+	int len, len_cp, batch;
+
+	cfg_socksize = BUFLEN * max_batch * SK_FUDGE_FACTOR;
+	do_set_socksize(fd);
+
+	tstop = gettime_now_ms() + (runtime_sec * 1000);
+	do {
+		len = random() % BUFLEN;
+
+		/* create some skbs with only zerocopy frags */
+		if (len && ((i % 200) < 100))
+			len_cp = random() % BUFLEN;
+		else
+			len_cp = 0;
+
+		batch = random() % max_batch;
+
+		fprintf(stderr, "stress: cnt=%lu len_cp=%u len=%u batch=%u\n",
+			i, len_cp, len, batch);
+		run_test(fd, len_cp, len, batch);
+
+		i++;
+	} while (gettime_now_ms() < tstop);
+}
+
+static void parse_opts(int argc, char **argv, struct in_addr *addr)
+{
+	int c;
+
+	addr->s_addr = 0;
+
+	while ((c = getopt(argc, argv, "b:H:n:s:S:vV:z")) != -1) {
+		switch (c) {
+		case 'b':
+			cfg_batch_notify = strtol(optarg, NULL, 0);
+			break;
+		case 'H':
+			if (inet_pton(AF_INET, optarg, addr) != 1)
+				error(1, 0, "inet_pton: could not parse host");
+			break;
+		case 'n':
+			cfg_num_runs = strtol(optarg, NULL, 0);
+			break;
+		case 's':
+			cfg_socksize = strtol(optarg, NULL, 0);
+			break;
+		case 'S':
+			cfg_stress_sec = strtol(optarg, NULL, 0);
+		case 'v':
+			cfg_verbose = 1;
+			break;
+		case 'V':
+			cfg_verbose = strtol(optarg, NULL, 0);
+			break;
+		case 'z':
+			cfg_zerocopy = true;
+			break;
+		}
+	}
+
+	if (addr->s_addr == 0)
+		error(1, 0, "host ('-H') argument required");
+
+	if (cfg_verbose) {
+		fprintf(stderr, "batch_notify:  %u\n", cfg_batch_notify);
+		fprintf(stderr, "num_runs:      %u\n", cfg_num_runs);
+		fprintf(stderr, "socksize:      %lu\n", cfg_socksize);
+		fprintf(stderr, "stress:        %u\n", cfg_stress_sec);
+		fprintf(stderr, "zerocopy:      %s\n", cfg_zerocopy ? "ON" : "OFF");
+	}
+}
+
+int main(int argc, char **argv)
+{
+	struct sockaddr_in addr = {};
+	int fd;
+
+	parse_opts(argc, argv, &addr.sin_addr);
+
+	fd = socket(PF_INET, SOCK_STREAM, 0);
+	if (fd == -1)
+		error(1, errno, "socket");
+
+	do_set_socksize(fd);
+
+	addr.sin_family = AF_INET;
+	addr.sin_port = htons(DEST_PORT);
+	if (connect(fd, (void *) &addr, sizeof(addr)))
+		error(1, errno, "connect");
+
+	if (cfg_num_runs)
+		run_tests(fd);
+
+	if (cfg_stress_sec)
+		run_stress_test(fd, cfg_stress_sec);
+
+	if (close(fd))
+		error(1, errno, "close");
+
+	fprintf(stderr, "OK. All tests passed\n");
+	return 0;
+}
diff --git a/tools/testing/selftests/net/snd_zerocopy_lo.c b/tools/testing/selftests/net/snd_zerocopy_lo.c
new file mode 100644
index 0000000..e7e3917
--- /dev/null
+++ b/tools/testing/selftests/net/snd_zerocopy_lo.c
@@ -0,0 +1,543 @@
+/* evaluate MSG_ZEROCOPY over the loopback interface */
+
+#define _GNU_SOURCE
+
+#include <arpa/inet.h>
+#include <error.h>
+#include <errno.h>
+#include <limits.h>
+#include <linux/errqueue.h>
+#include <linux/socket.h>
+#include <net/if.h>
+#include <netinet/ip.h>
+#include <netinet/tcp.h>
+#include <netinet/udp.h>
+#include <poll.h>
+#include <sched.h>
+#include <stdbool.h>
+#include <stdio.h>
+#include <stdint.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <sys/socket.h>
+#include <sys/stat.h>
+#include <sys/time.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <unistd.h>
+
+#define MSG_ZEROCOPY	0x4000000
+
+#define NUM_LOOPS	6	/* MUST BE > 1 for corking to work */
+#define TXC_FUDGE	100
+
+static int  cfg_len_ms		= 4200;
+static int  cfg_payload_len	= ((1 << 16) - 100);
+static bool cfg_test_raw;
+static bool cfg_test_raw_hdrincl;
+static bool cfg_test_tcp;
+static bool cfg_test_udp;
+static bool cfg_test_udp_cork;
+static bool cfg_verbose;
+static bool cfg_zerocopy;
+
+static bool flag_cork;
+
+static uint64_t tstop, treport;
+
+/* make frequency scaling invariant RDTSCP call */
+static uint64_t getcycles(void)
+{
+#ifdef __x86_64
+	uint64_t rax, rdx;
+	uint32_t aux;
+
+	asm volatile("rdtscp\n" : "=a" (rax), "=d" (rdx), "=c" (aux) : : );
+	return (rdx << 32) | rax;
+#else
+	/* TODO: fix */
+	return 0;
+#endif
+}
+
+static uint64_t getclockrate(void)
+{
+	static uint64_t cycles;
+
+	if (cycles)
+		return cycles;
+
+	cycles = getcycles();
+	usleep(100000);
+	cycles = getcycles() - cycles;
+	cycles *= 10;
+
+	fprintf(stderr, "clockrate: %lu MCyc/s\n", cycles >> 20);
+	return cycles;
+}
+
+static void timer_start(int timeout_ms)
+{
+	uint64_t tstart;
+
+	tstart = getcycles();
+	treport = tstart + getclockrate();
+	tstop = tstart + (timeout_ms * (getclockrate() / 1000));
+}
+
+static bool timer_report(void)
+{
+	uint64_t tstart;
+
+	tstart = getcycles();
+	if (tstart < treport)
+		return false;
+
+	treport = tstart + getclockrate();
+	return true;
+}
+
+static bool timer_stop(void)
+{
+	return getcycles() > tstop;
+}
+
+static int getnumcpus(void)
+{
+	int num = sysconf(_SC_NPROCESSORS_ONLN);
+
+	if (num < 1)
+		error(1, 0, "get num cpus\n");
+	return num;
+}
+
+static int setcpu(int cpu)
+{
+	cpu_set_t mask;
+
+	CPU_ZERO(&mask);
+	CPU_SET(cpu, &mask);
+	if (sched_setaffinity(0, sizeof(mask), &mask)) {
+		fprintf(stderr, "setaffinity %d\n", cpu);
+		return 1;
+	}
+
+	return 0;
+}
+
+static void test_mtu_is_max(int fd)
+{
+	struct ifreq ifr = {
+		.ifr_name = "lo",
+	};
+
+	if (ioctl(fd, SIOCGIFMTU, &ifr))
+		error(1, errno, "ioctl get mtu");
+
+	if (ifr.ifr_mtu != 1 << 16)
+		error(1, 0, "mtu=%u expected=2^16\n", ifr.ifr_mtu);
+}
+
+static void do_poll(int fd, int dir)
+{
+	struct pollfd pfd;
+	int ret;
+
+	pfd.events = dir;
+	pfd.revents = 0;
+	pfd.fd = fd;
+
+	ret = poll(&pfd, 1, 10);
+	if (ret == -1)
+		error(1, errno, "poll");
+	if (ret == 0)
+		error(1, 0, "poll: EAGAIN");
+}
+
+static bool do_write_once(int fd, struct msghdr *msg, int total_len, bool zcopy)
+{
+	int ret, flags;
+
+	flags = MSG_DONTWAIT;
+	if (zcopy)
+		flags |= MSG_ZEROCOPY;
+
+	ret = sendmsg(fd, msg, flags);
+	if (ret == -1 && (errno == EAGAIN || errno == ENOBUFS))
+		return false;
+
+	if (ret == -1)
+		error(1, errno, "send");
+	if (ret != total_len)
+		error(1, 0, "send: ret=%u\n", ret);
+
+	return true;
+}
+
+static void do_print_data_mismatch(char *tx, char *rx, int len)
+{
+	int i;
+
+	fprintf(stderr, "tx: ");
+	for (i = 0; i < len; i++)
+		fprintf(stderr, "%hx ", tx[i] & 0xff);
+	fprintf(stderr, "\nrx: ");
+	for (i = 0; i < len; i++)
+		fprintf(stderr, "%hx ", rx[i] & 0xff);
+	fprintf(stderr, "\n");
+}
+
+static bool do_read_once(int fd, char *tbuf, int type, bool corked, long *bytes)
+{
+	char rbuf[32], *payload;
+	int ret, len, expected, flags;
+
+	flags = MSG_DONTWAIT;
+	/* MSG_TRUNC differs on SOCK_STREAM: it flushes the buffer */
+	if (type != SOCK_STREAM)
+		flags |= MSG_TRUNC;
+
+	ret = recv(fd, rbuf, sizeof(rbuf), flags);
+	if (ret == -1 && errno == EAGAIN)
+		return false;
+	if (ret == -1)
+		error(1, errno, "recv");
+	if (type == SOCK_RAW)
+		ret -= sizeof(struct iphdr);
+
+	expected = sizeof(rbuf);
+	if (flags & MSG_TRUNC) {
+		expected = cfg_payload_len;
+		if (corked)
+			expected *= NUM_LOOPS;
+		*bytes += expected;
+	} else {
+		*bytes += cfg_payload_len;
+	}
+	if (ret != expected)
+		error(1, 0, "recv: ret=%u (exp=%u)\n", ret, expected);
+
+	payload = rbuf;
+	len = sizeof(rbuf);
+	if (type == SOCK_RAW) {
+		payload += sizeof(struct iphdr);
+		len -= sizeof(struct iphdr);
+	}
+
+	if (memcmp(payload, tbuf, len)) {
+		do_print_data_mismatch(tbuf, payload, len);
+		error(1, 0, "\nrecv: data mismatch\n");
+	}
+
+	/* Stream sockets are not truncated, so flush explicitly */
+	if (type == SOCK_STREAM) {
+		static char flushbuf[1 << 20];
+		int remainder = cfg_payload_len - sizeof(rbuf);
+
+		if (sizeof(flushbuf) < remainder)
+			error(1, 0, "recv (flush) bufsize");
+
+		ret = recv(fd, flushbuf, remainder, MSG_TRUNC);
+		if (ret == -1)
+			error(1, errno, "recv (flush)");
+		if (ret != remainder)
+			error(1, 0, "recv (flush) %uB", ret);
+	}
+
+	return true;
+}
+
+static void setup_iph(struct iphdr *iph, uint16_t payload_len)
+{
+	memset(iph, 0, sizeof(*iph));
+	iph->version	= 4;
+	iph->tos	= 0;
+	iph->ihl	= 5;
+	iph->ttl	= 8;
+	iph->saddr	= htonl(INADDR_LOOPBACK);
+	iph->daddr	= htonl(INADDR_LOOPBACK);
+	iph->protocol	= IPPROTO_EGP;
+	iph->tot_len	= htons(sizeof(*iph) + payload_len);
+	/* No need to calculate checksum: set by kernel */
+}
+
+static void do_cork(int fd, bool enable)
+{
+	int cork = enable;
+
+	if (setsockopt(fd, IPPROTO_UDP, UDP_CORK, &cork, sizeof(cork)))
+		error(1, errno, "cork %u", enable);
+}
+
+static int do_read_notification(int fd)
+{
+	struct sock_extended_err *serr;
+	struct cmsghdr *cm;
+	struct msghdr msg = {};
+	char control[100];
+	unsigned int ret;
+	uint16_t hi, lo;
+
+	msg.msg_control = control;
+	msg.msg_controllen = sizeof(control);
+
+	ret = recvmsg(fd, &msg, MSG_DONTWAIT | MSG_ERRQUEUE);
+	if (ret == -1 && errno == EAGAIN)
+		return 0;
+
+	if (ret == -1)
+		error(1, errno, "recvmsg notification");
+	if (msg.msg_flags & MSG_CTRUNC)
+		error(1, errno, "recvmsg notification: truncated");
+
+	cm = CMSG_FIRSTHDR(&msg);
+	if (!cm || cm->cmsg_level != SOL_IP ||
+	    (cm->cmsg_type != IP_RECVERR && cm->cmsg_type != IPV6_RECVERR))
+		error(1, 0, "cmsg: wrong type");
+
+	serr = (void *) CMSG_DATA(cm);
+	if (serr->ee_errno != 0 || serr->ee_origin != SO_EE_ORIGIN_ZEROCOPY)
+		error(1, 0, "serr: wrong type");
+
+	hi = serr->ee_data >> 16;
+	lo = serr->ee_data & 0xFFFF;
+	ret = hi >= lo ? hi - lo + 1 : 0xFFFFLU + hi - lo;
+
+	if (cfg_verbose)
+		fprintf(stderr, "completed: %u (h=%u l=%u)\n", ret, hi, lo);
+
+	return ret;
+}
+
+static int do_read_notifications(int fd)
+{
+	int ret, len = 0;
+
+	do {
+		ret = do_read_notification(fd);
+		len += ret;
+	} while (ret);
+
+	return len;
+}
+
+static void do_run(int fdt, int fdr, int type, int protocol)
+{
+	static char tbuf[1 << 16];
+	struct msghdr msg;
+	struct iovec iov[2];
+	struct iphdr iph;
+	long numtx = 0, numrx = 0, bytesrx = 0, numtxc = 0, expected_txc = 0;
+	int cpu, i, total_len = 0;
+
+	memset(&msg, 0, sizeof(msg));
+	memset(&iov, 0, sizeof(iov));
+	for (i = 0; i < sizeof(tbuf); i++)
+		tbuf[i] = 'a' + (i % 26);
+
+	i = 0;
+	if (protocol == IPPROTO_RAW) {
+		setup_iph(&iph, cfg_payload_len);
+		iov[i].iov_base = (void *) &iph;
+		iov[i].iov_len = sizeof(iph);
+		total_len += iov[i].iov_len;
+		i++;
+	}
+	iov[i].iov_base = tbuf;
+	iov[i].iov_len = cfg_payload_len;
+	total_len += iov[i].iov_len;
+
+	msg.msg_iovlen = i + 1;
+	msg.msg_iov = iov;
+
+	cpu = getnumcpus() - 1;
+	setcpu(cpu);
+	fprintf(stderr, "cpu: %u\n", cpu);
+
+	do {
+		if (cfg_zerocopy)
+			numtxc += do_read_notifications(fdt);
+
+		if (flag_cork)
+			do_cork(fdt, true);
+
+		for (i = 0; i < NUM_LOOPS; i++) {
+			bool do_zcopy = cfg_zerocopy;
+
+			if (flag_cork && (i & 0x1))
+				do_zcopy = false;
+
+			if (!do_write_once(fdt, &msg, total_len, do_zcopy)) {
+				do_poll(fdt, POLLOUT);
+				break;
+			}
+
+			numtx++;
+			if (do_zcopy)
+				expected_txc++;
+		}
+		if (flag_cork)
+			do_cork(fdt, false);
+
+		while (do_read_once(fdr, tbuf, type, flag_cork, &bytesrx))
+			numrx++;
+
+		if (timer_report()) {
+			fprintf(stderr, "rx=%lu (%lu MB) tx=%lu txc=%lu\n",
+				numrx, bytesrx >> 20, numtx, numtxc);
+		}
+	} while (!timer_stop());
+
+	if (cfg_zerocopy)
+		numtxc += do_read_notifications(fdt);
+
+	if (flag_cork)
+		numtx /= NUM_LOOPS;
+
+	if (labs(numtx - numrx) > TXC_FUDGE)
+		error(1, 0, "missing packets: %lu != %lu\n", numrx, numtx);
+	if (cfg_zerocopy && labs(expected_txc - numtxc) > TXC_FUDGE)
+		error(1, 0, "missing completions: rx=%lu expected=%lu\n",
+			    numtxc, expected_txc);
+}
+
+static void do_setup_and_run(int domain, int type, int protocol)
+{
+	struct sockaddr_in addr;
+	socklen_t alen;
+	int protocol_r;
+	int fdr, fdt, ret;
+
+	fprintf(stderr, "test socket(%u, %u, %u)\n", domain, type, protocol);
+
+	protocol_r = protocol == IPPROTO_RAW ? IPPROTO_EGP : protocol;
+	fdr = socket(PF_INET, type, protocol_r);
+	if (fdr == -1)
+		error(1, errno, "socket r");
+
+	fdt = socket(PF_INET, type, protocol);
+	if (fdt == -1)
+		error(1, errno, "socket t");
+
+	test_mtu_is_max(fdr);
+
+	memset(&addr, 0, sizeof(addr));
+	addr.sin_family = domain;
+	addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+	alen = sizeof(addr);
+
+	if (bind(fdr, (void *) &addr, sizeof(addr)))
+		error(1, errno, "bind");
+	if (type == SOCK_STREAM && listen(fdr, 1))
+		error(1, errno, "listen");
+	if (getsockname(fdr, (void *) &addr, &alen) || alen != sizeof(addr))
+		error(1, 0, "getsockname");
+	if (connect(fdt, (void *) &addr, sizeof(addr)))
+		error(1, errno, "connect");
+	if (type == SOCK_STREAM) {
+		int fda = fdr;
+
+		fdr = accept(fda, NULL, NULL);
+		if (fdr == -1)
+			error(1, errno, "accept");
+		if (close(fda))
+			error(1, errno, "close listen sock");
+	}
+
+	ret = 1 << 22;
+	if (setsockopt(fdr, SOL_SOCKET, SO_RCVBUF, &ret, sizeof(ret)))
+		error(1, errno, "socklen r");
+	if (setsockopt(fdt, SOL_SOCKET, SO_SNDBUF, &ret, sizeof(ret)))
+		error(1, errno, "socklen t");
+
+	timer_start(cfg_len_ms);
+	do_run(fdt, fdr, type, protocol);
+
+	if (close(fdt))
+		error(1, errno, "close t");
+	if (close(fdr))
+		error(1, errno, "close r");
+
+}
+
+static void parse_opts(int argc, char **argv)
+{
+	const char on[] = "ON", off[] = "OFF";
+	const int max_payload = IP_MAXPACKET - sizeof(struct iphdr);
+	int c;
+
+	while ((c = getopt(argc, argv, "l:rRs:tuUvz")) != -1) {
+		switch (c) {
+		case 'l':
+			cfg_len_ms = strtoul(optarg, NULL, 10) * 1000;
+			break;
+		case 'r':
+			cfg_test_raw = true;
+			break;
+		case 'R':
+			cfg_test_raw_hdrincl = true;
+			break;
+		case 's':
+			cfg_payload_len = strtoul(optarg, NULL, 0);
+			break;
+		case 't':
+			cfg_test_tcp = true;
+			break;
+		case 'u':
+			cfg_test_udp = true;
+			break;
+		case 'U':
+			cfg_test_udp_cork = true;
+			break;
+		case 'v':
+			cfg_verbose = true;
+			break;
+		case 'z':
+			cfg_zerocopy = true;
+			break;
+		}
+	}
+
+	if (cfg_payload_len > max_payload)
+		error(1, 0, "-s: payload too long");
+	if (cfg_payload_len >= (max_payload - sizeof(struct tcphdr) - 10))
+		fprintf(stderr, "warn: len may exceed limit\n");
+
+	if (cfg_verbose) {
+		fprintf(stderr, "time:     %u ms\n"
+				"size:     %u B\n"
+				"zerocopy: %s\n",
+			cfg_len_ms,
+			cfg_payload_len,
+			cfg_zerocopy ? on : off);
+	}
+}
+
+int main(int argc, char **argv)
+{
+	parse_opts(argc, argv);
+
+	if (cfg_test_udp)
+		do_setup_and_run(AF_INET, SOCK_DGRAM, 0);
+	if (cfg_test_udp_cork) {
+		int saved_payload_len = cfg_payload_len;
+
+		cfg_payload_len /= NUM_LOOPS;
+
+		flag_cork = true;
+		do_setup_and_run(AF_INET, SOCK_DGRAM, 0);
+		flag_cork = false;
+
+		cfg_payload_len = saved_payload_len;
+	}
+	if (cfg_test_raw)
+		do_setup_and_run(AF_INET, SOCK_RAW, IPPROTO_EGP);
+	if (cfg_test_raw_hdrincl)
+		do_setup_and_run(AF_INET, SOCK_RAW, IPPROTO_RAW);
+	if (cfg_test_tcp)
+		do_setup_and_run(AF_INET, SOCK_STREAM, 0);
+
+	fprintf(stderr, "OK. All tests passed\n");
+	return 0;
+}
-- 
2.5.0.276.gf5e568e
