From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] net-timestamp: expand documentation
Date: Sun, 31 Aug 2014 21:27:47 -0400
Message-ID: <1409534867-32710-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:54317 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbaIAB15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2014 21:27:57 -0400
Received: by mail-pd0-f202.google.com with SMTP id w10so707056pde.5
        for <netdev@vger.kernel.org>; Sun, 31 Aug 2014 18:27:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expand Documentation/networking/timestamping.txt with new
interfaces and bytestream timestamping. Also minor
cleanup of the other text.

Import txtimestamp.c test of the new features.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 Documentation/networking/timestamping.txt          | 368 ++++++++++++----
 Documentation/networking/timestamping/Makefile     |  10 +-
 .../networking/timestamping/txtimestamp.c          | 470 +++++++++++++++++++++
 3 files changed, 764 insertions(+), 84 deletions(-)
 create mode 100644 Documentation/networking/timestamping/txtimestamp.c

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index 897f942..412f45c 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -1,102 +1,307 @@
-The existing interfaces for getting network packages time stamped are:
+
+1. Control Interfaces
+
+The interfaces for receiving network packages timestamps are:
 
 * SO_TIMESTAMP
-  Generate time stamp for each incoming packet using the (not necessarily
-  monotonous!) system time. Result is returned via recv_msg() in a
-  control message as timeval (usec resolution).
+  Generates a timestamp for each incoming packet in (not necessarily
+  monotonic) system time. Reports the timestamp via recvmsg() in a
+  control message as struct timeval (usec resolution).
 
 * SO_TIMESTAMPNS
-  Same time stamping mechanism as SO_TIMESTAMP, but returns result as
-  timespec (nsec resolution).
+  Same timestamping mechanism as SO_TIMESTAMP, but reports the
+  timestamp as struct timespec (nsec resolution).
 
 * IP_MULTICAST_LOOP + SO_TIMESTAMP[NS]
-  Only for multicasts: approximate send time stamp by receiving the looped
-  packet and using its receive time stamp.
+  Only for multicast:approximate transmit timestamp obtained by
+  reading the looped packet receive timestamp.
 
-The following interface complements the existing ones: receive time
-stamps can be generated and returned for arbitrary packets and much
-closer to the point where the packet is really sent. Time stamps can
-be generated in software (as before) or in hardware (if the hardware
-has such a feature).
+* SO_TIMESTAMPING
+  Generates timestamps on reception, transmission or both. Supports
+  multiple timestamp sources, including hardware. Supports generating
+  timestamps for stream sockets.
 
-SO_TIMESTAMPING:
 
-Instructs the socket layer which kind of information should be collected
-and/or reported.  The parameter is an integer with some of the following
-bits set. Setting other bits is an error and doesn't change the current
-state.
+1.1 SO_TIMESTAMP:
 
-Four of the bits are requests to the stack to try to generate
-timestamps.  Any combination of them is valid.
+This socket option enables timestamping of datagrams on the reception
+path. Because the destination socket, if any, is not known early in
+the network stack, the feature has to be enabled for all packets. The
+same is true for all early receive timestamp options.
 
-SOF_TIMESTAMPING_TX_HARDWARE:  try to obtain send time stamps in hardware
-SOF_TIMESTAMPING_TX_SOFTWARE:  try to obtain send time stamps in software
-SOF_TIMESTAMPING_RX_HARDWARE:  try to obtain receive time stamps in hardware
-SOF_TIMESTAMPING_RX_SOFTWARE:  try to obtain receive time stamps in software
+For interface details, see `man 7 socket`.
+
+
+1.2 SO_TIMESTAMPNS:
+
+This option is identical to SO_TIMESTAMP except for the returned data type.
+Its struct timespec allows for higher resolution (ns) timestamps than the
+timeval of SO_TIMESTAMP (ms).
+
+
+1.3 SO_TIMESTAMPING:
+
+Supports multiple types of timestamp requests. As a result, this
+socket option takes a bitmap of flags, not a boolean. In
+
+  err = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING, (void *) val, &val);
+
+val is an integer with any of the following bits set. Setting other
+bit returns EINVAL and does not change the current state.
 
