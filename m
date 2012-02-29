From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/17] tipc: Simplify enforcement of reserved name type prohibition
Date: Wed, 29 Feb 2012 18:18:30 -0500
Message-ID: <1330557523-2024-5-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53937 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965160Ab2B2XS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:18:59 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Streamlines the logic that prevents an application from binding a
reserved TIPC name type to a port by moving the check to the code
that handles a socket bind() operation. This allows internal TIPC
subsystems to bind a reserved name without having to set an atomic
flag to gain permission to use such a name. (This simplification is
now possible due to the elimination of support for TIPC's native API.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.c     |    2 +-
 net/tipc/name_table.c |   24 +-----------------------
 net/tipc/name_table.h |    2 --
 net/tipc/socket.c     |    3 +++
 net/tipc/subscr.c     |    2 +-
 5 files changed, 6 insertions(+), 27 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 4785bf2..9fefd32 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -481,7 +481,7 @@ int tipc_cfg_init(void)
 
 	seq.type = TIPC_CFG_SRV;
 	seq.lower = seq.upper = tipc_own_addr;
-	res = tipc_nametbl_publish_rsv(config_port_ref, TIPC_ZONE_SCOPE, &seq);
+	res = tipc_publish(config_port_ref, TIPC_ZONE_SCOPE, &seq);
 	if (res)
 		goto failed;
 
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 89eb562..1196f05 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -114,10 +114,8 @@ struct name_table {
 };
 
 static struct name_table table;
-static atomic_t rsv_publ_ok = ATOMIC_INIT(0);
 DEFINE_RWLOCK(tipc_nametbl_lock);
 
-
 static int hash(int x)
 {
 	return x & (tipc_nametbl_size - 1);
@@ -665,22 +663,7 @@ exit:
 	return res;
 }
 
-/**
- * tipc_nametbl_publish_rsv - publish port name using a reserved name type
- */
-
-int tipc_nametbl_publish_rsv(u32 ref, unsigned int scope,
-			struct tipc_name_seq const *seq)
-{
-	int res;
-
-	atomic_inc(&rsv_publ_ok);
-	res = tipc_publish(ref, scope, seq);
-	atomic_dec(&rsv_publ_ok);
-	return res;
-}
-
-/**
+/*
  * tipc_nametbl_publish - add name publication to network name tables
  */
 
@@ -694,11 +677,6 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 		     tipc_max_publications);
 		return NULL;
 	}
-	if ((type < TIPC_RESERVED_TYPES) && !atomic_read(&rsv_publ_ok)) {
-		warn("Publication failed, reserved name {%u,%u,%u}\n",
-		     type, lower, upper);
-		return NULL;
-	}
 
 	write_lock_bh(&tipc_nametbl_lock);
 	table.local_publ_count++;
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index 8086b42..207d59e 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -91,8 +91,6 @@ struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space);
 u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *node);
 int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
 			 struct tipc_port_list *dports);
-int tipc_nametbl_publish_rsv(u32 ref, unsigned int scope,
-			struct tipc_name_seq const *seq);
 struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 				    u32 scope, u32 port_ref, u32 key);
 int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e2f7c5d..d3227f2 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -355,6 +355,9 @@ static int bind(struct socket *sock, struct sockaddr *uaddr, int uaddr_len)
 	else if (addr->addrtype != TIPC_ADDR_NAMESEQ)
 		return -EAFNOSUPPORT;
 
+	if (addr->addr.nameseq.type < TIPC_RESERVED_TYPES)
+		return -EACCES;
+
 	return (addr->scope > 0) ?
 		tipc_publish(portref, addr->scope, &addr->addr.nameseq) :
 		tipc_withdraw(portref, -addr->scope, &addr->addr.nameseq);
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 8c49566..b2964e9 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -552,7 +552,7 @@ int tipc_subscr_start(void)
 	if (res)
 		goto failed;
 
-	res = tipc_nametbl_publish_rsv(topsrv.setup_port, TIPC_NODE_SCOPE, &seq);
+	res = tipc_publish(topsrv.setup_port, TIPC_NODE_SCOPE, &seq);
 	if (res) {
 		tipc_deleteport(topsrv.setup_port);
 		topsrv.setup_port = 0;
-- 
1.7.9.1
