From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/08]: VLAN update
Date: Wed, 09 Jul 2008 14:12:26 +0200
Message-ID: <4874AB2A.7000704@trash.net>
References: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080808030807060705070304"
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58710 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbYGIMM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 08:12:28 -0400
In-Reply-To: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080808030807060705070304
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> These patches include an updated set of the VLAN packet socket fixes,
> now also supporting VLAN TCI delivery to userspace using mmaped packet
> sockets, as well as a patch to add ->get_flags ethtool support and
> a few minor cleanup patches.

And for reference, attached is a patch for libpcap to reconstruct
the VLAN header from the auxdata, as well as a ugly small program
for testing the new mmaped packet socket protocol version (since I
couldn't find a version of libpcap that already supports this for
some reason).


--------------080808030807060705070304
Content-Type: text/x-diff;
 name="libpcap.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="libpcap.diff"

diff --git a/pcap-linux.c b/pcap-linux.c
index e9db010..e877cd8 100644
--- a/pcap-linux.c
+++ b/pcap-linux.c
@@ -471,7 +471,13 @@ pcap_read_packet(pcap_t *handle, pcap_handler callback, u_char *userdata)
 	socklen_t		fromlen;
 	int			packet_len, caplen;
 	struct pcap_pkthdr	pcap_header;
-
+	struct iovec		iov;
+	struct msghdr		msg;
+	struct cmsghdr		*cmsg;
+	union {
+		struct cmsghdr	cmsg;
+		char		buf[CMSG_SPACE(sizeof(struct tpacket_auxdata))];
+	} cmsg_buf;
 #ifdef HAVE_PF_PACKET_SOCKETS
 	/*
 	 * If this is a cooked device, leave extra room for a
@@ -492,6 +498,15 @@ pcap_read_packet(pcap_t *handle, pcap_handler callback, u_char *userdata)
 	/* Receive a single packet from the kernel */
 
 	bp = handle->buffer + handle->offset;
+
+	msg.msg_name		= &from;
+	msg.msg_namelen		= sizeof(from);
+	msg.msg_iov		= &iov;
+	msg.msg_iovlen		= 1;
+	msg.msg_control		= &cmsg_buf;
+	msg.msg_controllen	= sizeof(cmsg_buf);
+	msg.msg_flags		= 0;
+
 	do {
 		/*
 		 * Has "pcap_breakloop()" been called?
@@ -505,11 +520,11 @@ pcap_read_packet(pcap_t *handle, pcap_handler callback, u_char *userdata)
 			handle->break_loop = 0;
 			return -2;
 		}
-		fromlen = sizeof(from);
-		packet_len = recvfrom(
-			handle->fd, bp + offset,
-			handle->bufsize - offset, MSG_TRUNC,
-			(struct sockaddr *) &from, &fromlen);
+
+		iov.iov_len	= handle->bufsize - offset;
+		iov.iov_base	= bp + offset;
+
+		packet_len = recvmsg(handle->fd, &msg, MSG_TRUNC);
 	} while (packet_len == -1 && errno == EINTR);
 
 	/* Check if an error occured */
@@ -524,6 +539,38 @@ pcap_read_packet(pcap_t *handle, pcap_handler callback, u_char *userdata)
 		}
 	}
 
