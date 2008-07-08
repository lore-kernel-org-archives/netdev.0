From: Patrick McHardy <kaber@trash.net>
Subject: [RFC PATCH 04/04]: libpcap: reconstruct VLAN header from auxdata
Date: Tue, 08 Jul 2008 12:17:10 +0200
Message-ID: <48733EA6.8050007@trash.net>
References: <48733E1B.8010501@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060208010901020001050405"
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54929 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441AbYGHKRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 06:17:13 -0400
Received: from [192.168.0.100] (unknown [78.42.204.165])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTP id D2E02948DA
	for <netdev@vger.kernel.org>; Tue,  8 Jul 2008 12:17:11 +0200 (MEST)
In-Reply-To: <48733E1B.8010501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060208010901020001050405
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit



--------------060208010901020001050405
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
 

--------------060208010901020001050405--
