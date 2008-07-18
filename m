From: Patrick McHardy <kaber@trash.net>
Subject: libpcap VLAN accel support
Date: Fri, 18 Jul 2008 20:30:01 +0200
Message-ID: <4880E129.6030709@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050702030704020004010706"
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60004 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753399AbYGRSaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 14:30:02 -0400
Received: from [192.168.0.100] (unknown [78.42.204.165])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTP id DB09B948A4
	for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 20:29:59 +0200 (MEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050702030704020004010706
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

In case someone is interested, I just sent these patches for
VLAN accel support to the libpcap maintainers.

The latest CVS version includes support for mmaped packet
sockets, so I also added support for this (this was missing
from the example patch I posted earlier since it was based
on an old Debian version).

Also the payload is not moved anymore when reconstructing
the VLAN headers, only the ethernet addresses are moved
further to the front to make room for the VLAN header.


--------------050702030704020004010706
Content-Type: text/plain;
 name="01-libpcap-fix-invalid-rcvbuf-size"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01-libpcap-fix-invalid-rcvbuf-size"

pcap-linux: fix invalid rcvbuf size

From: Patrick McHardy <kaber@trash.net>

Libpcap issues a SO_RCVBUF when the buffer size if unspecified (zero).
The intention appears to be to set it when its *not* zero.
---

 pcap-linux.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/pcap-linux.c b/pcap-linux.c
index d9f9f10..d4c06cb 100644
--- a/pcap-linux.c
+++ b/pcap-linux.c
@@ -557,7 +557,7 @@ pcap_activate_linux(pcap_t *handle)
 		goto fail;
 	}
 
