From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 7/7] net-timestamp: expand documentation
Date: Tue, 24 Jun 2014 11:43:52 -0400
Message-ID: <1403624632-17327-8-git-send-email-willemb@google.com>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
Cc: eric.dumazet@gmail.com, richardcochran@gmail.com,
	davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f202.google.com ([209.85.128.202]:43006 "EHLO
	mail-ve0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512AbaFXPvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 11:51:13 -0400
Received: by mail-ve0-f202.google.com with SMTP id oy12so43842veb.3
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 08:51:12 -0700 (PDT)
In-Reply-To: <1403624632-17327-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expand Documentation/networking/timestamping.txt with interface
details of MSG_TSTAMP and bytestream timestamping. Also minor
cleanup of the other text.

Add Documentation/networking/msg_tstamp.c example application
to demonstrate the implementation.

Signed-off-by: Willem de Bruijn <willemb@google.com>

--

I included msg_tstamp.c for reference during review, mostly. I can
remove it for v2.
---
 Documentation/networking/timestamping.txt          | 176 +++++++--
 Documentation/networking/timestamping/msg_tstamp.c | 409 +++++++++++++++++++++
 2 files changed, 561 insertions(+), 24 deletions(-)
 create mode 100644 Documentation/networking/timestamping/msg_tstamp.c

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index bc35541..21c5410 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -1,4 +1,4 @@
-The existing interfaces for getting network packages time stamped are:
+The interfaces for getting network packages time stamped are:
 
 * SO_TIMESTAMP
   Generate time stamp for each incoming packet using the (not necessarily
@@ -13,21 +13,47 @@ The existing interfaces for getting network packages time stamped are:
   Only for multicasts: approximate send time stamp by receiving the looped
   packet and using its receive time stamp.
 
-The following interface complements the existing ones: receive time
-stamps can be generated and returned for arbitrary packets and much
-closer to the point where the packet is really sent. Time stamps can
-be generated in software (as before) or in hardware (if the hardware
-has such a feature).
+* SO_TIMESTAMPING
+  Request timestamps on reception, transmission or both. Request hardware,
+  software or both timestamps.
+
+* MSG_TSTAMP..
+  Like SO_TIMESTAMPING, but unlike that socket option, request a timestamp
+  for the payload of one specific send() call only. Currently supports
+  only timestamping on transmission.
+
+
+SO_TIMESTAMP:
+
+This socket option enables timestamping of datagrams on the network reception
+path. Because the destination socket, if any, is not known early in the
+network stack, the feature has to be enabled for all possibly matching packets
+(i.e., datagrams). The same is true for all subsequent reception timestamp
+options, too.
+
+For interface details, see `man 7 socket`.
+
+
+SO_TIMESTAMPNS:
+
+This option is identical to SO_TIMESTAMP except for the returned data type.
+Its struct timespec allows for higher resolution (ns) timestamps than the
+timeval of SO_TIMESTAMP (ms).
+
 
 SO_TIMESTAMPING:
 
 Instructs the socket layer which kind of information should be collected
-and/or reported.  The parameter is an integer with some of the following
-bits set. Setting other bits is an error and doesn't change the current
-state.
+and/or reported. Unlike SO_TIMESTAMP(NS), the socket option is not a boolean,
+but a bitmap. In an expression
+
+  err = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING, (void *) val, &val);
+
+The parameter val is an integer with some of the following bits set. Setting
+other bits returns EINVAL and does not change the current state.
 
 Four of the bits are requests to the stack to try to generate
-timestamps.  Any combination of them is valid.
+timestamps. Any combination of them is valid.
 
 SOF_TIMESTAMPING_TX_HARDWARE:  try to obtain send time stamps in hardware
 SOF_TIMESTAMPING_TX_SOFTWARE:  try to obtain send time stamps in software
@@ -50,27 +76,129 @@ can generate hardware receive timestamps ignore
 SOF_TIMESTAMPING_RX_HARDWARE.  It is still a good idea to set that flag
 in case future drivers pay attention.
 
-If timestamps are reported, they will appear in a control message with
-cmsg_level==SOL_SOCKET, cmsg_type==SO_TIMESTAMPING, and a payload like
-this:
 
-struct scm_timestamping {
+MSG_TSTAMP:
+
+The socket options enable timestamps for all datagrams on a socket
+until the configuration is again updated. Timestamps are often of
+interest only selectively, for instance for sampled monitoring or
+to instrument outliers. In these cases, continuous monitoring imposes
+unnecessary cost.
+
+MSG_TSTAMP and the MSG_TSTAMP_* flags are passed immediately with
+a send() call and request a timestamp only for the data in that
+buffer. They do not change socket state, nor do they depend on any
+of the socket options. Both can be used independently. Enabling
+both concurrently is safe, but redundant.
+
+MSG_TSTAMP:
+  generates the same timestamp as
+  SOF_TIMESTAMPING_TX_SOFTWARE | SOF_TIMESTAMPING_SOFTWARE: a transmit
+  timestamp in the device driver prior to handing to the NIC. As such
+  support for this timestamp is device driver specific.
+
+MSG_TSTAMP_ENQ:
+  generates a timestamp in the traffic shaping layer, prior to queuing
+  a packet. Kernel transmit latency is, if long, often dominated by
+  queueing delay. The difference between MSG_TSTAMP_ENQ and MSG_TSTAMP
+  will expose this delay indepedently from protocol processing. On
+  machines with virtual devices where a transmitted packet travels
+  through multiple devices and, hence, multiple traffic shaping
+  layers, a timestamp is returned for each layer. This enables fine
+  grained measurement of queueing delay.
+
+MSG_TSTAMP_ACK:
+  generates a timestamp when all data in the send buffer has been
+  acknowledged. This only makes sense for reliable protocols. It is
+  currently only implemented for TCP. For that protocol, it may
+  over-report measurement, because it defines when all data up to
+  and including the buffer was acknowledged (a cumulative ACK). It
+  ignores SACK and FACK.
+
+Bytestream Timestamps
+
+Unlike the socket options, the MSG_TSTAMP_.. interface supports
+timestamping of data in a bytestream. Each request is interpreted
+as a request for when the entire content of the buffer has passed a
+defined timestamping point. That is, a MSG_TSTAMP request records
+when all bytes have reached the device driver, regardless of how
+many packets the data has been converted into.
+
+In general, bytestreams have no natural delimiters and therefore
+correlating a timestamp with data is non-trivial. A range of bytes
+may be split across packets, packets may be merged (possibly merging
+two halves of two previously split, otherwise independent, buffers).
+These segments may be reordered and can even coexist for reliable
+protocols that implement retransmissions.
+
+It is essential that all timestamps implement the same semantics,
+regardless of all possible transformations, as otherwise they are
+incomparable. Handling "rare" corner cases differently from the
+simple case (a 1:1 mapping from buffer to skb) is insufficient
+because performance debugging often needs to focus on such outliers.
+
+In practice, timestamps can be correlated with segments of a
+bytestream consistently, if both semantics of the timestamp and the
+timing of measurement are chosen correctly. This challenge is no
+different from deciding on a strategy for IP fragmentation. There, the
+definition is that only the first fragment is timestamped. For
+bytestreams, we chose that a timestamp is generated only when all
+bytes have passed a point. The MSG_TSTAMP_ACK as defined is easy to
+implement and reason about. An implementation that has to take into
+account SACK would be more complex due to possible transmission holes
+and out of order arrival.
+
+On the host, TCP can also break the simple 1:1 mapping from buffer to
+skb by
+- appending a buffer to an existing skb (e.g., Nagle, cork and autocork)
+- MSS-based segmentation
+- generic segmentation offload (GSO)
+
+The implementation avoids the first by effectively closing an skb
+for appends once a timestamp flag is set. The stack avoids
+segmentation due to MSS. GSO is supported by copying the relevant
+flag from the original large packet into the last of the segmented
+MTU or smaller sized packets.
+
+This ensures that the timestamp is generated only when all bytes have
+passed a timestamp point, if the network stack does not reorder the
+packets. The stack indeed tries to avoid reordering. The one exception
+is under administrator control: it is possible to construct a traffic
+shaping setup that delays segments differently. Such a setup would be
+unusual.
+
+
+Reading TIMESTAMPING and MSG_TSTAMP records
+
+Timestamps can be read using the ancillary data feature of recvmsg().
+See `man 3 cmsg` for details of this interface. Timestamps are
+returned in a control message with cmsg_level SOL_SOCKET, cmsg_type
+SO_TIMESTAMPING, and payload of type
+
+struct sock_errqueue_timestamping {
 	struct timespec systime;
 	struct timespec hwtimetrans;
 	struct timespec hwtimeraw;
+	__u32 ts_key;
+	__u32 ts_type;
+	__u64 ts_padding;
 };
 
-recvmsg() can be used to get this control message for regular incoming
-packets. For send time stamps the outgoing packet is looped back to
+For send timestamps the outgoing packet is looped back to
 the socket's error queue with the send time stamp(s) attached. It can
 be received with recvmsg(flags=MSG_ERRQUEUE). The call returns the
-original outgoing packet data including all headers preprended down to
-and including the link layer, the scm_timestamping control message and
+original outgoing packet data including all headers prefixed down to
+and including the link layer, the timestamping control message and
 a sock_extended_err control message with ee_errno==ENOMSG and
-ee_origin==SO_EE_ORIGIN_TIMESTAMPING. A socket with such a pending
-bounced packet is ready for reading as far as select() is concerned.
-If the outgoing packet has to be fragmented, then only the first
-fragment is time stamped and returned to the sending socket.
+ee_origin==SO_EE_ORIGIN_TIMESTAMPING. Reading from the error queue is
+always a non-blocking operation. The process can block for data using
+poll or select. In that case, the socket is ready for reading on POLLIN
+(not POLLERR).
+
+Fragmentation of outgoing datagrams is rare, but is possible, e.g., by
+explicitly disabling PMTU discovery. If an outgoing packet is fragmented,
+then only the first fragment is timestamped and returned to the sending
+socket.
 
 All three values correspond to the same event in time, but were
 generated in different ways. Each of these values may be empty (= all
@@ -97,7 +225,7 @@ Filled in if SOF_TIMESTAMPING_SYS_HARDWARE is set. Requires support
 by the network device and will be empty without that support.
 
 
-SIOCSHWTSTAMP, SIOCGHWTSTAMP:
+Hardware Timestamping configuration: SIOCSHWTSTAMP and SIOCGHWTSTAMP
 
 Hardware time stamping must also be initialized for each device driver
 that is expected to do hardware time stamping. The parameter is defined in
@@ -169,7 +297,7 @@ enum {
 };
 
 
-DEVICE IMPLEMENTATION
+Hardware Timestamping Implementation: Device Drivers
 
 A driver which supports hardware time stamping must support the
 SIOCSHWTSTAMP ioctl and update the supplied struct hwtstamp_config with
diff --git a/Documentation/networking/timestamping/msg_tstamp.c b/Documentation/networking/timestamping/msg_tstamp.c
new file mode 100644
index 0000000..0c85133
--- /dev/null
+++ b/Documentation/networking/timestamping/msg_tstamp.c
@@ -0,0 +1,409 @@
+/*
+ * Conformance tests for MSG_TSTAMP, including
+ *
+ * - UDP MSG_TSTAMP
+ * - TCP MSG_TSTAMP, MSG_TSTAMP_ENQ and MSG_TSTAMP_ACK
+ * - IPv4 and IPv6
+ * - various packet sizes (to test GSO and TSO)
+ *
+ * Consult the command line arguments for help on running
+ * the various testcases.
+ *
+ * This test requires a dummy TCP server.
+ * A simple `nc6 [-u] -l -p $DESTPORT` will do
+ *
+ * Tested against Linux 3.16-rc1 (7171511eaec5)
+ *
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ */
+
+#include <arpa/inet.h>
+#include <asm/types.h>
+#include <error.h>
+#include <errno.h>
+#include <linux/errqueue.h>
+#include <linux/if_ether.h>
+#include <linux/net_tstamp.h>
+#include <netdb.h>
+#include <net/if.h>
+#include <netinet/in.h>
+#include <netinet/ip.h>
+#include <netinet/udp.h>
+#include <netinet/tcp.h>
+#include <netpacket/packet.h>
+#include <stdarg.h>
+#include <stdint.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <sys/select.h>
+#include <sys/socket.h>
+#include <sys/time.h>
+#include <sys/types.h>
+#include <unistd.h>
+
+/* should be defined in include/uapi/linux/socket.h */
+#define MSG_TSTAMP	0x100000
+#define MSG_TSTAMP_ACK	0x200000
+#define MSG_TSTAMP_ENQ	0x400000
+
+#define NUM_RUNS	4
+
+/* command line parameters */
+static int do_udp;
+static int do_ipv4 = 1;
+static int do_ipv6 = 1;
+static int payload_len = 1;
+static int tstamp_no_payload;
+static uint16_t dest_port = 9000;
+
+struct sockaddr_in daddr;
+struct sockaddr_in6 daddr6;
+
+/* random globals */
+static struct timeval tv;
+static struct timespec ts_prev;
+static int tstamp_payload_len;
+
+static void __print_timestamp(const char *name, struct timespec *cur,
+			      uint32_t key)
+{
+	if (!(cur->tv_sec | cur->tv_nsec))
+		return;
+
+	fprintf(stderr, "  %s: %lu s %lu us (seq=%u, len=%u)",
+			name, cur->tv_sec, cur->tv_nsec / 1000,
+			key, tstamp_payload_len);
+
+	if ((ts_prev.tv_sec | ts_prev.tv_nsec)) {
+		int64_t cur_ms, prev_ms;
+
+		cur_ms = (long) cur->tv_sec * 1000 * 1000;
+		cur_ms += cur->tv_nsec / 1000;
+
+		prev_ms = (long) ts_prev.tv_sec * 1000 * 1000;
+		prev_ms += ts_prev.tv_nsec / 1000;
+
+		fprintf(stderr, "  (%+ld us)", cur_ms - prev_ms);
+	}
+
+	ts_prev = *cur;
+	fprintf(stderr, "\n");
+}
+
+static void print_timestamp_usr(void)
+{
+	struct timespec ts;
+
+	ts.tv_sec = tv.tv_sec;
+	ts.tv_nsec = tv.tv_usec * 1000;
+	__print_timestamp("  USR", &ts, 0);
+
+}
+
+static void print_timestamp(struct sock_errqueue_timestamping *tss)
+{
+	const char *tsname;
+
+	switch (tss->ts_type) {
+	case SCM_TSTAMP_ENQ:
+		tsname = "  ENQ";
+		break;
+	case SCM_TSTAMP_SND:
+		tsname = "  SND";
+		break;
+	case SCM_TSTAMP_ACK:
+		tsname = "  ACK";
+		break;
+	default:
+		error(1, 0, "unknown timestamp type: %u",
+		tss->ts_type);
+	}
+	__print_timestamp(tsname, &tss->ts_sw, tss->ts_key);
+}
+
+static void __recv_errmsg_cmsg(struct msghdr *msg)
+{
+	struct cmsghdr *cm;
+
+	for (cm = CMSG_FIRSTHDR(msg); cm; cm = CMSG_NXTHDR(msg, cm)) {
+		if (cm->cmsg_level == SOL_SOCKET &&
+		    cm->cmsg_type == SCM_TIMESTAMPING) {
+			print_timestamp((void *) CMSG_DATA(cm));
+			continue;
+		}
+
+		if ((cm->cmsg_level == SOL_IP &&
+		     cm->cmsg_type == IP_RECVERR) ||
+		    (cm->cmsg_level == SOL_IPV6 &&
+		     cm->cmsg_type == IPV6_RECVERR)) {
+			struct sock_extended_err *serr;
+
+			serr = (void *) CMSG_DATA(cm);
+			if (serr->ee_errno != ENOMSG ||
+			    serr->ee_origin != SO_EE_ORIGIN_TIMESTAMPING) {
+				fprintf(stderr, "unknown ip error %d %d\n",
+						serr->ee_errno,
+						serr->ee_origin);
+			}
+			continue;
+		}
+
+		fprintf(stderr, "%d, %d\n", cm->cmsg_level, cm->cmsg_type);
+	}
+
+}
+
+static int recv_errmsg(int fd)
+{
+	static char ctrl[1024 /* overcommit */];
+	static struct msghdr msg;
+	struct iovec entry;
+	static char *data;
+	int ret = 0;
+
+	data = malloc(payload_len);
+	if (!data)
+		error(1, 0, "malloc");
+
+	memset(&msg, 0, sizeof(msg));
+	memset(&entry, 0, sizeof(entry));
+	memset(ctrl, 0, sizeof(ctrl));
+	memset(data, 0, sizeof(data));
+
+	entry.iov_base = data;
+	/* for TCP we specify payload length to read one packet at a time. */
+	entry.iov_len = payload_len;
+	msg.msg_iov = &entry;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = ctrl;
+	msg.msg_controllen = sizeof(ctrl);
+
+	ret = recvmsg(fd, &msg, MSG_ERRQUEUE | MSG_DONTWAIT);
+	if (ret == -1 && (errno == EINTR || errno == EWOULDBLOCK))
+		goto done;
+	if (ret == -1)
+		error(1, errno, "recvmsg");
+
+	tstamp_payload_len = ret;
+	if (tstamp_no_payload && tstamp_payload_len)
+		error(1, 0, "recv: payload when configured without");
+	else if (!tstamp_no_payload && !tstamp_payload_len)
+		error(1, 0, "recv: no payload when configured with");
+
+	__recv_errmsg_cmsg(&msg);
+
+done:
+	free(data);
+	return ret == -1;
+}
+
+static void do_test(int family, unsigned int flags)
+{
+	char *buf;
+	int fd, i, val;
+
+	buf = malloc(payload_len);
+	if (!buf)
+		error(1, 0, "malloc");
+
+	if (do_udp)
+		fd = socket(family, SOCK_DGRAM, IPPROTO_UDP);
+	else
+		fd = socket(family, SOCK_STREAM, IPPROTO_TCP);
+	if (fd < 0)
+		error(1, errno, "socket");
+
+	if (!do_udp) {
+		val = 1;
+		if (setsockopt(fd, IPPROTO_TCP, TCP_NODELAY,
+			       (char*) &val, sizeof(val)))
+			error(1, 0, "setsockopt no nagle");
+
+		if (family == PF_INET) {
+			if (connect(fd, (void *) &daddr, sizeof(daddr)))
+				error(1, errno, "connect ipv4");
+		} else {
+			if (connect(fd, (void *) &daddr6, sizeof(daddr6)))
+				error(1, errno, "connect ipv6");
+		}
+	}
+
+	if (tstamp_no_payload) {
+		val = SOF_TIMESTAMPING_OPT_TX_NO_PAYLOAD;
+		if (setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING,
+			       (char *) &val, sizeof(val)))
+			error(1, 0, "setsockopt no payload");
+	}
+
+	for (i = 0; i < NUM_RUNS; i++) {
+		memset(&ts_prev, 0, sizeof(ts_prev));
+		memset(buf, 'a' + i, payload_len);
+		buf[payload_len - 1] = '\n';
+
+		gettimeofday(&tv, NULL);
+		if (do_udp) {
+			if (family == PF_INET)
+				val = sendto(fd, buf, payload_len, flags, (void *) &daddr, sizeof(daddr));
+			else
+				val = sendto(fd, buf, payload_len, flags, (void *) &daddr6, sizeof(daddr6));
+		} else {
+			val = send(fd, buf, payload_len, flags);
+		}
+		if (val != payload_len)
+			error(1, errno, "send");
+
+		usleep(50 * 1000);
+
+		print_timestamp_usr();
+		while (!recv_errmsg(fd)) {}
+	}
+
+	if (close(fd))
+		error(1, errno, "close");
+
+	free(buf);
+	usleep(400 * 1000);
+}
+
+static void __attribute__((noreturn)) usage(const char *filepath)
+{
+	fprintf(stderr, "\nUsage: %s [options] hostname\n"
+			"\nwhere options are:\n"
+			"  -4:   only IPv4\n"
+			"  -6:   only IPv6\n"
+			"  -h:   show this message\n"
+			"  -l N: send N bytes at a time\n"
+			"  -n:   no payload on tstamp\n"
+			"  -p N: connect to port N\n"
+			"  -u:   use udp\n",
+			filepath);
+	exit(1);
+}
+
+static void parse_opt(int argc, char **argv)
+{
+	char c;
+
+	while ((c = getopt(argc, argv, "46hl:np:u")) != -1) {
+		switch (c) {
+		case '4':
+			do_ipv6 = 0;
+			break;
+		case '6':
+			do_ipv4 = 0;
+			break;
+		case 'u':
+			do_udp = 1;
+			break;
+		case 'l':
+			payload_len = strtoul(optarg, NULL, 10);
+			break;
+		case 'n':
+			tstamp_no_payload = 1;
+			break;
+		case 'p':
+			dest_port = strtoul(optarg, NULL, 10);
+			break;
+		case 'h':
+		default:
+			usage(argv[0]);
+		}
+	}
+
+	if (do_udp && payload_len > 1472)
+		error(1, 0, "udp packet might exceed expected MTU");
+	if (!do_ipv4 && !do_ipv6)
+		error(1, 0, "pass -4 or -6, not both");
+
+	if (optind != argc - 1)
+		error(1, 0, "missing required hostname argument");
+}
+
+static void resolve_hostname(const char *hostname)
+{
+	struct addrinfo *addrs, *cur;
+	int have_ipv4 = 0, have_ipv6 = 0;
+
+	if (getaddrinfo(hostname, NULL, NULL, &addrs))
+		error(1, errno, "getaddrinfo");
+
+	cur = addrs;
+	while (cur && !have_ipv4 && !have_ipv6) {
+		if (!have_ipv4 && cur->ai_family == AF_INET) {
+			memcpy(&daddr, cur->ai_addr, sizeof(daddr));
+			daddr.sin_port = htons(dest_port);
+			have_ipv4 = 1;
+		}
+		else if (!have_ipv6 && cur->ai_family == AF_INET6) {
+			memcpy(&daddr6, cur->ai_addr, sizeof(daddr6));
+			daddr6.sin6_port = htons(dest_port);
+			have_ipv6 = 1;
+		}
+		cur = cur->ai_next;
+	}
+	if (addrs)
+		freeaddrinfo(addrs);
+
+	do_ipv4 &= have_ipv4;
+	do_ipv6 &= have_ipv6;
+}
+
+static void do_main(int family)
+{
+	fprintf(stderr, "family:       %s\n",
+			family == PF_INET ? "INET" : "INET6");
+
+	fprintf(stderr, "test SND\n");
+	do_test(family, MSG_TSTAMP);
+
+	fprintf(stderr, "test ENQ\n");
+	do_test(family, MSG_TSTAMP_ENQ);
+
+	fprintf(stderr, "test ENQ + SND\n");
+	do_test(family, MSG_TSTAMP_ENQ | MSG_TSTAMP);
+
+	if (!do_udp) {
+		fprintf(stderr, "\ntest ACK\n");
+		do_test(family, MSG_TSTAMP_ACK);
+
+		fprintf(stderr, "\ntest SND + ACK\n");
+		do_test(family, MSG_TSTAMP | MSG_TSTAMP_ACK);
+
+		fprintf(stderr, "\ntest ENQ + SND + ACK\n");
+		do_test(family, MSG_TSTAMP_ENQ | MSG_TSTAMP | MSG_TSTAMP_ACK);
+	}
+}
+
+int main(int argc, char **argv)
+{
+	parse_opt(argc, argv);
+	resolve_hostname(argv[argc - 1]);
+
+	fprintf(stderr, "protocol:     %s\n", do_udp ? "udp" : "tcp");
+	fprintf(stderr, "payload:      %u\n", payload_len);
+	fprintf(stderr, "server port:  %u\n", dest_port);
+	fprintf(stderr, "\n");
+
+	if (do_ipv4)
+		do_main(PF_INET);
+	if (do_ipv6)
+		do_main(PF_INET6);
+
+	return 0;
+}
-- 
2.0.0.526.g5318336
