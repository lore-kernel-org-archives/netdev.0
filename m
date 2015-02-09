From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 01/17] tipc: move and rename
	the legacy nl api to "nl compat"
Date: Mon, 9 Feb 2015 09:50:03 +0100
Message-ID: <1423471819-23112-2-git-send-email-richard.alpe@ericsson.com>
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

The new netlink API is no longer "v2" but rather the standard API and
the legacy API is now "nl compat". We split them into separate
start/stop and put them in different files in order to further
distinguish them.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/Makefile         |   4 +-
 net/tipc/bcast.c          |   2 +-
 net/tipc/bearer.c         |   4 +-
 net/tipc/core.c           |   7 ++++
 net/tipc/core.h           |   1 -
 net/tipc/link.c           |   2 +-
 net/tipc/name_table.c     |   2 +-
 net/tipc/net.c            |   2 +-
 net/tipc/netlink.c        |  67 ++---------------------------
 net/tipc/netlink.h        |   4 +-
 net/tipc/netlink_compat.c | 105 ++++++++++++++++++++++++++++++++++++++++++++++
 net/tipc/node.c           |   2 +-
 net/tipc/socket.c         |   4 +-
 13 files changed, 130 insertions(+), 76 deletions(-)
 create mode 100644 net/tipc/netlink_compat.c

diff --git a/net/tipc/Makefile b/net/tipc/Makefile
index 333e459..69b82bb 100644
--- a/net/tipc/Makefile
+++ b/net/tipc/Makefile
@@ -7,8 +7,8 @@ obj-$(CONFIG_TIPC) := tipc.o
 tipc-y	+= addr.o bcast.o bearer.o config.o \
 	   core.o link.o discover.o msg.o  \
 	   name_distr.o  subscr.o name_table.o net.o  \
-	   netlink.o node.o socket.o log.o eth_media.o \
-	   server.o
+	   netlink.o netlink_compat.o node.o socket.o log.o eth_media.o \
+	   server.o socket.o
 
 tipc-$(CONFIG_TIPC_MEDIA_IB)	+= ib_media.o
 tipc-$(CONFIG_SYSCTL)		+= sysctl.o
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 81b1fef..e96fd6a 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -810,7 +810,7 @@ int tipc_nl_add_bc_link(struct net *net, struct tipc_nl_msg *msg)
 
 	tipc_bclink_lock(net);
 
-	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_v2_family,
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
 			  NLM_F_MULTI, TIPC_NL_LINK_GET);
 	if (!hdr)
 		return -EMSGSIZE;
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 33dc348..35d400e 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -658,7 +658,7 @@ static int __tipc_nl_add_bearer(struct tipc_nl_msg *msg,
 	struct nlattr *attrs;
 	struct nlattr *prop;
 
-	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_v2_family,
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
 			  NLM_F_MULTI, TIPC_NL_BEARER_GET);
 	if (!hdr)
 		return -EMSGSIZE;
@@ -924,7 +924,7 @@ static int __tipc_nl_add_media(struct tipc_nl_msg *msg,
 	struct nlattr *attrs;
 	struct nlattr *prop;
 
-	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_v2_family,
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
 			  NLM_F_MULTI, TIPC_NL_MEDIA_GET);
 	if (!hdr)
 		return -EMSGSIZE;
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 674bd26..2d06d1f 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -111,6 +111,10 @@ static int __init tipc_init(void)
 	if (err)
 		goto out_netlink;
 
+	err = tipc_netlink_compat_start();
+	if (err)
+		goto out_netlink_compat;
+
 	err = tipc_socket_init();
 	if (err)
 		goto out_socket;
@@ -136,6 +140,8 @@ out_pernet:
 out_sysctl:
 	tipc_socket_stop();
 out_socket:
+	tipc_netlink_compat_stop();
+out_netlink_compat:
 	tipc_netlink_stop();
 out_netlink:
 	pr_err("Unable to start in single node mode\n");
