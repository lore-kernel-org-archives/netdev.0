From: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH NET-NEXT 01/12] net: new user space API for time stamping of incoming and outgoing packets
Date: Wed, 21 Jan 2009 11:10:01 +0100
Message-ID: <1232532612-10382-1-git-send-email-patrick.ohly@intel.com>
References: <1232532457.7829.19.camel@ecld0pohly>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1232532457.7829.19.camel@ecld0pohly>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

User space can request hardware and/or software time stamping.
Reporting of the result(s) via a new control message is enabled
separately for each field in the message because some of the
fields may require additional computation and thus cause overhead.
User space can tell the different kinds of time stamps apart
and choose what suits its needs.

When a TX timestamp operation is requested, the TX skb will be cloned
and the clone will be time stamped (in hardware or software) and added
to the socket error queue of the skb, if the skb has a socket
associated with it.

The actual TX timestamp will reach userspace as a RX timestamp on the
cloned packet. If timestamping is requested and no timestamping is
done in the device driver (potentially this may use hardware
timestamping), it will be done in software after the device's
start_hard_xmit routine.
---
 Documentation/networking/timestamping.txt          |  178 ++++++++
 Documentation/networking/timestamping/.gitignore   |    1 +
 Documentation/networking/timestamping/Makefile     |    3 +
 .../networking/timestamping/timestamping.c         |  469 ++++++++++++++++++++
 arch/alpha/include/asm/socket.h                    |    3 +
 arch/arm/include/asm/socket.h                      |    3 +
 arch/avr32/include/asm/socket.h                    |    3 +
 arch/blackfin/include/asm/socket.h                 |    3 +
 arch/cris/include/asm/socket.h                     |    3 +
 arch/h8300/include/asm/socket.h                    |    3 +
 arch/ia64/include/asm/socket.h                     |    3 +
 arch/mips/include/asm/socket.h                     |    3 +
 arch/parisc/include/asm/socket.h                   |    3 +
 arch/powerpc/include/asm/socket.h                  |    3 +
 arch/s390/include/asm/socket.h                     |    3 +
 arch/sh/include/asm/socket.h                       |    3 +
 arch/sparc/include/asm/socket.h                    |    3 +
 arch/x86/include/asm/socket.h                      |    3 +
 include/asm-frv/socket.h                           |    3 +
 include/asm-m32r/socket.h                          |    3 +
 include/asm-m68k/socket.h                          |    3 +
 include/asm-mn10300/socket.h                       |    3 +
 include/asm-xtensa/socket.h                        |    3 +
 include/linux/errqueue.h                           |    1 +
 include/linux/net_tstamp.h                         |  112 +++++
 include/linux/sockios.h                            |    3 +
 26 files changed, 824 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/networking/timestamping.txt
 create mode 100644 Documentation/networking/timestamping/.gitignore
 create mode 100644 Documentation/networking/timestamping/Makefile
 create mode 100644 Documentation/networking/timestamping/timestamping.c
 create mode 100644 include/linux/net_tstamp.h

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
new file mode 100644
index 0000000..a681a65
--- /dev/null
+++ b/Documentation/networking/timestamping.txt
@@ -0,0 +1,178 @@
+The existing interfaces for getting network packages time stamped are:
+
+* SO_TIMESTAMP
+  Generate time stamp for each incoming packet using the (not necessarily
+  monotonous!) system time. Result is returned via recv_msg() in a
+  control message as timeval (usec resolution).
+
+* SO_TIMESTAMPNS
+  Same time stamping mechanism as SO_TIMESTAMP, but returns result as
+  timespec (nsec resolution).
+
+* IP_MULTICAST_LOOP + SO_TIMESTAMP[NS]
+  Only for multicasts: approximate send time stamp by receiving the looped
+  packet and using its receive time stamp.
+
+The following interface complements the existing ones: receive time
+stamps can be generated and returned for arbitrary packets and much
+closer to the point where the packet is really sent. Time stamps can
+be generated in software (as before) or in hardware (if the hardware
+has such a feature).
+
+SO_TIMESTAMPING:
+
+Instructs the socket layer which kind of information is wanted. The
+parameter is an integer with some of the following bits set. Setting
+other bits is an error and doesn't change the current state.
+
+SOF_TIMESTAMPING_TX_HARDWARE:  try to obtain send time stamp in hardware
+SOF_TIMESTAMPING_TX_SOFTWARE:  if SOF_TIMESTAMPING_TX_HARDWARE is off or
+                               fails, then do it in software
+SOF_TIMESTAMPING_RX_HARDWARE:  return the original, unmodified time stamp
+                               as generated by the hardware
+SOF_TIMESTAMPING_RX_SOFTWARE:  if SOF_TIMESTAMPING_RX_HARDWARE is off or
+                               fails, then do it in software
+SOF_TIMESTAMPING_RAW_HARDWARE: return original raw hardware time stamp
+SOF_TIMESTAMPING_SYS_HARDWARE: return hardware time stamp transformed to
+                               the system time base
+SOF_TIMESTAMPING_SOFTWARE:     return system time stamp generated in
+                               software
+
+SOF_TIMESTAMPING_TX/RX determine how time stamps are generated.
+SOF_TIMESTAMPING_RAW/SYS determine how they are reported in the
+following control message:
+    struct scm_timestamping {
+           struct timespec systime;
+           struct timespec hwtimetrans;
+           struct timespec hwtimeraw;
+    };
+
+recvmsg() can be used to get this control message for regular incoming
+packets. For send time stamps the outgoing packet is looped back to
+the socket's error queue with the send time stamp(s) attached. It can
+be received with recvmsg(flags=MSG_ERRQUEUE). The call returns the
+original outgoing packet data including all headers preprended down to
+and including the link layer, the scm_timestamping control message and
+a sock_extended_err control message with ee_errno==ENOMSG and
+ee_origin==SO_EE_ORIGIN_TIMESTAMPING. A socket with such a pending
+bounced packet is ready for reading as far as select() is concerned.
+
+All three values correspond to the same event in time, but were
+generated in different ways. Each of these values may be empty (= all
+zero), in which case no such value was available. If the application
+is not interested in some of these values, they can be left blank to
+avoid the potential overhead of calculating them.
+
+systime is the value of the system time at that moment. This
+corresponds to the value also returned via SO_TIMESTAMP[NS]. If the
+time stamp was generated by hardware, then this field is
+empty. Otherwise it is filled in if SOF_TIMESTAMPING_SOFTWARE is
+set.
+
+hwtimeraw is the original hardware time stamp. Filled in if
+SOF_TIMESTAMPING_RAW_HARDWARE is set. No assumptions about its
+relation to system time should be made.
+
+hwtimetrans is the hardware time stamp transformed so that it
+corresponds as good as possible to system time. This correlation is
+not perfect; as a consequence, sorting packets received via different
+NICs by their hwtimetrans may differ from the order in which they were
+received. hwtimetrans may be non-monotonic even for the same NIC.
+Filled in if SOF_TIMESTAMPING_SYS_HARDWARE is set. Requires support
+by the network device and will be empty without that support.
+
+
+SIOCSHWTSTAMP:
+
+Hardware time stamping must also be initialized for each device driver
+that is expected to do hardware time stamping. The parameter is:
+
+struct hwtstamp_config {
+    int flags;           /* no flags defined right now, must be zero */
+    int tx_type;         /* HWTSTAMP_TX_* */
+    int rx_filter;       /* HWTSTAMP_FILTER_* */
+};
+
+Desired behavior is passed into the kernel and to a specific device by
+calling ioctl(SIOCSHWTSTAMP) with a pointer to a struct ifreq whose
+ifr_data points to a struct hwtstamp_config. The tx_type and
+rx_filter are hints to the driver what it is expected to do. If
+the requested fine-grained filtering for incoming packets is not
+supported, the driver may time stamp more than just the requested types
+of packets.
+
+A driver which supports hardware time stamping shall update the struct
+with the actual, possibly more permissive configuration. If the
+requested packets cannot be time stamped, then nothing should be
+changed and ERANGE shall be returned (in contrast to EINVAL, which
+indicates that SIOCSHWTSTAMP is not supported at all).
+
+Only a processes with admin rights may change the configuration. User
+space is responsible to ensure that multiple processes don't interfere
+with each other and that the settings are reset.
+
+/* possible values for hwtstamp_config->tx_type */
+enum {
+	/*
+	 * no outgoing packet will need hardware time stamping;
+	 * should a packet arrive which asks for it, no hardware
+	 * time stamping will be done
+	 */
+	HWTSTAMP_TX_OFF,
+
+	/*
+	 * enables hardware time stamping for outgoing packets;
+	 * the sender of the packet decides which are to be
+	 * time stamped by setting SOF_TIMESTAMPING_TX_SOFTWARE
+	 * before sending the packet
+	 */
+	HWTSTAMP_TX_ON,
+};
+
+/* possible values for hwtstamp_config->rx_filter */
+enum {
+	/* time stamp no incoming packet at all */
+	HWTSTAMP_FILTER_NONE,
+
+	/* time stamp any incoming packet */
+	HWTSTAMP_FILTER_ALL,
+
+        /* return value: time stamp all packets requested plus some others */
+        HWTSTAMP_FILTER_SOME,
+
+	/* PTP v1, UDP, any kind of event packet */
+	HWTSTAMP_FILTER_PTP_V1_L4_EVENT,
+
+        ...
+};
+
+
+DEVICE IMPLEMENTATION
+
+A driver which supports hardware time stamping must support the
+SIOCSHWTSTAMP ioctl. Time stamps for received packets must be stored
+in the skb with skb_hwtstamp_set().
+
+Time stamps for outgoing packets are to be generated as follows:
+- In hard_start_xmit(), check if skb_hwtstamp_check_tx_hardware()
+  returns non-zero. If yes, then the driver is expected
+  to do hardware time stamping.
+- If this is possible for the skb and requested, then declare
+  that the driver is doing the time stamping by calling
+  skb_hwtstamp_tx_in_progress(). A driver not supporting
+  hardware time stamping doesn't do that. A driver must never
+  touch sk_buff::tstamp! It is used to store how time stamping
+  for an outgoing packets is to be done.
+- As soon as the driver has sent the packet and/or obtained a
+  hardware time stamp for it, it passes the time stamp back by
+  calling skb_hwtstamp_tx() with the original skb, the raw
+  hardware time stamp and a handle to the device (necessary
+  to convert the hardware time stamp to system time). If obtaining
+  the hardware time stamp somehow fails, then the driver should
+  not fall back to software time stamping. The rationale is that
+  this would occur at a later time in the processing pipeline
+  than other software time stamping and therefore could lead
+  to unexpected deltas between time stamps.
+- If the driver did not call skb_hwtstamp_tx_in_progress(), then
+  dev_hard_start_xmit() checks whether software time stamping
+  is wanted as fallback and potentially generates the time stamp.
diff --git a/Documentation/networking/timestamping/.gitignore b/Documentation/networking/timestamping/.gitignore
new file mode 100644
index 0000000..71e81eb
--- /dev/null
+++ b/Documentation/networking/timestamping/.gitignore
@@ -0,0 +1 @@
+timestamping
diff --git a/Documentation/networking/timestamping/Makefile b/Documentation/networking/timestamping/Makefile
new file mode 100644
index 0000000..ce170d1
--- /dev/null
+++ b/Documentation/networking/timestamping/Makefile
@@ -0,0 +1,3 @@
+CPPFLAGS = -I../../../include
+
+timestamping: timestamping.c
diff --git a/Documentation/networking/timestamping/timestamping.c b/Documentation/networking/timestamping/timestamping.c
new file mode 100644
index 0000000..26d2e25
--- /dev/null
+++ b/Documentation/networking/timestamping/timestamping.c
@@ -0,0 +1,469 @@
+/*
+ * This program demonstrates how the various time stamping features in
+ * the Linux kernel work. It emulates the behavior of a PTP
+ * implementation in stand-alone master mode by sending PTPv1 Sync
+ * multicasts once every second. It looks for similar packets, but
+ * beyond that doesn't actually implement PTP.
+ *
+ * Outgoing packets are time stamped with SO_TIMESTAMPING with or
+ * without hardware support.
+ *
+ * Incoming packets are time stamped with SO_TIMESTAMPING with or
+ * without hardware support, SIOCGSTAMP[NS] (per-socket time stamp) and
+ * SO_TIMESTAMP[NS].
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <string.h>
+
+#include <sys/time.h>
+#include <sys/socket.h>
+#include <sys/select.h>
+#include <sys/ioctl.h>
+#include <arpa/inet.h>
+#include <net/if.h>
+
+#include "asm/types.h"
+#include "linux/net_tstamp.h"
+#include "linux/errqueue.h"
+
+#ifndef SO_TIMESTAMPNS
+# define SO_TIMESTAMPNS 35
+#endif
+
+#ifndef SIOCGSTAMPNS
+# define SIOCGSTAMPNS 0x8907
+#endif
+
+static void usage(const char *error)
+{
+	if (error)
+		printf("invalid option: %s\n", error);
+	printf("timestamping interface (IP_MULTICAST_LOOP|SO_TIMESTAMP|SO_TIMESTAMPNS|SOF_TIMESTAMPING_TX_HARDWARE|SOF_TIMESTAMPING_TX_SOFTWARE|SOF_TIMESTAMPING_RX_HARDWARE|SOF_TIMESTAMPING_RX_SOFTWARE|SOF_TIMESTAMPING_SOFTWARE|SOF_TIMESTAMPING_SYS_HARDWARE|SOF_TIMESTAMPING_RAW_HARDWARE|SIOCGSTAMP|SIOCGSTAMPNS)*\n");
+	exit(1);
+}
+
+static void bail(const char *error)
+{
+	printf("%s: %s\n", error, strerror(errno));
+	exit(1);
+}
+
+static const unsigned char sync[] = {
+	0x00,0x01, 0x00,0x01,
+	0x5f,0x44, 0x46,0x4c,
+	0x54,0x00, 0x00,0x00,
+	0x00,0x00, 0x00,0x00,
+	0x00,0x00, 0x00,0x00,
+	0x01,0x01,
+
+	/* fake uuid */
+	0x00,0x01,
+	0x02,0x03, 0x04,0x05,
+
+	0x00,0x01, 0x00,0x37,
+	0x00,0x00, 0x00,0x08,
+	0x00,0x00, 0x00,0x00,
+	0x49,0x05, 0xcd,0x01,
+	0x29,0xb1, 0x8d,0xb0,
+	0x00,0x00, 0x00,0x00,
+	0x00,0x01,
+
+	/* fake uuid */
+	0x00,0x01,
+	0x02,0x03, 0x04,0x05,
+
+	0x00,0x00, 0x00,0x37,
+	0x00,0x00, 0x00,0x04,
+	0x44,0x46, 0x4c,0x54,
+	0x00,0x00, 0xf0,0x60,
+	0x00,0x01, 0x00,0x00,
+	0x00,0x00, 0x00,0x01,
+	0x00,0x00, 0xf0,0x60,
+	0x00,0x00, 0x00,0x00,
+	0x00,0x00, 0x00,0x04,
+	0x44,0x46, 0x4c,0x54,
+	0x00,0x01,
+
+	/* fake uuid */
+	0x00,0x01,
+	0x02,0x03, 0x04,0x05,
+
+	0x00,0x00, 0x00,0x00,
+	0x00,0x00, 0x00,0x00,
+	0x00,0x00, 0x00,0x00,
+	0x00,0x00, 0x00,0x00
+};
+
+static void sendpacket(int sock, struct sockaddr *addr, socklen_t addr_len)
+{
+	struct timeval now;
+	int res;
+
+	res = sendto(sock, sync, sizeof(sync), 0,
+		addr, addr_len);
+	gettimeofday(&now, 0);
+	if (res < 0)
+		printf("%s: %s\n", "send", strerror(errno));
+	else
+		printf("%ld.%06ld: sent %d bytes\n",
+			(long)now.tv_sec, (long)now.tv_usec,
+			res);
+}
+
+static void recvpacket(int sock, int recvmsg_flags,
+		int siocgstamp, int siocgstampns)
+{
+	char data[256];
+	struct timeval now;
+	struct msghdr msg;
+	struct iovec entry;
+	struct sockaddr_in from_addr;
+	struct {
+		struct cmsghdr cm;
+		char control[512];
+	} control;
+	int res;
+
+	memset(&msg, 0, sizeof(msg));
+	msg.msg_iov = &entry;
+	msg.msg_iovlen = 1;
+	entry.iov_base = data;
+	entry.iov_len = sizeof(data);
+	msg.msg_name = (caddr_t)&from_addr;
+	msg.msg_namelen = sizeof(from_addr);
+	msg.msg_control = &control;
+	msg.msg_controllen = sizeof(control);
+
+	res = recvmsg(sock, &msg, recvmsg_flags|MSG_DONTWAIT);
+	gettimeofday(&now, 0);
+	if (res < 0) {
+		printf("%s %s: %s\n",
+			"recvmsg",
+			(recvmsg_flags & MSG_ERRQUEUE) ? "error" : "regular",
+			strerror(errno));
+	} else {
+		struct cmsghdr *cmsg;
+		struct timeval tv;
+		struct timespec ts;
+
+		printf("%ld.%06ld: received %s data, %d bytes from %s, %d bytes control messages\n",
+			(long)now.tv_sec, (long)now.tv_usec,
+			(recvmsg_flags & MSG_ERRQUEUE) ? "error" : "regular",
+			res,
+			inet_ntoa(from_addr.sin_addr),
+			msg.msg_controllen);
+		for (cmsg = CMSG_FIRSTHDR(&msg);
+		     cmsg;
+		     cmsg = CMSG_NXTHDR(&msg, cmsg)) {
+			printf("   cmsg len %d: ", cmsg->cmsg_len);
+			switch (cmsg->cmsg_level) {
+			case SOL_SOCKET:
+				printf("SOL_SOCKET ");
+				switch (cmsg->cmsg_type) {
+				case SO_TIMESTAMP: {
+					struct timeval *stamp =
+						(struct timeval *)CMSG_DATA(cmsg);
+					printf("SO_TIMESTAMP %ld.%06ld",
+						(long)stamp->tv_sec,
+						(long)stamp->tv_usec);
+					break;
+				}
+				case SO_TIMESTAMPNS: {
+					struct timespec *stamp =
+						(struct timespec *)CMSG_DATA(cmsg);
+					printf("SO_TIMESTAMPNS %ld.%09ld",
+						(long)stamp->tv_sec,
+						(long)stamp->tv_nsec);
+					break;
+				}
+				case SO_TIMESTAMPING: {
+					struct timespec *stamp =
+						(struct timespec *)CMSG_DATA(cmsg);
+					printf("SO_TIMESTAMPING ");
+					printf("SW %ld.%09ld ",
+						(long)stamp->tv_sec,
+						(long)stamp->tv_nsec);
+					stamp++;
+					printf("HW transformed %ld.%09ld ",
+						(long)stamp->tv_sec,
+						(long)stamp->tv_nsec);
+					stamp++;
+					printf("HW raw %ld.%09ld",
+						(long)stamp->tv_sec,
+						(long)stamp->tv_nsec);
+					break;
+				}
+				default:
+					printf("type %d", cmsg->cmsg_type);
+					break;
+				}
+				break;
+			case IPPROTO_IP:
+				printf("IPPROTO_IP ");
+				switch (cmsg->cmsg_type) {
+				case IP_RECVERR: {
+					struct sock_extended_err *err =
+						(struct sock_extended_err *)CMSG_DATA(cmsg);
+					printf("IP_RECVERR ee_errno '%s' ee_origin %d => %s",
+						strerror(err->ee_errno),
+						err->ee_origin,
+#ifdef SO_EE_ORIGIN_TIMESTAMPING
+						err->ee_origin == SO_EE_ORIGIN_TIMESTAMPING ?
+						"bounced packet" : "unexpected origin"
+#else
+						"probably SO_EE_ORIGIN_TIMESTAMPING"
+#endif
+						);
+					if (res < sizeof(sync))
+						printf(" => truncated data?!");
+					else if (!memcmp(sync, data + res - sizeof(sync),
+								sizeof(sync)))
+						printf(" => GOT OUR DATA BACK (HURRAY!)");
+					break;
+				}
+				case IP_PKTINFO: {
+					struct in_pktinfo *pktinfo =
+						(struct in_pktinfo *)CMSG_DATA(cmsg);
+					printf("IP_PKTINFO interface index %u",
+						pktinfo->ipi_ifindex);
+					break;
+				}
+				default:
+					printf("type %d", cmsg->cmsg_type);
+					break;
+				}
+				break;
+			default:
+				printf("level %d type %d",
+					cmsg->cmsg_level,
+					cmsg->cmsg_type);
+				break;
+			}
+			printf("\n");
+		}
+
+		if (siocgstamp) {
+			if (ioctl(sock, SIOCGSTAMP, &tv))
+				printf("   %s: %s\n", "SIOCGSTAMP", strerror(errno));
+			else
+				printf("SIOCGSTAMP %ld.%06ld\n",
+					(long)tv.tv_sec,
+					(long)tv.tv_usec);
+		}
+		if (siocgstampns) {
+			if (ioctl(sock, SIOCGSTAMPNS, &ts))
+				printf("   %s: %s\n", "SIOCGSTAMPNS", strerror(errno));
+			else
+				printf("SIOCGSTAMPNS %ld.%09ld\n",
+					(long)ts.tv_sec,
+					(long)ts.tv_nsec);
+		}
+	}
+}
+
+int main(int argc, char **argv)
+{
+	int so_timestamping_flags = 0;
+	int so_timestamp = 0;
+	int so_timestampns = 0;
+	int siocgstamp = 0;
+	int siocgstampns = 0;
+	int ip_multicast_loop = 0;
+	char *interface;
+	int i;
+	int enabled = 1;
+	int sock;
+	struct ifreq device;
+	struct ifreq hwtstamp;
+	struct hwtstamp_config hwconfig, hwconfig_requested;
+	struct sockaddr_in addr;
+	struct ip_mreq imr;
+	struct in_addr iaddr;
+	int val;
+	socklen_t len;
+	struct timeval next;
+
+	if (argc < 2)
+		usage(0);
+	interface = argv[1];
+
+	for (i = 2; i < argc; i++ ) {
+		if (!strcasecmp(argv[i], "SO_TIMESTAMP")) {
+			so_timestamp = 1;
+		} else if (!strcasecmp(argv[i], "SO_TIMESTAMPNS")) {
+			so_timestampns = 1;
+		} else if (!strcasecmp(argv[i], "SIOCGSTAMP")) {
+			siocgstamp = 1;
+		} else if (!strcasecmp(argv[i], "SIOCGSTAMPNS")) {
+			siocgstampns = 1;
+		} else if (!strcasecmp(argv[i], "IP_MULTICAST_LOOP")) {
+			ip_multicast_loop = 1;
+		} else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_TX_HARDWARE")) {
+			so_timestamping_flags |= SOF_TIMESTAMPING_TX_HARDWARE;
+		} else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_TX_SOFTWARE")) {
+			so_timestamping_flags |= SOF_TIMESTAMPING_TX_SOFTWARE;
+		} else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_RX_HARDWARE")) {
+			so_timestamping_flags |= SOF_TIMESTAMPING_RX_HARDWARE;
+		} else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_RX_SOFTWARE")) {
+			so_timestamping_flags |= SOF_TIMESTAMPING_RX_SOFTWARE;
+		} else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_SOFTWARE")) {
+			so_timestamping_flags |= SOF_TIMESTAMPING_SOFTWARE;
+		} else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_SYS_HARDWARE")) {
+			so_timestamping_flags |= SOF_TIMESTAMPING_SYS_HARDWARE;
+		} else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_RAW_HARDWARE")) {
+			so_timestamping_flags |= SOF_TIMESTAMPING_RAW_HARDWARE;
+		} else {
+			usage(argv[i]);
+		}
+	}
+
+	sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
+	if (socket < 0)
+		bail("socket");
+
+	memset(&device, 0, sizeof(device));
+	strncpy(device.ifr_name, interface, sizeof(device.ifr_name));
+	if (ioctl(sock, SIOCGIFADDR, &device) < 0)
+		bail("getting interface IP address");
+
+	memset(&hwtstamp, 0, sizeof(hwtstamp));
+	strncpy(hwtstamp.ifr_name, interface, sizeof(hwtstamp.ifr_name));
+	hwtstamp.ifr_data = (void *)&hwconfig;
+	memset(&hwconfig, 0, sizeof(&hwconfig));
+	hwconfig.tx_type =
+		(so_timestamping_flags & SOF_TIMESTAMPING_TX_HARDWARE) ?
+		HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
+	hwconfig.rx_filter =
+		(so_timestamping_flags & SOF_TIMESTAMPING_RX_HARDWARE) ?
+		HWTSTAMP_FILTER_PTP_V1_L4_SYNC : HWTSTAMP_FILTER_NONE;
+	hwconfig_requested = hwconfig;
+	if (ioctl(sock, SIOCSHWTSTAMP, &hwtstamp) < 0) {
+		if ((errno == EINVAL || errno == ENOTSUP) &&
+			hwconfig_requested.tx_type == HWTSTAMP_TX_OFF &&
+			hwconfig_requested.rx_filter == HWTSTAMP_FILTER_NONE)
+			printf("SIOCSHWTSTAMP: disabling hardware time stamping not possible\n");
+		else
+			bail("SIOCSHWTSTAMP");
+	}
+	printf("SIOCSHWTSTAMP: tx_type %d requested, got %d; rx_filter %d requested, got %d\n",
+		hwconfig_requested.tx_type, hwconfig.tx_type,
+		hwconfig_requested.rx_filter, hwconfig.rx_filter);
+
+	/* bind to PTP port */
+	addr.sin_family = AF_INET;
+	addr.sin_addr.s_addr = htonl(INADDR_ANY);
+	addr.sin_port = htons(319 /* PTP event port */);
+	if (bind(sock, (struct sockaddr*)&addr, sizeof(struct sockaddr_in)) < 0)
+		bail("bind");
+
+	/* set multicast group for outgoing packets */
+	inet_aton("224.0.1.130", &iaddr); /* alternate PTP domain 1 */
+	addr.sin_addr = iaddr;
+	imr.imr_multiaddr.s_addr = iaddr.s_addr;
+	imr.imr_interface.s_addr = ((struct sockaddr_in *)&device.ifr_addr)->sin_addr.s_addr;
+	if (setsockopt(sock, IPPROTO_IP, IP_MULTICAST_IF,
+			&imr.imr_interface.s_addr, sizeof(struct in_addr)) < 0)
+		bail("set multicast");
+
+	/* join multicast group, loop our own packet */
+	if (setsockopt(sock, IPPROTO_IP, IP_ADD_MEMBERSHIP, &imr, sizeof(struct ip_mreq)) < 0)
+		bail("join multicast group");
+
+	if (setsockopt(sock, IPPROTO_IP, IP_MULTICAST_LOOP, &ip_multicast_loop, sizeof(enabled)) < 0) {
+		bail("loop multicast");
+	}
+
+	/* set socket options for time stamping */
+	if (so_timestamp &&
+		setsockopt(sock, SOL_SOCKET, SO_TIMESTAMP, &enabled, sizeof(enabled)) < 0)
+		bail("setsockopt SO_TIMESTAMP");
+
+	if (so_timestampns &&
+		setsockopt(sock, SOL_SOCKET, SO_TIMESTAMPNS, &enabled, sizeof(enabled)) < 0)
+		bail("setsockopt SO_TIMESTAMPNS");
+
+	if (so_timestamping_flags &&
+		setsockopt(sock, SOL_SOCKET, SO_TIMESTAMPING, &so_timestamping_flags, sizeof(so_timestamping_flags)) < 0)
+		bail("setsockopt SO_TIMESTAMPING");
+
+	/* request IP_PKTINFO for debugging purposes */
+	if (setsockopt(sock, SOL_IP, IP_PKTINFO, &enabled, sizeof(enabled)) < 0)
+		printf("%s: %s\n", "setsockopt IP_PKTINFO", strerror(errno));
+
+	/* verify socket options */
+	len = sizeof(val);
+	if (getsockopt(sock, SOL_SOCKET, SO_TIMESTAMP, &val, &len) < 0)
+		printf("%s: %s\n", "getsockopt SO_TIMESTAMP", strerror(errno));
+	else
+		printf("SO_TIMESTAMP %d\n", val);
+
+	if (getsockopt(sock, SOL_SOCKET, SO_TIMESTAMPNS, &val, &len) < 0)
+		printf("%s: %s\n", "getsockopt SO_TIMESTAMPNS", strerror(errno));
+	else
+		printf("SO_TIMESTAMPNS %d\n", val);
+
+	if (getsockopt(sock, SOL_SOCKET, SO_TIMESTAMPING, &val, &len) < 0) {
+		printf("%s: %s\n", "getsockopt SO_TIMESTAMPING", strerror(errno));
+	} else {
+		printf("SO_TIMESTAMPING %d\n", val);
+		if (val != so_timestamping_flags)
+			printf("   not the expected value %d\n", so_timestamping_flags);
+	}
+
+	/* send packets forever every five seconds */
+	gettimeofday(&next, 0);
+	next.tv_sec = (next.tv_sec + 1) / 5 * 5;
+	next.tv_usec = 0;
+	while(1) {
+		struct timeval now;
+		struct timeval delta;
+		long delta_us;
+		int res;
+		fd_set readfs, errorfs;
+
+		gettimeofday(&now, 0);
+		delta_us = (long)(next.tv_sec - now.tv_sec) * 1000000 +
+			(long)(next.tv_usec - now.tv_usec);
+		if (delta_us > 0) {
+			/* continue waiting for timeout or data */
+			delta.tv_sec = delta_us / 1000000;
+			delta.tv_usec = delta_us % 1000000;
+
+			FD_ZERO(&readfs);
+			FD_ZERO(&errorfs);
+			FD_SET(sock, &readfs);
+			FD_SET(sock, &errorfs);
+			printf("%ld.%06ld: select %ldus\n",
+				(long)now.tv_sec, (long)now.tv_usec,
+				delta_us);
+			res = select(sock + 1, &readfs, 0, &errorfs, &delta);
+			gettimeofday(&now, 0);
+			printf("%ld.%06ld: select returned: %d, %s\n",
+				(long)now.tv_sec, (long)now.tv_usec,
+				res,
+				res < 0 ? strerror(errno) : "success");
+			if (res > 0) {
+				if (FD_ISSET(sock, &readfs))
+					printf("ready for reading\n");
+				if (FD_ISSET(sock, &errorfs))
+					printf("has error\n");
+				recvpacket(sock, 0,
+					siocgstamp,
+					siocgstampns);
+				recvpacket(sock, MSG_ERRQUEUE,
+					siocgstamp,
+					siocgstampns);
+			}
+		} else {
+			/* write one packet */
+			sendpacket(sock, (struct sockaddr *)&addr, sizeof(addr));
+			next.tv_sec += 5;
+			continue;
+		}
+	}
+
+	return 0;
+}
diff --git a/arch/alpha/include/asm/socket.h b/arch/alpha/include/asm/socket.h
index a1057c2..5135249 100644
--- a/arch/alpha/include/asm/socket.h
+++ b/arch/alpha/include/asm/socket.h
@@ -61,6 +61,9 @@
 #define SO_SECURITY_ENCRYPTION_NETWORK		21
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
diff --git a/arch/arm/include/asm/socket.h b/arch/arm/include/asm/socket.h
index 6817be9..5bd9130 100644
--- a/arch/arm/include/asm/socket.h
+++ b/arch/arm/include/asm/socket.h
@@ -53,5 +53,8 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/avr32/include/asm/socket.h b/arch/avr32/include/asm/socket.h
index 35863f2..707877b 100644
--- a/arch/avr32/include/asm/socket.h
+++ b/arch/avr32/include/asm/socket.h
@@ -53,5 +53,8 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/blackfin/include/asm/socket.h b/arch/blackfin/include/asm/socket.h
index 2ca702e..a51a777 100644
--- a/arch/blackfin/include/asm/socket.h
+++ b/arch/blackfin/include/asm/socket.h
@@ -52,5 +52,8 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif				/* _ASM_SOCKET_H */
diff --git a/arch/cris/include/asm/socket.h b/arch/cris/include/asm/socket.h
index 9df0ca8..ce30092 100644
--- a/arch/cris/include/asm/socket.h
+++ b/arch/cris/include/asm/socket.h
@@ -55,6 +55,9 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/h8300/include/asm/socket.h b/arch/h8300/include/asm/socket.h
index da2520d..660efa4 100644
--- a/arch/h8300/include/asm/socket.h
+++ b/arch/h8300/include/asm/socket.h
@@ -53,5 +53,8 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/asm/socket.h b/arch/ia64/include/asm/socket.h
index d5ef0aa..6afb493 100644
--- a/arch/ia64/include/asm/socket.h
+++ b/arch/ia64/include/asm/socket.h
@@ -62,5 +62,8 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/mips/include/asm/socket.h b/arch/mips/include/asm/socket.h
index facc2d7..06ad2bc 100644
--- a/arch/mips/include/asm/socket.h
+++ b/arch/mips/include/asm/socket.h
@@ -74,6 +74,9 @@ To add: #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #ifdef __KERNEL__
 
