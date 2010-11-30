From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/11] tipc: Remove obsolete native API files and exports
Date: Tue, 30 Nov 2010 17:00:53 -0500
Message-ID: <1291154463-26346-2-git-send-email-paul.gortmaker@windriver.com>
References: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58694 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab0K3WBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:01:09 -0500
In-Reply-To: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

As part of the removal of TIPC's native API support it is no longer
necessary for TIPC to export symbols for routines that can be called
by kernel-based applications, nor for it to have header files that
kernel-based applications can include to access the declarations for
those routines. This commit eliminates the exporting of symbols by
TIPC and migrates the contents of each obsolete native API include
file into its corresponding non-native API equivalent.

The code which was migrated in this commit was migrated intact, in
that there are no technical changes combined with the relocation.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/net/tipc/tipc.h        |  186 ------------------------------------
 include/net/tipc/tipc_bearer.h |  138 --------------------------
 include/net/tipc/tipc_msg.h    |  207 ----------------------------------------
 include/net/tipc/tipc_port.h   |  101 -------------------
 net/tipc/bcast.c               |    1 +
 net/tipc/bearer.h              |   69 +++++++++++++-
 net/tipc/config.c              |    2 +-
 net/tipc/core.c                |   40 --------
 net/tipc/core.h                |   14 ++-
 net/tipc/eth_media.c           |    6 +-
 net/tipc/msg.h                 |  168 +++++++++++++++++++++++++++++++--
 net/tipc/port.h                |  131 +++++++++++++++++++++++++
 net/tipc/socket.c              |    3 +-
 net/tipc/subscr.c              |    1 +
 net/tipc/user_reg.h            |    5 +
 15 files changed, 382 insertions(+), 690 deletions(-)
 delete mode 100644 include/net/tipc/tipc.h
 delete mode 100644 include/net/tipc/tipc_bearer.h
 delete mode 100644 include/net/tipc/tipc_msg.h
 delete mode 100644 include/net/tipc/tipc_port.h

