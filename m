From: Richard Cochran <rcochran@linutronix.de>
Subject: [PATCH RFC V1 net-next 0/6] Time based packet transmission
Date: Mon, 18 Sep 2017 09:41:15 +0200
Message-ID: <cover.1505719061.git.rcochran@linutronix.de>
Cc: <linux-kernel@vger.kernel.org>, intel-wired-lan@lists.osuosl.org,
        Andre Guedes <andre.guedes@intel.com>,
        Anna-Maria Gleixner <anna-maria@linutronix.de>,
        David Miller <davem@davemloft.net>,
        Henrik Austad <henrik@austad.us>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is an early RFC that introduces a new socket option
allowing time based transmission of packets.  This option will be
useful in implementing various real time protocols over Ethernet,
including but not limited to P802.1Qbv, which is currently finding
its way into 802.1Q.

* Open questions about SO_TXTIME semantics

  - What should the kernel do if the dialed Tx time is in the past?
    Should the packet be sent ASAP, or should we throw an error?

  - Should the kernel inform the user if it detects a missed deadline,
    via the error queue for example?

  - What should the timescale be for the dialed Tx time?  Should the
    kernel select UTC when using the SW Qdisc and the HW time
    otherwise?  Or should the socket option include a clockid_t?

* Things todo

  - Design a Qdisc for purpose of configuring SO_TXTIME.  There should
    be one option to dial HW offloading or SW best effort.

  - Implement the SW best effort variant.  Here is my back of the
    napkin sketch.  Each interface has its own timerqueue keeping the
    TXTIME packets in order and a FIFO for all other traffic.  A guard
    window starts at the earliest deadline minus the maximum MTU minus
    a configurable fudge factor.  The Qdisc uses a hrtimer to transmit
    the next packet in the timerqueue.  During the guard window, all
    other traffic is defered unless the next packet can be transmitted
    before the guard window expires.

* Current limitations

  - The driver does not handle out of order packets.  If user space
    sends a packet with an earlier Tx time, then the code should stop
    the queue, reshuffle the descriptors accordingly, and then
    restart the queue.

  - The driver does not correctly queue up packets in the distant
    future.  The i210 has a limited time window of +/- 0.5 seconds.
    Packets with a Tx time greater than that should be deferred in
    order to enqueue them later on.

* Performance measurements

  1. Prepared a PC and the Device Under Test (DUT) each with an Intel
     i210 card connected with a crossover cable.
  2. The DUT was a Pentium(R) D CPU 2.80GHz running PREEMPT_RT
     4.9.40-rt30 with about 50 usec maximum latency under cyclictest.
  3. Synchronized the DUT's PHC to the PC's PHC using ptp4l.
  4. Synchronized the DUT's system clock to its PHC using phc2sys.
  5. Started netperf to produce some network load.
  6. Measured the arrival time of the packets at the PC's PHC using
     hardware time stamping.

  I ran ten minute tests both with and without using the so_txtime
  option, with a period was 1 millisecond.  I then repeated the
  so_txtime case but with a 250 microsecond period.  The measured
  offset from the expected period (in nanoseconds) is shown in the
  following table.

  |         | plain preempt_rt |     so_txtime | txtime @ 250 us |
  |---------+------------------+---------------+-----------------|
  | min:    |    +1.940800e+04 | +4.720000e+02 |   +4.720000e+02 |
  | max:    |    +7.556000e+04 | +5.680000e+02 |   +5.760000e+02 |
  | pk-pk:  |    +5.615200e+04 | +9.600000e+01 |   +1.040000e+02 |
  | mean:   |    +3.292776e+04 | +5.072274e+02 |   +5.073602e+02 |
  | stddev: |    +6.514709e+03 | +1.310849e+01 |   +1.507144e+01 |
  | count:  |           600000 |        600000 |         2400000 |

  Using so_txtime, the peak to peak jitter is about 100 nanoseconds,
  independent of the period.  In contrast, plain preempt_rt shows a
  jitter of of 56 microseconds.  The average delay of 507 nanoseconds
  when using so_txtime is explained by the documented input and output
  delays on the i210 cards.

  The test program is appended, below.  If anyone is interested in
  reproducing this test, I can provide helper scripts.

Thanks,
Richard


