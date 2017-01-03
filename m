From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 3/3] sctp: remove asoc ssnmap and ssnmap.c
Date: Tue,  3 Jan 2017 13:59:48 +0800
Message-ID: <be8a2770ddc2381266050c9f168add9802b90a49.1483422833.git.lucien.xin@gmail.com>
References: <cover.1483422833.git.lucien.xin@gmail.com>
 <684ad8ddd79f23844883dede4c34360ce744dfc3.1483422833.git.lucien.xin@gmail.com>
 <c752879a5af358c08da949b391416452f1322c43.1483422833.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35954 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755610AbdACGAU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 01:00:20 -0500
In-Reply-To: <c752879a5af358c08da949b391416452f1322c43.1483422833.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483422833.git.lucien.xin@gmail.com>
References: <cover.1483422833.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since asoc stream arrays has replaced ssnmap, ssnmap is not used any
more, this patch is to remove asoc ssnmap and ssnmap.c.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sctp.h    |   1 -
 include/net/sctp/structs.h |  33 ------------
 net/sctp/Makefile          |   3 +-
 net/sctp/objcnt.c          |   2 -
 net/sctp/ssnmap.c          | 125 ---------------------------------------------
 5 files changed, 1 insertion(+), 163 deletions(-)
 delete mode 100644 net/sctp/ssnmap.c

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index d8833a8..598d938 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -283,7 +283,6 @@ extern atomic_t sctp_dbg_objcnt_chunk;
 extern atomic_t sctp_dbg_objcnt_bind_addr;
 extern atomic_t sctp_dbg_objcnt_bind_bucket;
 extern atomic_t sctp_dbg_objcnt_addr;
-extern atomic_t sctp_dbg_objcnt_ssnmap;
 extern atomic_t sctp_dbg_objcnt_datamsg;
 extern atomic_t sctp_dbg_objcnt_keys;
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index f81c321..9075d61 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -82,7 +82,6 @@ struct sctp_outq;
 struct sctp_bind_addr;
 struct sctp_ulpq;
 struct sctp_ep_common;
-struct sctp_ssnmap;
 struct crypto_shash;
 
 
@@ -377,35 +376,6 @@ typedef struct sctp_sender_hb_info {
 	__u64 hb_nonce;
 } __packed sctp_sender_hb_info_t;
 
