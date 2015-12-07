From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/8] netprio_cgroup: limit the maximum css->id to USHRT_MAX
Date: Mon,  7 Dec 2015 17:38:51 -0500
Message-ID: <1449527935-27056-5-git-send-email-tj@kernel.org>
References: <1449527935-27056-1-git-send-email-tj@kernel.org>
Cc: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-team-b10kYP2dOMg@public.gmane.org, ninasc-b10kYP2dOMg@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449527935-27056-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

netprio builds per-netdev contiguous priomap array which is indexed by
css->id.  The array is allocated using kzalloc() effectively limiting
the maximum ID supported to some thousand range.  This patch caps the
maximum supported css->id to USHRT_MAX which should be way above what
is actually useable.

This allows reducing sock->sk_cgrp_prioidx to u16 from u32.  The freed
up part will be used to overload the cgroup related fields.
sock->sk_cgrp_prioidx's position is swapped with sk_mark so that the
two cgroup related fields are adjacent.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
CC: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 include/net/sock.h        | 10 +++++-----
 net/core/netprio_cgroup.c |  9 +++++++++
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 6f58b84..a95bcf7 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -288,7 +288,6 @@ struct cg_proto;
   *	@sk_ack_backlog: current listen backlog
   *	@sk_max_ack_backlog: listen backlog set in listen()
   *	@sk_priority: %SO_PRIORITY setting
-  *	@sk_cgrp_prioidx: socket group's priority map index
   *	@sk_type: socket type (%SOCK_STREAM, etc)
   *	@sk_protocol: which protocol this socket belongs in this network family
   *	@sk_peer_pid: &struct pid for this socket's peer
@@ -309,6 +308,7 @@ struct cg_proto;
   *	@sk_send_head: front of stuff to transmit
   *	@sk_security: used by security modules
   *	@sk_mark: generic packet mark
+  *	@sk_cgrp_prioidx: socket group's priority map index
   *	@sk_classid: this socket's cgroup classid
   *	@sk_cgrp: this socket's cgroup-specific proto data
   *	@sk_write_pending: a write to stream socket waits to start
@@ -425,9 +425,7 @@ struct sock {
 	u32			sk_ack_backlog;
 	u32			sk_max_ack_backlog;
 	__u32			sk_priority;
-#if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
-	__u32			sk_cgrp_prioidx;
-#endif
+	__u32			sk_mark;
 	struct pid		*sk_peer_pid;
 	const struct cred	*sk_peer_cred;
 	long			sk_rcvtimeo;
@@ -445,7 +443,9 @@ struct sock {
 #ifdef CONFIG_SECURITY
 	void			*sk_security;
 #endif
-	__u32			sk_mark;
+#if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
+	u16			sk_cgrp_prioidx;
+#endif
 #ifdef CONFIG_CGROUP_NET_CLASSID
 	u32			sk_classid;
 #endif
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index cbd0a19..2b9159b 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -27,6 +27,12 @@
 
 #include <linux/fdtable.h>
 
+/*
+ * netprio allocates per-net_device priomap array which is indexed by
+ * css->id.  Limiting css ID to 16bits doesn't lose anything.
+ */
+#define NETPRIO_ID_MAX		USHRT_MAX
+
 #define PRIOMAP_MIN_SZ		128
 
 /*
@@ -144,6 +150,9 @@ static int cgrp_css_online(struct cgroup_subsys_state *css)
 	struct net_device *dev;
 	int ret = 0;
 
+	if (css->id > NETPRIO_ID_MAX)
+		return -ENOSPC;
+
 	if (!parent_css)
 		return 0;
 
-- 
2.5.0