@@ -146,6 +152,7 @@ static void __exit tipc_exit(void)
 {
 	tipc_bearer_cleanup();
 	tipc_netlink_stop();
+	tipc_netlink_compat_stop();
 	tipc_socket_stop();
 	tipc_unregister_sysctl();
 	unregister_pernet_subsys(&tipc_net_ops);
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 817b2e9..451c346 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -115,5 +115,4 @@ void tipc_unregister_sysctl(void);
 #define tipc_register_sysctl() 0
 #define tipc_unregister_sysctl()
 #endif
-
 #endif
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 9424912..466f28f 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2498,7 +2498,7 @@ static int __tipc_nl_add_link(struct net *net, struct tipc_nl_msg *msg,
 	struct nlattr *prop;
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
-	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_v2_family,
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
 			  NLM_F_MULTI, TIPC_NL_LINK_GET);
 	if (!hdr)
 		return -EMSGSIZE;
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 18a3d44..2251912 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -1055,7 +1055,7 @@ static int __tipc_nl_add_nametable_publ(struct tipc_nl_msg *msg,
 		*last_publ = p->key;
 
 		hdr = genlmsg_put(msg->skb, msg->portid, msg->seq,
-				  &tipc_genl_v2_family, NLM_F_MULTI,
+				  &tipc_genl_family, NLM_F_MULTI,
 				  TIPC_NL_NAME_TABLE_GET);
 		if (!hdr)
 			return -EMSGSIZE;
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 263267e..8b0fb09 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -156,7 +156,7 @@ static int __tipc_nl_add_net(struct net *net, struct tipc_nl_msg *msg)
 	void *hdr;
 	struct nlattr *attrs;
 
-	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_v2_family,
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
 			  NLM_F_MULTI, TIPC_NL_NET_GET);
 	if (!hdr)
 		return -EMSGSIZE;
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index fe0f513..7f6475e 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -35,7 +35,6 @@
  */
 
 #include "core.h"
-#include "config.h"
 #include "socket.h"
 #include "name_table.h"
 #include "bearer.h"
@@ -44,39 +43,6 @@
 #include "net.h"
 #include <net/genetlink.h>
 
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
 static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
 	[TIPC_NLA_UNSPEC]	= { .type = NLA_UNSPEC, },
 	[TIPC_NLA_BEARER]	= { .type = NLA_NESTED, },
@@ -89,28 +55,10 @@ static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
 	[TIPC_NLA_NAME_TABLE]	= { .type = NLA_NESTED, }
 };
 
-/* Legacy ASCII API */
-static struct genl_family tipc_genl_family = {
-	.id		= GENL_ID_GENERATE,
-	.name		= TIPC_GENL_NAME,
-	.version	= TIPC_GENL_VERSION,
-	.hdrsize	= TIPC_GENL_HDRLEN,
-	.maxattr	= 0,
-	.netnsok	= true,
-};
-
-/* Legacy ASCII API */
-static struct genl_ops tipc_genl_ops[] = {
-	{
-		.cmd		= TIPC_GENL_CMD,
-		.doit		= handle_cmd,
-	},
-};
-
 /* Users of the legacy API (tipc-config) can't handle that we add operations,
  * so we have a separate genl handling for the new API.
  */