Richard Cochran (6):
  net: Add a new socket option for a future transmit time.
  net: skbuff: Add a field to support time based transmission.
  net: ipv4: raw: Hook into time based transmission.
  net: ipv4: udp: Hook into time based transmission.
  net: packet: Hook into time based transmission.
  net: igb: Implement time based transmission.

 arch/alpha/include/uapi/asm/socket.h           |  3 ++
 arch/frv/include/uapi/asm/socket.h             |  3 ++
 arch/ia64/include/uapi/asm/socket.h            |  3 ++
 arch/m32r/include/uapi/asm/socket.h            |  3 ++
 arch/mips/include/uapi/asm/socket.h            |  3 ++
 arch/mn10300/include/uapi/asm/socket.h         |  3 ++
 arch/parisc/include/uapi/asm/socket.h          |  3 ++
 arch/powerpc/include/uapi/asm/socket.h         |  3 ++
 arch/s390/include/uapi/asm/socket.h            |  3 ++
 arch/sparc/include/uapi/asm/socket.h           |  3 ++
 arch/xtensa/include/uapi/asm/socket.h          |  3 ++
 drivers/net/ethernet/intel/igb/e1000_82575.h   |  1 +
 drivers/net/ethernet/intel/igb/e1000_defines.h | 68 +++++++++++++++++++++++++-
 drivers/net/ethernet/intel/igb/e1000_regs.h    |  5 ++
 drivers/net/ethernet/intel/igb/igb.h           |  3 +-
 drivers/net/ethernet/intel/igb/igb_main.c      | 68 +++++++++++++++++++++++---
 include/linux/skbuff.h                         |  2 +
 include/net/sock.h                             |  2 +
 include/uapi/asm-generic/socket.h              |  3 ++
 net/core/sock.c                                | 12 +++++
 net/ipv4/raw.c                                 |  2 +
 net/ipv4/udp.c                                 |  5 +-
 net/packet/af_packet.c                         |  6 +++
 23 files changed, 200 insertions(+), 10 deletions(-)

-- 
2.11.0

---8<---
/*
 * This program demonstrates transmission of UDP packets using the
 * system TAI timer.
 *
 * Copyright (C) 2017 linutronix GmbH
 *
 * Large portions taken from the linuxptp stack.
 * Copyright (C) 2011, 2012 Richard Cochran <richardcochran@gmail.com>
 *
 * Some portions taken from the sgd test program.
 * Copyright (C) 2015 linutronix GmbH
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
#define _GNU_SOURCE /*for CPU_SET*/
#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <ifaddrs.h>
#include <linux/ethtool.h>
#include <linux/net_tstamp.h>
#include <linux/sockios.h>
#include <net/if.h>
#include <netinet/in.h>
#include <poll.h>
#include <pthread.h>
#include <sched.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#define DEFAULT_PERIOD	1000000
#define DEFAULT_DELAY	500000
#define MCAST_IPADDR	"239.1.1.1"
#define UDP_PORT	7788

#ifndef SO_TXTIME
#define SO_TXTIME	61
#endif

#define pr_err(s)	fprintf(stderr, s "\n")
#define pr_info(s)	fprintf(stdout, s "\n")

static int running = 1, use_so_txtime = 1;
static int period_nsec = DEFAULT_PERIOD;
static int waketx_delay = DEFAULT_DELAY;
static struct in_addr mcast_addr;

static int mcast_bind(int fd, int index)
{
	int err;
	struct ip_mreqn req;
	memset(&req, 0, sizeof(req));
	req.imr_ifindex = index;
	err = setsockopt(fd, IPPROTO_IP, IP_MULTICAST_IF, &req, sizeof(req));
	if (err) {
		pr_err("setsockopt IP_MULTICAST_IF failed: %m");
		return -1;
	}
	return 0;
}

static int mcast_join(int fd, int index, const struct sockaddr *grp,
		      socklen_t grplen)
{
	int err, off = 0;
	struct ip_mreqn req;
	struct sockaddr_in *sa = (struct sockaddr_in *) grp;

	memset(&req, 0, sizeof(req));
	memcpy(&req.imr_multiaddr, &sa->sin_addr, sizeof(struct in_addr));
	req.imr_ifindex = index;
	err = setsockopt(fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &req, sizeof(req));
	if (err) {
		pr_err("setsockopt IP_ADD_MEMBERSHIP failed: %m");
		return -1;
	}
	err = setsockopt(fd, IPPROTO_IP, IP_MULTICAST_LOOP, &off, sizeof(off));
	if (err) {
		pr_err("setsockopt IP_MULTICAST_LOOP failed: %m");
		return -1;
	}
	return 0;
}

