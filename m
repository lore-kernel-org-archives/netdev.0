From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/11] tipc: Remove support for TIPC mode change callback
Date: Tue, 30 Nov 2010 17:00:58 -0500
Message-ID: <1291154463-26346-7-git-send-email-paul.gortmaker@windriver.com>
References: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58717 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617Ab0K3WBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:01:13 -0500
In-Reply-To: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates support for the callback routine invoked when TIPC
changes its mode of operation from inactive to standalone or from
standalone to networked. This callback was part of TIPC's obsolete
native API and is not used by TIPC internally.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.c   |    2 +-
 net/tipc/subscr.c   |    2 +-
 net/tipc/user_reg.c |   50 ++------------------------------------------------
 net/tipc/user_reg.h |    4 +---
 4 files changed, 5 insertions(+), 53 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 2ee5a9a..bdde39f 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -560,7 +560,7 @@ int tipc_cfg_init(void)
 	struct tipc_name_seq seq;
 	int res;
 
-	res = tipc_attach(&mng.user_ref, NULL, NULL);
+	res = tipc_attach(&mng.user_ref);
 	if (res)
 		goto failed;
 
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index e7fb38b..e13c89a 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -549,7 +549,7 @@ int tipc_subscr_start(void)
 	INIT_LIST_HEAD(&topsrv.subscriber_list);
 
 	spin_lock_bh(&topsrv.lock);
-	res = tipc_attach(&topsrv.user_ref, NULL, NULL);
+	res = tipc_attach(&topsrv.user_ref);
 	if (res) {
 		spin_unlock_bh(&topsrv.lock);
 		return res;
diff --git a/net/tipc/user_reg.c b/net/tipc/user_reg.c
index 5069288..2e2702e 100644
--- a/net/tipc/user_reg.c
+++ b/net/tipc/user_reg.c
@@ -50,15 +50,11 @@
 /**
  * struct tipc_user - registered TIPC user info
  * @next: index of next free registry entry (or -1 for an allocated entry)
- * @callback: ptr to routine to call when TIPC mode changes (NULL if none)
- * @usr_handle: user-defined value passed to callback routine
  * @ports: list of user ports owned by the user
  */
 
 struct tipc_user {
 	int next;
-	tipc_mode_event callback;
-	void *usr_handle;
 	struct list_head ports;
 };
 
@@ -95,41 +91,12 @@ static int reg_init(void)
 }
 
 /**
- * reg_callback - inform TIPC user about current operating mode
- */
-
-static void reg_callback(struct tipc_user *user_ptr)
-{
-	tipc_mode_event cb;
-	void *arg;
-
-	spin_lock_bh(&reg_lock);
-	cb = user_ptr->callback;
-	arg = user_ptr->usr_handle;
-	spin_unlock_bh(&reg_lock);
-
-	if (cb)
-		cb(arg, tipc_mode, tipc_own_addr);
-}
-
-/**
  * tipc_reg_start - activate TIPC user registry
  */
 
 int tipc_reg_start(void)
 {
-	u32 u;
-	int res;
-
-	if ((res = reg_init()))
-		return res;
-
-	for (u = 1; u <= MAX_USERID; u++) {
-		if (users[u].callback)
-			tipc_k_signal((Handler)reg_callback,
-				      (unsigned long)&users[u]);
-	}
-	return 0;
+	return reg_init();
 }
 
 /**
@@ -138,15 +105,9 @@ int tipc_reg_start(void)
 
 void tipc_reg_stop(void)
 {
-	int id;
-
 	if (!users)
 		return;
 
-	for (id = 1; id <= MAX_USERID; id++) {
-		if (users[id].callback)
-			reg_callback(&users[id]);
-	}
 	kfree(users);
 	users = NULL;
 }
@@ -157,12 +118,10 @@ void tipc_reg_stop(void)
  * NOTE: This routine may be called when TIPC is inactive.
  */
 
-int tipc_attach(u32 *userid, tipc_mode_event cb, void *usr_handle)
+int tipc_attach(u32 *userid)
 {
 	struct tipc_user *user_ptr;
 
-	if ((tipc_mode == TIPC_NOT_RUNNING) && !cb)
-		return -ENOPROTOOPT;
 	if (!users)
 		reg_init();
 
@@ -177,13 +136,9 @@ int tipc_attach(u32 *userid, tipc_mode_event cb, void *usr_handle)
 	user_ptr->next = -1;
 	spin_unlock_bh(&reg_lock);
 
-	user_ptr->callback = cb;
-	user_ptr->usr_handle = usr_handle;
 	INIT_LIST_HEAD(&user_ptr->ports);
 	atomic_inc(&tipc_user_count);
 
-	if (cb && (tipc_mode != TIPC_NOT_RUNNING))
-		tipc_k_signal((Handler)reg_callback, (unsigned long)user_ptr);
 	return 0;
 }
 
@@ -207,7 +162,6 @@ void tipc_detach(u32 userid)
 	}
 
 	user_ptr = &users[userid];
-	user_ptr->callback = NULL;
 	INIT_LIST_HEAD(&ports_temp);
 	list_splice(&user_ptr->ports, &ports_temp);
 	user_ptr->next = next_free_user;
diff --git a/net/tipc/user_reg.h b/net/tipc/user_reg.h
index a05981f..109eed0 100644
--- a/net/tipc/user_reg.h
+++ b/net/tipc/user_reg.h
@@ -42,9 +42,7 @@
 int tipc_reg_start(void);
 void tipc_reg_stop(void);
 
-typedef void (*tipc_mode_event)(void *usr_handle, int mode, u32 addr);
-
-int tipc_attach(unsigned int *userref, tipc_mode_event, void *usr_handle);
+int tipc_attach(unsigned int *userref);
 void tipc_detach(unsigned int userref);
 
 int tipc_reg_add_port(struct user_port *up_ptr);
-- 
1.7.3.2.146.g2d444