diff --git a/include/net/tipc/tipc.h b/include/net/tipc/tipc.h
deleted file mode 100644
index 1e0645e..0000000
--- a/include/net/tipc/tipc.h
+++ /dev/null
@@ -1,186 +0,0 @@
-/*
- * include/net/tipc/tipc.h: Main include file for TIPC users
- * 
- * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005,2010 Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#ifndef _NET_TIPC_H_
-#define _NET_TIPC_H_
-
-#ifdef __KERNEL__
-
-#include <linux/tipc.h>
-#include <linux/skbuff.h>
-
-/* 
- * Native API
- */
-
-/*
- * TIPC operating mode routines
- */
-
-#define TIPC_NOT_RUNNING  0
-#define TIPC_NODE_MODE    1
-#define TIPC_NET_MODE     2
-
-typedef void (*tipc_mode_event)(void *usr_handle, int mode, u32 addr);
-
-int tipc_attach(unsigned int *userref, tipc_mode_event, void *usr_handle);
-
-void tipc_detach(unsigned int userref);
-
-/*
- * TIPC port manipulation routines
- */
-
-typedef void (*tipc_msg_err_event) (void *usr_handle,
-				    u32 portref,
-				    struct sk_buff **buf,
-				    unsigned char const *data,
-				    unsigned int size,
-				    int reason, 
-				    struct tipc_portid const *attmpt_destid);
-
-typedef void (*tipc_named_msg_err_event) (void *usr_handle,
-					  u32 portref,
-					  struct sk_buff **buf,
-					  unsigned char const *data,
-					  unsigned int size,
-					  int reason, 
-					  struct tipc_name_seq const *attmpt_dest);
-
-typedef void (*tipc_conn_shutdown_event) (void *usr_handle,
-					  u32 portref,
-					  struct sk_buff **buf,
-					  unsigned char const *data,
-					  unsigned int size,
-					  int reason);
-
-typedef void (*tipc_msg_event) (void *usr_handle,
-				u32 portref,
-				struct sk_buff **buf,
-				unsigned char const *data,
-				unsigned int size,
-				unsigned int importance, 
-				struct tipc_portid const *origin);
-
-typedef void (*tipc_named_msg_event) (void *usr_handle,
-				      u32 portref,
-				      struct sk_buff **buf,
-				      unsigned char const *data,
-				      unsigned int size,
-				      unsigned int importance, 
-				      struct tipc_portid const *orig,
-				      struct tipc_name_seq const *dest);
-
-typedef void (*tipc_conn_msg_event) (void *usr_handle,
-				     u32 portref,
-				     struct sk_buff **buf,
-				     unsigned char const *data,
-				     unsigned int size);
-
-typedef void (*tipc_continue_event) (void *usr_handle, 
-				     u32 portref);
-
-int tipc_createport(unsigned int tipc_user, 
-		    void *usr_handle, 
-		    unsigned int importance, 
-		    tipc_msg_err_event error_cb, 
-		    tipc_named_msg_err_event named_error_cb, 
-		    tipc_conn_shutdown_event conn_error_cb, 
-		    tipc_msg_event message_cb, 
-		    tipc_named_msg_event named_message_cb, 
-		    tipc_conn_msg_event conn_message_cb, 
-		    tipc_continue_event continue_event_cb,
-		    u32 *portref);
-
-int tipc_deleteport(u32 portref);
-
-int tipc_ownidentity(u32 portref, struct tipc_portid *port);
-
-int tipc_portimportance(u32 portref, unsigned int *importance);
-int tipc_set_portimportance(u32 portref, unsigned int importance);
-
-int tipc_portunreliable(u32 portref, unsigned int *isunreliable);
-int tipc_set_portunreliable(u32 portref, unsigned int isunreliable);
-
-int tipc_portunreturnable(u32 portref, unsigned int *isunreturnable);
-int tipc_set_portunreturnable(u32 portref, unsigned int isunreturnable);
-
-int tipc_publish(u32 portref, unsigned int scope, 
-		 struct tipc_name_seq const *name_seq);
-int tipc_withdraw(u32 portref, unsigned int scope,
-		  struct tipc_name_seq const *name_seq);
-
-int tipc_connect2port(u32 portref, struct tipc_portid const *port);
-
-int tipc_disconnect(u32 portref);
-
-int tipc_shutdown(u32 ref);
-
-/*
- * TIPC messaging routines
- */
-
-#define TIPC_PORT_IMPORTANCE 100	/* send using current port setting */
-
-
-int tipc_send(u32 portref,
-	      unsigned int num_sect,
-	      struct iovec const *msg_sect);
-
-int tipc_send2name(u32 portref, 
-		   struct tipc_name const *name, 
-		   u32 domain,
-		   unsigned int num_sect,
-		   struct iovec const *msg_sect);
-
-int tipc_send2port(u32 portref,
-		   struct tipc_portid const *dest,
-		   unsigned int num_sect,
-		   struct iovec const *msg_sect);
-
-int tipc_send_buf2port(u32 portref,
-		       struct tipc_portid const *dest,
-		       struct sk_buff *buf,
-		       unsigned int dsz);
-
-int tipc_multicast(u32 portref, 
-		   struct tipc_name_seq const *seq, 
-		   u32 domain,	/* currently unused */
-		   unsigned int section_count,
-		   struct iovec const *msg);
-#endif
-
-#endif
diff --git a/include/net/tipc/tipc_bearer.h b/include/net/tipc/tipc_bearer.h
deleted file mode 100644
index ee2f304..0000000
--- a/include/net/tipc/tipc_bearer.h
+++ /dev/null
@@ -1,138 +0,0 @@
-/*
- * include/net/tipc/tipc_bearer.h: Include file for privileged access to TIPC bearers
- * 
- * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#ifndef _NET_TIPC_BEARER_H_
-#define _NET_TIPC_BEARER_H_
-
-#ifdef __KERNEL__
-
-#include <linux/tipc_config.h>
-#include <linux/skbuff.h>
-#include <linux/spinlock.h>
-
-/*
- * Identifiers of supported TIPC media types
- */
-
-#define TIPC_MEDIA_TYPE_ETH	1
-
-/* 
- * Destination address structure used by TIPC bearers when sending messages
- * 
- * IMPORTANT: The fields of this structure MUST be stored using the specified
- * byte order indicated below, as the structure is exchanged between nodes
- * as part of a link setup process.
- */
-
-struct tipc_media_addr {
-	__be32  type;			/* bearer type (network byte order) */
-	union {
-		__u8   eth_addr[6];	/* 48 bit Ethernet addr (byte array) */ 
-#if 0
-		/* Prototypes for other possible bearer types */
-
-		struct {
-			__u16 sin_family;
-			__u16 sin_port;
-			struct {
-				__u32 s_addr;
-			} sin_addr;
-			char pad[4];
-		} addr_in;		/* IP-based bearer */
-		__u16  sock_descr;	/* generic socket bearer */
-#endif
-	} dev_addr;
-};
-
-/**
- * struct tipc_bearer - TIPC bearer info available to privileged users
- * @usr_handle: pointer to additional user-defined information about bearer
- * @mtu: max packet size bearer can support
- * @blocked: non-zero if bearer is blocked
- * @lock: spinlock for controlling access to bearer
- * @addr: media-specific address associated with bearer
- * @name: bearer name (format = media:interface)
- * 
- * Note: TIPC initializes "name" and "lock" fields; user is responsible for
- * initialization all other fields when a bearer is enabled.
- */
-
-struct tipc_bearer {
-	void *usr_handle;
-	u32 mtu;
-	int blocked;
-	spinlock_t lock;
-	struct tipc_media_addr addr;
-	char name[TIPC_MAX_BEARER_NAME];
-};
-
-/*
- * TIPC routines available to supported media types
- */
-
-int  tipc_register_media(u32 media_type,
-			 char *media_name, 
-			 int (*enable)(struct tipc_bearer *), 
-			 void (*disable)(struct tipc_bearer *), 
-			 int (*send_msg)(struct sk_buff *, 
-					 struct tipc_bearer *,
-					 struct tipc_media_addr *), 
-			 char *(*addr2str)(struct tipc_media_addr *a,
-					   char *str_buf,
-					   int str_size),
-			 struct tipc_media_addr *bcast_addr,
-			 const u32 bearer_priority,
-			 const u32 link_tolerance,  /* [ms] */
-			 const u32 send_window_limit); 
-
-void tipc_recv_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr);
-
-int  tipc_block_bearer(const char *name);
-void tipc_continue(struct tipc_bearer *tb_ptr); 
-
-int tipc_enable_bearer(const char *bearer_name, u32 bcast_scope, u32 priority);
-int tipc_disable_bearer(const char *name);
-
-/*
- * Routines made available to TIPC by supported media types
- */
-
-int  tipc_eth_media_start(void);
-void tipc_eth_media_stop(void);
-
-#endif
-
-#endif
diff --git a/include/net/tipc/tipc_msg.h b/include/net/tipc/tipc_msg.h
deleted file mode 100644
index ffe50b4..0000000
--- a/include/net/tipc/tipc_msg.h
+++ /dev/null
@@ -1,207 +0,0 @@
-/*
- * include/net/tipc/tipc_msg.h: Include file for privileged access to TIPC message headers
- * 
- * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#ifndef _NET_TIPC_MSG_H_
-#define _NET_TIPC_MSG_H_
-
-#ifdef __KERNEL__
-
-struct tipc_msg {
-	__be32 hdr[15];
-};
-
-
-/*
-		TIPC user data message header format, version 2:
-
-
-       1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0 
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w0:|vers | user  |hdr sz |n|d|s|-|          message size           |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w1:|mstyp| error |rer cnt|lsc|opt p|      broadcast ack no         |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w2:|        link level ack no      |   broadcast/link level seq no |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w3:|                       previous node                           |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w4:|                      originating port                         |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w5:|                      destination port                         |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+    
-   w6:|                      originating node                         |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w7:|                      destination node                         |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w8:|            name type / transport sequence number              |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w9:|              name instance/multicast lower bound              |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+    
-   wA:|                    multicast upper bound                      |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+    
-      /                                                               /
-      \                           options                             \
-      /                                                               /
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-
-*/
-
-#define TIPC_CONN_MSG	0
-#define TIPC_MCAST_MSG	1
-#define TIPC_NAMED_MSG	2
-#define TIPC_DIRECT_MSG	3
-
-
-static inline u32 msg_word(struct tipc_msg *m, u32 pos)
-{
-	return ntohl(m->hdr[pos]);
-}
-
-static inline u32 msg_bits(struct tipc_msg *m, u32 w, u32 pos, u32 mask)
-{
-	return (msg_word(m, w) >> pos) & mask;
-}
-
-static inline u32 msg_importance(struct tipc_msg *m)
-{
-	return msg_bits(m, 0, 25, 0xf);
-}
-
-static inline u32 msg_hdr_sz(struct tipc_msg *m)
-{
-	return msg_bits(m, 0, 21, 0xf) << 2;
-}
-
-static inline int msg_short(struct tipc_msg *m)
-{
-	return msg_hdr_sz(m) == 24;
-}
-
-static inline u32 msg_size(struct tipc_msg *m)
-{
-	return msg_bits(m, 0, 0, 0x1ffff);
-}
-
-static inline u32 msg_data_sz(struct tipc_msg *m)
-{
-	return msg_size(m) - msg_hdr_sz(m);
-}
-
-static inline unchar *msg_data(struct tipc_msg *m)
-{
-	return ((unchar *)m) + msg_hdr_sz(m);
-}
-
-static inline u32 msg_type(struct tipc_msg *m)
-{
-	return msg_bits(m, 1, 29, 0x7);
-}
-
-static inline u32 msg_named(struct tipc_msg *m)
-{
-	return msg_type(m) == TIPC_NAMED_MSG;
-}
-
-static inline u32 msg_mcast(struct tipc_msg *m)
-{
-	return msg_type(m) == TIPC_MCAST_MSG;
-}
-
-static inline u32 msg_connected(struct tipc_msg *m)
-{
-	return msg_type(m) == TIPC_CONN_MSG;
-}
-
-static inline u32 msg_errcode(struct tipc_msg *m)
-{
-	return msg_bits(m, 1, 25, 0xf);
-}
-
-static inline u32 msg_prevnode(struct tipc_msg *m)
-{
-	return msg_word(m, 3);
-}
-
-static inline u32 msg_origport(struct tipc_msg *m)
-{
-	return msg_word(m, 4);
-}
-
-static inline u32 msg_destport(struct tipc_msg *m)
-{
-	return msg_word(m, 5);
-}
-
-static inline u32 msg_mc_netid(struct tipc_msg *m)
-{
-	return msg_word(m, 5);
-}
-
-static inline u32 msg_orignode(struct tipc_msg *m)
-{
-	if (likely(msg_short(m)))
-		return msg_prevnode(m);
-	return msg_word(m, 6);
-}
-
-static inline u32 msg_destnode(struct tipc_msg *m)
-{
-	return msg_word(m, 7);
-}
-
-static inline u32 msg_nametype(struct tipc_msg *m)
-{
-	return msg_word(m, 8);
-}
-
-static inline u32 msg_nameinst(struct tipc_msg *m)
-{
-	return msg_word(m, 9);
-}
-
-static inline u32 msg_namelower(struct tipc_msg *m)
-{
-	return msg_nameinst(m);
-}
-
-static inline u32 msg_nameupper(struct tipc_msg *m)
-{
-	return msg_word(m, 10);
-}
-
-#endif
-
-#endif
diff --git a/include/net/tipc/tipc_port.h b/include/net/tipc/tipc_port.h
deleted file mode 100644
index 1893aaf..0000000
--- a/include/net/tipc/tipc_port.h
+++ /dev/null
@@ -1,101 +0,0 @@
-/*
- * include/net/tipc/tipc_port.h: Include file for privileged access to TIPC ports
- * 
- * Copyright (c) 1994-2007, Ericsson AB
- * Copyright (c) 2005-2008, Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#ifndef _NET_TIPC_PORT_H_
-#define _NET_TIPC_PORT_H_
-
-#ifdef __KERNEL__
-
-#include <linux/tipc.h>
-#include <linux/skbuff.h>
-#include <net/tipc/tipc_msg.h>
-
-#define TIPC_FLOW_CONTROL_WIN 512
-
-/**
- * struct tipc_port - native TIPC port info available to privileged users
- * @usr_handle: pointer to additional user-defined information about port
- * @lock: pointer to spinlock for controlling access to port
- * @connected: non-zero if port is currently connected to a peer port
- * @conn_type: TIPC type used when connection was established
- * @conn_instance: TIPC instance used when connection was established
- * @conn_unacked: number of unacknowledged messages received from peer port
- * @published: non-zero if port has one or more associated names
- * @congested: non-zero if cannot send because of link or port congestion
- * @max_pkt: maximum packet size "hint" used when building messages sent by port
- * @ref: unique reference to port in TIPC object registry
- * @phdr: preformatted message header used when sending messages
- */
-
-struct tipc_port {
-        void *usr_handle;
-        spinlock_t *lock;
-	int connected;
-        u32 conn_type;
-        u32 conn_instance;
-	u32 conn_unacked;
-	int published;
-	u32 congested;
-	u32 max_pkt;
-	u32 ref;
-	struct tipc_msg phdr;
-};
-
-
-struct tipc_port *tipc_createport_raw(void *usr_handle,
-			u32 (*dispatcher)(struct tipc_port *, struct sk_buff *),
-			void (*wakeup)(struct tipc_port *),
-			const u32 importance);
-
-int tipc_reject_msg(struct sk_buff *buf, u32 err);
-
-int tipc_send_buf_fast(struct sk_buff *buf, u32 destnode);
-
-void tipc_acknowledge(u32 port_ref,u32 ack);
-
-struct tipc_port *tipc_get_port(const u32 ref);
-
-/*
- * The following routines require that the port be locked on entry
- */
-
-int tipc_disconnect_port(struct tipc_port *tp_ptr);
-
-
-#endif
-
-#endif
-
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 22a60fc..7d449f0 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -47,6 +47,7 @@
 #include "name_distr.h"
 #include "bearer.h"
 #include "name_table.h"
