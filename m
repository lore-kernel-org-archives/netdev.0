From: Anoop Naravaram <anaravaram@google.com>
Subject: [PATCH 1/5] net: create the networking cgroup controller
Date: Wed, 10 Aug 2016 17:53:14 -0700
Message-ID: <1470876798-4024-2-git-send-email-anaravaram@google.com>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
Cc: edumazet@google.com, maheshb@google.com, weiwan@google.com,
	tom@herbertland.com, Anoop Naravaram <anaravaram@google.com>
To: corbet@lwn.net, tj@kernel.org, lizefan@huawei.com,
	hannes@cmpxchg.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-doc@vger.kernel.org, cgroups@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1470876798-4024-1-git-send-email-anaravaram@google.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a skeleton implementation of a cgroup controller for networking
properties. It will be used for:
* limiting the specific ports that a process in a cgroup is allowed to bind
  to or listen on
* restricting which dscp values processes can use with their sockets
* limiting the total number of udp ports that can be used by a process

Also there is new documentation of this controller in
Documentation/cgroup-v1/net.txt.

Signed-off-by: Anoop Naravaram <anaravaram@google.com>
---
 Documentation/cgroup-v1/net.txt |  9 ++++++
 include/linux/cgroup_subsys.h   |  4 +++
 include/net/net_cgroup.h        | 27 ++++++++++++++++++
 net/Kconfig                     | 10 +++++++
 net/core/Makefile               |  1 +
 net/core/net_cgroup.c           | 62 +++++++++++++++++++++++++++++++++++++++++
 6 files changed, 113 insertions(+)
 create mode 100644 Documentation/cgroup-v1/net.txt
 create mode 100644 include/net/net_cgroup.h
 create mode 100644 net/core/net_cgroup.c

diff --git a/Documentation/cgroup-v1/net.txt b/Documentation/cgroup-v1/net.txt
new file mode 100644
index 0000000..580c214
--- /dev/null
+++ b/Documentation/cgroup-v1/net.txt
@@ -0,0 +1,9 @@
+Networking cgroup
+=================
+
+The net cgroup controller keeps track of the following networking related
+properties for each process group:
+* bind port ranges
+* listen port ranges
+* dscp ranges
+* udp port usage and limit
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 0df0336a..81ff75b 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -40,6 +40,10 @@ SUBSYS(freezer)
 SUBSYS(net_cls)
 #endif
 
+#if IS_ENABLED(CONFIG_CGROUP_NET)
+SUBSYS(net)
+#endif
+
 #if IS_ENABLED(CONFIG_CGROUP_PERF)
 SUBSYS(perf_event)
 #endif
diff --git a/include/net/net_cgroup.h b/include/net/net_cgroup.h
new file mode 100644
index 0000000..8e98803
--- /dev/null
+++ b/include/net/net_cgroup.h
@@ -0,0 +1,27 @@
+/*
+ * net_cgroup.h			Networking Control Group
+ *
+ * Copyright (C) 2016 Google, Inc.
+ *
+ * Authors:	Anoop Naravaram <anaravaram@google.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ */
+
+#ifndef _NET_CGROUP_H
+#define _NET_CGROUP_H
+
+#include <linux/cgroup.h>
+
+#ifdef CONFIG_CGROUP_NET
+
+struct net_cgroup {
+	struct cgroup_subsys_state	css;
+};
+
+#endif /* CONFIG_CGROUP_NET */
+#endif  /* _NET_CGROUP_H */
diff --git a/net/Kconfig b/net/Kconfig
index c2cdbce..47f68bd 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -278,6 +278,16 @@ config CGROUP_NET_CLASSID
 	  Cgroup subsystem for use as general purpose socket classid marker that is
 	  being used in cls_cgroup and for netfilter matching.
 
+config CGROUP_NET
+	bool "Networking cgroup"
+	depends on CGROUPS
+	---help---
+	  Cgroup subsystem for use in managing several networking properties,
+	  such as restricting which ports are available for processes to bind
+	  and listen on, restricting which dscp values processes can use with
+	  their sockets, and limiting the number of udp ports that can be
+	  acquired by processes from the cgroup.
+
 config NET_RX_BUSY_POLL
 	bool
 	default y
diff --git a/net/core/Makefile b/net/core/Makefile
index d6508c2..9dbc8b6 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
 obj-$(CONFIG_NET_PTP_CLASSIFY) += ptp_classifier.o
 obj-$(CONFIG_CGROUP_NET_PRIO) += netprio_cgroup.o
 obj-$(CONFIG_CGROUP_NET_CLASSID) += netclassid_cgroup.o
+obj-$(CONFIG_CGROUP_NET) += net_cgroup.o
 obj-$(CONFIG_LWTUNNEL) += lwtunnel.o
 obj-$(CONFIG_DST_CACHE) += dst_cache.o
 obj-$(CONFIG_HWBM) += hwbm.o
diff --git a/net/core/net_cgroup.c b/net/core/net_cgroup.c
new file mode 100644
index 0000000..3a46960
--- /dev/null
+++ b/net/core/net_cgroup.c
@@ -0,0 +1,62 @@
+/*
+ * net/core/net_cgroup.c	Networking Control Group
+ *
+ * Copyright (C) 2016 Google, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * Authors:	Anoop Naravaram <anaravaram@google.com>
+ */
+
+#include <linux/slab.h>
+#include <net/net_cgroup.h>
+
+static struct net_cgroup *css_to_net_cgroup(struct cgroup_subsys_state *css)
+{
+	return css ? container_of(css, struct net_cgroup, css) : NULL;
+}
+
+static struct net_cgroup *task_to_net_cgroup(struct task_struct *p)
+{
+	return css_to_net_cgroup(task_css(p, net_cgrp_id));
+}
+
+static struct net_cgroup *net_cgroup_to_parent(struct net_cgroup *netcg)
+{
+	return css_to_net_cgroup(netcg->css.parent);
+}
+
+static void free_net_cgroup(struct net_cgroup *netcg)
+{
+	kfree(netcg);
+}
+
+static struct cgroup_subsys_state *
+cgrp_css_alloc(struct cgroup_subsys_state *parent_css)
+{
+	struct net_cgroup *netcg;
+
+	netcg = kzalloc(sizeof(*netcg), GFP_KERNEL);
+	if (!netcg)
+		return ERR_PTR(-ENOMEM);
+
+	return &netcg->css;
+}
+
+static void cgrp_css_free(struct cgroup_subsys_state *css)
+{
+	free_net_cgroup(css_to_net_cgroup(css));
+}
+
+static struct cftype ss_files[] = {
+	{ }	/* terminate */
+};
+
+struct cgroup_subsys net_cgrp_subsys = {
+	.css_alloc		= cgrp_css_alloc,
+	.css_free		= cgrp_css_free,
+	.legacy_cftypes		= ss_files,
+};
-- 
2.8.0.rc3.226.g39d4020