+	for (cmsg = CMSG_FIRSTHDR(&msg); cmsg; cmsg = CMSG_NXTHDR(&msg, cmsg)) {
+		struct tpacket_auxdata *aux;
+		unsigned int len, copy;
+		unsigned short *ptr;
+
+		if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct tpacket_auxdata)) ||
+		    cmsg->cmsg_level != SOL_PACKET ||
+		    cmsg->cmsg_type != PACKET_AUXDATA)
+			continue;
+
+		aux = (struct tpacket_auxdata *)CMSG_DATA(cmsg);
+		if (aux->tp_vlan_tci == 0)
+			continue;
+
+		len = packet_len > iov.iov_len ? iov.iov_len : packet_len;
+		if (len > 2 * ETH_ALEN + 4) {
+			copy = len - 2 * ETH_ALEN - 4;
+			if (copy > iov.iov_len - 2 * ETH_ALEN - 4)
+				copy = iov.iov_len - 2 * ETH_ALEN - 4;
+
+			memmove(iov.iov_base + 2 * ETH_ALEN + 4,
+				iov.iov_base + 2 * ETH_ALEN, copy);
+		}
+
+		ptr = (unsigned short *)(iov.iov_base + 2 * ETH_ALEN);
+		if (len >= 2 * ETH_ALEN + 2)
+			*(ptr++) = htons(ETH_P_8021Q);
+		if (len >= 2 * ETH_ALEN + 4)
+			*(ptr++) = htons(aux->tp_vlan_tci);
+		packet_len += 4;
+	}
+
 #ifdef HAVE_PF_PACKET_SOCKETS
 	if (!handle->md.sock_packet) {
 		/*
@@ -1631,6 +1678,7 @@ iface_bind(int fd, int ifindex, char *ebuf)
 	struct sockaddr_ll	sll;
 	int			err;
 	socklen_t		errlen = sizeof(err);
+	int			val;
 
 	memset(&sll, 0, sizeof(sll));
 	sll.sll_family		= AF_PACKET;
@@ -1657,6 +1705,12 @@ iface_bind(int fd, int ifindex, char *ebuf)
 		return -2;
 	}
 
+	val = 1;
+	if (setsockopt(fd, SOL_PACKET, PACKET_AUXDATA, &val, sizeof(val)) == -1) {
+		snprintf(ebuf, PCAP_ERRBUF_SIZE,
+			 "setsockopt: %s", pcap_strerror(errno));
+		return -3;
+	}
 	return 0;
 }
 

--------------080808030807060705070304
Content-Type: text/x-diff;
 name="mmap-test.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mmap-test.diff"

diff -urN /tmp/null/if_packet.h mmap-test/if_packet.h
--- /tmp/null/if_packet.h	1970-01-01 01:00:00.000000000 +0100
+++ mmap-test/if_packet.h	2008-07-09 12:56:08.000000000 +0200
@@ -0,0 +1,144 @@
+#ifndef __LINUX_IF_PACKET_H
+#define __LINUX_IF_PACKET_H
+
+#include <linux/types.h>
+
+struct sockaddr_pkt
+{
+	unsigned short spkt_family;
+	unsigned char spkt_device[14];
+	__be16 spkt_protocol;
+};
+
+struct sockaddr_ll
+{
+	unsigned short	sll_family;
+	__be16		sll_protocol;
+	int		sll_ifindex;
+	unsigned short	sll_hatype;
+	unsigned char	sll_pkttype;
+	unsigned char	sll_halen;
+	unsigned char	sll_addr[8];
+};
+
+/* Packet types */
+
+#define PACKET_HOST		0		/* To us		*/
+#define PACKET_BROADCAST	1		/* To all		*/
+#define PACKET_MULTICAST	2		/* To group		*/
+#define PACKET_OTHERHOST	3		/* To someone else 	*/
+#define PACKET_OUTGOING		4		/* Outgoing of any type */
+/* These ones are invisible by user level */
+#define PACKET_LOOPBACK		5		/* MC/BRD frame looped back */
+#define PACKET_FASTROUTE	6		/* Fastrouted frame	*/
+
+/* Packet socket options */
+
+#define PACKET_ADD_MEMBERSHIP		1
+#define PACKET_DROP_MEMBERSHIP		2
+#define PACKET_RECV_OUTPUT		3
+/* Value 4 is still used by obsolete turbo-packet. */
+#define PACKET_RX_RING			5
+#define PACKET_STATISTICS		6
+#define PACKET_COPY_THRESH		7
+#define PACKET_AUXDATA			8
+#define PACKET_ORIGDEV			9
+#define PACKET_VERSION			10
+#define PACKET_HDRLEN			11
+
+struct tpacket_stats
+{
+	unsigned int	tp_packets;
+	unsigned int	tp_drops;
+};
+
+struct tpacket_auxdata
+{
+	__u32		tp_status;
+	__u32		tp_len;
+	__u32		tp_snaplen;
+	__u16		tp_mac;
+	__u16		tp_net;
+	__u16		tp_vlan_tci;
+};
+
+struct tpacket_hdr
+{
+	unsigned long	tp_status;
+#define TP_STATUS_KERNEL	0
+#define TP_STATUS_USER		1
+#define TP_STATUS_COPY		2
+#define TP_STATUS_LOSING	4
+#define TP_STATUS_CSUMNOTREADY	8
+	unsigned int	tp_len;
+	unsigned int	tp_snaplen;
+	unsigned short	tp_mac;
+	unsigned short	tp_net;
+	unsigned int	tp_sec;
+	unsigned int	tp_usec;
+};
+
+#define TPACKET_ALIGNMENT	16
+#define TPACKET_ALIGN(x)	(((x)+TPACKET_ALIGNMENT-1)&~(TPACKET_ALIGNMENT-1))
+#define TPACKET_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket_hdr)) + sizeof(struct sockaddr_ll))
+
+struct tpacket2_hdr
+{
+	__u32		tp_status;
+	__u32		tp_len;
+	__u32		tp_snaplen;
+	__u16		tp_mac;
+	__u16		tp_net;
+	__u32		tp_sec;
+	__u32		tp_nsec;
+#ifdef TEST_VLAN_TCI
+	__u16		tp_vlan_tci;
+#endif
+};
+
+#ifdef __KERNEL__
+#define TPACKET2_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket2_hdr)) + sizeof(struct sockaddr_ll))
+#else
+#define TPACKET2_HDRLEN(x)	(TPACKET_ALIGN(x) + sizeof(struct sockaddr_ll))
+#endif
+
+enum tpacket_versions
+{
+	TPACKET_V1,
+	TPACKET_V2,
+};
+
+/*
+   Frame structure:
+
+   - Start. Frame must be aligned to TPACKET_ALIGNMENT=16
+   - struct tpacket_hdr
+   - pad to TPACKET_ALIGNMENT=16
+   - struct sockaddr_ll
+   - Gap, chosen so that packet data (Start+tp_net) alignes to TPACKET_ALIGNMENT=16
+   - Start+tp_mac: [ Optional MAC header ]
+   - Start+tp_net: Packet data, aligned to TPACKET_ALIGNMENT=16.
+   - Pad to align to TPACKET_ALIGNMENT=16
+ */
+
+struct tpacket_req
+{
+	unsigned int	tp_block_size;	/* Minimal size of contiguous block */
+	unsigned int	tp_block_nr;	/* Number of blocks */
+	unsigned int	tp_frame_size;	/* Size of frame */
+	unsigned int	tp_frame_nr;	/* Total number of frames */
+};
+
+struct packet_mreq
+{
+	int		mr_ifindex;
+	unsigned short	mr_type;
+	unsigned short	mr_alen;
+	unsigned char	mr_address[8];
+};
+
+#define PACKET_MR_MULTICAST	0
+#define PACKET_MR_PROMISC	1
+#define PACKET_MR_ALLMULTI	2
+
+#endif
diff -urN /tmp/null/Makefile mmap-test/Makefile
--- /tmp/null/Makefile	1970-01-01 01:00:00.000000000 +0100
+++ mmap-test/Makefile	2008-07-09 03:21:21.000000000 +0200
@@ -0,0 +1,3 @@
+CFLAGS	+= -O2 -I. -Wall -g
+
+all: test
diff -urN /tmp/null/test.c mmap-test/test.c
--- /tmp/null/test.c	1970-01-01 01:00:00.000000000 +0100
+++ mmap-test/test.c	2008-07-09 12:56:40.000000000 +0200
@@ -0,0 +1,150 @@
+#include <unistd.h>
+#include <stddef.h>
+#include <stdio.h>
+#include <errno.h>
+#include <string.h>
+#include <sys/socket.h>
+#include <sys/mman.h>
+#include <poll.h>
+#include <arpa/inet.h>
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/if_ether.h>
+
+#define V2
+#ifdef V2
+#define TEST_VLAN_TCI 1
+#endif
+
+#include "if_packet.h"
+
+int main(int argc, char **argv)
+{
+	struct sockaddr_ll lladdr;
+	struct tpacket_req req;
+#ifdef V2
+	struct tpacket2_hdr *hdr;
+#else
+	struct tpacket_hdr *hdr;
+#endif
+	unsigned int hdrlen;
+	int val;
+	socklen_t len;
+	void *ring;
+	unsigned int head;
+	unsigned int total = 0;
+	int fd;
+
+	fd = socket(AF_PACKET, SOCK_RAW, 0);
+	if (fd < 0) {
+		perror("socket");
+		return 1;
+	}
+
+#ifdef V2
+	val = TPACKET_V2;
+	len = sizeof(val);
+	if (getsockopt(fd, SOL_PACKET, PACKET_HDRLEN, &val, &len) < 0) {
+		perror("setsockopt(PACKET_HDRLEN)");
+		return 1;
+	}
+	hdrlen = val;
+
+	printf("hdrlen=%u sizeof(struct tpacket2_hdr)=%Zu\n",
+		hdrlen, sizeof(struct tpacket2_hdr));
+
+	val = TPACKET_V2;
+	if (setsockopt(fd, SOL_PACKET, PACKET_VERSION, &val, sizeof(val)) < 0) {
+		perror("setsockopt(PACKET_VERSION)");
+		return 1;
+	}
+#else
+	hdrlen = sizeof(struct tpacket_hdr);
+#endif
+
+	memset(&req, 0, sizeof(req));
+	req.tp_block_size	= 16 * 4096;
+	req.tp_block_nr		= 16;
+	req.tp_frame_size	= 1024;
+	req.tp_frame_nr		= 16 * 64;
+
+	if (setsockopt(fd, SOL_PACKET, PACKET_RX_RING, &req, sizeof(req)) < 0) {
+		perror("setsockopt");
+		return 1;
+	}
+
+	ring = mmap(NULL, req.tp_block_nr * req.tp_block_size,
+		    PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
+	if ((long)ring == -1L) {
+		perror("mmap");
+		return 1;
+	}
+
+	memset(&lladdr, 0, sizeof(lladdr));
+	lladdr.sll_family = AF_PACKET;
+	lladdr.sll_protocol = htons(ETH_P_ALL);
+	lladdr.sll_ifindex = 2;
+
+	if (bind(fd, (struct sockaddr *)&lladdr, sizeof(lladdr)) < 0) {
+		perror("bind");
+		return 1;
+	}
+
+	hdr = ring;
+	head = 0;
+
+	while (1) {
+		unsigned int cnt = 0;
+		struct pollfd pfds[1];
+
+		pfds[0].fd	= fd;
+		pfds[0].events	= POLLIN | POLLERR;
+		pfds[0].revents	= 0;
+
+		if (poll(pfds, 1, -1) < 0 && errno != EINTR) {
+			perror("poll");
+			return 1;
+		}
+
+		if (pfds[0].revents & POLLERR) {
+			char buf[16384];
+			recv(fd, buf, sizeof(buf), MSG_DONTWAIT | MSG_ERRQUEUE);
+			printf("error %d\n", errno);
+			continue;
+		}
+
+		if (!(pfds[0].revents & POLLIN))
+			continue;
+
+		while (hdr->tp_status != TP_STATUS_KERNEL) {
+			struct sockaddr_ll *sll;
+			unsigned char *data = (void *)hdr + hdr->tp_mac;
+			unsigned int i;
+
+			printf("%.4u ring[%u]: tp_status=%u tp_len=%u "
+			       "tp_snaplen=%u\n",
+				total, head, hdr->tp_status, hdr->tp_len, hdr->tp_snaplen);
+#ifdef TEST_VLAN_TCI
+			printf("tp_vlan_tci=%u id=%u\n",
+			       hdr->tp_vlan_tci, hdr->tp_vlan_tci & 0xfff);
+#endif
+			for (i = 0; i < (hdr->tp_snaplen > 32 ? 32 : hdr->tp_snaplen); i++)
+				printf("%.2x ", data[i]);
+			printf("\n");
+
+			sll = (void *)hdr + TPACKET_ALIGN(hdrlen);
+			printf("sll_family=%u sll_protocol=%u sll_ifindex=%d sll_hatype=%u "
+			       "sll_pkttype=%u sll_halen=%u\n",
+			       sll->sll_family, ntohs(sll->sll_protocol),
+			       sll->sll_ifindex, sll->sll_hatype,
+			       sll->sll_pkttype, sll->sll_halen);
+			hdr->tp_status = TP_STATUS_KERNEL;
+
+			head = head == req.tp_frame_nr - 1 ? 0 : head + 1;
+			hdr = ring + head * req.tp_frame_size;
+			cnt++, total++;
+		}
+		printf("received %u consecutive entries, %u total\n\n", cnt, total);
+	}
+	return 0;
+}

--------------080808030807060705070304--
