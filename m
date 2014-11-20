From: <richard.alpe@ericsson.com>
Subject: [PATCH v3 net-next 01/14] tipc: add bearer
	disable/enable to new netlink api
Date: Thu, 20 Nov 2014 10:29:07 +0100
Message-ID: <1416475760-18914-2-git-send-email-richard.alpe@ericsson.com>
References: <1416475760-18914-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1416475760-18914-1-git-send-email-richard.alpe@ericsson.com>
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

A new netlink API for tipc that can disable or enable a tipc bearer.

The new API is separated from the old API because of a bug in the
user space client (tipc-config). The problem is that older versions
of tipc-config has a very low receive limit and adding commands to
the legacy genl_opts struct causes the ctrl_getfamily() response
message to grow, subsequently breaking the tool.

The new API utilizes netlink policies for input validation. Where the
top-level netlink attributes are tipc-logical entities, like bearer.
The top level entities then contain nested attributes. In this case
a name, nested link properties and a domain.

Netlink commands implemented in this patch:
TIPC_NL_BEARER_ENABLE
TIPC_NL_BEARER_DISABLE

Netlink logical layout of bearer enable message:
-> bearer
    -> name
    [ -> domain ]
    [
    -> properties
        -> priority
    ]

Netlink logical layout of bearer disable message:
-> bearer
    -> name

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_netlink.h |   83 +++++++++++++++++++++++++++++++
 net/tipc/bearer.c                 |   99 ++++++++++++++++++++++++++++++++++++-
 net/tipc/bearer.h                 |    7 ++-
 net/tipc/core.h                   |    1 +
 net/tipc/link.c                   |   47 ++++++++++++++++++
 net/tipc/link.h                   |    3 ++
 net/tipc/netlink.c                |   42 +++++++++++++++-
 net/tipc/netlink.h                |   41 +++++++++++++++
 8 files changed, 320 insertions(+), 3 deletions(-)
 create mode 100644 include/uapi/linux/tipc_netlink.h
 create mode 100644 net/tipc/netlink.h

diff --git a/include/uapi/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
new file mode 100644
index 0000000..b9b710f
--- /dev/null
+++ b/include/uapi/linux/tipc_netlink.h
@@ -0,0 +1,83 @@
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
+#ifndef _LINUX_TIPC_NETLINK_H_
+#define _LINUX_TIPC_NETLINK_H_
+
+#define TIPC_GENL_V2_NAME      "TIPCv2"
+#define TIPC_GENL_V2_VERSION   0x1
+
+/* Netlink commands */
+enum {
+	TIPC_NL_UNSPEC,
+	TIPC_NL_LEGACY,
+	TIPC_NL_BEARER_DISABLE,
+	TIPC_NL_BEARER_ENABLE,
+
+	__TIPC_NL_CMD_MAX,
+	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
+};
+
+/* Top level netlink attributes */
+enum {
+	TIPC_NLA_UNSPEC,
+	TIPC_NLA_BEARER,		/* nest */
+
+	__TIPC_NLA_MAX,
+	TIPC_NLA_MAX = __TIPC_NLA_MAX - 1
+};
+
+/* Bearer info */
+enum {
+	TIPC_NLA_BEARER_UNSPEC,
+	TIPC_NLA_BEARER_NAME,		/* string */
+	TIPC_NLA_BEARER_PROP,		/* nest */
+	TIPC_NLA_BEARER_DOMAIN,		/* u32 */
+
+	__TIPC_NLA_BEARER_MAX,
+	TIPC_NLA_BEARER_MAX = __TIPC_NLA_BEARER_MAX - 1
+};
+
+/* Nest, link propreties. Valid for link, media and bearer */
+enum {
+	TIPC_NLA_PROP_UNSPEC,
+
+	TIPC_NLA_PROP_PRIO,		/* u32 */
+	TIPC_NLA_PROP_TOL,		/* u32 */
+	TIPC_NLA_PROP_WIN,		/* u32 */
+
+	__TIPC_NLA_PROP_MAX,
+	TIPC_NLA_PROP_MAX = __TIPC_NLA_PROP_MAX - 1
+};
+
+#endif
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 2644743..59815be 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/bearer.c: TIPC bearer code
  *
