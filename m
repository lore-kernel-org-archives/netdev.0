From: Daniel Borkmann <dxchgb@gmail.com>
Subject: [PATCH net-next] doc: packet_mmap: update doc to implementation
 status
Date: Thu, 8 Nov 2012 13:37:01 +0100
Message-ID: <20121108123700.GA25799@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ronny Meeus <ronny.meeus@gmail.com>,
	Ulisses Alonso =?iso-8859-1?Q?Camar=F3?= <uaca@alumni.uv.es>,
	Johann Baudy <johann.baudy@gnu-log.net>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:48206 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317Ab2KHMhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 07:37:06 -0500
Received: by mail-ea0-f174.google.com with SMTP id c13so1036645eaa.19
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2012 04:37:05 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This improves the packet_mmap.txt document in the following ways:

 * Add initial information about different TPACKET versions
 * Add initial information about packet fanout
 * Add pointer to BPF document (since this also could be of interest)
 * 'Fix' minor, rather cosmetic things

Information partially taken from related commit messages.

Reported-by: Ronny Meeus <ronny.meeus@gmail.com>
Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
Cc: Ulisses Alonso Camar=F3 <uaca@alumni.uv.es>
Cc: Johann Baudy <johann.baudy@gnu-log.net>
---
 Documentation/networking/packet_mmap.txt |  233 ++++++++++++++++++++++=
+++++---
 1 files changed, 209 insertions(+), 24 deletions(-)

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/n=
etworking/packet_mmap.txt
index 7cd879e..241364f 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -3,9 +3,9 @@
 ----------------------------------------------------------------------=
----------
=20
 This file documents the mmap() facility available with the PACKET
-socket interface on 2.4 and 2.6 kernels. This type of sockets is used =
for=20
-capture network traffic with utilities like tcpdump or any other that =
needs
-raw access to network interface.
+socket interface on 2.4/2.6/3.x kernels. This type of sockets is used =
for=20
+i) capture network traffic with utilities like tcpdump, ii) transmit n=
etwork
+traffic, or any other that needs raw access to network interface.
=20
 You can find the latest version of this document at:
     http://wiki.ipxwarzone.com/index.php5?title=3DLinux_packet_mmap
@@ -21,19 +21,18 @@ Please send your comments to
 + Why use PACKET_MMAP
 ----------------------------------------------------------------------=
----------
=20
-In Linux 2.4/2.6 if PACKET_MMAP is not enabled, the capture process is=
 very
-inefficient. It uses very limited buffers and requires one system call
-to capture each packet, it requires two if you want to get packet's=20
-timestamp (like libpcap always does).
+In Linux 2.4/2.6/3.x if PACKET_MMAP is not enabled, the capture proces=
s is very
+inefficient. It uses very limited buffers and requires one system call=
 to
+capture each packet, it requires two if you want to get packet's times=
tamp
+(like libpcap always does).
=20
 In the other hand PACKET_MMAP is very efficient. PACKET_MMAP provides =
a size=20
 configurable circular buffer mapped in user space that can be used to =
either
 send or receive packets. This way reading packets just needs to wait f=
or them,
 most of the time there is no need to issue a single system call. Conce=
rning
 transmission, multiple packets can be sent through one system call to =
get the
-highest bandwidth.
-By using a shared buffer between the kernel and the user also has the =
benefit
-of minimizing packet copies.
+highest bandwidth. By using a shared buffer between the kernel and the=
 user
+also has the benefit of minimizing packet copies.
=20
 It's fine to use PACKET_MMAP to improve the performance of the capture=
 and
 transmission process, but it isn't everything. At least, if you are ca=
pturing
@@ -41,7 +40,8 @@ at high speeds (this is relative to the cpu speed), y=
ou should check if the
 device driver of your network interface card supports some sort of int=
errupt
 load mitigation or (even better) if it supports NAPI, also make sure i=
t is
 enabled. For transmission, check the MTU (Maximum Transmission Unit) u=
sed and
-supported by devices of your network.
+supported by devices of your network. CPU IRQ pinning of your network =
interface
+card can also be an advantage.
=20
 ----------------------------------------------------------------------=
----------
 + How to use mmap() to improve capture process
@@ -87,9 +87,7 @@ the following process:
 socket creation and destruction is straight forward, and is done=20
 the same way with or without PACKET_MMAP:
=20
-int fd;
-
-fd=3D socket(PF_PACKET, mode, htons(ETH_P_ALL))
+ int fd =3D socket(PF_PACKET, mode, htons(ETH_P_ALL));
=20
 where mode is SOCK_RAW for the raw interface were link level
 information can be captured or SOCK_DGRAM for the cooked
@@ -180,7 +178,6 @@ and the PACKET_TX_HAS_OFF option.
 + PACKET_MMAP settings
 ----------------------------------------------------------------------=
----------
=20
-
 To setup PACKET_MMAP from user level code is done with a call like
=20
  - Capture process