static void normalize(struct timespec *ts)
{
	while (ts->tv_nsec > 999999999) {
		ts->tv_sec += 1;
		ts->tv_nsec -= 1000000000;
	}
}

static int sk_interface_index(int fd, const char *name)
{
	struct ifreq ifreq;
	int err;

	memset(&ifreq, 0, sizeof(ifreq));
	strncpy(ifreq.ifr_name, name, sizeof(ifreq.ifr_name) - 1);
	err = ioctl(fd, SIOCGIFINDEX, &ifreq);
	if (err < 0) {
		pr_err("ioctl SIOCGIFINDEX failed: %m");
		return err;
	}
	return ifreq.ifr_ifindex;
}

static int open_socket(const char *name, struct in_addr mc_addr, short port)
{
	struct sockaddr_in addr;
	int fd, index, on = 1;

	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(INADDR_ANY);
	addr.sin_port = htons(port);

	fd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (fd < 0) {
		pr_err("socket failed: %m");
		goto no_socket;
	}
	index = sk_interface_index(fd, name);
	if (index < 0)
		goto no_option;

	if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on))) {
		pr_err("setsockopt SO_REUSEADDR failed: %m");
		goto no_option;
	}
	if (bind(fd, (struct sockaddr *) &addr, sizeof(addr))) {
		pr_err("bind failed: %m");
		goto no_option;
	}
	if (setsockopt(fd, SOL_SOCKET, SO_BINDTODEVICE, name, strlen(name))) {
		pr_err("setsockopt SO_BINDTODEVICE failed: %m");
		goto no_option;
	}
	addr.sin_addr = mc_addr;
	if (mcast_join(fd, index, (struct sockaddr *) &addr, sizeof(addr))) {
		pr_err("mcast_join failed");
		goto no_option;
	}
	if (mcast_bind(fd, index)) {
		goto no_option;
	}
	if (use_so_txtime && setsockopt(fd, SOL_SOCKET, SO_TXTIME, &on, sizeof(on))) {
		pr_err("setsockopt SO_TXTIME failed: %m");
		goto no_option;
	}

	return fd;
no_option:
	close(fd);
no_socket:
	return -1;
}

static int udp_open(const char *name)
{
	int fd;

	if (!inet_aton(MCAST_IPADDR, &mcast_addr))
		return -1;

	fd = open_socket(name, mcast_addr, UDP_PORT);

	return fd;
}

static int udp_send(int fd, void *buf, int len, __u64 txtime)
{
	union {
		char buf[CMSG_SPACE(sizeof(__u64))];
		struct cmsghdr align;
	} u;
	struct sockaddr_in sin;
	struct cmsghdr *cmsg;
	struct msghdr msg;
	struct iovec iov;
	ssize_t cnt;

	memset(&sin, 0, sizeof(sin));
	sin.sin_family = AF_INET;
	sin.sin_addr = mcast_addr;
	sin.sin_port = htons(UDP_PORT);

	iov.iov_base = buf;
	iov.iov_len = len;

	memset(&msg, 0, sizeof(msg));
	msg.msg_name = &sin;
	msg.msg_namelen = sizeof(sin);
	msg.msg_iov = &iov;
	msg.msg_iovlen = 1;

	/*
	 * We specify the transmission time in the CMSG.
	 */
	if (use_so_txtime) {
		msg.msg_control = u.buf;
		msg.msg_controllen = sizeof(u.buf);
		cmsg = CMSG_FIRSTHDR(&msg);
		cmsg->cmsg_level = SOL_SOCKET;
		cmsg->cmsg_type = SO_TXTIME;
		cmsg->cmsg_len = CMSG_LEN(sizeof(__u64));
		*((__u64 *) CMSG_DATA(cmsg)) = txtime;
	}
	cnt = sendmsg(fd, &msg, 0);
	if (cnt < 1) {
		pr_err("sendmsg failed: %m");
		return cnt;
	}
	return cnt;
}

static unsigned char tx_buffer[256];
static int marker;

