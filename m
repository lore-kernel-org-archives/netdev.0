From: Bryan Schumaker <bjschuma-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] NFS: Fix infinite loop in gss_create_upcall()
Date: Tue, 12 Apr 2011 13:41:04 -0400
Message-ID: <4DA48EB0.40600@netapp.com>
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org> <4D96E4C5.2080302@suse.cz> <1302122693.16786.0.camel@lade.trondhjem.org> <4D9D5CC9.2040002@suse.cz> <4DA36722.2020402@suse.cz> <4DA36758.4070203@suse.cz> <4DA36DB6.8060108@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	mm-commits-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ML netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4DA36DB6.8060108-AlSwsSmVLrQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/11/2011 05:08 PM, Jiri Slaby wrote:
> 
> Sorry for an extra message. I've just found out that there appears
> messages in dmesg:
> [   58.656048] RPC: AUTH_GSS upcall timed out.
> [   58.656050] Please check user daemon is running.
> [   88.656065] RPC: AUTH_GSS upcall timed out.
> [   88.656068] Please check user daemon is running.
> [  118.656077] RPC: AUTH_GSS upcall timed out.
> [  118.656080] Please check user daemon is running.
> [  148.656049] RPC: AUTH_GSS upcall timed out.
> [  148.656052] Please check user daemon is running.
> [  178.656046] RPC: AUTH_GSS upcall timed out.
> [  178.656049] Please check user daemon is running.
> 
> 
> I instrumented the code and it's stuck with trying RPC_AUTH_GSS_KRB5.
> 
> I don't use GSS at all.
> 
> regards,

Does this patch help?

- Bryan



There can be an infinite loop if gss_create_upcall() is called without
the userspace program running.  To prevent this, we return -EACCES if
we notice that pipe_version hasn't changed (indicating that the pipe
has not been opened).

Signed-off-by: Bryan Schumaker <bjschuma-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
--
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9bf41ea..8a03ee0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2224,8 +2224,9 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 
 	for (i = 0; i < len; i++) {
 		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
-		if (status != -EPERM)
-			break;
+		if (status == -EPERM || status == -EACCES)
+			continue;
+		break;
 	}
 	if (status == 0)
 		status = nfs4_server_capabilities(server, fhandle);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index f3914d0..339ba64 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -520,7 +520,7 @@ gss_refresh_upcall(struct rpc_task *task)
 		warn_gssd();
 		task->tk_timeout = 15*HZ;
 		rpc_sleep_on(&pipe_version_rpc_waitqueue, task, NULL);
-		return 0;
+		return -EAGAIN;
 	}
 	if (IS_ERR(gss_msg)) {
 		err = PTR_ERR(gss_msg);
@@ -563,10 +563,12 @@ retry:
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		err = wait_event_interruptible_timeout(pipe_version_waitqueue,
 				pipe_version >= 0, 15*HZ);
+		if (pipe_version < 0) {
+			warn_gssd();
+			err = -EACCES;
+		}
 		if (err)
 			goto out;
-		if (pipe_version < 0)
-			warn_gssd();
 		goto retry;
 	}
 	if (IS_ERR(gss_msg)) {


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
