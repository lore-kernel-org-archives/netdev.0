From: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] NFS: NFSROOT should default to "proto=udp"
Date: Thu, 10 Feb 2011 12:46:44 -0500
Message-ID: <20110210174644.3073.91582.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: trond.myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There have been a number of recent reports that NFSROOT is no longer
working with default mount options, but fails only with certain NICs.

Brian Downing <bdowning-oU/tDdhfGLReoWH0uzbU5w@public.gmane.org> bisected to commit 56463e50 "NFS:
Use super.c for NFSROOT mount option parsing".  Among other things,
this commit changes the default mount options for NFSROOT to use TCP
instead of UDP as the underlying transport.

TCP seems less able to deal with NICs that are slow to initialize.
The system logs that have accompanied reports of problems all show
that NFSROOT attempts to establish a TCP connection before the NIC is
fully initialized, and thus the TCP connection attempt fails.

Because NFSROOT is used in some environments where it is not possible
to update the kernel command line to specify "udp", the proper thing
to do is change NFSROOT to use UDP by default, as it did before commit
56463e50.

To make it easier to see how to change default mount options for
NFSROOT and to distinguish default settings from mandatory settings,
I've adjusted a couple of areas to document the specifics.

Tested-by: Brian Downing <bdowning-oU/tDdhfGLReoWH0uzbU5w@public.gmane.org>
Signed-off-by: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> # 2.6.37
---

 fs/nfs/nfsroot.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 903908a..0bc654f 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -86,11 +86,14 @@
 /* Default path we try to mount. "%s" gets replaced by our IP address */
 #define NFS_ROOT		"/tftpboot/%s"
 
+/* Default NFSROOT mount options. */
+#define NFS_DEF_OPTIONS		"udp"
+
 /* Parameters passed from the kernel command line */
 static char nfs_root_parms[256] __initdata = "";
 
 /* Text-based mount options passed to super.c */
-static char nfs_root_options[256] __initdata = "";
+static char nfs_root_options[256] __initdata = NFS_DEF_OPTIONS;
 
 /* Address of NFS server */
 static __be32 servaddr __initdata = htonl(INADDR_NONE);
@@ -217,7 +220,7 @@ static int __init root_nfs_parse_options(char *incoming, char *exppath,
  */
 static int __init root_nfs_data(char *cmdline)
 {
-	char addr_option[sizeof("nolock,addr=") + INET_ADDRSTRLEN + 1];
+	char mand_options[sizeof("nolock,addr=") + INET_ADDRSTRLEN + 1];
 	int len, retval = -1;
 	char *tmp = NULL;
 	const size_t tmplen = sizeof(nfs_export_path);
@@ -244,9 +247,9 @@ static int __init root_nfs_data(char *cmdline)
 	 * Append mandatory options for nfsroot so they override
 	 * what has come before
 	 */
-	snprintf(addr_option, sizeof(addr_option), "nolock,addr=%pI4",
+	snprintf(mand_options, sizeof(mand_options), "nolock,addr=%pI4",
 			&servaddr);
-	if (root_nfs_cat(nfs_root_options, addr_option,
+	if (root_nfs_cat(nfs_root_options, mand_options,
 						sizeof(nfs_root_options)))
 		goto out_optionstoolong;
 

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
