From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 7/7 net-2.6.26] [TIPC]: Removal of message header option code
Date: Tue,  4 Mar 2008 16:20:19 -0500
Message-ID: <1204665619-6345-8-git-send-email-allan.stephens@windriver.com>
References: <1204665619-6345-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48084 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760766AbYCDVgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 16:36:11 -0500
In-Reply-To: <1204665619-6345-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes code associated with optional, user-specified
fields of the TIPC message header.  Such fields were never
utilized by TIPC, and have now been removed from the protocol
specification.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 include/net/tipc/tipc_port.h |    7 -------
 net/tipc/core.c              |    1 -
 net/tipc/msg.h               |   23 -----------------------
 net/tipc/port.c              |    7 -------
 4 files changed, 0 insertions(+), 38 deletions(-)

diff --git a/include/net/tipc/tipc_port.h b/include/net/tipc/tipc_port.h
index cfc4ba4..c9b36b7 100644
--- a/include/net/tipc/tipc_port.h
+++ b/include/net/tipc/tipc_port.h
@@ -86,13 +86,6 @@ u32 tipc_createport_raw(void *usr_handle,
 			void (*wakeup)(struct tipc_port *),
 			const u32 importance);
 
-/*
- * tipc_set_msg_option(): port must be locked.
- */
-int tipc_set_msg_option(struct tipc_port *tp_ptr,
-			const char *opt,
-			const u32 len);
-
 int tipc_reject_msg(struct sk_buff *buf, u32 err);
 
 int tipc_send_buf_fast(struct sk_buff *buf, u32 destnode);
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 10209ec..e28e189 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -268,7 +268,6 @@ EXPORT_SYMBOL(tipc_register_media);
 /* TIPC API for external APIs (see tipc_port.h) */
 
 EXPORT_SYMBOL(tipc_createport_raw);
-EXPORT_SYMBOL(tipc_set_msg_option);
 EXPORT_SYMBOL(tipc_reject_msg);
 EXPORT_SYMBOL(tipc_send_buf_fast);
 EXPORT_SYMBOL(tipc_acknowledge);
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 5afa60b..6ad070d 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -190,18 +190,6 @@ static inline void msg_set_lookup_scope(struct tipc_msg *m, u32 n)
 	msg_set_bits(m, 1, 19, 0x3, n);
 }
 
-static inline void msg_set_options(struct tipc_msg *m, const char *opt, u32 sz)
-{
-	u32 hsz = msg_hdr_sz(m);
-	char *to = (char *)&m->hdr[hsz/4];
-
-	if ((hsz < DIR_MSG_H_SIZE) || ((hsz + sz) > MAX_H_SIZE))
-		return;
-	msg_set_bits(m, 1, 16, 0x7, (hsz - 28)/4);
-	msg_set_hdr_sz(m, hsz + sz);
-	memcpy(to, opt, sz);
-}
-
 static inline u32 msg_bcast_ack(struct tipc_msg *m)
 {
 	return msg_bits(m, 1, 0, 0xffff);
@@ -330,17 +318,6 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 	return (struct tipc_msg *)msg_data(m);
 }
 
-static inline void msg_expand(struct tipc_msg *m, u32 destnode)
-{
-	if (!msg_short(m))
-		return;
-	msg_set_hdr_sz(m, LONG_H_SIZE);
-	msg_set_orignode(m, msg_prevnode(m));
-	msg_set_destnode(m, destnode);
-	memset(&m->hdr[8], 0, 12);
-}
-
-
 
 /*
 		TIPC internal message header format, version 2
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 6ec82e0..e2646a9 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -414,13 +414,6 @@ static struct sk_buff *port_build_proto_msg(u32 destport, u32 destnode,
 	return buf;
 }
 
-int tipc_set_msg_option(struct tipc_port *tp_ptr, const char *opt, const u32 sz)
-{
-	msg_expand(&tp_ptr->phdr, msg_destnode(&tp_ptr->phdr));
-	msg_set_options(&tp_ptr->phdr, opt, sz);
-	return TIPC_OK;
-}
-
 int tipc_reject_msg(struct sk_buff *buf, u32 err)
 {
 	struct tipc_msg *msg = buf_msg(buf);
-- 
1.5.3.2

