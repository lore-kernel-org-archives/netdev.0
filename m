From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 2/3] net: flow: Introduce flow table hairpin API
Date: Wed, 18 Feb 2015 14:25:58 -0500
Message-ID: <1424287559-25700-3-git-send-email-simon.horman@netronome.com>
References: <1424287559-25700-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:51599 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709AbbBRT0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 14:26:25 -0500
Received: by mail-yk0-f174.google.com with SMTP id 9so1873435ykp.5
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 11:26:24 -0800 (PST)
In-Reply-To: <1424287559-25700-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

*** Not for Upstream Merge
*** For informational purposes only

This introduces an netlink API to allow the Flow API to be hairpined
back to user-space thus allowing the NDOs of the Flow API to be backed there.

This will be used by a follow-up patch.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/linux/if_flow_hairpin.h      |   6 ++
 include/uapi/linux/if_flow_hairpin.h | 159 +++++++++++++++++++++++++++++++++++
 2 files changed, 165 insertions(+)
 create mode 100644 include/linux/if_flow_hairpin.h
 create mode 100644 include/uapi/linux/if_flow_hairpin.h

diff --git a/include/linux/if_flow_hairpin.h b/include/linux/if_flow_hairpin.h
new file mode 100644
index 0000000..d958f8d
--- /dev/null
+++ b/include/linux/if_flow_hairpin.h
@@ -0,0 +1,6 @@
+#ifndef _LINUX_IF_FLOW_HAIRPIN_H
+#define _LINUX_IF_FLOW_HAIRPIN_H
+
+#include <uapi/linux/if_flow_hairpin.h>
+
+#endif
diff --git a/include/uapi/linux/if_flow_hairpin.h b/include/uapi/linux/if_flow_hairpin.h
new file mode 100644
index 0000000..eb4cbd8
--- /dev/null
+++ b/include/uapi/linux/if_flow_hairpin.h
@@ -0,0 +1,159 @@
+/*
+ * include/uapi/linux/if_flow_hairpin.h -
+ * Hairpin to allow the messages of the Flow table interface for
+ * Swtich devices to be forwarded to user-space
+ * Copyright (c) 2014 Simon Horman <simon.horman@netronome.com>
+ *
+ * Based on: Flow table interface for Switch devices
+ * Copyright (c) 2014 John Fastabend <john.r.fastabend@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Author: Simon Horman <simon.horman@netronome.com>
+ */
+
+/* Netlink description:
+ *
+ * The NFL_* attributes contained in NFLH_ENCAP_ATTR
+ * should also include their nested attributes, as described in
+ * include/uapi/linux/if_flow.h.
+
+ * Set Listener <Request>,
+ * Get Listener <Request> and
+ * Get Listener <Reply> description.
+ *
+ * Set Listener registers netlink port ids to receive flow deletion
+ * notifications if the NFLH_LISTENER_ATTR_PIDS attribute is
+ * present. Otherwise it unregisters port ids if they were previously
+ * registered by a Set Listener with the
+ * NFLH_LISTENER_ATTR_PIDS attribute present.
+ *
+ * Get Listener reports the port ids if they were previously registered by
+ * a Set Listener with the NFLH_LISTENER_ATTR_PIDS.  If no ids
+ * are registered then the NFLH_LISTENER_ATTR_PIDS attribute of
+ * the reply should be omitted.
+ *
+ * The NFLH_LISTENER_ATTR_PIDS attribute is an array of u32
+ * values. If the attribute is present then it must contain at least one
+ * element. The implementation may choose to ignore some elements.
+ * Currently the implementation ignores all elements other than the first
+ * one.
+ *
+ *
+ * [NFLH_LISTENER]
+ *   [NFLH_LISTENER_ATTR_TYPE]
+ *   [NFLH_LISTENER_ATTR_PIDS]
+ *
+ * Message used to encapsulate both a NFL message forwardeded from
+ * the kernel to user-space as a notification, and the reply of processing
+ * that message sent from user-space to the kernel. In the case of the
+ * former NFLH_ENCAP_STATUS whould be omitted. In the case
+ * of the latter it should be included and its value should be 0 on success
+ * otherwise a negative error code.
+ *
+ * [NFLH_ENCAP]
+ *   [NFLH_ENCAP_CMD_TYPE]
+ *   [NFLH_ENCAP_CMD]
+ *   [NFLH_ENCAP_SEQ]
+ *   [NFLH_ENCAP_STATUS]
+ *   [NFLH_ENCAP_ATTR]
+ *     [NFL_TABLES]
+ *     [NFL_HEADERS]
+ *     [NFL_ACTIONS]
+ *     [NFL_HEADER_GRAPH]
+ *     [NFL_TABLE_GRAPH]
+ *     [NFL_FLOWS]
+ *     [NFL_FLOWS_ERROR]
+ */
+
+#ifndef _UAPI_LINUX_IF_FLOW_HAIRPIN
+#define _UAPI_LINUX_IF_FLOW_HAIRPIN
+
+#include <linux/types.h>
+
+/**
+ * @struct net_flow_hairpin_encap_header
+ * @brief defines the header of an encapsulated message
+ *
+ * @cmd_type: type of inner command
+ * @cmd: identifier of inner command
+ * @status: status of command execution
+ * @seq: sequence number of request
+ */
+struct net_flow_hairpin_encap_header {
+	__u32 cmd_type;
+	__u32 cmd;
+	__u64 seq;
+	__s32 status;
+};
+
+enum {
+	NFLH_LISTENER_ATTR_TYPE_ENCAP,
+};
+
+enum {
+	NFLH_LISTENER_ATTR_UNSPEC,
+	NFLH_LISTENER_ATTR_TYPE,
+	NFLH_LISTENER_ATTR_PIDS,
+	__NFLH_LISTENER_ATTR_MAX,
+};
+#define NFLH_LISTENER_ATTR_MAX (__NFLH_LISTENER_ATTR_MAX - 1)
+
+enum {
+	/* A Net Flow Table Command is used */
+	NFLH_ENCAP_CMD_NFL_CMD,
+};
+
+enum {
+	/* A Net Flow Table Command is used */
+	NFLH_ENCAP_STATUS_OK,
+	NFLH_ENCAP_STATUS_EINVAL,
+	NFLH_ENCAP_STATUS_EOPNOTSUPP,
+};
+
+enum {
+	NFLH_ENCAP_UNSPEC,
+	NFLH_ENCAP_CMD_TYPE,
+	NFLH_ENCAP_CMD,
+	NFLH_ENCAP_SEQ,
+	NFLH_ENCAP_STATUS,
+	NFLH_ENCAP_ATTR,
+	__NFLH_ENCAP_MAX,
+};
+#define NFLH_ENCAP_MAX (__NFLH_ENCAP_MAX - 1)
+
+enum {
+	NFLH_UNSPEC,
+
+	NFLH_ENCAP,
+	NFLH_LISTENER,
+
+	__NFLH_MAX,
+};
+#define NFLH_MAX (__NFLH_MAX - 1)
+
+enum {
+	/* Userspace commands. */
+	NFLH_CMD_SET_LISTENER,
+	NFLH_CMD_GET_LISTENER,
+
+	/* Both userspace commands and Kernel-to-user notifications. */
+	NFLH_CMD_ENCAP,
+
+	__NFLH_CMD_MAX,
+	NFLH_CMD_MAX = (__NFLH_CMD_MAX - 1),
+};
+
+#define NFLH_GENL_NAME "net_flow_hp"
+#define NFLH_GENL_VERSION 0x1
+#endif /* _UAPI_LINUX_IF_FLOW_HAIRPIN */
-- 
2.1.4
