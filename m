From: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 03/11] SUNRPC: sysctl root for debug table introduced
Date: Wed, 14 Dec 2011 14:45:05 +0300
Message-ID: <20111214104505.3991.45390.stgit@localhost6.localdomain6>
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111214103602.3991.20990.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sysctl root is required for handliong sysctl dentries per network namespace
context. IOW, it's "lookup" method will be used to find per-net sysctl's set in
further patches.
Also this patch modifies sysctl registering helpers to make them use new sysctl
root.

Signed-off-by: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

---
 net/sunrpc/sysctl.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index 64c0034..f6e7da2 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -39,6 +39,9 @@ EXPORT_SYMBOL_GPL(nlm_debug);
 
 #ifdef RPC_DEBUG
 
+#include <linux/nsproxy.h>
+#include <net/net_namespace.h>
+
 static struct ctl_table_header *sunrpc_table_header;
 static ctl_table		debug_table[];
 
@@ -47,18 +50,24 @@ struct ctl_path sunrpc_path[] = {
 	{ },
 };
 
+static struct ctl_table_root sunrpc_debug_root = {
+};
+
 struct ctl_table_header *register_sunrpc_sysctl(struct ctl_table *table)
 {
-	return register_sysctl_paths(sunrpc_path, table);
-
+	return __register_sysctl_paths(&sunrpc_debug_root, current->nsproxy,
+				       sunrpc_path, table);
 }
 EXPORT_SYMBOL_GPL(register_sunrpc_sysctl);
 
 void
 rpc_register_sysctl(void)
 {
-	if (!sunrpc_table_header)
+	if (!sunrpc_table_header) {
+		setup_sysctl_set(&sunrpc_debug_root.default_set, NULL, NULL);
+		register_sysctl_root(&sunrpc_debug_root);
 		sunrpc_table_header = register_sunrpc_sysctl(debug_table);
+	}
 }
 
 void
@@ -66,6 +75,7 @@ rpc_unregister_sysctl(void)
 {
 	if (sunrpc_table_header) {
 		unregister_sysctl_table(sunrpc_table_header);
+		unregister_sysctl_root(&sunrpc_debug_root);
 		sunrpc_table_header = NULL;
 	}
 }

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