-The other three bits control which timestamps will be reported in a
-generated control message.  If none of these bits are set or if none of
-the set bits correspond to data that is available, then the control
-message will not be generated:
 
-SOF_TIMESTAMPING_SOFTWARE:     report systime if available
-SOF_TIMESTAMPING_SYS_HARDWARE: report hwtimetrans if available (deprecated)
-SOF_TIMESTAMPING_RAW_HARDWARE: report hwtimeraw if available
+1.3.1 Timestamp Generation
 
-It is worth noting that timestamps may be collected for reasons other
-than being requested by a particular socket with
-SOF_TIMESTAMPING_[TR]X_(HARD|SOFT)WARE.  For example, most drivers that
-can generate hardware receive timestamps ignore
-SOF_TIMESTAMPING_RX_HARDWARE.  It is still a good idea to set that flag
-in case future drivers pay attention.
+Some bits are requests to the stack to try to generate timestamps. Any
+combination of them is valid. Changes to these bits apply to newly
+created packets, not to packets already in the stack. As a result, it
+is possible to selectively request timestamps for a subset of packets
+(e.g., for sampling) by embedding an send() call within two setsockopt
+calls, one to enable timestamp generation and one to disable it.
+Timestamps may also be generated for reasons other than being
+requested by a particular socket, such as when receive timestamping is
+enabled system wide, as explained earlier.
 
