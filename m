From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 11/11] Phonet: kernel documentation
Date: Mon, 22 Sep 2008 18:47:25 +0300
Message-ID: <1222098445-26175-11-git-send-email-remi.denis-courmont@nokia.com>
References: <200809221845.54736.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:53013 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753619AbYIVPru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 11:47:50 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8MFlZFj027641
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 18:47:47 +0300
In-Reply-To: <200809221845.54736.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 Documentation/networking/phonet.txt |  111 +++++++++++++++++++++++++++=
++++++++
 1 files changed, 111 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/networking/phonet.txt

diff --git a/Documentation/networking/phonet.txt b/Documentation/networ=
king/phonet.txt
new file mode 100644
index 0000000..f3c72e0
--- /dev/null
+++ b/Documentation/networking/phonet.txt
@@ -0,0 +1,111 @@
+Linux Phonet protocol family
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
+
+Introduction
+------------
+
+Phonet is a packet protocol used by Nokia cellular modems for both IPC
+and RPC. With the Linux Phonet socket family, Linux host processes can
+receive and send messages from/to the modem, or any other external
+device attached to the modem. The modem takes care of routing.
+
+Phonet packets can be exchanged through various hardware connections
+depending on the device, such as:
+  - USB with the CDC Phonet interface,
+  - infrared,
+  - Bluetooth,
+  - an RS232 serial port (with a dedicated "FBUS" line discipline),
+  - the SSI bus with some TI OMAP processors.
+
+
+Packets format
+--------------
+
+Phonet packet have a common header as follow:
+
+  struct phonethdr {
+    uint8_t  pn_media;  /* Media type (link-layer identifier) */
+    uint8_t  pn_rdev;   /* Receiver device ID */
+    uint8_t  pn_sdev;   /* Sender device ID */
+    uint8_t  pn_res;    /* Resource ID or function */
+    uint16_t pn_length; /* Big-endian message byte length (minus 6) */
+    uint8_t  pn_robj;   /* Receiver object ID */
+    uint8_t  pn_sobj;   /* Sender object ID */
+  };
+
+The device ID is split: the 6 higher order bits consitutes the device
+address, while the 2 lower order bits are used for multiplexing, as ar=
e
+the 8-bits object identifiers. As such, Phonet can be considered as a
+network layer with 6 bits of address space and 10 bits for transport
+protocol (much like port numbers in IP world).
+
+The modem always has address number zero. Each other device has a its
+own 6-bits address.
+
+
+Link layer
+----------
+
+Phonet links are always point-to-point links. The link layer header
+consists of a single Phonet media type byte. It uniquely identifies th=
e
+link through which the packet is transmitted, from the modem's
+perspective.
+
+Linux Phonet network interfaces use a dedicated link layer type
+(ETH_P_PHONET) which is out of the Ethernet type range. They can only
+send and receive Phonet packets.
+
+Note that Phonet interfaces are not allowed to re-order packets, so
+only the (default) Linux FIFO qdisc should be used with them.
+
+
+Network layer
+-------------
+
+The Phonet socket address family maps the Phonet packet header:
+
+  struct sockaddr_pn {
+    sa_family_t spn_family;    /* AF_PHONET */
+    uint8_t     spn_obj;       /* Object ID */
+    uint8_t     spn_dev;       /* Device ID */
+    uint8_t     spn_resource;  /* Resource or function */
+    uint8_t     spn_zero[...]; /* Padding */
+  };
+
+The resource field is only used when sending and receiving;
+It is ignored by bind() and getsockname().
+
+
+Low-level datagram protocol
+---------------------------
+
+Applications can send Phonet messages using the Phonet datagram socket
+protocol from the PF_PHONET family. Each socket is bound to one of the
+2^10 object IDs available, and can send and receive packets with any
+other peer.
+
+  struct sockaddr_pn addr =3D { .spn_family =3D AF_PHONET, };
+  ssize_t len;
+  socklen_t addrlen =3D sizeof(addr);
+  int fd;
+
+  fd =3D socket(PF_PHONET, SOCK_DGRAM, 0);
+  bind(fd, (struct sockaddr *)&addr, sizeof(addr));
+  /* ... */
+
+  sendto(fd, msg, msglen, 0, (struct sockaddr *)&addr, sizeof(addr));
+  len =3D recvfrom(fd, buf, sizeof(buf), 0,
+                 (struct sockaddr *)&addr, &addrlen);
+
+This protocol follows the SOCK_DGRAM connection-less semantics.
+However, connect() and getpeername() are not supported, as they did
+not seem useful with Phonet usages (could be added easily).
+
+
+Authors
+-------
+
+Linux Phonet was initially written by Sakari Ailus.
+Other contributors include Mik=C3=A4 Liljeberg, Andras Domokos,
+Carlos Chinea and R=C3=A9mi Denis-Courmont.
+Copyright (C) 2008 Nokia Corporation.
--=20
1.5.4.3

