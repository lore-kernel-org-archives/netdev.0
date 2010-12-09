From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [PATCH 0/5 V2] Firewire networking assorted fixes
Date: Thu, 09 Dec 2010 03:42:41 +0200
Message-ID: <1291858961.3331.4.camel@maxim-laptop>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
	 <1291779177.32420.8.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-+5PvVgGuBnxMkfPpY39/"
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>, netdev@vger.kernel.org
To: linux1394-devel <linux1394-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:56047 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754794Ab0LIBmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 20:42:49 -0500
Received: by bwz16 with SMTP id 16so2076098bwz.4
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 17:42:47 -0800 (PST)
In-Reply-To: <1291779177.32420.8.camel@maxim-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+5PvVgGuBnxMkfPpY39/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Wed, 2010-12-08 at 05:32 +0200, Maxim Levitsky wrote:
> On Mon, 2010-11-29 at 04:09 +0200, Maxim Levitsky wrote:
> > Hi,
> > 
> > This is updated version of the patches.
> > I updated the changelogs, addressed comments on patch #2
> > 
> > Best regards,
> > 	Maxim Levitsky
> > 
> 
> Today I have achieved the ultimate goal,
> full support of firewire networking via NetworkManager.
> 
> Currently it is patched with few hacks but much less that I expected.
> 
> I also had to patch dhclient as it unfortunately sends raw packets
> together with hardware header (ethernet of course...)
> 
> I will soon clean up these hacks to turn them into patches and send to
> developers.
> 
> The kernel side needs only the attached patch.
> It adds the link state detection to firewire-net
> 
> Just for fun, this is screenshot that proves that NM works:
> http://img210.imageshack.us/img210/6019/screenshotdjk.png

And cleaned up patches that add the support attached.
Will send these to NM and dhcp ML soon.

Best regards,
	Maxim Levitsky


--=-+5PvVgGuBnxMkfPpY39/
Content-Disposition: attachment; filename="0001-Add-support-for-RFC2855-DHCP-over-IEEE1394.patch"
Content-Type: text/x-patch; name="0001-Add-support-for-RFC2855-DHCP-over-IEEE1394.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 09750594f8c861d58762969d4fe1f1b3b81b0b5f Mon Sep 17 00:00:00 2001
From: Maxim Levitsky <maximlevitsky@gmail.com>
Date: Thu, 9 Dec 2010 02:49:23 +0200
Subject: [PATCH] Add support for RFC2855, DHCP over IEEE1394

---
 client/dhclient.c    |   18 ++++++++++
 common/Makefile.dist |    6 ++-
 common/discover.c    |   15 ++++++--
 common/firewire.c    |   90 ++++++++++++++++++++++++++++++++++++++++++++++++++
 common/lpf.c         |    9 ++++-
 common/packet.c      |   13 +++++++
 includes/dhcpd.h     |    7 ++++
 7 files changed, 151 insertions(+), 7 deletions(-)
 create mode 100644 common/firewire.c

diff --git a/client/dhclient.c b/client/dhclient.c
index a9a0993..5f079b3 100644
--- a/client/dhclient.c
+++ b/client/dhclient.c
@@ -1890,6 +1890,24 @@ void make_client_options (client, lease, type, sid, rip, prl, op)
 		client -> requested_address.len = 0;
 	}
 