-If timestamps are reported, they will appear in a control message with
-cmsg_level==SOL_SOCKET, cmsg_type==SO_TIMESTAMPING, and a payload like
-this:
+SOF_TIMESTAMPING_RX_HARDWARE:
+  Request rx timestamps generated by the network adapter.
+
+SOF_TIMESTAMPING_RX_SOFTWARE:
+  Request rx timestamps when data enters the kernel. These timestamps
+  are generated just after a device driver hands a packet to the
+  kernel receive stack.
+
+SOF_TIMESTAMPING_TX_HARDWARE:
+  Request tx timestamps generated by the network adapter.
+
+SOF_TIMESTAMPING_TX_SOFTWARE:
+  Request tx timestamps when data leaves the kernel. These timestamps
+  are generated in the device driver as close as possible, but always
+  prior to, passing the packet to the network interface. Hence, they
+  require driver support and may not be available for all devices.
+
+SOF_TIMESTAMPING_TX_SCHED:
+  Request tx timestamps prior to entering the packet scheduler. Kernel
+  transmit latency is, if long, often dominated by queuing delay. The
+  difference between this timestamp and one taken at
+  SOF_TIMESTAMPING_TX_SOFTWARE will expose this latency independent
+  of protocol processing. The latency incurred in protocol
+  processing, if any, can be computed by subtracting a userspace
+  timestamp taken immediately before send() from this timestamp. On
+  machines with virtual devices where a transmitted packet travels
+  through multiple devices and, hence, multiple packet schedulers,
+  a timestamp is generated at each layer. This allows for fine
+  grained measurement of queuing delay.
+
+SOF_TIMESTAMPING_TX_ACK:
+  Request tx timestamps when all data in the send buffer has been
+  acknowledged. This only makes sense for reliable protocols. It is
+  currently only implemented for TCP. For that protocol, it may
+  over-report measurement, because the timestamp is generated when all
+  data up to and including the buffer at send() was acknowledged: the
+  cumulative acknowledgment. The mechanism ignores SACK and FACK.
+
+
+1.3.2 Timestamp Reporting
+
+The other three bits control which timestamps will be reported in a
+generated control message. Changes to the bits take immediate
+effect at the timestamp reporting locations in the stack. Timestamps
+are only reported for packets that also have the relevant timestamp
+generation request set.
+
+SOF_TIMESTAMPING_SOFTWARE:
+  Report any software timestamps when available.
+
+SOF_TIMESTAMPING_SYS_HARDWARE:
+  This option is deprecated and ignored.
+
+SOF_TIMESTAMPING_RAW_HARDWARE:
+  Report hardware timestamps as generated by
+  SOF_TIMESTAMPING_TX_HARDWARE when available.
+
+
+1.3.3 Timestamp Options
+
+The interface supports one option
+
+SOF_TIMESTAMPING_OPT_ID:
+
+  Generate a unique identifier along with each packet. A process can
+  have multiple concurrent timestamping requests outstanding. Packets
+  can be reordered in the transmit path, for instance in the packet
+  scheduler. In that case timestamps will be queued onto the error
+  queue out of order from the original send() calls. This option
+  embeds a counter that is incremented at send() time, to order
+  timestamps within a flow.
+
+  This option is implemented only for transmit timestamps. There, the
+  timestamp is always looped along with a struct sock_extended_err.
+  The option modifies field ee_info to pass an id that is unique
+  among all possibly concurrently outstanding timestamp requests for
+  that socket. In practice, it is a monotonically increasing u32
+  (that wraps).
+
+  In datagram sockets, the counter increments on each send call. In
+  stream sockets, it increments with every byte.
+
+
+1.4 Bytestream Timestamps
+
+The SO_TIMESTAMPING interface supports timestamping of bytes in a
+bytestream. Each request is interpreted as a request for when the
+entire contents of the buffer has passed a timestamping point. That
+is, for streams option SOF_TIMESTAMPING_TX_SOFTWARE will record
+when all bytes have reached the device driver, regardless of how
+many packets the data has been converted into.
+
+In general, bytestreams have no natural delimiters and therefore
+correlating a timestamp with data is non-trivial. A range of bytes
+may be split across segments, any segments may be merged (possibly
+coalescing sections of previously segmented buffers associated with
+independent send() calls). Segments can be reordered and the same
+byte range can coexist in multiple segments for protocols that
+implement retransmissions.
+
+It is essential that all timestamps implement the same semantics,
+regardless of these possible transformations, as otherwise they are
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
+bytes have passed a point. SOF_TIMESTAMPING_TX_ACK as defined is easy to
+implement and reason about. An implementation that has to take into
+account SACK would be more complex due to possible transmission holes
+and out of order arrival.
+
+On the host, TCP can also break the simple 1:1 mapping from buffer to
+skbuff as a result of Nagle, cork, autocork, segmentation and GSO. The
+implementation ensures correctness in all cases by tracking the
+individual last byte passed to send(), even if it is no longer the
+last byte after an skbuff extend or merge operation. It stores the
+relevant sequence number in skb_shinfo(skb)->tskey. Because an skbuff
+has only one such field, only one timestamp can be generated.
+
+In rare cases, a timestamp request can be missed if two requests are
+collapsed onto the same skb. A process can detect this situation by
+enabling SOF_TIMESTAMPING_OPT_ID and comparing the byte offset at
+send time with the value returned for each timestamp. It can prevent
+the situation by always flushing the TCP stack in between requests,
+for instance by enabling TCP_NODELAY and disabling TCP_CORK and
+autocork.
+
+These precautions ensure that the timestamp is generated only when all
+bytes have passed a timestamp point, assuming that the network stack
+itself does not reorder the segments. The stack indeed tries to avoid
+reordering. The one exception is under administrator control: it is
+possible to construct a packet scheduler configuration that delays
+segments from the same stream differently. Such a setup would be
+unusual.
+
+
+2 Data Interfaces
+
+Timestamps are read using the ancillary data feature of recvmsg().
+See `man 3 cmsg` for details of this interface. The socket manual
+page (`man 7 socket`) describes how timestamps generated with
+SO_TIMESTAMP and SO_TIMESTAMPNS records can be retrieved.
+
+
+2.1 SCM_TIMESTAMPING records
+
+These timestamps are returned in a control message with cmsg_level
+SOL_SOCKET, cmsg_type SCM_TIMESTAMPING, and payload of type
 
 struct scm_timestamping {
-	struct timespec systime;
-	struct timespec hwtimetrans;
-	struct timespec hwtimeraw;
+	struct timespec ts[3];
 };
 
