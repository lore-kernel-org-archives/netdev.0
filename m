From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/25] NFS: Adjust nfs_clone_mount structure to store
	"struct	sockaddr *"
Date: Tue, 13 Nov 2007 13:32:25 -0500
Message-ID: <20071113183225.5087.84047.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Change the addr field in the nfs_clone_mount structure to store a "struct
sockaddr *" to support non-IPv4 addresses in the NFS client.

Note this is mostly a cosmetic change, and does not actually allow
referrals using IPv6 addresses.  The existing referral code assumes that
the server returns a string that represents an IPv4 address.  This code
needs to support hostnames and IPv6 addresses as well as IPv4 addresses,
thus it will need to be restructured in order to handle DNS resolution in
user space.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/client.c        |    3 ++-
 fs/nfs/internal.h      |    2 +-
 fs/nfs/nfs4namespace.c |   11 ++++++-----
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index f03a742..5e53892 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1072,7 +1072,8 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 
 	/* Get a client representation.
 	 * Note: NFSv4 always uses TCP, */
-	error = nfs4_set_client(server, data->hostname, data->addr,
+	error = nfs4_set_client(server, data->hostname,
+			(struct sockaddr_in *)data->addr,
 			parent_client->cl_ipaddr,
 			data->authflavor,
 			parent_server->client->cl_xprt->prot,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ef40539..40f2619 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -21,7 +21,7 @@ struct nfs_clone_mount {
 	struct nfs_fattr *fattr;
 	char *hostname;
 	char *mnt_path;
-	struct sockaddr_in *addr;
+	struct sockaddr *addr;
 	rpc_authflavor_t authflavor;
 };
 
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index bd1b161..65dcbfd 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -172,7 +172,10 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 
 		s = 0;
 		while (s < location->nservers) {
-			struct sockaddr_in addr = {};
+			struct sockaddr_in addr = {
+				.sin_family	= AF_INET,
+				.sin_port	= htons(NFS_PORT),
+			};
 
 			if (location->servers[s].len <= 0 ||
 			    valid_ipaddr4(location->servers[s].data) < 0) {
@@ -181,10 +184,8 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 			}
 
 			mountdata.hostname = location->servers[s].data;
-			addr.sin_addr.s_addr = in_aton(mountdata.hostname);
-			addr.sin_family = AF_INET;
-			addr.sin_port = htons(NFS_PORT);
-			mountdata.addr = &addr;
+			addr.sin_addr.s_addr = in_aton(mountdata.hostname),
+			mountdata.addr = (struct sockaddr *)&addr;
 
 			snprintf(page, PAGE_SIZE, "%s:%s",
 					mountdata.hostname,


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