static int run_nanosleep(clockid_t clkid, int fd)
{
	struct timespec ts;
	int cnt, err;
	__u64 txtime;

	clock_gettime(clkid, &ts);

	/* Start one to two seconds in the future. */
	ts.tv_sec += 1;
	ts.tv_nsec = 1000000000 - waketx_delay;
	normalize(&ts);

	txtime = ts.tv_sec * 1000000000ULL + ts.tv_nsec;
	txtime += waketx_delay;

	while (running) {
		err = clock_nanosleep(clkid, TIMER_ABSTIME, &ts, NULL);
		switch (err) {
		case 0:
			cnt = udp_send(fd, tx_buffer, sizeof(tx_buffer), txtime);
			if (cnt != sizeof(tx_buffer)) {
				pr_err("udp_send failed");
			}
			memset(tx_buffer, marker++, sizeof(tx_buffer));
			ts.tv_nsec += period_nsec;
			normalize(&ts);
			txtime += period_nsec;
			break;
		case EINTR:
			continue;
		default:
			fprintf(stderr, "clock_nanosleep returned %d: %s",
				err, strerror(err));
			return err;
		}
	}

	return 0;
}

static int set_realtime(pthread_t thread, int priority, int cpu)
{
	cpu_set_t cpuset;
	struct sched_param sp;
	int err, policy;

	int min = sched_get_priority_min(SCHED_FIFO);
	int max = sched_get_priority_max(SCHED_FIFO);

	fprintf(stderr, "min %d max %d\n", min, max);

	if (priority < 0) {
		return 0;
	}

	err = pthread_getschedparam(thread, &policy, &sp);
	if (err) {
		fprintf(stderr, "pthread_getschedparam: %s\n", strerror(err));
		return -1;
	}

	sp.sched_priority = priority;

	err = pthread_setschedparam(thread, SCHED_FIFO, &sp);
	if (err) {
		fprintf(stderr, "pthread_setschedparam: %s\n", strerror(err));
		return -1;
	}

	if (cpu < 0) {
		return 0;
	}
	CPU_ZERO(&cpuset);
	CPU_SET(cpu, &cpuset);
	err = pthread_setaffinity_np(thread, sizeof(cpu_set_t), &cpuset);
	if (err) {
		fprintf(stderr, "pthread_setaffinity_np: %s\n", strerror(err));
		return -1;
	}

	return 0;
}

static void usage(char *progname)
{
	fprintf(stderr,
		"\n"
		"usage: %s [options]\n"
		"\n"
		" -c [num]   run on CPU 'num'\n"
		" -d [num]   delay from wake up to transmission in nanoseconds (default %d)\n"
		" -h         prints this message and exits\n"
		" -i [name]  use network interface 'name'\n"
		" -p [num]   run with RT priorty 'num'\n"
		" -P [num]   period in nanoseconds (default %d)\n"
		" -u         do not use SO_TXTIME\n"
		"\n",
		progname, DEFAULT_DELAY, DEFAULT_PERIOD);
}

int main(int argc, char *argv[])
{
	int c, cpu = -1, err, fd, priority = -1;
	clockid_t clkid = CLOCK_TAI;
	char *iface = NULL, *progname;

	/* Process the command line arguments. */
	progname = strrchr(argv[0], '/');
	progname = progname ? 1 + progname : argv[0];
	while (EOF != (c = getopt(argc, argv, "c:d:hi:p:P:u"))) {
		switch (c) {
		case 'c':
			cpu = atoi(optarg);
			break;
		case 'd':
			waketx_delay = atoi(optarg);
			break;
		case 'h':
			usage(progname);
			return 0;
		case 'i':
			iface = optarg;
			break;
		case 'p':
			priority = atoi(optarg);
			break;
		case 'P':
			period_nsec = atoi(optarg);
			break;
		case 'u':
			use_so_txtime = 0;
			break;
		case '?':
			usage(progname);
			return -1;
		}
	}

	if (waketx_delay > 999999999 || waketx_delay < 0) {
		pr_err("Bad wake up to transmission delay.");
		usage(progname);
		return -1;
	}

	if (period_nsec < 1000) {
		pr_err("Bad period.");
		usage(progname);
		return -1;
	}

	if (!iface) {
		pr_err("Need a network interface.");
		usage(progname);
		return -1;
	}

	if (set_realtime(pthread_self(), priority, cpu)) {
		return -1;
	}

	fd = udp_open(iface);
	if (fd < 0) {
		return -1;
	}

	err = run_nanosleep(clkid, fd);

	close(fd);
	return err;
}