-/*
- *  RFC 2960 1.3.2 Sequenced Delivery within Streams
- *
- *  The term "stream" is used in SCTP to refer to a sequence of user
- *  messages that are to be delivered to the upper-layer protocol in
- *  order with respect to other messages within the same stream.  This is
- *  in contrast to its usage in TCP, where it refers to a sequence of
- *  bytes (in this document a byte is assumed to be eight bits).
- *  ...
- *
- *  This is the structure we use to track both our outbound and inbound
- *  SSN, or Stream Sequence Numbers.
- */
-
-struct sctp_stream {
-	__u16 *ssn;
-	unsigned int len;
-};
-
-struct sctp_ssnmap {
-	struct sctp_stream in;
-	struct sctp_stream out;
-};
-
-struct sctp_ssnmap *sctp_ssnmap_new(__u16 in, __u16 out,
-				    gfp_t gfp);
-void sctp_ssnmap_free(struct sctp_ssnmap *map);
-void sctp_ssnmap_clear(struct sctp_ssnmap *map);
-
 /* What is the current SSN number for this stream? */
 #define sctp_ssn_peek(asoc, type, sid) \
 	((asoc)->stream##type[sid].ssn)
@@ -1751,9 +1721,6 @@ struct sctp_association {
 	/* Default receive parameters */
 	__u32 default_rcv_context;
 
-	/* This tracks outbound ssn for a given stream.	 */
-	struct sctp_ssnmap *ssnmap;
-
 	/* All outbound chunks go through this structure.  */
 	struct sctp_outq outqueue;
 
diff --git a/net/sctp/Makefile b/net/sctp/Makefile
index 6c4f749..48bfc74 100644
--- a/net/sctp/Makefile
+++ b/net/sctp/Makefile
@@ -11,8 +11,7 @@ sctp-y := sm_statetable.o sm_statefuns.o sm_sideeffect.o \
 	  transport.o chunk.o sm_make_chunk.o ulpevent.o \
 	  inqueue.o outqueue.o ulpqueue.o \
 	  tsnmap.o bind_addr.o socket.o primitive.o \
-	  output.o input.o debug.o ssnmap.o auth.o \
-	  offload.o
+	  output.o input.o debug.o auth.o offload.o
 
 sctp_probe-y := probe.o
 
diff --git a/net/sctp/objcnt.c b/net/sctp/objcnt.c
index 40e7fac..105ac33 100644
--- a/net/sctp/objcnt.c
+++ b/net/sctp/objcnt.c
@@ -51,7 +51,6 @@ SCTP_DBG_OBJCNT(bind_addr);
 SCTP_DBG_OBJCNT(bind_bucket);
 SCTP_DBG_OBJCNT(chunk);
 SCTP_DBG_OBJCNT(addr);
-SCTP_DBG_OBJCNT(ssnmap);
 SCTP_DBG_OBJCNT(datamsg);
 SCTP_DBG_OBJCNT(keys);
 
@@ -67,7 +66,6 @@ static sctp_dbg_objcnt_entry_t sctp_dbg_objcnt[] = {
 	SCTP_DBG_OBJCNT_ENTRY(bind_addr),
 	SCTP_DBG_OBJCNT_ENTRY(bind_bucket),
 	SCTP_DBG_OBJCNT_ENTRY(addr),
-	SCTP_DBG_OBJCNT_ENTRY(ssnmap),
 	SCTP_DBG_OBJCNT_ENTRY(datamsg),
 	SCTP_DBG_OBJCNT_ENTRY(keys),
 };
diff --git a/net/sctp/ssnmap.c b/net/sctp/ssnmap.c
deleted file mode 100644
index b9c8521..0000000
--- a/net/sctp/ssnmap.c
+++ /dev/null
@@ -1,125 +0,0 @@
-/* SCTP kernel implementation
- * Copyright (c) 2003 International Business Machines, Corp.
- *
- * This file is part of the SCTP kernel implementation
- *
- * These functions manipulate sctp SSN tracker.
- *
- * This SCTP implementation is free software;
- * you can redistribute it and/or modify it under the terms of
- * the GNU General Public License as published by
- * the Free Software Foundation; either version 2, or (at your option)
- * any later version.
- *
- * This SCTP implementation is distributed in the hope that it
- * will be useful, but WITHOUT ANY WARRANTY; without even the implied
- *                 ************************
- * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
- * See the GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, see
- * <http://www.gnu.org/licenses/>.
- *
- * Please send any bug reports or fixes you make to the
- * email address(es):
- *    lksctp developers <linux-sctp@vger.kernel.org>
- *
- * Written or modified by:
- *    Jon Grimm             <jgrimm@us.ibm.com>
- */
-
-#include <linux/types.h>
-#include <linux/slab.h>
-#include <net/sctp/sctp.h>
-#include <net/sctp/sm.h>
-
-static struct sctp_ssnmap *sctp_ssnmap_init(struct sctp_ssnmap *map, __u16 in,
-					    __u16 out);
-
-/* Storage size needed for map includes 2 headers and then the
- * specific needs of in or out streams.
- */
-static inline size_t sctp_ssnmap_size(__u16 in, __u16 out)
-{
-	return sizeof(struct sctp_ssnmap) + (in + out) * sizeof(__u16);
-}
-
-
-/* Create a new sctp_ssnmap.
- * Allocate room to store at least 'len' contiguous TSNs.
- */
-struct sctp_ssnmap *sctp_ssnmap_new(__u16 in, __u16 out,
-				    gfp_t gfp)
-{
-	struct sctp_ssnmap *retval;
-	int size;
-
-	size = sctp_ssnmap_size(in, out);
-	if (size <= KMALLOC_MAX_SIZE)
-		retval = kmalloc(size, gfp);
-	else
-		retval = (struct sctp_ssnmap *)
-			  __get_free_pages(gfp, get_order(size));
-	if (!retval)
-		goto fail;
-
-	if (!sctp_ssnmap_init(retval, in, out))
-		goto fail_map;
-
-	SCTP_DBG_OBJCNT_INC(ssnmap);
-
-	return retval;
-
-fail_map:
-	if (size <= KMALLOC_MAX_SIZE)
-		kfree(retval);
-	else
-		free_pages((unsigned long)retval, get_order(size));
-fail:
-	return NULL;
-}
-
-
-/* Initialize a block of memory as a ssnmap.  */
-static struct sctp_ssnmap *sctp_ssnmap_init(struct sctp_ssnmap *map, __u16 in,
-					    __u16 out)
-{
-	memset(map, 0x00, sctp_ssnmap_size(in, out));
-
-	/* Start 'in' stream just after the map header. */
-	map->in.ssn = (__u16 *)&map[1];
-	map->in.len = in;
-
-	/* Start 'out' stream just after 'in'. */
-	map->out.ssn = &map->in.ssn[in];
-	map->out.len = out;
-
-	return map;
-}
-
-/* Clear out the ssnmap streams.  */
-void sctp_ssnmap_clear(struct sctp_ssnmap *map)
-{
-	size_t size;
-
-	size = (map->in.len + map->out.len) * sizeof(__u16);
-	memset(map->in.ssn, 0x00, size);
-}
-
-/* Dispose of a ssnmap.  */
-void sctp_ssnmap_free(struct sctp_ssnmap *map)
-{
-	int size;
-
-	if (unlikely(!map))
-		return;
-
-	size = sctp_ssnmap_size(map->in.len, map->out.len);
-	if (size <= KMALLOC_MAX_SIZE)
-		kfree(map);
-	else
-		free_pages((unsigned long)map, get_order(size));
-
-	SCTP_DBG_OBJCNT_DEC(ssnmap);
-}
-- 
2.1.0
