From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 16/17] tipc: nl compat add
	noop and remove legacy nl framework
Date: Mon, 9 Feb 2015 09:50:18 +0100
Message-ID: <1423471819-23112-17-git-send-email-richard.alpe@ericsson.com>
References: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Richard Alpe <richard.alpe@ericsson.com>

Add TIPC_CMD_NOOP to compat layer and remove the old framework.

All legacy nl commands are now converted to the compat layer in
netlink_compat.c.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/Makefile         |   2 +-
 net/tipc/bearer.c         |   1 -
 net/tipc/config.c         | 157 ----------------------------------------------
 net/tipc/config.h         |  67 --------------------
 net/tipc/core.c           |   3 +-
 net/tipc/link.c           |   1 -
 net/tipc/log.c            |   1 -
 net/tipc/name_table.c     |   4 +-
 net/tipc/net.c            |   2 -
 net/tipc/netlink_compat.c |  73 ++-------------------
 net/tipc/node.c           |   2 +-
 net/tipc/socket.c         |   1 -
 12 files changed, 13 insertions(+), 301 deletions(-)
 delete mode 100644 net/tipc/config.c
 delete mode 100644 net/tipc/config.h

diff --git a/net/tipc/Makefile b/net/tipc/Makefile
index 69b82bb..6864b9d 100644
--- a/net/tipc/Makefile
+++ b/net/tipc/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_TIPC) := tipc.o
 
-tipc-y	+= addr.o bcast.o bearer.o config.o \
+tipc-y	+= addr.o bcast.o bearer.o \
 	   core.o link.o discover.o msg.o  \
 	   name_distr.o  subscr.o name_table.o net.o  \
 	   netlink.o netlink_compat.o node.o socket.o log.o eth_media.o \
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index c7e3b5d..858c5a6 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -36,7 +36,6 @@
 
 #include <net/sock.h>
 #include "core.h"
-#include "config.h"
 #include "bearer.h"
 #include "link.h"
 #include "discover.h"