+#ifdef HAVE_ARPHRD_IEEE1394
+	/* Per RFC2855, send hardware address inside client identifier
+		by default*/
+	if (client -> interface -> hw_address.hbuf [0] == ARPHRD_IEEE1394) {
+		i = DHO_DHCP_CLIENT_IDENTIFIER;
+		if (!(option_code_hash_lookup(&option, dhcp_universe.code_hash,
+						&i, 0, MDL) &&
+			make_const_option_cache(&oc, NULL,
+				&client -> interface -> hw_address.hbuf [1], 8,
+						option, MDL)))
+			log_error ("can't make requested address cache.");
+		else {
+			save_option (&dhcp_universe, *op, oc);
+			option_cache_dereference (&oc, MDL);
+		}
+		option_dereference(&option, MDL);
+	}
+#endif
 	i = DHO_DHCP_MESSAGE_TYPE;
 	if (!(option_code_hash_lookup(&option, dhcp_universe.code_hash, &i, 0,
 				      MDL) &&
diff --git a/common/Makefile.dist b/common/Makefile.dist
index 2b9faee..52f280b 100644
--- a/common/Makefile.dist
+++ b/common/Makefile.dist
@@ -23,11 +23,13 @@
 CATMANPAGES = dhcp-options.cat5 dhcp-eval.cat5
 SEDMANPAGES = dhcp-options.man5 dhcp-eval.man5
 SRC    = raw.c parse.c nit.c icmp.c dispatch.c conflex.c upf.c bpf.c socket.c \
-	 lpf.c dlpi.c packet.c tr.c ethernet.c memory.c print.c options.c \
+	 lpf.c dlpi.c packet.c tr.c ethernet.c firewire.c \
+	 memory.c print.c options.c \
 	 inet.c tree.c tables.c alloc.c fddi.c ctrace.c dns.c resolv.c \
 	 execute.c discover.c comapi.c
 OBJ    = raw.o parse.o nit.o icmp.o dispatch.o conflex.o upf.o bpf.o socket.o \
-	 lpf.o dlpi.o packet.o tr.o ethernet.o memory.o print.o options.o \
+	 lpf.o dlpi.o packet.o tr.o ethernet.o firewire.o \
+	 memory.o print.o options.o \
 	 inet.o tree.o tables.o alloc.o fddi.o ctrace.o dns.o resolv.o \
 	 execute.o discover.o comapi.o
 MAN    = dhcp-options.5 dhcp-eval.5
diff --git a/common/discover.c b/common/discover.c
index 69d23b1..979b1c4 100644
--- a/common/discover.c
+++ b/common/discover.c
@@ -471,15 +471,22 @@ void discover_interfaces (state)
 		     case ARPHRD_SIT:
 			/* ignore IPv6-in-IPv4 interfaces. */
 #endif
-#ifdef HAVE_ARPHRD_IEEE1394
-		     case ARPHRD_IEEE1394:
-			/* ignore IEEE1394 interfaces. */
-#endif
 #ifdef HAVE_ARPHRD_LOOPBACK
 		      case ARPHRD_LOOPBACK:
 			/* ignore loopback interface */
 			break;
 #endif
+#ifdef HAVE_ARPHRD_IEEE1394
+		     case ARPHRD_IEEE1394:
+			/* According to RFC2855, we set hlen to 0,
+			but store hardware address in the client ID,
+			so store hardware address but set len to 0 */
+			tmp -> hw_address.hlen = 1;
+			tmp -> hw_address.hbuf [0] = ARPHRD_IEEE1394;
+			memcpy (&tmp -> hw_address.hbuf [1], sa.sa_data, 8);
+			break;
+#endif
+
 
 		      case ARPHRD_ETHER:
 			tmp -> hw_address.hlen = 7;
diff --git a/common/firewire.c b/common/firewire.c
new file mode 100644
index 0000000..f11efd2
--- /dev/null
+++ b/common/firewire.c
@@ -0,0 +1,90 @@
+/* firewire.c
+
+Based on ethernet.c
+
+/*
+ * Copyright (c) 2004 by Internet Systems Consortium, Inc. ("ISC")
+ * Copyright (c) 1996-2003 by Internet Software Consortium
+ *
+ * Permission to use, copy, modify, and distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND ISC DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS.  IN NO EVENT SHALL ISC BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
+ * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ *
+ *   Internet Systems Consortium, Inc.
+ *   950 Charter Street
+ *   Redwood City, CA 94063
+ *   <info@isc.org>
+ *   https://www.isc.org/
+ *
+ * This software has been written for Internet Systems Consortium
+ * by Ted Lemon in cooperation with Vixie Enterprises and Nominum, Inc.
+ * To learn more about Internet Systems Consortium, see
+ * ``https://www.isc.org/''.  To learn more about Vixie Enterprises,
+ * see ``http://www.vix.com''.   To learn more about Nominum, Inc., see
+ * ``http://www.nominum.com''.
+ */
+
+#ifndef lint
+static char copyright[] =
+"$Id: firewire.c,v 1.8.140.1 2009/07/23 21:43:33 sar Exp $ Copyright (c) 2004 Internet Systems Consortium.  All rights reserved.\n";
+#endif /* not lint */
+
+#include "dhcpd.h"
+
+#if defined (PACKET_ASSEMBLY) || defined (PACKET_DECODING)
+#include "includes/netinet/if_ether.h"
+#endif /* PACKET_ASSEMBLY || PACKET_DECODING */
+
+#define FWNET_ALEN 8
+struct fwnet_header {
+	unsigned char h_dest[FWNET_ALEN];	/* destination address */
+	uint16_t h_proto;		/* packet type ID field */
+} __attribute__((packed));
+
+#if defined (PACKET_ASSEMBLY)
+/* Assemble an hardware header... */
+
+void assemble_fw_header (struct interface_info *interface,
+			unsigned char *buf,
+			unsigned *bufix,
+			struct hardware *to)
+{
+  struct fwnet_header hdr;
+  memset(hdr.h_dest, 0xFF, FWNET_ALEN);
+  hdr.h_proto = htons (ETHERTYPE_IP);
+  memcpy (&buf [*bufix], &hdr, sizeof(hdr));
+  *bufix += sizeof(hdr);
+}
+
+#endif /* PACKET_ASSEMBLY */
+
+#ifdef PACKET_DECODING
+/* Decode a hardware header... */
+
+ssize_t decode_fw_header(struct interface_info *interface,
+				unsigned char *buf,
+				unsigned bufix,
+				struct hardware *from)
+{
+  struct fwnet_header hdr;
+  memcpy(&hdr, buf + bufix, sizeof(hdr));
+
+#ifdef USERLAND_FILTER
+  if (ntohs (hdr.h_proto) != ETHERTYPE_IP)
+	  return -1;
+#endif
+
+  memcpy(&from->hbuf[1], hdr.h_dest, FWNET_ALEN);
+  from->hlen = FWNET_ALEN + 1;
+  return sizeof(hdr);
+}
+
+#endif /* PACKET_DECODING */
diff --git a/common/lpf.c b/common/lpf.c
index 5922660..a3fafef 100644
--- a/common/lpf.c
+++ b/common/lpf.c
@@ -181,6 +181,13 @@ void if_register_receive (info)
 		lpf_tr_filter_setup (info);
 	else
 #endif
+#if defined (HAVE_ARPHRD_IEEE1394)
+	/* FIXME: this currently piggybacks on TR no-op filter, as
+		generic filter don't work for FW */
+	if (info -> hw_address.hbuf[0] == ARPHRD_IEEE1394)
+		lpf_tr_filter_setup (info);
+	else
+#endif
 		lpf_gen_filter_setup (info);
 
 	if (!quiet_interface_discovery)
@@ -245,7 +252,7 @@ static void lpf_gen_filter_setup (info)
 	}
 }
 