diff --git a/arch/parisc/include/asm/socket.h b/arch/parisc/include/asm/socket.h
index fba402c..885472b 100644
--- a/arch/parisc/include/asm/socket.h
+++ b/arch/parisc/include/asm/socket.h
@@ -54,6 +54,9 @@
 
 #define SO_MARK			0x401f
 
+#define SO_TIMESTAMPING		0x4020
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/powerpc/include/asm/socket.h b/arch/powerpc/include/asm/socket.h
index f5a4e16..bd15a06 100644
--- a/arch/powerpc/include/asm/socket.h
+++ b/arch/powerpc/include/asm/socket.h
@@ -60,5 +60,8 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/asm/socket.h b/arch/s390/include/asm/socket.h
index c786ab6..0cc8f3a 100644
--- a/arch/s390/include/asm/socket.h
+++ b/arch/s390/include/asm/socket.h
@@ -61,5 +61,8 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sh/include/asm/socket.h b/arch/sh/include/asm/socket.h
index 6d4bf65..b4697cb 100644
--- a/arch/sh/include/asm/socket.h
+++ b/arch/sh/include/asm/socket.h
@@ -53,5 +53,8 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif /* __ASM_SH_SOCKET_H */
diff --git a/arch/sparc/include/asm/socket.h b/arch/sparc/include/asm/socket.h
index bf50d0c..982a12f 100644
--- a/arch/sparc/include/asm/socket.h
+++ b/arch/sparc/include/asm/socket.h
@@ -50,6 +50,9 @@
 
 #define SO_MARK			0x0022
 
