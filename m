From: Daniel Mack <daniel@zonque.org>
Subject: [RFC PATCH 2/5] cgroup: add bpf_{e,in}gress pointers
Date: Wed, 17 Aug 2016 16:00:45 +0200
Message-ID: <1471442448-1248-3-git-send-email-daniel@zonque.org>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
	pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
	Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:47315 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752472AbcHQOLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 10:11:15 -0400
In-Reply-To: <1471442448-1248-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two pointers for eBPF programs to struct cgroup. These will be used
to store programs for ingress and egress for accounting and filtering.

This new feature is guarded by CONFIG_CGROUP_BPF.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 include/linux/cgroup-defs.h | 6 ++++++
 init/Kconfig                | 8 ++++++++
 kernel/cgroup.c             | 9 +++++++++
 3 files changed, 23 insertions(+)

diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 5b17de6..cff3560 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -300,6 +300,12 @@ struct cgroup {
 	/* used to schedule release agent */
 	struct work_struct release_agent_work;
 
+#ifdef CONFIG_CGROUP_BPF
+	/* used by the networking layer */
+	struct bpf_prog *bpf_ingress;
+	struct bpf_prog *bpf_egress;
+#endif
+
 	/* ids of the ancestors at each level including self */
 	int ancestor_ids[];
 };
diff --git a/init/Kconfig b/init/Kconfig
index cac3f09..8bf2f3e 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1144,6 +1144,14 @@ config CGROUP_PERF
 
 	  Say N if unsure.
 
+config CGROUP_BPF
+	bool "Enable eBPF programs in cgroups"
+	depends on BPF_SYSCALL
+	help
+	  This options allows cgroups to accommodate eBPF programs that
+	  can be used for network traffic filtering and accounting. See
+	  Documentation/networking/filter.txt for more information.
+
 config CGROUP_DEBUG
 	bool "Example controller"
 	default n
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d1c51b7..65e5701 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -62,6 +62,7 @@
 #include <linux/proc_ns.h>
 #include <linux/nsproxy.h>
 #include <linux/file.h>
+#include <linux/bpf.h>
 #include <net/sock.h>
 
 /*
@@ -5461,6 +5462,14 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	for_each_css(css, ssid, cgrp)
 		kill_css(css);
 
+#ifdef CONFIG_CGROUP_BPF
+	if (cgrp->bpf_ingress)
+		bpf_prog_put(cgrp->bpf_ingress);
+
+	if (cgrp->bpf_egress)
+		bpf_prog_put(cgrp->bpf_egress);
+#endif
+
 	/*
 	 * Remove @cgrp directory along with the base files.  @cgrp has an
 	 * extra ref on its kn.
-- 
2.5.5