-recvmsg() can be used to get this control message for regular incoming
-packets. For send time stamps the outgoing packet is looped back to
-the socket's error queue with the send time stamp(s) attached. It can
-be received with recvmsg(flags=MSG_ERRQUEUE). The call returns the
-original outgoing packet data including all headers preprended down to
-and including the link layer, the scm_timestamping control message and
-a sock_extended_err control message with ee_errno==ENOMSG and
-ee_origin==SO_EE_ORIGIN_TIMESTAMPING. A socket with such a pending
-bounced packet is ready for reading as far as select() is concerned.
-If the outgoing packet has to be fragmented, then only the first
-fragment is time stamped and returned to the sending socket.
-
-All three values correspond to the same event in time, but were
-generated in different ways. Each of these values may be empty (= all
-zero), in which case no such value was available. If the application
-is not interested in some of these values, they can be left blank to
-avoid the potential overhead of calculating them.
-
-systime is the value of the system time at that moment. This
-corresponds to the value also returned via SO_TIMESTAMP[NS]. If the
-time stamp was generated by hardware, then this field is
-empty. Otherwise it is filled in if SOF_TIMESTAMPING_SOFTWARE is
-set.
-
-hwtimeraw is the original hardware time stamp. Filled in if
-SOF_TIMESTAMPING_RAW_HARDWARE is set. No assumptions about its
-relation to system time should be made.
-
-hwtimetrans is always zero. This field is deprecated. It used to hold
-hw timestamps converted to system time. Instead, expose the hardware
-clock device on the NIC directly as a HW PTP clock source, to allow
-time conversion in userspace and optionally synchronize system time
-with a userspace PTP stack such as linuxptp. For the PTP clock API,
-see Documentation/ptp/ptp.txt.
-
-
-SIOCSHWTSTAMP, SIOCGHWTSTAMP:
+The structure can return up to three timestamps. This is a legacy
+feature. Only one field is non-zero at any time. Most timestamps
+are passed in ts[0]. Hardware timestamps are passed in ts[2].
+
+ts[1] used to hold hardware timestamps converted to system time.
+Instead, expose the hardware clock device on the NIC directly as
+a HW PTP clock source, to allow time conversion in userspace and
+optionally synchronize system time with a userspace PTP stack such
+as linuxptp. For the PTP clock API, see Documentation/ptp/ptp.txt.
+
+2.1.1 Transmit timestamps with MSG_ERRQUEUE
+
+For transmit timestamps the outgoing packet is looped back to the
+socket's error queue with the send timestamp(s) attached. A process
+receives the timestamps by calling recvmsg() with flag MSG_ERRQUEUE
+set and with a msg_control buffer sufficiently large to receive the
+relevant metadata structures. The recvmsg call returns the original
+outgoing data packet with two ancillary messages attached.
+
+A message of cm_level SOL_IP(V6) and cm_type IP(V6)_RECVERR
+embeds a struct sock_extended_err. This defines the error type. For
+timestamps, the ee_errno field is ENOMSG. The other ancillary message
+will have cm_level SOL_SOCKET and cm_type SCM_TIMESTAMPING. This
+embeds the struct scm_timestamping.
+
+
+2.1.1.2 Timestamp types
+
+The semantics of the three struct timespec are defined by field
+ee_info in the extended error structure. It contains a value of
+type SCM_TSTAMP_* to define the actual timestamp passed in
+scm_timestamping.
+
+The SCM_TSTAMP_* types are 1:1 matches to the SOF_TIMESTAMPING_*
+control fields discussed previously, with one exception. For legacy
+reasons, SCM_TSTAMP_SND is equal to zero and can be set for both
+SOF_TIMESTAMPING_TX_HARDWARE and SOF_TIMESTAMPING_TX_SOFTWARE. It
+is the first if ts[2] is non-zero, the second otherwise, in which
+case the timestamp is stored in ts[0].
+
+
+2.1.1.3 Fragmentation
+
+Fragmentation of outgoing datagrams is rare, but is possible, e.g., by
+explicitly disabling PMTU discovery. If an outgoing packet is fragmented,
+then only the first fragment is timestamped and returned to the sending
+socket.
+
+
+2.1.1.4 Packet Payload
+
+The calling application is often not interested in receiving the whole
+packet payload that it passed to the stack originally: the socket
+error queue mechanism is just a method to piggyback the timestamp on.
+In this case, the application can choose to read datagrams with a
+smaller buffer, possibly even of length 0. The payload is truncated
+accordingly. Until the process calls recvmsg() on the error queue,
+however, the full packet is queued, taking up budget from SO_RCVBUF.
+
+
+2.1.1.5 Blocking Read
+
+Reading from the error queue is always a non-blocking operation. To
+block waiting on a timestamp, use poll or select. poll() will return
+POLLERR in pollfd.revents if any data is ready on the error queue.
+There is no need to pass this flag in pollfd.events. This flag is
+ignored on request. See also `man 2 poll`.
+
+
+2.1.2 Receive timestamps
+
+On reception, there is no reason to read from the socket error queue.
+The SCM_TIMESTAMPING ancillary data is sent along with the packet data
+on a normal recvmsg(). Since this is not a socket error, it is not
+accompanied by a message SOL_IP(V6)/IP(V6)_RECVERROR. In this case,
+the meaning of the three fields in struct scm_timestamping is
+implicitly defined. ts[0] holds a software timestamp if set, ts[1]
+is again deprecated and ts[2] holds a hardware timestamp if set.
+
+
+3. Hardware Timestamping configuration: SIOCSHWTSTAMP and SIOCGHWTSTAMP
 
 Hardware time stamping must also be initialized for each device driver
 that is expected to do hardware time stamping. The parameter is defined in
