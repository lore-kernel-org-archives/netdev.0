From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/25] NFS: Change nfs4_set_client() to accept
	(sockaddr *, len)
Date: Tue, 13 Nov 2007 13:32:30 -0500
Message-ID: <20071113183230.5087.65127.stgit@manray.1015granger.net>
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

Adjust the arguments and callers of nfs4_set_client() to pass a "struct
sockaddr *" and a length instead of a "struct sockaddr_in *" to support
non-IPv4 addresses in the NFS client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/client.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5e53892..37b63a6 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -914,7 +914,9 @@ error:
  * Set up an NFS4 client
  */
 static int nfs4_set_client(struct nfs_server *server,
-		const char *hostname, const struct sockaddr_in *addr,
+		const char *hostname,
+		const struct sockaddr *addr,
+		const size_t addrlen,
 		const char *ip_addr,
 		rpc_authflavor_t authflavour,
 		int proto, int timeo, int retrans)
@@ -925,8 +927,7 @@ static int nfs4_set_client(struct nfs_server *server,
 	dprintk("--> nfs4_set_client()\n");
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(hostname, (struct sockaddr *)addr,
-				sizeof(*addr), 4);
+	clp = nfs_get_client(hostname, addr, addrlen, 4);
 	if (IS_ERR(clp)) {
 		error = PTR_ERR(clp);
 		goto error;
@@ -997,7 +998,8 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	/* Get a client record */
 	error = nfs4_set_client(server,
 			data->nfs_server.hostname,
-			&data->nfs_server.address,
+			(struct sockaddr *)&data->nfs_server.address,
+			sizeof(data->nfs_server.address),
 			data->client_address,
 			data->auth_flavors[0],
 			data->nfs_server.protocol,
@@ -1073,7 +1075,8 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	/* Get a client representation.
 	 * Note: NFSv4 always uses TCP, */
 	error = nfs4_set_client(server, data->hostname,
-			(struct sockaddr_in *)data->addr,
+			data->addr,
+			sizeof(*data->addr),
 			parent_client->cl_ipaddr,
 			data->authflavor,
 			parent_server->client->cl_xprt->prot,


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