-	if (handle->opt.buffer_size == 0) {
+	if (handle->opt.buffer_size != 0) {
 		/*
 		 * Set the socket buffer size to the specified value.
 		 */

--------------050702030704020004010706
Content-Type: text/plain;
 name="02-libpcap-recvmsg"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02-libpcap-recvmsg"

pcap-linux: convert to recvmsg()

From: Patrick McHardy <kaber@trash.net>

Convert pcap-linux to use recvmsg() as preparation for using PACKET_AUXDATA
cmsgs.
---

 pcap-linux.c |   23 ++++++++++++++++-------
 1 files changed, 16 insertions(+), 7 deletions(-)


diff --git a/pcap-linux.c b/pcap-linux.c
index d4c06cb..aac9b11 100644
--- a/pcap-linux.c
+++ b/pcap-linux.c
@@ -625,10 +625,10 @@ pcap_read_packet(pcap_t *handle, pcap_handler callback, u_char *userdata)
 #else
 	struct sockaddr		from;
 #endif
-	socklen_t		fromlen;
 	int			packet_len, caplen;
 	struct pcap_pkthdr	pcap_header;
-
+	struct iovec		iov;
+	struct msghdr		msg;
 #ifdef HAVE_PF_PACKET_SOCKETS
 	/*
 	 * If this is a cooked device, leave extra room for a
@@ -662,6 +662,18 @@ pcap_read_packet(pcap_t *handle, pcap_handler callback, u_char *userdata)
 	 * get notified of "network down" events.
 	 */
 	bp = handle->buffer + handle->offset;
+
+	msg.msg_name		= &from;
+	msg.msg_namelen		= sizeof(from);
+	msg.msg_iov		= &iov;
+	msg.msg_iovlen		= 1;
+	msg.msg_control		= NULL;
+	msg.msg_controllen	= 0;
+	msg.msg_flags		= 0;
+
+	iov.iov_len		= handle->bufsize - offset;
+	iov.iov_base		= bp + offset;
+
 	do {
 		/*
 		 * Has "pcap_breakloop()" been called?
@@ -675,11 +687,8 @@ pcap_read_packet(pcap_t *handle, pcap_handler callback, u_char *userdata)
 			handle->break_loop = 0;
 			return -2;
 		}
-		fromlen = sizeof(from);
-		packet_len = recvfrom(
-			handle->fd, bp + offset,
-			handle->bufsize - offset, MSG_TRUNC,
-			(struct sockaddr *) &from, &fromlen);
+
+		packet_len = recvmsg(handle->fd, &msg, MSG_TRUNC);
 	} while (packet_len == -1 && (errno == EINTR || errno == ENETDOWN));
 
 	/* Check if an error occured */

--------------050702030704020004010706
Content-Type: text/plain;
 name="03-libpcap-auxdata"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03-libpcap-auxdata"

pcap-linux: reconstruct VLAN header from PACKET_AUXDATA

From: Patrick McHardy <kaber@trash.net>

VLAN packets sent over devices supporting VLAN tagging/stripping in
hardwaredon't have a VLAN header when they are received on packet
sockets. The VLAN TCI is available through the PACKET_AUXDATA cmsg,
reconstruct the entire header when necessary.
---

 pcap-linux.c |   59 +++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 pcap/vlan.h  |   11 +++++++++++
 2 files changed, 67 insertions(+), 3 deletions(-)
 create mode 100644 pcap/vlan.h


diff --git a/pcap-linux.c b/pcap-linux.c
index aac9b11..fcc665a 100644
--- a/pcap-linux.c
+++ b/pcap-linux.c
@@ -108,6 +108,7 @@ static const char rcsid[] _U_ =
 
 #include "pcap-int.h"
 #include "pcap/sll.h"
+#include "pcap/vlan.h"
 
 #ifdef HAVE_DAG_API
 #include "pcap-dag.h"
@@ -165,6 +166,9 @@ static const char rcsid[] _U_ =
   */
 # ifdef PACKET_HOST
 #  define HAVE_PF_PACKET_SOCKETS
+#  ifdef PACKET_AUXDATA
+#   define HAVE_PACKET_AUXDATA
+#  endif /* PACKET_AUXDATA */
 # endif /* PACKET_HOST */
 
 
@@ -629,6 +633,11 @@ pcap_read_packet(pcap_t *handle, pcap_handler callback, u_char *userdata)
 	struct pcap_pkthdr	pcap_header;
 	struct iovec		iov;
 	struct msghdr		msg;
+	struct cmsghdr		*cmsg;
+	union {
+		struct cmsghdr	cmsg;
+		char		buf[CMSG_SPACE(sizeof(struct tpacket_auxdata))];
+	} cmsg_buf;
 #ifdef HAVE_PF_PACKET_SOCKETS
 	/*
 	 * If this is a cooked device, leave extra room for a
@@ -667,8 +676,8 @@ pcap_read_packet(pcap_t *handle, pcap_handler callback, u_char *userdata)
 	msg.msg_namelen		= sizeof(from);
 	msg.msg_iov		= &iov;
 	msg.msg_iovlen		= 1;
-	msg.msg_control		= NULL;
-	msg.msg_controllen	= 0;
+	msg.msg_control		= &cmsg_buf;
+	msg.msg_controllen	= sizeof(cmsg_buf);
 	msg.msg_flags		= 0;
 
 	iov.iov_len		= handle->bufsize - offset;
@@ -774,6 +783,36 @@ pcap_read_packet(pcap_t *handle, pcap_handler callback, u_char *userdata)
 		      from.sll_halen);
 		hdrp->sll_protocol = from.sll_protocol;
 	}
+
+#ifdef HAVE_PACKET_AUXDATA
+	for (cmsg = CMSG_FIRSTHDR(&msg); cmsg; cmsg = CMSG_NXTHDR(&msg, cmsg)) {
+		struct tpacket_auxdata *aux;
+		unsigned int len;
+		struct vlan_tag *tag;
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
+		if (len < 2 * ETH_ALEN)
+			break;
+
+		bp -= VLAN_TAG_LEN;
+		memmove(bp, bp + VLAN_TAG_LEN, 2 * ETH_ALEN);
+
+		tag = (struct vlan_tag *)(bp + 2 * ETH_ALEN);
+		tag->vlan_tpid = htons(ETH_P_8021Q);
+		tag->vlan_tci = htons(aux->tp_vlan_tci);
+
+		packet_len += VLAN_TAG_LEN;
+	}
+#endif /* HAVE_PACKET_AUXDATA */
 #endif
 
 	/*
@@ -1591,7 +1630,7 @@ static int
 activate_new(pcap_t *handle)
 {
 #ifdef HAVE_PF_PACKET_SOCKETS
-	int			sock_fd = -1, arptype;
+	int			sock_fd = -1, arptype, val;
 	int			err = 0;
 	struct packet_mreq	mr;
 	const char* device = handle->opt.source;
@@ -1802,6 +1841,20 @@ activate_new(pcap_t *handle)
 		}
 	}
 
+	/* Enable auxillary data if supported and reserve room for
+	 * reconstructing VLAN headers. */
+#ifdef HAVE_PACKET_AUXDATA
+	val = 1;
+	if (setsockopt(sock_fd, SOL_PACKET, PACKET_AUXDATA, &val,
+		       sizeof(val)) == -1 && errno != ENOPROTOOPT) {
+		snprintf(handle->errbuf, PCAP_ERRBUF_SIZE,
+			 "setsockopt: %s", pcap_strerror(errno));
+		close(sock_fd);
+		return PCAP_ERROR;
+	}
+	handle->offset += VLAN_TAG_LEN;
+#endif /* HAVE_PACKET_AUXDATA */
+
 	/*
 	 * This is a 2.2[.x] or later kernel (we know that
 	 * because we're not using a SOCK_PACKET socket -
diff --git a/pcap/vlan.h b/pcap/vlan.h
new file mode 100644
index 0000000..2a47ca2
--- /dev/null
+++ b/pcap/vlan.h
@@ -0,0 +1,11 @@
+#ifndef lib_pcap_vlan_h
+#define lib_pcap_vlan_h
+
+struct vlan_tag {
+	u_int16_t	vlan_tpid;		/* ETH_P_8021Q */
+	u_int16_t	vlan_tci;		/* VLAN TCI */
+};
+
+#define VLAN_TAG_LEN	4
+
+#endif

--------------050702030704020004010706
Content-Type: text/plain;
 name="04-libpcap-tpacket2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="04-libpcap-tpacket2"

pcap-linux: support new tpacket frame header format

From: Patrick McHardy <kaber@trash.net>

The tpacket_hdr is not clean for 64 bit kernel/32 bit userspace and
is not extendable because the struct sockaddr_ll following it is
expected at a fixed offset.

Linux 2.6.27-rc supports a new tpacket frame header that removes these
two limitations. Convert the mmap ring support to support both formats
and probe for availability of the new version.
---

 pcap-int.h   |    2 +
 pcap-linux.c |  152 ++++++++++++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 134 insertions(+), 20 deletions(-)


diff --git a/pcap-int.h b/pcap-int.h
index 4de319c..97238fd 100644
--- a/pcap-int.h
+++ b/pcap-int.h
@@ -132,6 +132,8 @@ struct pcap_md {
 	int	lo_ifindex;	/* interface index of the loopback device */
 	u_int	packets_read;	/* count of packets read with recvfrom() */
 	bpf_u_int32 oldmode;	/* mode to restore when turning monitor mode off */
+	u_int	tp_version;	/* version of tpacket_hdr for mmaped ring */
+	u_int	tp_hdrlen;	/* hdrlen of tpacket_hdr for mmaped ring */
 #endif /* linux */
 
 #ifdef HAVE_DAG_API
diff --git a/pcap-linux.c b/pcap-linux.c
index fcc665a..52d9bd8 100644
--- a/pcap-linux.c
+++ b/pcap-linux.c
@@ -177,6 +177,11 @@ static const char rcsid[] _U_ =
   * uses many ring related structs and macros */
 # ifdef TPACKET_HDRLEN
 #  define HAVE_PACKET_RING
+#  ifdef TPACKET2_HDRLEN
+#   define HAVE_TPACKET2
+#  else
+#   define TPACKET_V1	0
+#  endif /* TPACKET2_HDRLEN */
 # endif /* TPACKET_HDRLEN */
 #endif /* PF_PACKET */
 
@@ -240,11 +245,18 @@ static int pcap_setfilter_linux(pcap_t *, struct bpf_program *);
 static int pcap_setdirection_linux(pcap_t *, pcap_direction_t);
 static void pcap_cleanup_linux(pcap_t *);
 
+union thdr {
+	struct tpacket_hdr	*h1;
+	struct tpacket2_hdr	*h2;
+	void			*raw;
+};
+
 #ifdef HAVE_PACKET_RING
-#define RING_GET_FRAME(h) (((struct tpacket_hdr**)h->buffer)[h->offset])
+#define RING_GET_FRAME(h) (((union thdr **)h->buffer)[h->offset])
 
 static void destroy_ring(pcap_t *handle);
 static int create_ring(pcap_t *handle);
+static int prepare_tpacket_socket(pcap_t *handle);
 static void pcap_cleanup_linux_mmap(pcap_t *);
 static int pcap_read_linux_mmap(pcap_t *, int, pcap_handler , u_char *);
 static int pcap_setfilter_linux_mmap(pcap_t *, struct bpf_program *);
@@ -1897,6 +1909,9 @@ activate_mmap(pcap_t *handle)
 		/* by default request 2M for the ring buffer */
 		handle->opt.buffer_size = 2*1024*1024;
 	}
+	ret = prepare_tpacket_socket(handle);
+	if (ret == 0)
+		return ret;
 	ret = create_ring(handle);
 	if (ret == 0)
 		return ret;
@@ -1918,6 +1933,41 @@ activate_mmap(pcap_t *handle)
 }
 
 #ifdef HAVE_PACKET_RING
+static int
+prepare_tpacket_socket(pcap_t *handle)
+{
+	socklen_t len;
+	int val;
+
+	handle->md.tp_version = TPACKET_V1;
+	handle->md.tp_hdrlen = sizeof(struct tpacket_hdr);
+
+#ifdef HAVE_TPACKET2
+	/* Probe whether kernel supports TPACKET_V2 */
+	val = TPACKET_V2;
+	len = sizeof(val);
+	if (getsockopt(handle->fd, SOL_PACKET, PACKET_HDRLEN, &val, &len) < 0) {
+		if (errno == ENOPROTOOPT)
+			return 1;
+		snprintf(handle->errbuf, PCAP_ERRBUF_SIZE,
+			 "can't get TPACKET_V2 header len on socket %d: %d-%s",
+			 handle->fd, errno, pcap_strerror(errno));
+		return 0;
+	}
+	handle->md.tp_hdrlen = val;
+
+	val = TPACKET_V2;
+	if (setsockopt(handle->fd, SOL_PACKET, PACKET_VERSION, &val,
+		       sizeof(val)) < 0) {
+		snprintf(handle->errbuf, PCAP_ERRBUF_SIZE,
+			 "can't activate TPACKET_V2 on socket %d: %d-%s",
+			 handle->fd, errno, pcap_strerror(errno));
+		return 0;
+	}
+	handle->md.tp_version = TPACKET_V2;
+#endif /* HAVE_TPACKET2 */
+	return 1;
+}
 
 static void
 compute_ring_block(int frame_size, unsigned *block_size, unsigned *frames_per_block)
@@ -1944,7 +1994,9 @@ create_ring(pcap_t *handle)
 	 * (and a lot of memory will be unused). 
 	 * The snap len should be carefully chosen to achive best
 	 * performance */
-	req.tp_frame_size = TPACKET_ALIGN(handle->snapshot+TPACKET_HDRLEN);
+	req.tp_frame_size = TPACKET_ALIGN(handle->snapshot +
+					  TPACKET_ALIGN(handle->md.tp_hdrlen) +
+					  sizeof(struct sockaddr_ll));
 	req.tp_frame_nr = handle->opt.buffer_size/req.tp_frame_size;
 	compute_ring_block(req.tp_frame_size, &req.tp_block_size, &frames_per_block);
 	req.tp_block_nr = req.tp_frame_nr / frames_per_block;
@@ -1983,7 +2035,7 @@ retry:
 
 	/* allocate a ring for each frame header pointer*/
 	handle->cc = req.tp_frame_nr;
-	handle->buffer = malloc(handle->cc * sizeof(struct tpacket_hdr*));
+	handle->buffer = malloc(handle->cc * sizeof(union thdr *));
 	if (!handle->buffer) {
 		destroy_ring(handle);
 		return 0;
@@ -1992,9 +2044,9 @@ retry:
 	/* fill the header ring with proper frame ptr*/
 	handle->offset = 0;
 	for (i=0; i<req.tp_block_nr; ++i) {
-		u_char *base = &handle->bp[i*req.tp_block_size];
+		void *base = &handle->bp[i*req.tp_block_size];
 		for (j=0; j<frames_per_block; ++j, ++handle->offset) {
-			RING_GET_FRAME(handle) = (struct tpacket_hdr*) base;
+			RING_GET_FRAME(handle) = base;
 			base += req.tp_frame_size;
 		}
 	}
@@ -2055,6 +2107,29 @@ pcap_setnonblock_mmap(pcap_t *p, int nonblock, char *errbuf)
 	return 0;
 }
 
+static inline union thdr *
+pcap_get_ring_frame(pcap_t *handle, int status)
+{
+	union thdr h;
+
+	h.raw = RING_GET_FRAME(handle);
+	switch (handle->md.tp_version) {
+	case TPACKET_V1:
+		if (status != (h.h1->tp_status ? TP_STATUS_USER :
+						TP_STATUS_KERNEL))
+			return NULL;
+		break;
+#ifdef HAVE_TPACKET2
+	case TPACKET_V2:
+		if (status != (h.h2->tp_status ? TP_STATUS_USER :
+						TP_STATUS_KERNEL))
+			return NULL;
+		break;
+#endif
+	}
+	return h.raw;
+}
+
 static int
 pcap_read_linux_mmap(pcap_t *handle, int max_packets, pcap_handler callback, 
 		u_char *user)
@@ -2062,7 +2137,8 @@ pcap_read_linux_mmap(pcap_t *handle, int max_packets, pcap_handler callback,
 	int pkts = 0;
 
 	/* wait for frames availability.*/
-	if ((handle->md.timeout >= 0) && !(RING_GET_FRAME(handle)->tp_status)) {
+	if ((handle->md.timeout >= 0) &&
+	    !pcap_get_ring_frame(handle, TP_STATUS_USER)) {
 		struct pollfd pollinfo;
 		int ret;
 
@@ -2094,16 +2170,41 @@ pcap_read_linux_mmap(pcap_t *handle, int max_packets, pcap_handler callback,
 		struct sockaddr_ll *sll;
 		struct pcap_pkthdr pcaphdr;
 		unsigned char *bp;
-		struct tpacket_hdr* thdr = RING_GET_FRAME(handle);
-		if (thdr->tp_status == TP_STATUS_KERNEL)
+		union thdr h;
+		unsigned int tp_len;
+		unsigned int tp_mac;
+		unsigned int tp_snaplen;
+		unsigned int tp_sec;
+		unsigned int tp_usec;
+
+		h.raw = pcap_get_ring_frame(handle, TP_STATUS_USER);
+		if (!h.raw)
 			break;
 
+		switch (handle->md.tp_version) {
+		case TPACKET_V1:
+			tp_len	   = h.h1->tp_len;
+			tp_mac	   = h.h1->tp_mac;
+			tp_snaplen = h.h1->tp_snaplen;
+			tp_sec	   = h.h1->tp_sec;
+			tp_usec	   = h.h1->tp_usec;
+			break;
+#ifdef HAVE_TPACKET2
+		case TPACKET_V2:
+			tp_len	   = h.h2->tp_len;
+			tp_mac	   = h.h2->tp_mac;
+			tp_snaplen = h.h2->tp_snaplen;
+			tp_sec	   = h.h2->tp_sec;
+			tp_usec	   = h.h2->tp_nsec / 1000;
+			break;
+#endif
+		}
 		/* perform sanity check on internal offset. */
-		if (thdr->tp_mac+thdr->tp_snaplen > handle->bufsize) {
+		if (tp_mac + tp_snaplen > handle->bufsize) {
 			snprintf(handle->errbuf, PCAP_ERRBUF_SIZE, 
 				"corrupted frame on kernel ring mac "
 				"offset %d + caplen %d > frame len %d", 
-				thdr->tp_mac, thdr->tp_snaplen, handle->bufsize);
+				tp_mac, tp_snaplen, handle->bufsize);
 			return -1;
 		}
 
@@ -2116,25 +2217,25 @@ pcap_read_linux_mmap(pcap_t *handle, int max_packets, pcap_handler callback,
 		 * Note: alternatively it could be possible to stop applying 
 		 * the filter when the ring became empty, but it can possibly
 		 * happen a lot later... */
-		bp = (unsigned char*)thdr + thdr->tp_mac;
+		bp = (unsigned char*)h.raw + tp_mac;
 		run_bpf = (!handle->md.use_bpf) || 
 			((handle->md.use_bpf>1) && handle->md.use_bpf--);
 		if (run_bpf && handle->fcode.bf_insns && 
 				(bpf_filter(handle->fcode.bf_insns, bp,
-					thdr->tp_len, thdr->tp_snaplen) == 0))
+					tp_len, tp_snaplen) == 0))
 			goto skip;
 
 		/* check direction and interface index */
-		sll = (void*)thdr + TPACKET_ALIGN(sizeof(*thdr));
+		sll = (void *)h.raw + TPACKET_ALIGN(handle->md.tp_hdrlen);
 		if ((sll->sll_ifindex == handle->md.lo_ifindex) &&
 					(sll->sll_pkttype == PACKET_OUTGOING))
 			goto skip;
 
 		/* get required packet info from ring header */
-		pcaphdr.ts.tv_sec = thdr->tp_sec;
-		pcaphdr.ts.tv_usec = thdr->tp_usec;
-		pcaphdr.caplen = thdr->tp_snaplen;
-		pcaphdr.len = thdr->tp_len;
+		pcaphdr.ts.tv_sec = tp_sec;
+		pcaphdr.ts.tv_usec = tp_usec;
+		pcaphdr.caplen = tp_snaplen;
+		pcaphdr.len = tp_len;
 
 		/* if required build in place the sll header*/
 		if (handle->md.cooked) {
@@ -2156,7 +2257,9 @@ pcap_read_linux_mmap(pcap_t *handle, int max_packets, pcap_handler callback,
 			 * don't step on the header when we construct
 			 * the sll header.
 			 */
-			if (bp < (u_char *)thdr + TPACKET_HDRLEN) {
+			if (bp < (u_char *)h.raw +
+					   TPACKET_ALIGN(handle->md.tp_hdrlen) +
+					   sizeof(struct sockaddr_ll)) {
 				snprintf(handle->errbuf, PCAP_ERRBUF_SIZE, 
 					"cooked-mode frame doesn't have room for sll header");
 				return -1;
@@ -2185,7 +2288,16 @@ pcap_read_linux_mmap(pcap_t *handle, int max_packets, pcap_handler callback,
 
 skip:
 		/* next packet */
-		thdr->tp_status = TP_STATUS_KERNEL;
+		switch (handle->md.tp_version) {
+		case TPACKET_V1:
+			h.h1->tp_status = TP_STATUS_KERNEL;
+			break;
+#ifdef HAVE_TPACKET2
+		case TPACKET_V2:
+			h.h2->tp_status = TP_STATUS_KERNEL;
+			break;
+#endif
+		}
 		if (++handle->offset >= handle->cc)
 			handle->offset = 0;
 
@@ -2219,7 +2331,7 @@ pcap_setfilter_linux_mmap(pcap_t *handle, struct bpf_program *filter)
 	for (n=0; n < handle->cc; ++n) {
 		if (--handle->offset < 0)
 			handle->offset = handle->cc - 1;
-		if (RING_GET_FRAME(handle)->tp_status != TP_STATUS_KERNEL)
+		if (!pcap_get_ring_frame(handle, TP_STATUS_KERNEL))
 			break;
 	}
 

--------------050702030704020004010706
Content-Type: text/plain;
 name="05-libpcap-tpacket2-vlan"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="05-libpcap-tpacket2-vlan"

pcap-linux: reconstruct VLAN headers from tpacket2_hdr

From: Patrick McHardy <kaber@trash.net>

Similar to PACKET_AUXDATA for non-mmaped sockets, the VLAN TCI is
present in a new member of struct tpacket2_hdr. Use it to reconstruct
the VLAN header when necessary.
---

 pcap-linux.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)


diff --git a/pcap-linux.c b/pcap-linux.c
index 52d9bd8..bd01774 100644
--- a/pcap-linux.c
+++ b/pcap-linux.c
@@ -1965,6 +1965,17 @@ prepare_tpacket_socket(pcap_t *handle)
 		return 0;
 	}
 	handle->md.tp_version = TPACKET_V2;
+
+	/* Reserve space for VLAN tag reconstruction */
+	val = VLAN_TAG_LEN;
+	if (setsockopt(handle->fd, SOL_PACKET, PACKET_RESERVE, &val,
+		       sizeof(val)) < 0) {
+		snprintf(handle->errbuf, PCAP_ERRBUF_SIZE,
+			 "can't set up reserve on socket %d: %d-%s",
+			 handle->fd, errno, pcap_strerror(errno));
+		return 0;
+	}
+
 #endif /* HAVE_TPACKET2 */
 	return 1;
 }
@@ -2281,6 +2292,23 @@ pcap_read_linux_mmap(pcap_t *handle, int max_packets, pcap_handler callback,
 			pcaphdr.len += SLL_HDR_LEN;
 		}
 
+#ifdef HAVE_TPACKET2
+		if (handle->md.tp_version == TPACKET_V2 && h.h2->tp_vlan_tci &&
+		    tp_snaplen >= 2 * ETH_ALEN) {
+			struct vlan_tag *tag;
+
+			bp -= VLAN_TAG_LEN;
+			memmove(bp, bp + VLAN_TAG_LEN, 2 * ETH_ALEN);
+
+			tag = (struct vlan_tag *)(bp + 2 * ETH_ALEN);
+			tag->vlan_tpid = htons(ETH_P_8021Q);
+			tag->vlan_tci = htons(h.h2->tp_vlan_tci);
+
+			pcaphdr.caplen += VLAN_TAG_LEN;
+			pcaphdr.len += VLAN_TAG_LEN;
+		}
+#endif
+
 		/* pass the packet to the user */
 		pkts++;
 		callback(user, &pcaphdr, bp);

--------------050702030704020004010706--
