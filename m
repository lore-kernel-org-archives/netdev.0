From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [RFC PATCH net-next 2/3] sctp: offloading support structure
Date: Wed, 27 Jan 2016 15:06:32 -0200
Message-ID: <fff48833aa40f9a0874cd9eb41403ac63e3ebbf2.1453913331.git.marcelo.leitner@gmail.com>
References: <cover.1453913331.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, brouer@redhat.com,
	alexander.duyck@gmail.com, alexei.starovoitov@gmail.com,
	borkmann@iogearbox.net, marek@cloudflare.com,
	hannes@stressinduktion.org, fw@strlen.de, pabeni@redhat.com,
	john.r.fastabend@intel.com, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50911 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932973AbcA0RG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 12:06:58 -0500
In-Reply-To: <cover.1453913331.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch just adds initial offloading bits, just to ease reviewing of
the next one. It will be merged with GSO patch itself in the actual
submission.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/linux/skbuff.h  |  2 ++
 include/net/sctp/sctp.h |  4 ++++
 net/sctp/Makefile       |  3 ++-
 net/sctp/offload.c      | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 net/sctp/protocol.c     |  3 +++
 5 files changed, 58 insertions(+), 1 deletion(-)
 create mode 100644 net/sctp/offload.c

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 11f935c1a090419d6cda938aa925bfa79de3616b..7d0b02ad241b5c5936aea6b66941e42867f2e9e0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -481,6 +481,8 @@ enum {
 	SKB_GSO_UDP_TUNNEL_CSUM = 1 << 11,
 
 	SKB_GSO_TUNNEL_REMCSUM = 1 << 12,
+
+	SKB_GSO_SCTP = 1 << 13,
 };
 
 #if BITS_PER_LONG > 32
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 835aa2ed987092634a4242314e9eabb51d1e4e35..4b1159188525f193a11af95700e91f88b10268b6 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -165,6 +165,10 @@ void sctp_assocs_proc_exit(struct net *net);
 int sctp_remaddr_proc_init(struct net *net);
 void sctp_remaddr_proc_exit(struct net *net);
 
+/*
+ * sctp/offload.c
+ */
+int sctp_offload_init(void);
 
 /*
  * Module global variables
diff --git a/net/sctp/Makefile b/net/sctp/Makefile
index 3b4ffb021cf1728353b5311e519604759a03b617..a89d3f51604d1474b72ee10b9d9c6a2200c2ed9d 100644
--- a/net/sctp/Makefile
+++ b/net/sctp/Makefile
@@ -10,7 +10,8 @@ sctp-y := sm_statetable.o sm_statefuns.o sm_sideeffect.o \
 	  transport.o chunk.o sm_make_chunk.o ulpevent.o \
 	  inqueue.o outqueue.o ulpqueue.o \
 	  tsnmap.o bind_addr.o socket.o primitive.o \
-	  output.o input.o debug.o ssnmap.o auth.o
+	  output.o input.o debug.o ssnmap.o auth.o \
+	  offload.o
 
 sctp_probe-y := probe.o
 
diff --git a/net/sctp/offload.c b/net/sctp/offload.c
new file mode 100644
index 0000000000000000000000000000000000000000..7080a6318da7110c1688dd0c5bb240356dbd0cd3
--- /dev/null
+++ b/net/sctp/offload.c
@@ -0,0 +1,47 @@
+/*
+ * sctp_offload - GRO/GSO Offloading for SCTP
+ *
+ * Copyright (C) 2015, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/kernel.h>
+#include <linux/kprobes.h>
+#include <linux/socket.h>
+#include <linux/sctp.h>
+#include <linux/proc_fs.h>
+#include <linux/vmalloc.h>
+#include <linux/module.h>
+#include <linux/kfifo.h>
+#include <linux/time.h>
+#include <net/net_namespace.h>
+
+#include <linux/skbuff.h>
+#include <net/sctp/sctp.h>
+#include <net/sctp/checksum.h>
+#include <net/protocol.h>
+
+static const struct net_offload sctp_offload = {
+	.callbacks = {
+	},
+};
+
+int __init sctp_offload_init(void)
+{
+	return inet_add_offload(&sctp_offload, IPPROTO_SCTP);
+}
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index ab0d538a74ed593571cfaef02cd1bb7ce872abe6..a63464e56e46f046cb73f589c844e0203b96a5cd 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1485,6 +1485,9 @@ static __init int sctp_init(void)
 	if (status)
 		goto err_v6_add_protocol;
 
+	if (sctp_offload_init() < 0)
+		pr_crit("%s: Cannot add SCTP protocol offload\n", __func__);
+
 out:
 	return status;
 err_v6_add_protocol:
-- 
2.5.0