-struct genl_family tipc_genl_v2_family = {
+struct genl_family tipc_genl_family = {
 	.id		= GENL_ID_GENERATE,
 	.name		= TIPC_GENL_V2_NAME,
 	.version	= TIPC_GENL_V2_VERSION,
@@ -202,9 +150,9 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 
 int tipc_nlmsg_parse(const struct nlmsghdr *nlh, struct nlattr ***attr)
 {
-	u32 maxattr = tipc_genl_v2_family.maxattr;
+	u32 maxattr = tipc_genl_family.maxattr;
 
-	*attr = tipc_genl_v2_family.attrbuf;
+	*attr = tipc_genl_family.attrbuf;
 	if (!*attr)
 		return -EOPNOTSUPP;
 
@@ -215,13 +163,7 @@ int tipc_netlink_start(void)
 {
 	int res;
 
-	res = genl_register_family_with_ops(&tipc_genl_family, tipc_genl_ops);
-	if (res) {
-		pr_err("Failed to register legacy interface\n");
-		return res;
-	}
-
-	res = genl_register_family_with_ops(&tipc_genl_v2_family,
+	res = genl_register_family_with_ops(&tipc_genl_family,
 					    tipc_genl_v2_ops);
 	if (res) {
 		pr_err("Failed to register netlink interface\n");
@@ -233,5 +175,4 @@ int tipc_netlink_start(void)
 void tipc_netlink_stop(void)
 {
 	genl_unregister_family(&tipc_genl_family);
-	genl_unregister_family(&tipc_genl_v2_family);
 }
diff --git a/net/tipc/netlink.h b/net/tipc/netlink.h
index ae2f2d9..08a1db6 100644
--- a/net/tipc/netlink.h
+++ b/net/tipc/netlink.h
@@ -36,7 +36,7 @@
 #ifndef _TIPC_NETLINK_H
 #define _TIPC_NETLINK_H
 
-extern struct genl_family tipc_genl_v2_family;
+extern struct genl_family tipc_genl_family;
 int tipc_nlmsg_parse(const struct nlmsghdr *nlh, struct nlattr ***buf);
 
 struct tipc_nl_msg {
@@ -46,6 +46,8 @@ struct tipc_nl_msg {
 };
 
 int tipc_netlink_start(void);
+int tipc_netlink_compat_start(void);
 void tipc_netlink_stop(void);
+void tipc_netlink_compat_stop(void);
 
 #endif
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
new file mode 100644
index 0000000..f752854
--- /dev/null
+++ b/net/tipc/netlink_compat.c
@@ -0,0 +1,105 @@
+/*
+ * Copyright (c) 2014, Ericsson AB
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "core.h"
+#include "config.h"
+#include <net/genetlink.h>
+#include <linux/tipc_config.h>
+
+static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct sk_buff *rep_buf;
+	struct nlmsghdr *rep_nlh;
+	struct nlmsghdr *req_nlh = info->nlhdr;
+	struct tipc_genlmsghdr *req_userhdr = info->userhdr;
+	int hdr_space = nlmsg_total_size(GENL_HDRLEN + TIPC_GENL_HDRLEN);
+	u16 cmd;
+
+	if ((req_userhdr->cmd & 0xC000) &&
+	    (!netlink_net_capable(skb, CAP_NET_ADMIN)))
+		cmd = TIPC_CMD_NOT_NET_ADMIN;
+	else
+		cmd = req_userhdr->cmd;
+
+	rep_buf = tipc_cfg_do_cmd(net, req_userhdr->dest, cmd,
+				  nlmsg_data(req_nlh) + GENL_HDRLEN +
+				  TIPC_GENL_HDRLEN,
+				  nlmsg_attrlen(req_nlh, GENL_HDRLEN +
+				  TIPC_GENL_HDRLEN), hdr_space);
+
+	if (rep_buf) {
+		skb_push(rep_buf, hdr_space);
+		rep_nlh = nlmsg_hdr(rep_buf);
+		memcpy(rep_nlh, req_nlh, hdr_space);
+		rep_nlh->nlmsg_len = rep_buf->len;
+		genlmsg_unicast(net, rep_buf, NETLINK_CB(skb).portid);
+	}
+
+	return 0;
+}
+
+static struct genl_family tipc_genl_compat_family = {
+	.id		= GENL_ID_GENERATE,
+	.name		= TIPC_GENL_NAME,
+	.version	= TIPC_GENL_VERSION,
+	.hdrsize	= TIPC_GENL_HDRLEN,
+	.maxattr	= 0,
+	.netnsok	= true,
+};
+
+static struct genl_ops tipc_genl_compat_ops[] = {
+	{
+		.cmd		= TIPC_GENL_CMD,
+		.doit		= handle_cmd,
+	},
+};
+
+int tipc_netlink_compat_start(void)
+{
+	int res;
+
+	res = genl_register_family_with_ops(&tipc_genl_compat_family,
+					    tipc_genl_compat_ops);
+	if (res) {
+		pr_err("Failed to register legacy compat interface\n");
+		return res;
+	}
+
+	return 0;
+}
+
+void tipc_netlink_compat_stop(void)
+{
+	genl_unregister_family(&tipc_genl_compat_family);
+}
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 5230849..995618d 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -623,7 +623,7 @@ static int __tipc_nl_add_node(struct tipc_nl_msg *msg, struct tipc_node *node)
 	void *hdr;
 	struct nlattr *attrs;
 
-	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_v2_family,
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
 			  NLM_F_MULTI, TIPC_NL_NODE_GET);
 	if (!hdr)
 		return -EMSGSIZE;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 4a98d15..d76c171 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2783,7 +2783,7 @@ static int __tipc_nl_add_sk(struct sk_buff *skb, struct netlink_callback *cb,
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
 	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
-			  &tipc_genl_v2_family, NLM_F_MULTI, TIPC_NL_SOCK_GET);
+			  &tipc_genl_family, NLM_F_MULTI, TIPC_NL_SOCK_GET);
 	if (!hdr)
 		goto msg_cancel;
 
@@ -2864,7 +2864,7 @@ static int __tipc_nl_add_sk_publ(struct sk_buff *skb,
 	struct nlattr *attrs;
 
 	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
-			  &tipc_genl_v2_family, NLM_F_MULTI, TIPC_NL_PUBL_GET);
+			  &tipc_genl_family, NLM_F_MULTI, TIPC_NL_PUBL_GET);
 	if (!hdr)
 		goto msg_cancel;
 
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