- * Copyright (c) 1996-2006, 2013, Ericsson AB
+ * Copyright (c) 1996-2006, 2013-2014, Ericsson AB
  * Copyright (c) 2004-2006, 2010-2013, Wind River Systems
  * All rights reserved.
  *
@@ -37,6 +37,7 @@
 #include "core.h"
 #include "config.h"
 #include "bearer.h"
+#include "link.h"
 #include "discover.h"
 
 #define MAX_ADDR_STR 60
@@ -49,6 +50,17 @@ static struct tipc_media * const media_info_array[] = {
 	NULL
 };
 
+static const struct nla_policy
+tipc_nl_bearer_policy[TIPC_NLA_BEARER_MAX + 1]	= {
+	[TIPC_NLA_BEARER_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_BEARER_NAME] = {
+		.type = NLA_STRING,
+		.len = TIPC_MAX_BEARER_NAME
+	},
+	[TIPC_NLA_BEARER_PROP]			= { .type = NLA_NESTED },
+	[TIPC_NLA_BEARER_DOMAIN]		= { .type = NLA_U32 }
+};
+
 struct tipc_bearer __rcu *bearer_list[MAX_BEARERS + 1];
 
 static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down);
@@ -627,3 +639,88 @@ void tipc_bearer_stop(void)
 		}
 	}
 }
+
+int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
+{
+	int err;
+	char *name;
+	struct tipc_bearer *bearer;
+	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1];
+
+	if (!info->attrs[TIPC_NLA_BEARER])
+		return -EINVAL;
+
+	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
+			       info->attrs[TIPC_NLA_BEARER],
+			       tipc_nl_bearer_policy);
+	if (err)
+		return err;
+
+	if (!attrs[TIPC_NLA_BEARER_NAME])
+		return -EINVAL;
+
+	name = nla_data(attrs[TIPC_NLA_BEARER_NAME]);
+
+	rtnl_lock();
+	bearer = tipc_bearer_find(name);
+	if (!bearer) {
+		rtnl_unlock();
+		return -EINVAL;
+	}
+
+	bearer_disable(bearer, false);
+	rtnl_unlock();
+
+	return 0;
+}
+
+int tipc_nl_bearer_enable(struct sk_buff *skb, struct genl_info *info)
+{
+	int err;
+	char *bearer;
+	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1];
+	u32 domain;
+	u32 prio;
+
+	prio = TIPC_MEDIA_LINK_PRI;
+	domain = tipc_own_addr & TIPC_CLUSTER_MASK;
+
+	if (!info->attrs[TIPC_NLA_BEARER])
+		return -EINVAL;
+
+	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
+			       info->attrs[TIPC_NLA_BEARER],
+			       tipc_nl_bearer_policy);
+	if (err)
+		return err;
+
+	if (!attrs[TIPC_NLA_BEARER_NAME])
+		return -EINVAL;
+
+	bearer = nla_data(attrs[TIPC_NLA_BEARER_NAME]);
+
+	if (attrs[TIPC_NLA_BEARER_DOMAIN])
+		domain = nla_get_u32(attrs[TIPC_NLA_BEARER_DOMAIN]);
+
+	if (attrs[TIPC_NLA_BEARER_PROP]) {
+		struct nlattr *props[TIPC_NLA_PROP_MAX + 1];
+
+		err = tipc_nl_parse_link_prop(attrs[TIPC_NLA_BEARER_PROP],
+					      props);
+		if (err)
+			return err;
+
+		if (props[TIPC_NLA_PROP_PRIO])
+			prio = nla_get_u32(props[TIPC_NLA_PROP_PRIO]);
+	}
+
+	rtnl_lock();
+	err = tipc_enable_bearer(bearer, domain, prio);
+	if (err) {
+		rtnl_unlock();
+		return err;
+	}
+	rtnl_unlock();
+
+	return 0;
+}
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 78fccc4..a87e8c7 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/bearer.h: Include file for TIPC bearer code
  *