+#include "port.h"
 #include "bcast.h"
 
 #define MAX_PKT_DEFAULT_MCAST 1500	/* bcast link max packet size (fixed) */
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index a850b38..49af7fa 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -43,6 +43,45 @@
 #define MAX_BEARERS 8
 #define MAX_MEDIA 4
 
+/*
+ * Identifiers of supported TIPC media types
+ */
+#define TIPC_MEDIA_TYPE_ETH	1
+
+/*
+ * Destination address structure used by TIPC bearers when sending messages
+ *
+ * IMPORTANT: The fields of this structure MUST be stored using the specified
+ * byte order indicated below, as the structure is exchanged between nodes
+ * as part of a link setup process.
+ */
+struct tipc_media_addr {
+	__be32  type;			/* bearer type (network byte order) */
+	union {
+		__u8   eth_addr[6];	/* 48 bit Ethernet addr (byte array) */
+	} dev_addr;
+};
+
+/**
+ * struct tipc_bearer - TIPC bearer info available to media code
+ * @usr_handle: pointer to additional media-specific information about bearer
+ * @mtu: max packet size bearer can support
+ * @blocked: non-zero if bearer is blocked
+ * @lock: spinlock for controlling access to bearer
+ * @addr: media-specific address associated with bearer
+ * @name: bearer name (format = media:interface)
+ *
+ * Note: TIPC initializes "name" and "lock" fields; media code is responsible
+ * for initialization all other fields when a bearer is enabled.
+ */
+struct tipc_bearer {
+	void *usr_handle;
+	u32 mtu;
+	int blocked;
+	spinlock_t lock;
+	struct tipc_media_addr addr;
+	char name[TIPC_MAX_BEARER_NAME];
+};
 
 /**
  * struct media - TIPC media information available to internal users
@@ -55,7 +94,7 @@
  * @priority: default link (and bearer) priority
  * @tolerance: default time (in ms) before declaring link failure
  * @window: default window (in packets) before declaring link congestion
- * @type_id: TIPC media identifier [defined in tipc_bearer.h]
+ * @type_id: TIPC media identifier
  * @name: media name
  */
 