diff --git a/net/tipc/config.c b/net/tipc/config.c
deleted file mode 100644
index c2ad2ff..0000000
--- a/net/tipc/config.c
+++ /dev/null
@@ -1,157 +0,0 @@
-/*
- * net/tipc/config.c: TIPC configuration management code
- *
- * Copyright (c) 2002-2006, Ericsson AB
- * Copyright (c) 2004-2007, 2010-2013, Wind River Systems
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
-#include "socket.h"
-#include "name_table.h"
-#include "config.h"
-#include "server.h"
-
-#define REPLY_TRUNCATED "<truncated>\n"
-
-static const void *req_tlv_area;	/* request message TLV area */
-static int req_tlv_space;		/* request message TLV area size */
-static int rep_headroom;		/* reply message headroom to use */
-
-struct sk_buff *tipc_cfg_reply_alloc(int payload_size)
-{
-	struct sk_buff *buf;
-
-	buf = alloc_skb(rep_headroom + payload_size, GFP_ATOMIC);
-	if (buf)
-		skb_reserve(buf, rep_headroom);
-	return buf;
-}
-
-int tipc_cfg_append_tlv(struct sk_buff *buf, int tlv_type,
-			void *tlv_data, int tlv_data_size)
-{
-	struct tlv_desc *tlv = (struct tlv_desc *)skb_tail_pointer(buf);
-	int new_tlv_space = TLV_SPACE(tlv_data_size);
-
-	if (skb_tailroom(buf) < new_tlv_space)
-		return 0;
-	skb_put(buf, new_tlv_space);
-	tlv->tlv_type = htons(tlv_type);
-	tlv->tlv_len  = htons(TLV_LENGTH(tlv_data_size));
-	if (tlv_data_size && tlv_data)
-		memcpy(TLV_DATA(tlv), tlv_data, tlv_data_size);
-	return 1;
-}
-
-struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string)
-{
-	struct sk_buff *buf;
-	int string_len = strlen(string) + 1;
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(string_len));
-	if (buf)
-		tipc_cfg_append_tlv(buf, tlv_type, string, string_len);
-	return buf;
-}
-
-struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
-				const void *request_area, int request_space,
-				int reply_headroom)
-{
-	struct sk_buff *rep_tlv_buf;
-
-	rtnl_lock();
-
-	/* Save request and reply details in a well-known location */
-	req_tlv_area = request_area;
-	req_tlv_space = request_space;
-	rep_headroom = reply_headroom;
-
-	/* Check command authorization */
-	if (likely(in_own_node(net, orig_node))) {
-		/* command is permitted */
-	} else {
-		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-							  " (cannot be done remotely)");
-		goto exit;
-	}
-
-	/* Call appropriate processing routine */
-	switch (cmd) {
-	case TIPC_CMD_NOOP:
-		rep_tlv_buf = tipc_cfg_reply_none();
-		break;
-	case TIPC_CMD_NOT_NET_ADMIN:
-		rep_tlv_buf =
-			tipc_cfg_reply_error_string(TIPC_CFG_NOT_NET_ADMIN);
-		break;
-	case TIPC_CMD_SET_MAX_ZONES:
-	case TIPC_CMD_GET_MAX_ZONES:
-	case TIPC_CMD_SET_MAX_SLAVES:
-	case TIPC_CMD_GET_MAX_SLAVES:
-	case TIPC_CMD_SET_MAX_CLUSTERS:
-	case TIPC_CMD_GET_MAX_CLUSTERS:
-	case TIPC_CMD_SET_MAX_NODES:
-	case TIPC_CMD_GET_MAX_NODES:
-	case TIPC_CMD_SET_MAX_SUBSCR:
-	case TIPC_CMD_GET_MAX_SUBSCR:
-	case TIPC_CMD_SET_MAX_PUBL:
-	case TIPC_CMD_GET_MAX_PUBL:
-	case TIPC_CMD_SET_LOG_SIZE:
-	case TIPC_CMD_SET_REMOTE_MNG:
-	case TIPC_CMD_GET_REMOTE_MNG:
-	case TIPC_CMD_DUMP_LOG:
-	case TIPC_CMD_SET_MAX_PORTS:
-	case TIPC_CMD_GET_MAX_PORTS:
-		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-							  " (obsolete command)");
-		break;
-	default:
-		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-							  " (unknown command)");
-		break;
-	}
-
-	WARN_ON(rep_tlv_buf->len > TLV_SPACE(ULTRA_STRING_MAX_LEN));
-
-	/* Append an error message if we cannot return all requested data */
-	if (rep_tlv_buf->len == TLV_SPACE(ULTRA_STRING_MAX_LEN)) {
-		if (*(rep_tlv_buf->data + ULTRA_STRING_MAX_LEN) != '\0')
-			sprintf(rep_tlv_buf->data + rep_tlv_buf->len -
-				sizeof(REPLY_TRUNCATED) - 1, REPLY_TRUNCATED);
-	}
-
-	/* Return reply buffer */
-exit:
-	rtnl_unlock();
-	return rep_tlv_buf;
-}
diff --git a/net/tipc/config.h b/net/tipc/config.h
deleted file mode 100644
index 9e9b575..0000000
--- a/net/tipc/config.h
+++ /dev/null
@@ -1,67 +0,0 @@
-/*
- * net/tipc/config.h: Include file for TIPC configuration service code
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
-#ifndef _TIPC_CONFIG_H
-#define _TIPC_CONFIG_H
-
-#include "link.h"
-
-#define ULTRA_STRING_MAX_LEN	32768
-
-struct sk_buff *tipc_cfg_reply_alloc(int payload_size);
-int tipc_cfg_append_tlv(struct sk_buff *buf, int tlv_type,
-			void *tlv_data, int tlv_data_size);
-struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string);
-
-static inline struct sk_buff *tipc_cfg_reply_none(void)
-{
-	return tipc_cfg_reply_alloc(0);
-}
-
-static inline struct sk_buff *tipc_cfg_reply_error_string(char *string)
-{
-	return tipc_cfg_reply_string_type(TIPC_TLV_ERROR_STRING, string);
-}
-
-static inline struct sk_buff *tipc_cfg_reply_ultra_string(char *string)
-{
-	return tipc_cfg_reply_string_type(TIPC_TLV_ULTRA_STRING, string);
-}
-
-struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
-				const void *req_tlv_area, int req_tlv_space,
-				int headroom);
-#endif
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 2d06d1f..935205e 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -39,7 +39,8 @@
 #include "core.h"
 #include "name_table.h"
 #include "subscr.h"
-#include "config.h"
+#include "bearer.h"
+#include "net.h"
 #include "socket.h"
 
 #include <linux/module.h>
diff --git a/net/tipc/link.c b/net/tipc/link.c
index dfe6f4d..a4cf364 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -40,7 +40,6 @@
 #include "socket.h"
 #include "name_distr.h"
 #include "discover.h"
-#include "config.h"
 #include "netlink.h"
 
 #include <linux/pkt_sched.h>
diff --git a/net/tipc/log.c b/net/tipc/log.c
index abef644..b186af0 100644
--- a/net/tipc/log.c
+++ b/net/tipc/log.c
@@ -35,7 +35,6 @@
  */
 
 #include "core.h"
-#include "config.h"
 
 /**
  * tipc_snprintf - append formatted output to print buffer
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index c8eaa2a..105ba7ad 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -36,11 +36,13 @@
 
 #include <net/sock.h>
 #include "core.h"
-#include "config.h"
+#include "netlink.h"
 #include "name_table.h"
 #include "name_distr.h"
 #include "subscr.h"
 #include "bcast.h"
+#include "addr.h"
+#include <net/genetlink.h>
 
 #define TIPC_NAMETBL_SIZE 1024		/* must be a power of 2 */
 
diff --git a/net/tipc/net.c b/net/tipc/net.c
index e4028f9..a54f3cb 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -40,8 +40,6 @@
 #include "subscr.h"
 #include "socket.h"
 #include "node.h"
