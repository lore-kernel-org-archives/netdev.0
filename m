From: akpm@linux-foundation.org
Subject: [patch 1/1] cgroups: net_cls as module
Date: Tue, 23 Mar 2010 11:24:03 -0400
Message-ID: <201003231824.o2NIOtRD018169@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	bblum@andrew.cmu.edu, kamezawa.hiroyu@jp.fujitsu.com,
	laijs@cn.fujitsu.com, lizf@cn.fujitsu.com, menage@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41748 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750864Ab0CWSZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 14:25:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Blum <bblum@andrew.cmu.edu>

Allows the net_cls cgroup subsystem to be compiled as a module

This patch modifies net/sched/cls_cgroup.c to allow the net_cls subsystem
to be optionally compiled as a module instead of builtin.  The
cgroup_subsys struct is moved around a bit to allow the subsys_id to be
either declared as a compile-time constant by the cgroup_subsys.h include
in cgroup.h, or, if it's a module, initialized within the struct by
cgroup_load_subsys.

Signed-off-by: Ben Blum <bblum@andrew.cmu.edu>
Acked-by: Li Zefan <lizf@cn.fujitsu.com>
Cc: Paul Menage <menage@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sched/Kconfig      |    5 ++++-
 net/sched/cls_cgroup.c |   36 +++++++++++++++++++++++++++---------
 2 files changed, 31 insertions(+), 10 deletions(-)

diff -puN net/sched/Kconfig~cgroups-net_cls-as-module net/sched/Kconfig
--- a/net/sched/Kconfig~cgroups-net_cls-as-module
+++ a/net/sched/Kconfig
@@ -328,13 +328,16 @@ config NET_CLS_FLOW
 	  module will be called cls_flow.
 
 config NET_CLS_CGROUP
-	bool "Control Group Classifier"
+	tristate "Control Group Classifier"
 	select NET_CLS
 	depends on CGROUPS
 	---help---
 	  Say Y here if you want to classify packets based on the control
 	  cgroup of their process.
 
+	  To compile this code as a module, choose M here: the
+	  module will be called cls_cgroup.
+
 config NET_EMATCH
 	bool "Extended Matches"
 	select NET_CLS
diff -puN net/sched/cls_cgroup.c~cgroups-net_cls-as-module net/sched/cls_cgroup.c
--- a/net/sched/cls_cgroup.c~cgroups-net_cls-as-module
+++ a/net/sched/cls_cgroup.c
@@ -24,6 +24,25 @@ struct cgroup_cls_state
 	u32 classid;
 };
 
+static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
+					       struct cgroup *cgrp);
+static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
+static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
+
+struct cgroup_subsys net_cls_subsys = {
+	.name		= "net_cls",
+	.create		= cgrp_create,
+	.destroy	= cgrp_destroy,
+	.populate	= cgrp_populate,
+#ifdef CONFIG_NET_CLS_CGROUP
+	.subsys_id	= net_cls_subsys_id,
+#else
+#define net_cls_subsys_id net_cls_subsys.subsys_id
+#endif
+	.module		= THIS_MODULE,
+};
+
+
 static inline struct cgroup_cls_state *cgrp_cls_state(struct cgroup *cgrp)
 {
 	return container_of(cgroup_subsys_state(cgrp, net_cls_subsys_id),
@@ -79,14 +98,6 @@ static int cgrp_populate(struct cgroup_s
 	return cgroup_add_files(cgrp, ss, ss_files, ARRAY_SIZE(ss_files));
 }
 
-struct cgroup_subsys net_cls_subsys = {
-	.name		= "net_cls",
-	.create		= cgrp_create,
-	.destroy	= cgrp_destroy,
-	.populate	= cgrp_populate,
-	.subsys_id	= net_cls_subsys_id,
-};
-
 struct cls_cgroup_head
 {
 	u32			handle;
@@ -277,12 +288,19 @@ static struct tcf_proto_ops cls_cgroup_o
 
 static int __init init_cgroup_cls(void)
 {
-	return register_tcf_proto_ops(&cls_cgroup_ops);
+	int ret = register_tcf_proto_ops(&cls_cgroup_ops);
+	if (ret)
+		return ret;
+	ret = cgroup_load_subsys(&net_cls_subsys);
+	if (ret)
+		unregister_tcf_proto_ops(&cls_cgroup_ops);
+	return ret;
 }
 
 static void __exit exit_cgroup_cls(void)
 {
 	unregister_tcf_proto_ops(&cls_cgroup_ops);
+	cgroup_unload_subsys(&net_cls_subsys);
 }
 
 module_init(init_cgroup_cls);
_