@@ -116,6 +155,34 @@ struct link;
 
 extern struct bearer tipc_bearers[];
 
+/*
+ * TIPC routines available to supported media types
+ */
+int tipc_register_media(u32 media_type,
+		 char *media_name, int (*enable)(struct tipc_bearer *),
+		 void (*disable)(struct tipc_bearer *),
+		 int (*send_msg)(struct sk_buff *,
+			struct tipc_bearer *, struct tipc_media_addr *),
+		 char *(*addr2str)(struct tipc_media_addr *a,
+			char *str_buf, int str_size),
+		 struct tipc_media_addr *bcast_addr, const u32 bearer_priority,
+		 const u32 link_tolerance,  /* [ms] */
+		 const u32 send_window_limit);
+
+void tipc_recv_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr);
+
+int  tipc_block_bearer(const char *name);
+void tipc_continue(struct tipc_bearer *tb_ptr);
+
+int tipc_enable_bearer(const char *bearer_name, u32 bcast_scope, u32 priority);
+int tipc_disable_bearer(const char *name);
+
+/*
+ * Routines made available to TIPC by supported media types
+ */
+int  tipc_eth_media_start(void);
+void tipc_eth_media_stop(void);
+
 void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a);
 struct sk_buff *tipc_media_get_names(void);
 
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 50a6133..82267f3 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -43,8 +43,8 @@
 #include "addr.h"
 #include "name_table.h"
 #include "node.h"