-#if defined (HAVE_TR_SUPPORT)
+#if defined (HAVE_TR_SUPPORT) || defined (HAVE_ARPHRD_IEEE1394)
 static void lpf_tr_filter_setup (info)
 	struct interface_info *info;
 {
diff --git a/common/packet.c b/common/packet.c
index 4c878a6..378114e 100644
--- a/common/packet.c
+++ b/common/packet.c
@@ -111,6 +111,8 @@ void assemble_hw_header (interface, buf, bufix, to)
 	unsigned *bufix;
 	struct hardware *to;
 {
+
+
 #if defined (HAVE_TR_SUPPORT)
 	if (interface -> hw_address.hbuf [0] == HTYPE_IEEE802)
 		assemble_tr_header (interface, buf, bufix, to);
@@ -121,6 +123,11 @@ void assemble_hw_header (interface, buf, bufix, to)
 		     assemble_fddi_header (interface, buf, bufix, to);
 	else
 #endif
+#if defined (HAVE_ARPHRD_IEEE1394)
+	     if (interface -> hw_address.hbuf [0] == ARPHRD_IEEE1394)
+		     assemble_fw_header(interface, buf, bufix, to);
+#endif
+	else
 		assemble_ethernet_header (interface, buf, bufix, to);
 
 }
@@ -198,6 +205,7 @@ ssize_t decode_hw_header (interface, buf, bufix, from)
      unsigned bufix;
      struct hardware *from;
 {
+
 #if defined (HAVE_TR_SUPPORT)
 	if (interface -> hw_address.hbuf [0] == HTYPE_IEEE802)
 		return decode_tr_header (interface, buf, bufix, from);
@@ -208,6 +216,11 @@ ssize_t decode_hw_header (interface, buf, bufix, from)
 		     return decode_fddi_header (interface, buf, bufix, from);
 	else
 #endif
+#if defined (HAVE_ARPHRD_IEEE1394)
+	     if (interface -> hw_address.hbuf [0] == ARPHRD_IEEE1394)
+		     return decode_fw_header (interface, buf, bufix, from);
+#endif
+	else
 		return decode_ethernet_header (interface, buf, bufix, from);
 }
 
diff --git a/includes/dhcpd.h b/includes/dhcpd.h
index 50b899c..95b119a 100644
--- a/includes/dhcpd.h
+++ b/includes/dhcpd.h
@@ -2135,6 +2135,13 @@ ssize_t decode_tr_header PROTO ((struct interface_info *,
 				 unsigned char *,
 				 unsigned, struct hardware *));
 
+/* firewire.c */
+void assemble_fw_header PROTO ((struct interface_info *, unsigned char *,
+				unsigned *, struct hardware *));
+ssize_t decode_fw_header PROTO ((struct interface_info *,
+				 unsigned char *,
+				 unsigned, struct hardware *));
+
 /* dhxpxlt.c */
 void convert_statement PROTO ((struct parse *));
 void convert_host_statement PROTO ((struct parse *, jrefproto));
-- 
1.7.1


--=-+5PvVgGuBnxMkfPpY39/
Content-Disposition: attachment; filename="0001-NM-allow-use-of-IPV4-over-firewire.patch"
Content-Type: text/x-patch; name="0001-NM-allow-use-of-IPV4-over-firewire.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 93129738ca8450899e416420f630aee17c8301d5 Mon Sep 17 00:00:00 2001
From: Maxim Levitsky <maximlevitsky@gmail.com>
Date: Thu, 9 Dec 2010 00:30:55 +0200
Subject: [PATCH] NM: allow use of IPV4 over firewire

Don't ignore these devices since NM
works just fine with them iff the dhclient
works.
Patches are posted to make it work with
firewire networking link

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 src/nm-udev-manager.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/src/nm-udev-manager.c b/src/nm-udev-manager.c
index ff0ef68..3cd2970 100644
--- a/src/nm-udev-manager.c
+++ b/src/nm-udev-manager.c
@@ -408,7 +408,9 @@ net_add (NMUdevManager *self, GUdevDevice *device)
 	g_return_if_fail (device != NULL);
 
 	etype = g_udev_device_get_sysfs_attr_as_int (device, "type");
-	if (etype != 1) {
+
+	/* firewire devices are similiar to ethernet, so allow them too */
+	if (etype != 1 && etype != 24) {
 		nm_log_dbg (LOGD_HW, "ignoring interface with type %d", etype);
 		return; /* Not using ethernet encapsulation, don't care */
 	}
-- 
1.7.1


--=-+5PvVgGuBnxMkfPpY39/--