@@ -214,7 +211,6 @@ indeed, packet_set_ring checks that the following c=
ondition is true
=20
     frames_per_block * tp_block_nr =3D=3D tp_frame_nr
=20
-
 Lets see an example, with the following values:
=20
      tp_block_size=3D 4096
@@ -240,7 +236,6 @@ be spawned across two blocks, so there are some det=
ails you have to take into
 account when choosing the frame_size. See "Mapping and use of the circ=
ular=20
 buffer (ring)".
=20
-
 ----------------------------------------------------------------------=
----------
 + PACKET_MMAP setting constraints
 ----------------------------------------------------------------------=
----------
@@ -277,7 +272,6 @@ User space programs can include /usr/include/sys/us=
er.h and
 The pagesize can also be determined dynamically with the getpagesize (=
2)=20
 system call.=20
=20
-
  Block number limit
 --------------------
=20
@@ -297,7 +291,6 @@ called pg_vec, its size limits the number of blocks=
 that can be allocated.
       v  block #2
      block #1
=20
-
 kmalloc allocates any number of bytes of physically contiguous memory =
from=20
 a pool of pre-determined sizes. This pool of memory is maintained by t=
he slab=20
 allocator which is at the end the responsible for doing the allocation=
 and=20
@@ -312,7 +305,6 @@ pointers to blocks is
=20
      131072/4 =3D 32768 blocks
=20
-
  PACKET_MMAP buffer size calculator
 ------------------------------------
=20
@@ -353,7 +345,6 @@ and a value for <frame size> of 2048 bytes. These p=
arameters will yield
 and hence the buffer will have a 262144 MiB size. So it can hold=20
 262144 MiB / 2048 bytes =3D 134217728 frames
=20
-
 Actually, this buffer size is not possible with an i386 architecture.=20
 Remember that the memory is allocated in kernel space, in the case of=20
 an i386 kernel's memory size is limited to 1GiB.
@@ -385,7 +376,6 @@ the following (from include/linux/if_packet.h):
    - Start+tp_net: Packet data, aligned to TPACKET_ALIGNMENT=3D16.
    - Pad to align to TPACKET_ALIGNMENT=3D16
  */
-          =20
 =20
  The following are conditions that are checked in packet_set_ring
=20
@@ -426,7 +416,6 @@ and the following flags apply:
      #define TP_STATUS_LOSING        4=20
      #define TP_STATUS_CSUMNOTREADY  8=20
=20
-
 TP_STATUS_COPY        : This flag indicates that the frame (and associ=
ated
                         meta information) has been truncated because i=
t's=20
                         larger than tp_frame_size. This packet can be=20
@@ -475,7 +464,6 @@ packets are in the ring:
 It doesn't incur in a race condition to first check the status value a=
nd=20
 then poll for frames.
=20
-
 ++ Transmission process
 Those defines are also used for transmission:
=20
@@ -507,6 +495,196 @@ The user can also use poll() to check if a buffer=
 is available:
     retval =3D poll(&pfd, 1, timeout);
=20
 ----------------------------------------------------------------------=