+#define SO_TIMESTAMPING		0x0023
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/x86/include/asm/socket.h b/arch/x86/include/asm/socket.h
index 8ab9cc8..ca8bf2c 100644
--- a/arch/x86/include/asm/socket.h
+++ b/arch/x86/include/asm/socket.h
@@ -54,4 +54,7 @@
 
 #define SO_MARK			36
 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
+
 #endif /* _ASM_X86_SOCKET_H */
diff --git a/include/asm-frv/socket.h b/include/asm-frv/socket.h
index e51ca67..0539926 100644
--- a/include/asm-frv/socket.h
+++ b/include/asm-frv/socket.h
@@ -53,6 +53,9 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif /* _ASM_SOCKET_H */
 
diff --git a/include/asm-m32r/socket.h b/include/asm-m32r/socket.h
index 9a0e200..d100bae 100644
--- a/include/asm-m32r/socket.h
+++ b/include/asm-m32r/socket.h
@@ -53,5 +53,8 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/include/asm-m68k/socket.h b/include/asm-m68k/socket.h
index dbc64e9..1f425c6 100644
--- a/include/asm-m68k/socket.h
+++ b/include/asm-m68k/socket.h
@@ -53,5 +53,8 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-mn10300/socket.h b/include/asm-mn10300/socket.h
index 80af9c4..a633a06 100644
--- a/include/asm-mn10300/socket.h
+++ b/include/asm-mn10300/socket.h
@@ -53,5 +53,8 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-xtensa/socket.h b/include/asm-xtensa/socket.h
index 6100682..5ada734 100644
--- a/include/asm-xtensa/socket.h
+++ b/include/asm-xtensa/socket.h
@@ -64,5 +64,8 @@
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #define SO_MARK			36
+ 
+#define SO_TIMESTAMPING		37
+#define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/linux/errqueue.h b/include/linux/errqueue.h
index 92f8d4f..86d88dd 100644
--- a/include/linux/errqueue.h
+++ b/include/linux/errqueue.h
@@ -16,6 +16,7 @@ struct sock_extended_err
 #define SO_EE_ORIGIN_LOCAL	1
 #define SO_EE_ORIGIN_ICMP	2
 #define SO_EE_ORIGIN_ICMP6	3
