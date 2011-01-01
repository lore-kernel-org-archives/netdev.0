From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/20] tipc: Remove user registry subsystem
Date: Fri, 31 Dec 2010 23:59:22 -0500
Message-ID: <1293857975-30267-8-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53284 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173Ab1AAFAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:04 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates routines, data structures, and files that make up TIPC's
user registry. The user registry is no longer needed since the native
API routines that utilized it no longer exist and there are no longer
any internal TIPC services that use it.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/Makefile   |    2 +-
 net/tipc/config.c   |    2 +-
 net/tipc/core.c     |    3 -
 net/tipc/port.c     |   11 +--
 net/tipc/port.h     |    6 +-
 net/tipc/subscr.c   |    6 +-
 net/tipc/user_reg.c |  218 ---------------------------------------------------
 net/tipc/user_reg.h |   51 ------------
 8 files changed, 7 insertions(+), 292 deletions(-)
 delete mode 100644 net/tipc/user_reg.c
 delete mode 100644 net/tipc/user_reg.h

diff --git a/net/tipc/Makefile b/net/tipc/Makefile
index 849d819..d41cd11 100644
--- a/net/tipc/Makefile
+++ b/net/tipc/Makefile
@@ -8,6 +8,6 @@ tipc-y	+= addr.o bcast.o bearer.o config.o \
 	   core.o handler.o link.o discover.o msg.o  \
 	   name_distr.o  subscr.o name_table.o net.o  \
 	   netlink.o node.o node_subscr.o port.o ref.o  \
-	   socket.o user_reg.o dbg.o eth_media.o
+	   socket.o dbg.o eth_media.o
 
 # End of file
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 322367b..afa6e85 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -500,7 +500,7 @@ int tipc_cfg_init(void)
 	struct tipc_name_seq seq;
 	int res;
 
-	res = tipc_createport(0, NULL, TIPC_CRITICAL_IMPORTANCE,
+	res = tipc_createport(NULL, TIPC_CRITICAL_IMPORTANCE,
 			      NULL, NULL, NULL,
 			      NULL, cfg_named_msg_event, NULL,
 			      NULL, &config_port_ref);
diff --git a/net/tipc/core.c b/net/tipc/core.c
index b9a3ef1..a02bc49 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -42,7 +42,6 @@
 #include "core.h"
 #include "ref.h"
 #include "net.h"
-#include "user_reg.h"
 #include "name_table.h"
 #include "subscr.h"
 #include "config.h"
@@ -144,7 +143,6 @@ static void tipc_core_stop(void)
 	tipc_handler_stop();
 	tipc_cfg_stop();
 	tipc_subscr_stop();
-	tipc_reg_stop();
 	tipc_nametbl_stop();
 	tipc_ref_table_stop();
 	tipc_socket_stop();
@@ -167,7 +165,6 @@ static int tipc_core_start(void)
 
 	if ((res = tipc_handler_start()) ||
 	    (res = tipc_ref_table_init(tipc_max_ports, tipc_random)) ||
-	    (res = tipc_reg_start()) ||
 	    (res = tipc_nametbl_init()) ||
 	    (res = tipc_k_signal((Handler)tipc_subscr_start, 0)) ||
 	    (res = tipc_k_signal((Handler)tipc_cfg_init, 0)) ||
diff --git a/net/tipc/port.c b/net/tipc/port.c
index c033cb8..33d0b3b 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -38,7 +38,6 @@
 #include "config.h"
 #include "port.h"
 #include "name_table.h"
-#include "user_reg.h"
 
 /* Connection management: */
 #define PROBING_INTERVAL 3600000	/* [ms] => 1 h */
@@ -272,7 +271,6 @@ int tipc_deleteport(u32 ref)
 		tipc_nodesub_unsubscribe(&p_ptr->subscription);
 	}
 	if (p_ptr->user_port) {
-		tipc_reg_remove_port(p_ptr->user_port);
 		kfree(p_ptr->user_port);
 	}
 
@@ -934,12 +932,10 @@ void tipc_acknowledge(u32 ref, u32 ack)
 }
 
 /*
- * tipc_createport(): user level call. Will add port to
- *                    registry if non-zero user_ref.
+ * tipc_createport(): user level call.
  */
 