-#include "config.h"
-#include "bcast.h"
 
 static const struct nla_policy tipc_nl_net_policy[TIPC_NLA_NET_MAX + 1] = {
 	[TIPC_NLA_NET_UNSPEC]	= { .type = NLA_UNSPEC },
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index cb9086d..ce9121e 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -32,7 +32,6 @@
  */
 
 #include "core.h"
-#include "config.h"
 #include "bearer.h"
 #include "link.h"
 #include "name_table.h"
@@ -909,6 +908,11 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 	memset(&doit, 0, sizeof(doit));
 
 	switch (msg->cmd) {
+	case TIPC_CMD_NOOP:
+		msg->rep = tipc_tlv_alloc(0);
+		if (!msg->rep)
+			return -ENOMEM;
+		return 0;
 	case TIPC_CMD_GET_BEARER_NAMES:
 		msg->rep_size = MAX_BEARERS * TLV_SPACE(TIPC_MAX_BEARER_NAME);
 		dump.dumpit = tipc_nl_bearer_dump;
@@ -1044,71 +1048,6 @@ send:
 	return err;
 }
 
-static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
-{
-	struct net *net = genl_info_net(info);
-	struct sk_buff *rep_buf;
-	struct nlmsghdr *rep_nlh;
-	struct nlmsghdr *req_nlh = info->nlhdr;
-	struct tipc_genlmsghdr *req_userhdr = info->userhdr;
-	int hdr_space = nlmsg_total_size(GENL_HDRLEN + TIPC_GENL_HDRLEN);
-	u16 cmd;
-
-	if ((req_userhdr->cmd & 0xC000) &&
-	    (!netlink_net_capable(skb, CAP_NET_ADMIN)))
-		cmd = TIPC_CMD_NOT_NET_ADMIN;
-	else
-		cmd = req_userhdr->cmd;
-
-	rep_buf = tipc_cfg_do_cmd(net, req_userhdr->dest, cmd,
-				  nlmsg_data(req_nlh) + GENL_HDRLEN +
-				  TIPC_GENL_HDRLEN,
-				  nlmsg_attrlen(req_nlh, GENL_HDRLEN +
-				  TIPC_GENL_HDRLEN), hdr_space);
-
-	if (rep_buf) {
-		skb_push(rep_buf, hdr_space);
-		rep_nlh = nlmsg_hdr(rep_buf);
-		memcpy(rep_nlh, req_nlh, hdr_space);
-		rep_nlh->nlmsg_len = rep_buf->len;
-		genlmsg_unicast(net, rep_buf, NETLINK_CB(skb).portid);
-	}
-
-	return 0;
-}
-
-/* Temporary function to keep functionality throughout the patchset
- * without having to mess with the global variables and other trickery
- * of the old API.
- */
-static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
-{
-	struct tipc_genlmsghdr *req = info->userhdr;
-
-	switch (req->cmd) {
-	case TIPC_CMD_GET_BEARER_NAMES:
-	case TIPC_CMD_ENABLE_BEARER:
-	case TIPC_CMD_DISABLE_BEARER:
-	case TIPC_CMD_SHOW_LINK_STATS:
-	case TIPC_CMD_GET_LINKS:
-	case TIPC_CMD_SET_LINK_TOL:
-	case TIPC_CMD_SET_LINK_PRI:
-	case TIPC_CMD_SET_LINK_WINDOW:
-	case TIPC_CMD_RESET_LINK_STATS:
-	case TIPC_CMD_SHOW_NAME_TABLE:
-	case TIPC_CMD_SHOW_PORTS:
-	case TIPC_CMD_GET_MEDIA_NAMES:
-	case TIPC_CMD_GET_NODES:
-	case TIPC_CMD_SET_NODE_ADDR:
-	case TIPC_CMD_SET_NETID:
-	case TIPC_CMD_GET_NETID:
-	case TIPC_CMD_SHOW_STATS:
-		return tipc_nl_compat_recv(skb, info);
-	}
-
-	return handle_cmd(skb, info);
-}
-
 static struct genl_family tipc_genl_compat_family = {
 	.id		= GENL_ID_GENERATE,
 	.name		= TIPC_GENL_NAME,
@@ -1121,7 +1060,7 @@ static struct genl_family tipc_genl_compat_family = {
 static struct genl_ops tipc_genl_compat_ops[] = {
 	{
 		.cmd		= TIPC_GENL_CMD,
-		.doit		= tipc_nl_compat_tmp_wrap,
+		.doit		= tipc_nl_compat_recv,
 	},
 };
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index ddaa2bb..86152de 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -35,7 +35,7 @@
  */
 
 #include "core.h"
-#include "config.h"
+#include "link.h"
 #include "node.h"
 #include "name_distr.h"
 #include "socket.h"
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e77d738..f73e975 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -40,7 +40,6 @@
 #include "name_table.h"
 #include "node.h"
 #include "link.h"
-#include "config.h"
 #include "name_distr.h"
 #include "socket.h"
 
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
