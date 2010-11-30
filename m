From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/11] tipc: Eliminate obsolete native API forwarding routines
Date: Tue, 30 Nov 2010 17:01:02 -0500
Message-ID: <1291154463-26346-11-git-send-email-paul.gortmaker@windriver.com>
References: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58734 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab0K3WBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:01:16 -0500
In-Reply-To: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Moves the content of each native API message forwarding routine
into the sole routine that calls it, since the forwarding routines
no longer be called in isolation. Also removes code in each routine
that altered the outgoing message's importance level since this is
now no longer possible.

The previous function mapping (parent function, and child API) was
as follows:

   tipc_send2name
       \--tipc_forward2name

   tipc_send2port
       \--tipc_forward2port

   tipc_send_buf2port
       \--tipc_forward_buf2port

After this commit, the children don't exist and their functionality
is completely in the respective parent.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |  100 ++++++++----------------------------------------------
 net/tipc/port.h |    2 -
 2 files changed, 15 insertions(+), 87 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 01dcfee..73f232c 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -1265,16 +1265,11 @@ int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect)
 }
 
 /**
- * tipc_forward2name - forward message sections to port name
+ * tipc_send2name - send message sections to port name
  */
 
-static int tipc_forward2name(u32 ref,
-			     struct tipc_name const *name,
-			     u32 domain,
-			     u32 num_sect,
-			     struct iovec const *msg_sect,
-			     struct tipc_portid const *orig,
-			     unsigned int importance)
+int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
+	   unsigned int num_sect, struct iovec const *msg_sect)
 {
 	struct port *p_ptr;
 	struct tipc_msg *msg;
@@ -1288,14 +1283,12 @@ static int tipc_forward2name(u32 ref,
 
 	msg = &p_ptr->publ.phdr;
 	msg_set_type(msg, TIPC_NAMED_MSG);
-	msg_set_orignode(msg, orig->node);
-	msg_set_origport(msg, orig->ref);
+	msg_set_orignode(msg, tipc_own_addr);
+	msg_set_origport(msg, ref);
 	msg_set_hdr_sz(msg, LONG_H_SIZE);
 	msg_set_nametype(msg, name->type);
 	msg_set_nameinst(msg, name->instance);
 	msg_set_lookup_scope(msg, tipc_addr_scope(domain));
-	if (importance <= TIPC_CRITICAL_IMPORTANCE)
-		msg_set_importance(msg,importance);
 	destport = tipc_nametbl_translate(name->type, name->instance, &destnode);
 	msg_set_destnode(msg, destnode);
 	msg_set_destport(msg, destport);
@@ -1319,33 +1312,11 @@ static int tipc_forward2name(u32 ref,
 }
 
 /**
- * tipc_send2name - send message sections to port name
- */
-
-int tipc_send2name(u32 ref,
-		   struct tipc_name const *name,
-		   unsigned int domain,
-		   unsigned int num_sect,
-		   struct iovec const *msg_sect)
-{
-	struct tipc_portid orig;
-
-	orig.ref = ref;
-	orig.node = tipc_own_addr;
-	return tipc_forward2name(ref, name, domain, num_sect, msg_sect, &orig,
-				 TIPC_PORT_IMPORTANCE);
-}
-
-/**
- * tipc_forward2port - forward message sections to port identity
+ * tipc_send2port - send message sections to port identity
  */
 
-static int tipc_forward2port(u32 ref,
-			     struct tipc_portid const *dest,
-			     unsigned int num_sect,
-			     struct iovec const *msg_sect,
-			     struct tipc_portid const *orig,
-			     unsigned int importance)
+int tipc_send2port(u32 ref, struct tipc_portid const *dest,
+	   unsigned int num_sect, struct iovec const *msg_sect)
 {
 	struct port *p_ptr;
 	struct tipc_msg *msg;
@@ -1357,13 +1328,11 @@ static int tipc_forward2port(u32 ref,
 
 	msg = &p_ptr->publ.phdr;
 	msg_set_type(msg, TIPC_DIRECT_MSG);
-	msg_set_orignode(msg, orig->node);
-	msg_set_origport(msg, orig->ref);
+	msg_set_orignode(msg, tipc_own_addr);
+	msg_set_origport(msg, ref);
 	msg_set_destnode(msg, dest->node);
 	msg_set_destport(msg, dest->ref);
 	msg_set_hdr_sz(msg, DIR_MSG_H_SIZE);
-	if (importance <= TIPC_CRITICAL_IMPORTANCE)
-		msg_set_importance(msg, importance);
 	p_ptr->sent++;
 	if (dest->node == tipc_own_addr)
 		return tipc_port_recv_sections(p_ptr, num_sect, msg_sect);
@@ -1378,31 +1347,11 @@ static int tipc_forward2port(u32 ref,
 }
 
 /**
- * tipc_send2port - send message sections to port identity
+ * tipc_send_buf2port - send message buffer to port identity
  */
 
-int tipc_send2port(u32 ref,
-		   struct tipc_portid const *dest,
-		   unsigned int num_sect,
-		   struct iovec const *msg_sect)
-{
-	struct tipc_portid orig;
-
-	orig.ref = ref;
-	orig.node = tipc_own_addr;
-	return tipc_forward2port(ref, dest, num_sect, msg_sect, &orig,
-				 TIPC_PORT_IMPORTANCE);
-}
-
-/**
- * tipc_forward_buf2port - forward message buffer to port identity
- */
-static int tipc_forward_buf2port(u32 ref,
-				 struct tipc_portid const *dest,
-				 struct sk_buff *buf,
-				 unsigned int dsz,
-				 struct tipc_portid const *orig,
-				 unsigned int importance)
+int tipc_send_buf2port(u32 ref, struct tipc_portid const *dest,
+	       struct sk_buff *buf, unsigned int dsz)
 {
 	struct port *p_ptr;
 	struct tipc_msg *msg;
@@ -1414,13 +1363,11 @@ static int tipc_forward_buf2port(u32 ref,
 
 	msg = &p_ptr->publ.phdr;
 	msg_set_type(msg, TIPC_DIRECT_MSG);
-	msg_set_orignode(msg, orig->node);
-	msg_set_origport(msg, orig->ref);
+	msg_set_orignode(msg, tipc_own_addr);
+	msg_set_origport(msg, ref);
 	msg_set_destnode(msg, dest->node);
 	msg_set_destport(msg, dest->ref);
 	msg_set_hdr_sz(msg, DIR_MSG_H_SIZE);
-	if (importance <= TIPC_CRITICAL_IMPORTANCE)
-		msg_set_importance(msg, importance);
 	msg_set_size(msg, DIR_MSG_H_SIZE + dsz);
 	if (skb_cow(buf, DIR_MSG_H_SIZE))
 		return -ENOMEM;
@@ -1439,20 +1386,3 @@ static int tipc_forward_buf2port(u32 ref,
 	return -ELINKCONG;
 }
 
-/**
- * tipc_send_buf2port - send message buffer to port identity
- */
-
-int tipc_send_buf2port(u32 ref,
-		       struct tipc_portid const *dest,
-		       struct sk_buff *buf,
-		       unsigned int dsz)
-{
-	struct tipc_portid orig;
-
-	orig.ref = ref;
-	orig.node = tipc_own_addr;
-	return tipc_forward_buf2port(ref, dest, buf, dsz, &orig,
-				     TIPC_PORT_IMPORTANCE);
-}
-
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 711b4a0..3f6c0aa 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -222,8 +222,6 @@ int tipc_disconnect_port(struct tipc_port *tp_ptr);
 /*
  * TIPC messaging routines
  */
-#define TIPC_PORT_IMPORTANCE 100	/* send using current port setting */
-
 int tipc_send(u32 portref, unsigned int num_sect, struct iovec const *msg_sect);
 
 int tipc_send2name(u32 portref, struct tipc_name const *name, u32 domain,
-- 
1.7.3.2.146.g2d444