-int tipc_createport(u32 user_ref,
-		    void *usr_handle,
+int tipc_createport(void *usr_handle,
 		    unsigned int importance,
 		    tipc_msg_err_event error_cb,
 		    tipc_named_msg_err_event named_error_cb,
@@ -966,7 +962,6 @@ int tipc_createport(u32 user_ref,
 	}
 
 	p_ptr->user_port = up_ptr;
-	up_ptr->user_ref = user_ref;
 	up_ptr->usr_handle = usr_handle;
 	up_ptr->ref = p_ptr->publ.ref;
 	up_ptr->err_cb = error_cb;
@@ -976,8 +971,6 @@ int tipc_createport(u32 user_ref,
 	up_ptr->named_msg_cb = named_msg_cb;
 	up_ptr->conn_msg_cb = conn_msg_cb;
 	up_ptr->continue_event_cb = continue_event_cb;
-	INIT_LIST_HEAD(&up_ptr->uport_list);
-	tipc_reg_add_port(up_ptr);
 	*portref = p_ptr->publ.ref;
 	tipc_port_unlock(p_ptr);
 	return 0;
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 3a807fc..da607a8 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -77,15 +77,12 @@ typedef void (*tipc_continue_event) (void *usr_handle, u32 portref);
 
 /**
  * struct user_port - TIPC user port (used with native API)
- * @user_ref: id of user who created user port
  * @usr_handle: user-specified field
  * @ref: object reference to associated TIPC port
  * <various callback routines>
- * @uport_list: adjacent user ports in list of ports held by user
  */
 
 struct user_port {
-	u32 user_ref;
 	void *usr_handle;
 	u32 ref;
 	tipc_msg_err_event err_cb;
@@ -95,7 +92,6 @@ struct user_port {
 	tipc_named_msg_event named_msg_cb;
 	tipc_conn_msg_event conn_msg_cb;
 	tipc_continue_event continue_event_cb;
-	struct list_head uport_list;
 };
 
 /**
@@ -181,7 +177,7 @@ int tipc_send_buf_fast(struct sk_buff *buf, u32 destnode);
 
 void tipc_acknowledge(u32 port_ref, u32 ack);
 
-int tipc_createport(unsigned int tipc_user, void *usr_handle,
+int tipc_createport(void *usr_handle,
 		unsigned int importance, tipc_msg_err_event error_cb,
 		tipc_named_msg_err_event named_error_cb,
 		tipc_conn_shutdown_event conn_error_cb, tipc_msg_event msg_cb,
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 21abf17..c5ba323 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -493,8 +493,7 @@ static void subscr_named_msg_event(void *usr_handle,
 
 	/* Create server port & establish connection to subscriber */
 
-	tipc_createport(0,
-			subscriber,
+	tipc_createport(subscriber,
 			importance,
 			NULL,
 			NULL,
@@ -548,8 +547,7 @@ int tipc_subscr_start(void)
 	INIT_LIST_HEAD(&topsrv.subscriber_list);
 
 	spin_lock_bh(&topsrv.lock);
-	res = tipc_createport(0,
-			      NULL,
+	res = tipc_createport(NULL,
 			      TIPC_CRITICAL_IMPORTANCE,
 			      NULL,
 			      NULL,
diff --git a/net/tipc/user_reg.c b/net/tipc/user_reg.c
deleted file mode 100644
index 2e2702e..0000000
--- a/net/tipc/user_reg.c
+++ /dev/null
@@ -1,218 +0,0 @@
-/*
- * net/tipc/user_reg.c: TIPC user registry code
- *
- * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2004-2005, Wind River Systems
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
-#include "core.h"
-#include "user_reg.h"
-
-/*
- * TIPC user registry keeps track of users of the tipc_port interface.
- *
- * The registry utilizes an array of "TIPC user" entries;
- * a user's ID is the index of their associated array entry.
- * Array entry 0 is not used, so userid 0 is not valid;
- * TIPC sometimes uses this value to denote an anonymous user.
- * The list of free entries is initially chained from last entry to entry 1.
- */
-
-/**
- * struct tipc_user - registered TIPC user info
- * @next: index of next free registry entry (or -1 for an allocated entry)
- * @ports: list of user ports owned by the user
- */
-
-struct tipc_user {
-	int next;
-	struct list_head ports;
-};
-
-#define MAX_USERID 64
-#define USER_LIST_SIZE ((MAX_USERID + 1) * sizeof(struct tipc_user))
-
-static struct tipc_user *users = NULL;
-static u32 next_free_user = MAX_USERID + 1;
-static DEFINE_SPINLOCK(reg_lock);
-
-/**
- * reg_init - create TIPC user registry (but don't activate it)
- *
- * If registry has been pre-initialized it is left "as is".
- * NOTE: This routine may be called when TIPC is inactive.
- */
-
-static int reg_init(void)
-{
-	u32 i;
-
-	spin_lock_bh(&reg_lock);
-	if (!users) {
-		users = kzalloc(USER_LIST_SIZE, GFP_ATOMIC);
-		if (users) {
-			for (i = 1; i <= MAX_USERID; i++) {
-				users[i].next = i - 1;
-			}
-			next_free_user = MAX_USERID;
-		}
-	}
-	spin_unlock_bh(&reg_lock);
-	return users ? 0 : -ENOMEM;
-}
-
-/**
- * tipc_reg_start - activate TIPC user registry
- */
-
-int tipc_reg_start(void)
-{
-	return reg_init();
-}
-
-/**
- * tipc_reg_stop - shut down & delete TIPC user registry
- */
-
-void tipc_reg_stop(void)
-{
-	if (!users)
-		return;
-
-	kfree(users);
-	users = NULL;
-}
-
-/**
- * tipc_attach - register a TIPC user
- *
- * NOTE: This routine may be called when TIPC is inactive.
- */
-
-int tipc_attach(u32 *userid)
-{
-	struct tipc_user *user_ptr;
-
-	if (!users)
-		reg_init();
-
-	spin_lock_bh(&reg_lock);
-	if (!next_free_user) {
-		spin_unlock_bh(&reg_lock);
-		return -EBUSY;
-	}
-	user_ptr = &users[next_free_user];
-	*userid = next_free_user;
-	next_free_user = user_ptr->next;
-	user_ptr->next = -1;
-	spin_unlock_bh(&reg_lock);
-
-	INIT_LIST_HEAD(&user_ptr->ports);
-	atomic_inc(&tipc_user_count);
-
-	return 0;
-}
-
-/**
- * tipc_detach - deregister a TIPC user
- */
-
-void tipc_detach(u32 userid)
-{
-	struct tipc_user *user_ptr;
-	struct list_head ports_temp;
-	struct user_port *up_ptr, *temp_up_ptr;
-
-	if ((userid == 0) || (userid > MAX_USERID))
-		return;
-
-	spin_lock_bh(&reg_lock);
-	if ((!users) || (users[userid].next >= 0)) {
-		spin_unlock_bh(&reg_lock);
-		return;
-	}
-
-	user_ptr = &users[userid];
-	INIT_LIST_HEAD(&ports_temp);
-	list_splice(&user_ptr->ports, &ports_temp);
-	user_ptr->next = next_free_user;
-	next_free_user = userid;
-	spin_unlock_bh(&reg_lock);
-
-	atomic_dec(&tipc_user_count);
-
-	list_for_each_entry_safe(up_ptr, temp_up_ptr, &ports_temp, uport_list) {
-		tipc_deleteport(up_ptr->ref);
-	}
-}
-
-/**
- * tipc_reg_add_port - register a user's driver port
- */
-
-int tipc_reg_add_port(struct user_port *up_ptr)
-{
-	struct tipc_user *user_ptr;
-
-	if (up_ptr->user_ref == 0)
-		return 0;
-	if (up_ptr->user_ref > MAX_USERID)
-		return -EINVAL;
-	if ((tipc_mode == TIPC_NOT_RUNNING) || !users )
-		return -ENOPROTOOPT;
-
-	spin_lock_bh(&reg_lock);
-	user_ptr = &users[up_ptr->user_ref];
-	list_add(&up_ptr->uport_list, &user_ptr->ports);
-	spin_unlock_bh(&reg_lock);
-	return 0;
-}
-
-/**
- * tipc_reg_remove_port - deregister a user's driver port
- */
-
-int tipc_reg_remove_port(struct user_port *up_ptr)
-{
-	if (up_ptr->user_ref == 0)
-		return 0;
-	if (up_ptr->user_ref > MAX_USERID)
-		return -EINVAL;
-	if (!users )
-		return -ENOPROTOOPT;
-
-	spin_lock_bh(&reg_lock);
-	list_del_init(&up_ptr->uport_list);
-	spin_unlock_bh(&reg_lock);
-	return 0;
-}
-
diff --git a/net/tipc/user_reg.h b/net/tipc/user_reg.h
deleted file mode 100644
index 109eed0..0000000
--- a/net/tipc/user_reg.h
+++ /dev/null
@@ -1,51 +0,0 @@
-/*
- * net/tipc/user_reg.h: Include file for TIPC user registry code
- *
- * Copyright (c) 2000-2006, Ericsson AB
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
-#ifndef _TIPC_USER_REG_H
-#define _TIPC_USER_REG_H
-
-#include "port.h"
-
-int tipc_reg_start(void);
-void tipc_reg_stop(void);
-
-int tipc_attach(unsigned int *userref);
-void tipc_detach(unsigned int userref);
-
-int tipc_reg_add_port(struct user_port *up_ptr);
-int tipc_reg_remove_port(struct user_port *up_ptr);
-
-#endif
-- 
1.7.3.3