- * Copyright (c) 1996-2006, 2013, Ericsson AB
+ * Copyright (c) 1996-2006, 2013-2014, Ericsson AB
  * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -38,6 +38,8 @@
 #define _TIPC_BEARER_H
 
 #include "bcast.h"
+#include "netlink.h"
+#include <net/genetlink.h>
 
 #define MAX_BEARERS	2
 #define MAX_MEDIA	2
@@ -176,6 +178,9 @@ extern struct tipc_media eth_media_info;
 extern struct tipc_media ib_media_info;
 #endif
 
+int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info);
+int tipc_nl_bearer_enable(struct sk_buff *skb, struct genl_info *info);
+
 int tipc_media_set_priority(const char *name, u32 new_value);
 int tipc_media_set_window(const char *name, u32 new_value);
 void tipc_media_addr_printf(char *buf, int len, struct tipc_media_addr *a);
diff --git a/net/tipc/core.h b/net/tipc/core.h
index f773b14..b578b10 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -41,6 +41,7 @@
 
 #include <linux/tipc.h>
 #include <linux/tipc_config.h>
+#include <linux/tipc_netlink.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 7cf8004..e7f3650 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -40,6 +40,7 @@
 #include "name_distr.h"
 #include "discover.h"
 #include "config.h"
+#include "netlink.h"
 
 #include <linux/pkt_sched.h>
 
@@ -50,6 +51,14 @@ static const char *link_co_err = "Link changeover error, ";
 static const char *link_rst_msg = "Resetting link ";
 static const char *link_unk_evt = "Unknown link event ";
 
+/* Properties valid for media, bearar and link */
+static const struct nla_policy tipc_nl_prop_policy[TIPC_NLA_PROP_MAX + 1] = {
+	[TIPC_NLA_PROP_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_PROP_PRIO]		= { .type = NLA_U32 },
+	[TIPC_NLA_PROP_TOL]		= { .type = NLA_U32 },
+	[TIPC_NLA_PROP_WIN]		= { .type = NLA_U32 }
+};
+
 /*
  * Out-of-range value for link session numbers
  */
@@ -2376,3 +2385,41 @@ static void link_print(struct tipc_link *l_ptr, const char *str)
 	else
 		pr_cont("\n");
 }
+
+/* Parse and validate nested (link) properties valid for media, bearer and link
+ */
+int tipc_nl_parse_link_prop(struct nlattr *prop, struct nlattr *props[])
+{
+	int err;
+
+	err = nla_parse_nested(props, TIPC_NLA_PROP_MAX, prop,
+			       tipc_nl_prop_policy);
+	if (err)
+		return err;
+
+	if (props[TIPC_NLA_PROP_PRIO]) {
+		u32 prio;
+
+		prio = nla_get_u32(props[TIPC_NLA_PROP_PRIO]);
+		if (prio > TIPC_MAX_LINK_PRI)
+			return -EINVAL;
+	}
+
+	if (props[TIPC_NLA_PROP_TOL]) {
+		u32 tol;
+
+		tol = nla_get_u32(props[TIPC_NLA_PROP_TOL]);
+		if ((tol < TIPC_MIN_LINK_TOL) || (tol > TIPC_MAX_LINK_TOL))
+			return -EINVAL;
+	}
+
+	if (props[TIPC_NLA_PROP_WIN]) {
+		u32 win;
+
+		win = nla_get_u32(props[TIPC_NLA_PROP_WIN]);
+		if ((win < TIPC_MIN_LINK_WIN) || (win > TIPC_MAX_LINK_WIN))
+			return -EINVAL;
+	}
+
+	return 0;
+}
diff --git a/net/tipc/link.h b/net/tipc/link.h
index b567a34..4338294 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -37,6 +37,7 @@
 #ifndef _TIPC_LINK_H
 #define _TIPC_LINK_H
 