+#define SO_EE_ORIGIN_TIMESTAMPING 4
 
 #define SO_EE_OFFENDER(ee)	((struct sockaddr*)((ee)+1))
 
diff --git a/include/linux/net_tstamp.h b/include/linux/net_tstamp.h
new file mode 100644
index 0000000..27d177e
--- /dev/null
+++ b/include/linux/net_tstamp.h
@@ -0,0 +1,112 @@
+/*
+ * Userspace API for hardware time stamping of network packets
+ *
+ * (C) Copyright 2008,2009 Intel Corporation
+ * Author: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
+ *
+ */
+
+#ifndef _NET_TIMESTAMPING_H
+#define _NET_TIMESTAMPING_H
+
+#include <linux/socket.h>   /* for SO_TIMESTAMPING */
+
+/*
+ * user space linux/socket.h might not have these defines yet:
+ * provide fallback
+ */
+#if !defined(__KERNEL__) && !defined(SO_TIMESTAMPING)
+# define SO_TIMESTAMPING         37
+# define SCM_TIMESTAMPING        SO_TIMESTAMPING
+#endif
+
+/* SO_TIMESTAMPING gets an integer bit field comprised of these values */
+enum {
+	SOF_TIMESTAMPING_TX_HARDWARE = (1<<0),
+	SOF_TIMESTAMPING_TX_SOFTWARE = (1<<1),
+	SOF_TIMESTAMPING_RX_HARDWARE = (1<<2),
+	SOF_TIMESTAMPING_RX_SOFTWARE = (1<<3),
+	SOF_TIMESTAMPING_SOFTWARE = (1<<4),
+	SOF_TIMESTAMPING_SYS_HARDWARE = (1<<5),
+	SOF_TIMESTAMPING_RAW_HARDWARE = (1<<6),
+	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_RAW_HARDWARE - 1) | SOF_TIMESTAMPING_RAW_HARDWARE
+};
+
+#if !defined(__kernel__) && !defined(SIOCSHWTSTAMP)
+# define SIOCSHWTSTAMP 0x89b0
+#endif
+
+/**
+ * struct hwtstamp_config - %SIOCSHWTSTAMP parameter
+ *
+ * @flags:	no flags defined right now, must be zero
+ * @tx_type:	one of HWTSTAMP_TX_*
+ * @rx_type:	one of one of HWTSTAMP_FILTER_*
+ *
+ * %SIOCSHWTSTAMP expects a &struct ifreq with a ifr_data pointer
+ * to this structure.
+ */
+struct hwtstamp_config {
+	int flags;
+	int tx_type;
+	int rx_filter;
+};
+
+/* possible values for hwtstamp_config->tx_type */
+enum {
+	/*
+	 * No outgoing packet will need hardware time stamping;
+	 * should a packet arrive which asks for it, no hardware
+	 * time stamping will be done.
+	 */
+	HWTSTAMP_TX_OFF,
+
+	/*
+	 * Enables hardware time stamping for outgoing packets;
+	 * the sender of the packet decides which are to be
+	 * time stamped by setting %SOF_TIMESTAMPING_TX_SOFTWARE
+	 * before sending the packet.
+	 */
+	HWTSTAMP_TX_ON,
+};
+
+/* possible values for hwtstamp_config->rx_filter */
+enum {
+	/* time stamp no incoming packet at all */
+	HWTSTAMP_FILTER_NONE,
+
+	/* time stamp any incoming packet */
+	HWTSTAMP_FILTER_ALL,
+
+        /* return value: time stamp all packets requested plus some others */
+        HWTSTAMP_FILTER_SOME,
+
+	/* PTP v1, UDP, any kind of event packet */
+	HWTSTAMP_FILTER_PTP_V1_L4_EVENT,
+	/* PTP v1, UDP, Sync packet */
+	HWTSTAMP_FILTER_PTP_V1_L4_SYNC,
+	/* PTP v1, UDP, Delay_req packet */
+	HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ,
+	/* PTP v2, UDP, any kind of event packet */
+	HWTSTAMP_FILTER_PTP_V2_L4_EVENT,
+	/* PTP v2, UDP, Sync packet */
+	HWTSTAMP_FILTER_PTP_V2_L4_SYNC,
+	/* PTP v2, UDP, Delay_req packet */
+	HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ,
+
+	/* 802.AS1, Ethernet, any kind of event packet */
+	HWTSTAMP_FILTER_PTP_V2_L2_EVENT,
+	/* 802.AS1, Ethernet, Sync packet */
+	HWTSTAMP_FILTER_PTP_V2_L2_SYNC,
+	/* 802.AS1, Ethernet, Delay_req packet */
+	HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ,
+
+	/* PTP v2/802.AS1, any layer, any kind of event packet */
+	HWTSTAMP_FILTER_PTP_V2_EVENT,
+	/* PTP v2/802.AS1, any layer, Sync packet */
+	HWTSTAMP_FILTER_PTP_V2_SYNC,
+	/* PTP v2/802.AS1, any layer, Delay_req packet */
+	HWTSTAMP_FILTER_PTP_V2_DELAY_REQ,
+};
+
+#endif /* _NET_TIMESTAMPING_H */
diff --git a/include/linux/sockios.h b/include/linux/sockios.h
index abef759..241f179 100644
--- a/include/linux/sockios.h
+++ b/include/linux/sockios.h
@@ -122,6 +122,9 @@
 #define SIOCBRADDIF	0x89a2		/* add interface to bridge      */
 #define SIOCBRDELIF	0x89a3		/* remove interface from bridge */
 
+/* hardware time stamping: parameters in linux/net_tstamp.h */
+#define SIOCSHWTSTAMP   0x89b0
+
 /* Device private ioctl calls */
 
 /*
-- 
1.5.5.3

--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