+#include "user_reg.h"
 #include "config.h"
-#include "discover.h"
 
 struct subscr_data {
 	char usr_handle[8];
diff --git a/net/tipc/core.c b/net/tipc/core.c
index e2a09eb..785362f 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -236,43 +236,3 @@ module_exit(tipc_exit);
 MODULE_DESCRIPTION("TIPC: Transparent Inter Process Communication");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(TIPC_MOD_VER);
-
-/* Native TIPC API for kernel-space applications (see tipc.h) */
-
-EXPORT_SYMBOL(tipc_attach);
-EXPORT_SYMBOL(tipc_detach);
-EXPORT_SYMBOL(tipc_createport);
-EXPORT_SYMBOL(tipc_deleteport);
-EXPORT_SYMBOL(tipc_ownidentity);
-EXPORT_SYMBOL(tipc_portimportance);
-EXPORT_SYMBOL(tipc_set_portimportance);
-EXPORT_SYMBOL(tipc_portunreliable);
-EXPORT_SYMBOL(tipc_set_portunreliable);
-EXPORT_SYMBOL(tipc_portunreturnable);
-EXPORT_SYMBOL(tipc_set_portunreturnable);
-EXPORT_SYMBOL(tipc_publish);
-EXPORT_SYMBOL(tipc_withdraw);
-EXPORT_SYMBOL(tipc_connect2port);
-EXPORT_SYMBOL(tipc_disconnect);
-EXPORT_SYMBOL(tipc_shutdown);
-EXPORT_SYMBOL(tipc_send);
-EXPORT_SYMBOL(tipc_send2name);
-EXPORT_SYMBOL(tipc_send2port);
-EXPORT_SYMBOL(tipc_multicast);
-
-/* TIPC API for external bearers (see tipc_bearer.h) */
-
-EXPORT_SYMBOL(tipc_block_bearer);
-EXPORT_SYMBOL(tipc_continue);
-EXPORT_SYMBOL(tipc_disable_bearer);
-EXPORT_SYMBOL(tipc_enable_bearer);
-EXPORT_SYMBOL(tipc_recv_msg);
-EXPORT_SYMBOL(tipc_register_media);
-
-/* TIPC API for external APIs (see tipc_port.h) */
-
-EXPORT_SYMBOL(tipc_createport_raw);
-EXPORT_SYMBOL(tipc_reject_msg);
-EXPORT_SYMBOL(tipc_send_buf_fast);
-EXPORT_SYMBOL(tipc_acknowledge);
-
diff --git a/net/tipc/core.h b/net/tipc/core.h
index e19389e..ca7e171 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -39,10 +39,6 @@
 
 #include <linux/tipc.h>
 #include <linux/tipc_config.h>
-#include <net/tipc/tipc_msg.h>
-#include <net/tipc/tipc_port.h>
-#include <net/tipc/tipc_bearer.h>
-#include <net/tipc/tipc.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
@@ -62,6 +58,9 @@
 
 #define TIPC_MOD_VER "2.0.0"
 
+struct tipc_msg;	/* msg.h */
+struct print_buf;	/* dbg.h */
+
 /*
  * TIPC sanity test macros
  */
@@ -174,6 +173,13 @@ void tipc_dump_dbg(struct print_buf *, const char *fmt, ...);
 #define ELINKCONG EAGAIN	/* link congestion <=> resource unavailable */
 
 /*
+ * TIPC operating mode routines
+ */
+#define TIPC_NOT_RUNNING  0
+#define TIPC_NODE_MODE    1
+#define TIPC_NET_MODE     2
+
+/*
  * Global configuration variables
  */
 
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 6e988ba..ee683cc 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -34,13 +34,13 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include <net/tipc/tipc.h>
-#include <net/tipc/tipc_bearer.h>
-#include <net/tipc/tipc_msg.h>
 #include <linux/netdevice.h>
 #include <linux/slab.h>
 #include <net/net_namespace.h>
 
+#include "core.h"
+#include "bearer.h"
+
 #define MAX_ETH_BEARERS		2
 #define ETH_LINK_PRIORITY	TIPC_DEF_LINK_PRI
 #define ETH_LINK_TOLERANCE	TIPC_DEF_LINK_TOL
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 031aad1..aee5386 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -37,10 +37,51 @@
 #ifndef _TIPC_MSG_H
 #define _TIPC_MSG_H
 
-#include "core.h"
+#include "bearer.h"
 
 #define TIPC_VERSION              2
 
+/*
+ *		TIPC user data message header format, version 2:
+ *
+ *
+ *     1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * w0:|vers | user  |hdr sz |n|d|s|-|          message size           |
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * w1:|mstyp| error |rer cnt|lsc|opt p|      broadcast ack no         |
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * w2:|        link level ack no      |   broadcast/link level seq no |
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * w3:|                       previous node                           |
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * w4:|                      originating port                         |
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * w5:|                      destination port                         |
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * w6:|                      originating node                         |
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * w7:|                      destination node                         |
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * w8:|            name type / transport sequence number              |
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * w9:|              name instance/multicast lower bound              |
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * wA:|                    multicast upper bound                      |
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *    /                                                               /
+ *    \                           options                             \
+ *    /                                                               /
+ *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ */
+
+#define TIPC_CONN_MSG		0
+#define TIPC_MCAST_MSG		1
+#define TIPC_NAMED_MSG		2
+#define TIPC_DIRECT_MSG		3
+
+
 #define SHORT_H_SIZE              24	/* Connected, in-cluster messages */
 #define DIR_MSG_H_SIZE            32	/* Directly addressed messages */
 #define LONG_H_SIZE               40	/* Named messages */
@@ -52,20 +93,26 @@
 #define MAX_MSG_SIZE (MAX_H_SIZE + TIPC_MAX_USER_MSG_SIZE)
 
 
-/*
-		TIPC user data message header format, version 2
+struct tipc_msg {
+	__be32 hdr[15];
+};
 
-	- Fundamental definitions available to privileged TIPC users
-	  are located in tipc_msg.h.
-	- Remaining definitions available to TIPC internal users appear below.
-*/
 
+static inline u32 msg_word(struct tipc_msg *m, u32 pos)
+{
+	return ntohl(m->hdr[pos]);
+}
 
 static inline void msg_set_word(struct tipc_msg *m, u32 w, u32 val)
 {
 	m->hdr[w] = htonl(val);
 }
 
+static inline u32 msg_bits(struct tipc_msg *m, u32 w, u32 pos, u32 mask)
+{
+	return (msg_word(m, w) >> pos) & mask;
+}
+
 static inline void msg_set_bits(struct tipc_msg *m, u32 w,
 				u32 pos, u32 mask, u32 val)
 {
@@ -112,16 +159,36 @@ static inline void msg_set_user(struct tipc_msg *m, u32 n)
 	msg_set_bits(m, 0, 25, 0xf, n);
 }
 
+static inline u32 msg_importance(struct tipc_msg *m)
+{
+	return msg_bits(m, 0, 25, 0xf);
+}
+
 static inline void msg_set_importance(struct tipc_msg *m, u32 i)
 {
 	msg_set_user(m, i);
 }
 
+static inline u32 msg_hdr_sz(struct tipc_msg *m)
+{
+	return msg_bits(m, 0, 21, 0xf) << 2;
+}
+
 static inline void msg_set_hdr_sz(struct tipc_msg *m,u32 n)
 {
 	msg_set_bits(m, 0, 21, 0xf, n>>2);
 }
 
+static inline u32 msg_size(struct tipc_msg *m)
+{
+	return msg_bits(m, 0, 0, 0x1ffff);
+}
+
+static inline u32 msg_data_sz(struct tipc_msg *m)
+{
+	return msg_size(m) - msg_hdr_sz(m);
+}
+
 static inline int msg_non_seq(struct tipc_msg *m)
 {
 	return msg_bits(m, 0, 20, 1);
@@ -162,11 +229,36 @@ static inline void msg_set_size(struct tipc_msg *m, u32 sz)
  * Word 1
  */
 
+static inline u32 msg_type(struct tipc_msg *m)
+{
+	return msg_bits(m, 1, 29, 0x7);
+}
+
 static inline void msg_set_type(struct tipc_msg *m, u32 n)
 {
 	msg_set_bits(m, 1, 29, 0x7, n);
 }
 
+static inline u32 msg_named(struct tipc_msg *m)
+{
+	return msg_type(m) == TIPC_NAMED_MSG;
+}
+
+static inline u32 msg_mcast(struct tipc_msg *m)
+{
+	return msg_type(m) == TIPC_MCAST_MSG;
+}
+
+static inline u32 msg_connected(struct tipc_msg *m)
+{
+	return msg_type(m) == TIPC_CONN_MSG;
+}
+
+static inline u32 msg_errcode(struct tipc_msg *m)
+{
+	return msg_bits(m, 1, 25, 0xf);
+}
+
 static inline void msg_set_errcode(struct tipc_msg *m, u32 err)
 {
 	msg_set_bits(m, 1, 25, 0xf, err);
@@ -257,31 +349,68 @@ static inline void msg_set_destnode_cache(struct tipc_msg *m, u32 dnode)
  */
 
 
+static inline u32 msg_prevnode(struct tipc_msg *m)
+{
+	return msg_word(m, 3);
+}
+
 static inline void msg_set_prevnode(struct tipc_msg *m, u32 a)
 {
 	msg_set_word(m, 3, a);
 }
 
+static inline u32 msg_origport(struct tipc_msg *m)
+{
+	return msg_word(m, 4);
+}
+
 static inline void msg_set_origport(struct tipc_msg *m, u32 p)
 {
 	msg_set_word(m, 4, p);
 }
 
+static inline u32 msg_destport(struct tipc_msg *m)
+{
+	return msg_word(m, 5);
+}
+
 static inline void msg_set_destport(struct tipc_msg *m, u32 p)
 {
 	msg_set_word(m, 5, p);
 }
 
+static inline u32 msg_mc_netid(struct tipc_msg *m)
+{
+	return msg_word(m, 5);
+}
+
 static inline void msg_set_mc_netid(struct tipc_msg *m, u32 p)
 {
 	msg_set_word(m, 5, p);
 }
 
+static inline int msg_short(struct tipc_msg *m)
+{
+	return msg_hdr_sz(m) == 24;
+}
+
+static inline u32 msg_orignode(struct tipc_msg *m)
+{
+	if (likely(msg_short(m)))
+		return msg_prevnode(m);
+	return msg_word(m, 6);
+}
+
 static inline void msg_set_orignode(struct tipc_msg *m, u32 a)
 {
 	msg_set_word(m, 6, a);
 }
 
+static inline u32 msg_destnode(struct tipc_msg *m)
+{
+	return msg_word(m, 7);
+}
+
 static inline void msg_set_destnode(struct tipc_msg *m, u32 a)
 {
 	msg_set_word(m, 7, a);
@@ -299,6 +428,11 @@ static inline u32 msg_routed(struct tipc_msg *m)
 	return(msg_destnode(m) ^ msg_orignode(m)) >> 11;
 }
 
+static inline u32 msg_nametype(struct tipc_msg *m)
+{
+	return msg_word(m, 8);
+}
+
 static inline void msg_set_nametype(struct tipc_msg *m, u32 n)
 {
 	msg_set_word(m, 8, n);
@@ -324,6 +458,16 @@ static inline void msg_set_transp_seqno(struct tipc_msg *m, u32 n)
 	msg_set_word(m, 8, n);
 }
 
+static inline u32 msg_nameinst(struct tipc_msg *m)
+{
+	return msg_word(m, 9);
+}
+
+static inline u32 msg_namelower(struct tipc_msg *m)
+{
+	return msg_nameinst(m);
+}
+
 static inline void msg_set_namelower(struct tipc_msg *m, u32 n)
 {
 	msg_set_word(m, 9, n);
@@ -334,11 +478,21 @@ static inline void msg_set_nameinst(struct tipc_msg *m, u32 n)
 	msg_set_namelower(m, n);
 }
 
+static inline u32 msg_nameupper(struct tipc_msg *m)
+{
+	return msg_word(m, 10);
+}
+
 static inline void msg_set_nameupper(struct tipc_msg *m, u32 n)
 {
 	msg_set_word(m, 10, n);
 }
 
+static inline unchar *msg_data(struct tipc_msg *m)
+{
+	return ((unchar *)m) + msg_hdr_sz(m);
+}
+
 static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 {
 	return (struct tipc_msg *)msg_data(m);
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 73bbf44..8b9d87a 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -44,6 +44,39 @@
 #include "dbg.h"
 #include "node_subscr.h"
 
+#define TIPC_FLOW_CONTROL_WIN 512
+
+typedef void (*tipc_msg_err_event) (void *usr_handle, u32 portref,
+		struct sk_buff **buf, unsigned char const *data,
+		unsigned int size, int reason,
+		struct tipc_portid const *attmpt_destid);
+
+typedef void (*tipc_named_msg_err_event) (void *usr_handle, u32 portref,
+		struct sk_buff **buf, unsigned char const *data,
+		unsigned int size, int reason,
+		struct tipc_name_seq const *attmpt_dest);
+
+typedef void (*tipc_conn_shutdown_event) (void *usr_handle, u32 portref,
+		struct sk_buff **buf, unsigned char const *data,
+		unsigned int size, int reason);
+
+typedef void (*tipc_msg_event) (void *usr_handle, u32 portref,
+		struct sk_buff **buf, unsigned char const *data,
+		unsigned int size, unsigned int importance,
+		struct tipc_portid const *origin);
+
+typedef void (*tipc_named_msg_event) (void *usr_handle, u32 portref,
+		struct sk_buff **buf, unsigned char const *data,
+		unsigned int size, unsigned int importance,
+		struct tipc_portid const *orig,
+		struct tipc_name_seq const *dest);
+
+typedef void (*tipc_conn_msg_event) (void *usr_handle, u32 portref,
+		struct sk_buff **buf, unsigned char const *data,
+		unsigned int size);
+
+typedef void (*tipc_continue_event) (void *usr_handle, u32 portref);
+
 /**
  * struct user_port - TIPC user port (used with native API)
  * @user_ref: id of user who created user port
@@ -68,6 +101,34 @@ struct user_port {
 };
 
 /**
+ * struct tipc_port - TIPC port info available to socket API
+ * @usr_handle: pointer to additional user-defined information about port
+ * @lock: pointer to spinlock for controlling access to port
+ * @connected: non-zero if port is currently connected to a peer port
+ * @conn_type: TIPC type used when connection was established
+ * @conn_instance: TIPC instance used when connection was established
+ * @conn_unacked: number of unacknowledged messages received from peer port
+ * @published: non-zero if port has one or more associated names
+ * @congested: non-zero if cannot send because of link or port congestion
+ * @max_pkt: maximum packet size "hint" used when building messages sent by port
+ * @ref: unique reference to port in TIPC object registry
+ * @phdr: preformatted message header used when sending messages
+ */
+struct tipc_port {
+	void *usr_handle;
+	spinlock_t *lock;
+	int connected;
+	u32 conn_type;
+	u32 conn_instance;
+	u32 conn_unacked;
+	int published;
+	u32 congested;
+	u32 max_pkt;
+	u32 ref;
+	struct tipc_msg phdr;
+};
+
+/**
  * struct port - TIPC port structure
  * @publ: TIPC port info available to privileged users
  * @port_list: adjacent ports in TIPC's global list of ports
@@ -109,6 +170,76 @@ struct port {
 extern spinlock_t tipc_port_list_lock;
 struct port_list;
 
+/*
+ * TIPC port manipulation routines
+ */
+struct tipc_port *tipc_createport_raw(void *usr_handle,
+		u32 (*dispatcher)(struct tipc_port *, struct sk_buff *),
+		void (*wakeup)(struct tipc_port *), const u32 importance);
+
+int tipc_reject_msg(struct sk_buff *buf, u32 err);
+
+int tipc_send_buf_fast(struct sk_buff *buf, u32 destnode);
+
+void tipc_acknowledge(u32 port_ref, u32 ack);
+
+int tipc_createport(unsigned int tipc_user, void *usr_handle,
+		unsigned int importance, tipc_msg_err_event error_cb,
+		tipc_named_msg_err_event named_error_cb,
+		tipc_conn_shutdown_event conn_error_cb, tipc_msg_event msg_cb,
+		tipc_named_msg_event named_msg_cb,
+		tipc_conn_msg_event conn_msg_cb,
+		tipc_continue_event continue_event_cb, u32 *portref);
+
+int tipc_deleteport(u32 portref);
+
+int tipc_ownidentity(u32 portref, struct tipc_portid *port);
+
+int tipc_portimportance(u32 portref, unsigned int *importance);
+int tipc_set_portimportance(u32 portref, unsigned int importance);
+
+int tipc_portunreliable(u32 portref, unsigned int *isunreliable);
+int tipc_set_portunreliable(u32 portref, unsigned int isunreliable);
+
+int tipc_portunreturnable(u32 portref, unsigned int *isunreturnable);
+int tipc_set_portunreturnable(u32 portref, unsigned int isunreturnable);
+
+int tipc_publish(u32 portref, unsigned int scope,
+		struct tipc_name_seq const *name_seq);
+int tipc_withdraw(u32 portref, unsigned int scope,
+		struct tipc_name_seq const *name_seq);
+
+int tipc_connect2port(u32 portref, struct tipc_portid const *port);
+
+int tipc_disconnect(u32 portref);
+
+int tipc_shutdown(u32 ref);
+
+
+/*
+ * The following routines require that the port be locked on entry
+ */
+int tipc_disconnect_port(struct tipc_port *tp_ptr);
+
+/*
+ * TIPC messaging routines
+ */
+#define TIPC_PORT_IMPORTANCE 100	/* send using current port setting */
+
+int tipc_send(u32 portref, unsigned int num_sect, struct iovec const *msg_sect);
+
+int tipc_send2name(u32 portref, struct tipc_name const *name, u32 domain,
+		unsigned int num_sect, struct iovec const *msg_sect);
+
+int tipc_send2port(u32 portref, struct tipc_portid const *dest,
+		unsigned int num_sect, struct iovec const *msg_sect);
+
+int tipc_send_buf2port(u32 portref, struct tipc_portid const *dest,
+		struct sk_buff *buf, unsigned int dsz);
+
+int tipc_multicast(u32 portref, struct tipc_name_seq const *seq, u32 domain,
+		unsigned int section_count, struct iovec const *msg);
+
 int tipc_port_reject_sections(struct port *p_ptr, struct tipc_msg *hdr,
 			      struct iovec const *msg_sect, u32 num_sect,
 			      int err);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e9f0d50..23a12e4 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -49,10 +49,9 @@
 
 #include <linux/tipc.h>
 #include <linux/tipc_config.h>
-#include <net/tipc/tipc_msg.h>
-#include <net/tipc/tipc_port.h>
 
 #include "core.h"
+#include "port.h"
 
 #define SS_LISTENING	-1	/* socket is listening */
 #define SS_READY	-2	/* socket is connectionless */
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 3331396..a857e6e 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -37,6 +37,7 @@
 #include "core.h"
 #include "dbg.h"
 #include "name_table.h"
+#include "user_reg.h"
 #include "port.h"
 #include "ref.h"
 #include "subscr.h"
diff --git a/net/tipc/user_reg.h b/net/tipc/user_reg.h
index 81dc12e..a05981f 100644
--- a/net/tipc/user_reg.h
+++ b/net/tipc/user_reg.h
@@ -42,6 +42,11 @@
 int tipc_reg_start(void);
 void tipc_reg_stop(void);
 
+typedef void (*tipc_mode_event)(void *usr_handle, int mode, u32 addr);
+
+int tipc_attach(unsigned int *userref, tipc_mode_event, void *usr_handle);
+void tipc_detach(unsigned int userref);
+
 int tipc_reg_add_port(struct user_port *up_ptr);
 int tipc_reg_remove_port(struct user_port *up_ptr);
 
-- 
1.7.3.2.146.g2d444