---------
++ What TPACKET versions are available and when to use them?
+----------------------------------------------------------------------=
---------
+
+ int val =3D tpacket_version;
+ setsockopt(fd, SOL_PACKET, PACKET_VERSION, &val, sizeof(val));
+ getsockopt(fd, SOL_PACKET, PACKET_VERSION, &val, sizeof(val));
+
+where 'tpacket_version' can be TPACKET_V1 (default), TPACKET_V2, TPACK=
ET_V3.
+
+TPACKET_V1:
+	- Default if not otherwise specified by setsockopt(2)
+	- RX_RING, TX_RING available
+	- VLAN metadata information available for packets
+	  (TP_STATUS_VLAN_VALID)
+
+TPACKET_V1 --> TPACKET_V2:
+	- Made 64 bit clean due to unsigned long usage in TPACKET_V1
+	  structures, thus this also works on 64 bit kernel with 32 bit
+	  userspace and the like
+	- Timestamp resolution in nanoseconds instead of microseconds
+	- RX_RING, TX_RING available
+	- How to switch to TPACKET_V2:
+		1. Replace struct tpacket_hdr by struct tpacket2_hdr
+		2. Query header len and save
+		3. Set protocol version to 2, set up ring as usual
+		4. For getting the sockaddr_ll,
+		   use (void *)hdr + TPACKET_ALIGN(hdrlen) instead of
+		   (void *)hdr + TPACKET_ALIGN(sizeof(struct tpacket_hdr))
+
+TPACKET_V2 --> TPACKET_V3:
+	- Flexible buffer implementation:
+		1. Blocks can be configured with non-static frame-size
+		2. Read/poll is at a block-level (as opposed to packet-level)
+		3. Added poll timeout to avoid indefinite user-space wait
+		   on idle links
+		4. Added user-configurable knobs:
+			4.1 block::timeout
+			4.2 tpkt_hdr::sk_rxhash
+	- RX Hash data available in user space
+	- Currently only RX_RING available
+
+----------------------------------------------------------------------=
---------
++ AF_PACKET fanout mode
+----------------------------------------------------------------------=
---------
+
+In the AF_PACKET fanout mode, packet reception can be load balanced am=
ong
+processes. This also works in combination with mmap(2) on packet socke=
ts.
+
+Minimal example code by David S. Miller (try things like "./test eth0 =
hash",
+"./test eth0 lb", etc.):
+
+#include <stddef.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
+
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <sys/socket.h>
+#include <sys/ioctl.h>
+
+#include <unistd.h>
+
+#include <linux/if_ether.h>
+#include <linux/if_packet.h>
+
+#include <net/if.h>
+
+static const char *device_name;
+static int fanout_type;
+static int fanout_id;
+
+#ifndef PACKET_FANOUT
+# define PACKET_FANOUT			18
+# define PACKET_FANOUT_HASH		0
+# define PACKET_FANOUT_LB		1
+#endif
+
+static int setup_socket(void)
+{
+	int err, fd =3D socket(AF_PACKET, SOCK_RAW, htons(ETH_P_IP));
+	struct sockaddr_ll ll;
+	struct ifreq ifr;
+	int fanout_arg;
+
+	if (fd < 0) {
+		perror("socket");
+		return EXIT_FAILURE;
+	}
+
+	memset(&ifr, 0, sizeof(ifr));
+	strcpy(ifr.ifr_name, device_name);
+	err =3D ioctl(fd, SIOCGIFINDEX, &ifr);
+	if (err < 0) {
+		perror("SIOCGIFINDEX");
+		return EXIT_FAILURE;
+	}
+
+	memset(&ll, 0, sizeof(ll));
+	ll.sll_family =3D AF_PACKET;
+	ll.sll_ifindex =3D ifr.ifr_ifindex;
+	err =3D bind(fd, (struct sockaddr *) &ll, sizeof(ll));
+	if (err < 0) {
+		perror("bind");
+		return EXIT_FAILURE;
+	}
+
+	fanout_arg =3D (fanout_id | (fanout_type << 16));
+	err =3D setsockopt(fd, SOL_PACKET, PACKET_FANOUT,
+			 &fanout_arg, sizeof(fanout_arg));
+	if (err) {
+		perror("setsockopt");
+		return EXIT_FAILURE;
+	}
+
+	return fd;
+}
+
+static void fanout_thread(void)
+{
+	int fd =3D setup_socket();
+	int limit =3D 10000;
+
+	if (fd < 0)
+		exit(fd);
+
+	while (limit-- > 0) {
+		char buf[1600];
+		int err;
+
+		err =3D read(fd, buf, sizeof(buf));
+		if (err < 0) {
+			perror("read");
+			exit(EXIT_FAILURE);
+		}
+		if ((limit % 10) =3D=3D 0)
+			fprintf(stdout, "(%d) \n", getpid());
+	}
+
+	fprintf(stdout, "%d: Received 10000 packets\n", getpid());
+
+	close(fd);
+	exit(0);
+}
+
+int main(int argc, char **argp)
+{
+	int fd, err;
+	int i;
+
+	if (argc !=3D 3) {
+		fprintf(stderr, "Usage: %s INTERFACE {hash|lb}\n", argp[0]);
+		return EXIT_FAILURE;
+	}
+
+	if (!strcmp(argp[2], "hash"))
+		fanout_type =3D PACKET_FANOUT_HASH;
+	else if (!strcmp(argp[2], "lb"))
+		fanout_type =3D PACKET_FANOUT_LB;
+	else {
+		fprintf(stderr, "Unknown fanout type [%s]\n", argp[2]);
+		exit(EXIT_FAILURE);
+	}
+
+	device_name =3D argp[1];
+	fanout_id =3D getpid() & 0xffff;
+
+	for (i =3D 0; i < 4; i++) {
+		pid_t pid =3D fork();
+
+		switch (pid) {
+		case 0:
+			fanout_thread();
+
+		case -1:
+			perror("fork");
+			exit(EXIT_FAILURE);
+		}
+	}
+
+	for (i =3D 0; i < 4; i++) {
+		int status;
+
+		wait(&status);
+	}
+
+	return 0;
+}
+
+----------------------------------------------------------------------=
---------
 + PACKET_TIMESTAMP
 ----------------------------------------------------------------------=
---------
=20
@@ -532,6 +710,13 @@ the networking stack is used (the behavior before =
this setting was added).
 See include/linux/net_tstamp.h and Documentation/networking/timestampi=
ng
 for more information on hardware timestamps.
=20
+----------------------------------------------------------------------=
---------
++ Miscellaneous bits
+----------------------------------------------------------------------=
---------
+
+- Packet sockets work well together with Linux socket filters, thus yo=
u also
+  might want to have a look at Documentation/networking/filter.txt
+
 ----------------------------------------------------------------------=
----------
 + THANKS
 ----------------------------------------------------------------------=
----------