@@ -167,8 +372,7 @@ enum {
 	 */
 };
 
-
-DEVICE IMPLEMENTATION
+3.1 Hardware Timestamping Implementation: Device Drivers
 
 A driver which supports hardware time stamping must support the
 SIOCSHWTSTAMP ioctl and update the supplied struct hwtstamp_config with
diff --git a/Documentation/networking/timestamping/Makefile b/Documentation/networking/timestamping/Makefile
index d934afc..95e239c 100644
--- a/Documentation/networking/timestamping/Makefile
+++ b/Documentation/networking/timestamping/Makefile
@@ -1,14 +1,20 @@
+# To compile, from the source root
+#
+#    make headers_install
+#    make M=documentation
+
 # kbuild trick to avoid linker error. Can be omitted if a module is built.
 obj- := dummy.o
 
 # List of programs to build
-hostprogs-y := timestamping hwtstamp_config
+hostprogs-y := timestamping txtimestamp hwtstamp_config
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
 
 HOSTCFLAGS_timestamping.o += -I$(objtree)/usr/include
+HOSTCFLAGS_txtimestamp.o += -I$(objtree)/usr/include
 HOSTCFLAGS_hwtstamp_config.o += -I$(objtree)/usr/include
 
 clean:
-	rm -f timestamping hwtstamp_config
+	rm -f timestamping txtimestamp hwtstamp_config
diff --git a/Documentation/networking/timestamping/txtimestamp.c b/Documentation/networking/timestamping/txtimestamp.c
new file mode 100644
index 0000000..e5b0b98
--- /dev/null
+++ b/Documentation/networking/timestamping/txtimestamp.c
@@ -0,0 +1,470 @@
+/*
+ * Copyright 2014 Google Inc.
+ * Author: willemb@google.com (Willem de Bruijn)
+ *
+ * Test software tx timestamping, including
+ *
+ * - SCHED, SND and ACK timestamps
+ * - RAW, UDP and TCP
+ * - IPv4 and IPv6
+ * - various packet sizes (to test GSO and TSO)
+ *
+ * Consult the command line arguments for help on running
+ * the various testcases.
+ *
+ * This test requires a dummy TCP server.
+ * A simple `nc6 [-u] -l -p $DESTPORT` will do
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
+#include <poll.h>
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
+#include <time.h>
+#include <unistd.h>
+
+/* command line parameters */
+static int cfg_proto = SOCK_STREAM;
+static int cfg_ipproto = IPPROTO_TCP;
+static int cfg_num_pkts = 4;
+static int do_ipv4 = 1;
+static int do_ipv6 = 1;
+static int cfg_payload_len = 10;
+static uint16_t dest_port = 9000;
+
+static struct sockaddr_in daddr;
+static struct sockaddr_in6 daddr6;
+static struct timespec ts_prev;
+
+static void __print_timestamp(const char *name, struct timespec *cur,
+			      uint32_t key, int payload_len)
+{
+	if (!(cur->tv_sec | cur->tv_nsec))
+		return;
+
+	fprintf(stderr, "  %s: %lu s %lu us (seq=%u, len=%u)",
+			name, cur->tv_sec, cur->tv_nsec / 1000,
+			key, payload_len);
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
+	struct timeval tv;	/* avoid dependency on -lrt */
+
+	gettimeofday(&tv, NULL);
+	ts.tv_sec = tv.tv_sec;
+	ts.tv_nsec = tv.tv_usec * 1000;
+
+	__print_timestamp("  USR", &ts, 0, 0);
+}
+
+static void print_timestamp(struct scm_timestamping *tss, int tstype,
+			    int tskey, int payload_len)
+{
+	const char *tsname;
+
+	switch (tstype) {
+	case SCM_TSTAMP_SCHED:
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
+		tstype);
+	}
+	__print_timestamp(tsname, &tss->ts[0], tskey, payload_len);
+}
+
+static void __poll(int fd)
+{
+	struct pollfd pollfd;
+	int ret;
+
+	memset(&pollfd, 0, sizeof(pollfd));
+	pollfd.fd = fd;
+	ret = poll(&pollfd, 1, 100);
+	if (ret != 1)
+		error(1, errno, "poll");
+}
+
+static void __recv_errmsg_cmsg(struct msghdr *msg, int payload_len)
+{
+	struct sock_extended_err *serr = NULL;
+	struct scm_timestamping *tss = NULL;
+	struct cmsghdr *cm;
+
+	for (cm = CMSG_FIRSTHDR(msg);
+	     cm && cm->cmsg_len;
+	     cm = CMSG_NXTHDR(msg, cm)) {
+		if (cm->cmsg_level == SOL_SOCKET &&
+		    cm->cmsg_type == SCM_TIMESTAMPING) {
+			tss = (void *) CMSG_DATA(cm);
+		} else if ((cm->cmsg_level == SOL_IP &&
+		     cm->cmsg_type == IP_RECVERR) ||
+		    (cm->cmsg_level == SOL_IPV6 &&
+		     cm->cmsg_type == IPV6_RECVERR)) {
+
+			serr = (void *) CMSG_DATA(cm);
+			if (serr->ee_errno != ENOMSG ||
+			    serr->ee_origin != SO_EE_ORIGIN_TIMESTAMPING) {
+				fprintf(stderr, "unknown ip error %d %d\n",
+						serr->ee_errno,
+						serr->ee_origin);
+				serr = NULL;
+			}
+		} else
+			fprintf(stderr, "unknown cmsg %d,%d\n",
+					cm->cmsg_level, cm->cmsg_type);
+	}
+
+	if (serr && tss)
+		print_timestamp(tss, serr->ee_info, serr->ee_data, payload_len);
+}
+
+static int recv_errmsg(int fd)
+{
+	static char ctrl[1024 /* overprovision*/];
+	static struct msghdr msg;
+	struct iovec entry;
+	static char *data;
+	int ret = 0;
+
+	data = malloc(cfg_payload_len);
+	if (!data)
+		error(1, 0, "malloc");
+
+	memset(&msg, 0, sizeof(msg));
+	memset(&entry, 0, sizeof(entry));
+	memset(ctrl, 0, sizeof(ctrl));
+	memset(data, 0, sizeof(data));
+
+	entry.iov_base = data;
+	entry.iov_len = cfg_payload_len;
+	msg.msg_iov = &entry;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = ctrl;
+	msg.msg_controllen = sizeof(ctrl);
+
+	ret = recvmsg(fd, &msg, MSG_ERRQUEUE);
+	if (ret == -1 && errno != EAGAIN)
+		error(1, errno, "recvmsg");
+
+	__recv_errmsg_cmsg(&msg, ret);
+
+	free(data);
+	return ret == -1;
+}
+
+static void do_test(int family, unsigned int opt)
+{
+	char *buf;
+	int fd, i, val, total_len;
+
+	if (family == IPPROTO_IPV6 && cfg_proto != SOCK_STREAM) {
+		/* due to lack of checksum generation code */
+		fprintf(stderr, "test: skipping datagram over IPv6\n");
+		return;
+	}
+
+	total_len = cfg_payload_len;
+	if (cfg_proto == SOCK_RAW) {
+		total_len += sizeof(struct udphdr);
+		if (cfg_ipproto == IPPROTO_RAW)
+			total_len += sizeof(struct iphdr);
+	}
+
+	buf = malloc(total_len);
+	if (!buf)
+		error(1, 0, "malloc");
+
+	fd = socket(family, cfg_proto, cfg_ipproto);
+	if (fd < 0)
+		error(1, errno, "socket");
+
+	if (cfg_proto == SOCK_STREAM) {
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
+	opt |= SOF_TIMESTAMPING_SOFTWARE |
+	       SOF_TIMESTAMPING_OPT_ID;
+	if (setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING,
+		       (char *) &opt, sizeof(opt)))
+		error(1, 0, "setsockopt timestamping");
+
+	for (i = 0; i < cfg_num_pkts; i++) {
+		memset(&ts_prev, 0, sizeof(ts_prev));
+		memset(buf, 'a' + i, total_len);
+		buf[total_len - 2] = '\n';
+		buf[total_len - 1] = '\0';
+
+		if (cfg_proto == SOCK_RAW) {
+			struct udphdr *udph;
+			int off = 0;
+
+			if (cfg_ipproto == IPPROTO_RAW) {
+				struct iphdr *iph = (void *) buf;
+
+				memset(iph, 0, sizeof(*iph));
+				iph->ihl      = 5;
+				iph->version  = 4;
+				iph->ttl      = 2;
+				iph->daddr    = daddr.sin_addr.s_addr;
+				iph->protocol = IPPROTO_UDP;
+				/* kernel writes saddr, csum, len */
+
+				off = sizeof(*iph);
+			}
+
+			udph = (void *) buf + off;
+			udph->source = ntohs(9000); 	/* random spoof */
+			udph->dest   = ntohs(dest_port);
+			udph->len    = ntohs(sizeof(*udph) + cfg_payload_len);
+			udph->check  = 0;	/* not allowed for IPv6 */
+		}
+
+		print_timestamp_usr();
+		if (cfg_proto != SOCK_STREAM) {
+			if (family == PF_INET)
+				val = sendto(fd, buf, total_len, 0, (void *) &daddr, sizeof(daddr));
+			else
+				val = sendto(fd, buf, total_len, 0, (void *) &daddr6, sizeof(daddr6));
+		} else {
+			val = send(fd, buf, cfg_payload_len, 0);
+		}
+		if (val != total_len)
+			error(1, errno, "send");
+
+		/* wait for all errors to be queued, else ACKs arrive OOO */
+		usleep(50 * 1000);
+
+		__poll(fd);
+
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
+			"  -r:   use raw\n"
+			"  -R:   use raw (IP_HDRINCL)\n"
+			"  -p N: connect to port N\n"
+			"  -u:   use udp\n",
+			filepath);
+	exit(1);
+}
+
+static void parse_opt(int argc, char **argv)
+{
+	int proto_count = 0;
+	char c;
+
+	while ((c = getopt(argc, argv, "46hl:p:rRu")) != -1) {
+		switch (c) {
+		case '4':
+			do_ipv6 = 0;
+			break;
+		case '6':
+			do_ipv4 = 0;
+			break;
+		case 'r':
+			proto_count++;
+			cfg_proto = SOCK_RAW;
+			cfg_ipproto = IPPROTO_UDP;
+			break;
+		case 'R':
+			proto_count++;
+			cfg_proto = SOCK_RAW;
+			cfg_ipproto = IPPROTO_RAW;
+			break;
+		case 'u':
+			proto_count++;
+			cfg_proto = SOCK_DGRAM;
+			cfg_ipproto = IPPROTO_UDP;
+			break;
+		case 'l':
+			cfg_payload_len = strtoul(optarg, NULL, 10);
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
+	if (!cfg_payload_len)
+		error(1, 0, "payload may not be nonzero");
+	if (cfg_proto != SOCK_STREAM && cfg_payload_len > 1472)
+		error(1, 0, "udp packet might exceed expected MTU");
+	if (!do_ipv4 && !do_ipv6)
+		error(1, 0, "pass -4 or -6, not both");
+	if (proto_count > 1)
+		error(1, 0, "pass -r, -R or -u, not multiple");
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
+	do_test(family, SOF_TIMESTAMPING_TX_SOFTWARE);
+
+	fprintf(stderr, "test ENQ\n");
+	do_test(family, SOF_TIMESTAMPING_TX_SCHED);
+
+	fprintf(stderr, "test ENQ + SND\n");
+	do_test(family, SOF_TIMESTAMPING_TX_SCHED |
+			SOF_TIMESTAMPING_TX_SOFTWARE);
+
+	if (cfg_proto == SOCK_STREAM) {
+		fprintf(stderr, "\ntest ACK\n");
+		do_test(family, SOF_TIMESTAMPING_TX_ACK);
+
+		fprintf(stderr, "\ntest SND + ACK\n");
+		do_test(family, SOF_TIMESTAMPING_TX_SOFTWARE |
+				SOF_TIMESTAMPING_TX_ACK);
+
+		fprintf(stderr, "\ntest ENQ + SND + ACK\n");
+		do_test(family, SOF_TIMESTAMPING_TX_SCHED |
+				SOF_TIMESTAMPING_TX_SOFTWARE |
+				SOF_TIMESTAMPING_TX_ACK);
+	}
+}
+
+const char *sock_names[] = { NULL, "TCP", "UDP", "RAW" };
+
+int main(int argc, char **argv)
+{
+	if (argc == 1)
+		usage(argv[0]);
+
+	parse_opt(argc, argv);
+	resolve_hostname(argv[argc - 1]);
+
+	fprintf(stderr, "protocol:     %s\n", sock_names[cfg_proto]);
+	fprintf(stderr, "payload:      %u\n", cfg_payload_len);
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
2.1.0.rc2.206.gedb03e5