+#include <net/genetlink.h>
 #include "msg.h"
 #include "node.h"
 
@@ -239,6 +240,8 @@ void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window);
 void tipc_link_retransmit(struct tipc_link *l_ptr,
 			  struct sk_buff *start, u32 retransmits);
 
+int tipc_nl_parse_link_prop(struct nlattr *prop, struct nlattr *props[]);
+
 /*
  * Link sequence number manipulation routines (uses modulo 2**16 arithmetic)
  */
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index ad844d3..af506ae 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/netlink.c: TIPC configuration handling
  *
- * Copyright (c) 2005-2006, Ericsson AB
+ * Copyright (c) 2005-2006, 2014, Ericsson AB
  * Copyright (c) 2005-2007, Wind River Systems
  * All rights reserved.
  *
@@ -36,6 +36,7 @@
 
 #include "core.h"
 #include "config.h"
+#include "bearer.h"
 #include <net/genetlink.h>
 
 static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
@@ -68,6 +69,12 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 	return 0;
 }
 
+static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
+	[TIPC_NLA_UNSPEC]	= { .type = NLA_UNSPEC, },
+	[TIPC_NLA_BEARER]	= { .type = NLA_NESTED, },
+};
+
+/* Legacy ASCII API */
 static struct genl_family tipc_genl_family = {
 	.id		= GENL_ID_GENERATE,
 	.name		= TIPC_GENL_NAME,
@@ -76,6 +83,7 @@ static struct genl_family tipc_genl_family = {
 	.maxattr	= 0,
 };
 
+/* Legacy ASCII API */
 static struct genl_ops tipc_genl_ops[] = {
 	{
 		.cmd		= TIPC_GENL_CMD,
@@ -83,12 +91,43 @@ static struct genl_ops tipc_genl_ops[] = {
 	},
 };
 
+/* Users of the legacy API (tipc-config) can't handle that we add operations,
+ * so we have a separate genl handling for the new API.
+ */
+struct genl_family tipc_genl_v2_family = {
+	.id		= GENL_ID_GENERATE,
+	.name		= TIPC_GENL_V2_NAME,
+	.version	= TIPC_GENL_V2_VERSION,
+	.hdrsize	= 0,
+	.maxattr	= TIPC_NLA_MAX,
+};
+
+static const struct genl_ops tipc_genl_v2_ops[] = {
+	{
+		.cmd	= TIPC_NL_BEARER_DISABLE,
+		.doit	= tipc_nl_bearer_disable,
+		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_BEARER_ENABLE,
+		.doit	= tipc_nl_bearer_enable,
+		.policy = tipc_nl_policy,
+	}
+};
+
 int tipc_netlink_start(void)
 {
 	int res;
 
 	res = genl_register_family_with_ops(&tipc_genl_family, tipc_genl_ops);
 	if (res) {
+		pr_err("Failed to register legacy interface\n");
+		return res;
+	}
+
+	res = genl_register_family_with_ops(&tipc_genl_v2_family,
+					    tipc_genl_v2_ops);
+	if (res) {
 		pr_err("Failed to register netlink interface\n");
 		return res;
 	}
@@ -98,4 +137,5 @@ int tipc_netlink_start(void)
 void tipc_netlink_stop(void)
 {
 	genl_unregister_family(&tipc_genl_family);
+	genl_unregister_family(&tipc_genl_v2_family);
 }
diff --git a/net/tipc/netlink.h b/net/tipc/netlink.h
new file mode 100644
index 0000000..e9980c0
--- /dev/null
+++ b/net/tipc/netlink.h
@@ -0,0 +1,41 @@
+/*
+ * net/tipc/netlink.h: Include file for TIPC netlink code
+ *
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
+#ifndef _TIPC_NETLINK_H
+#define _TIPC_NETLINK_H
+
+extern struct genl_family tipc_genl_v2_family;
+
+#endif
-- 
1.7.10.4


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
