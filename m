From: Jan Kaluza <jkaluza@redhat.com>
Subject: [PATCH v3 3/3] Send cgroup_path in SCM_CGROUP
Date: Wed,  4 Sep 2013 08:14:21 +0200
Message-ID: <1378275261-4553-4-git-send-email-jkaluza@redhat.com>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
 <1378275261-4553-1-git-send-email-jkaluza@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	eparis@redhat.com, rgb@redhat.com, tj@kernel.org,
	lizefan@huawei.com, containers@lists.linux-foundation.org,
	cgroups@vger.kernel.org, viro@zeniv.linux.org.uk,
	Jan Kaluza <jkaluza@redhat.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378275261-4553-1-git-send-email-jkaluza@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Server-like processes in many cases need credentials and other
metadata of the peer, to decide if the calling process is allowed to
request a specific action, or the server just wants to log away this
type of information for auditing tasks.

The current practice to retrieve such process metadata is to look that
information up in procfs with the $PID received over SCM_CREDENTIALS.
This is sufficient for long-running tasks, but introduces a race which
cannot be worked around for short-living processes; the calling
process and all the information in /proc/$PID/ is gone before the
receiver of the socket message can look it up.

This introduces a new SCM type called SCM_CGROUP to allow the direct
attaching of "cgroup_path" to SCM, which is significantly more
efficient and will reliably avoid the race with the round-trip over
procfs.

Signed-off-by: Jan Kaluza <jkaluza@redhat.com>
---
 include/linux/socket.h |  1 +
 include/net/af_unix.h  |  1 +
 include/net/scm.h      | 15 +++++++++++++++
 net/core/scm.c         | 18 ++++++++++++++++++
 net/unix/af_unix.c     | 20 ++++++++++++++++++++
 5 files changed, 55 insertions(+)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 6c7ace0..621fff1 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -133,6 +133,7 @@ static inline struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct cmsghdr
 #define SCM_AUDIT	0x04		/* rw: struct uaudit		*/
 #define SCM_PROCINFO	0x05	/* rw: comm + cmdline (NULL terminated
 					   array of char *) */
+#define SCM_CGROUP	0x06		/* rw: cgroup path */
 
 struct ucred {
 	__u32	pid;
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 05c7678..c49bf35 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -32,6 +32,7 @@ struct unix_skb_parms_scm {
 	unsigned int sessionid;
 	char *procinfo;
 	int procinfo_len;
+	char *cgroup_path;
 };
 
 struct unix_skb_parms {
diff --git a/include/net/scm.h b/include/net/scm.h
index 3346030..5398826 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -41,6 +41,7 @@ struct scm_cookie {
 	struct scm_creds	creds;		/* Skb credentials	*/
 	struct scm_audit	audit;		/* Skb audit	*/
 	struct scm_procinfo	procinfo;	/* Skb procinfo */
+	char *cgroup_path;
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Passed security ID 	*/
 #endif
@@ -52,6 +53,7 @@ extern int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie
 extern void __scm_destroy(struct scm_cookie *scm);
 extern struct scm_fp_list * scm_fp_dup(struct scm_fp_list *fpl);
 extern int scm_get_current_procinfo(char **procinfo);
+extern int scm_get_current_cgroup_path(char **cgroup_path);
 
 #ifdef CONFIG_SECURITY_NETWORK
 static __inline__ void unix_get_peersec_dgram(struct socket *sock, struct scm_cookie *scm)
@@ -86,6 +88,12 @@ static inline void scm_set_procinfo(struct scm_cookie *scm,
 	scm->procinfo.len = len;
 }
 
+static inline void scm_set_cgroup_path(struct scm_cookie *scm,
+				    char *cgroup_path)
+{
+	scm->cgroup_path = cgroup_path;
+}
+
 static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
 {
 	put_pid(scm->pid);
@@ -140,6 +148,9 @@ static inline void scm_passec(struct socket *sock, struct msghdr *msg, struct sc
 			security_release_secctx(secdata, seclen);
 		}
 	}
+
+	kfree(scm->cgroup_path);
+	scm->cgroup_path = NULL;
 }
 #else
 static inline void scm_passec(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm)
@@ -172,6 +183,10 @@ static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 		put_cmsg(msg, SOL_SOCKET, SCM_AUDIT, sizeof(uaudits), &uaudits);
 		put_cmsg(msg, SOL_SOCKET, SCM_PROCINFO, scm->procinfo.len,
 				 scm->procinfo.procinfo);
+		if (scm->cgroup_path) {
+			put_cmsg(msg, SOL_SOCKET, SCM_CGROUP,
+				 strlen(scm->cgroup_path), scm->cgroup_path);
+		}
 	}
 
 	scm_destroy_cred(scm);
diff --git a/net/core/scm.c b/net/core/scm.c
index 09ec044..2d408b9 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -404,3 +404,21 @@ out:
 	return res;
 }
 EXPORT_SYMBOL(scm_get_current_procinfo);
+
+int scm_get_current_cgroup_path(char **cgroup_path)
+{
+	int ret = 0;
+
+	*cgroup_path = kmalloc(PATH_MAX, GFP_KERNEL);
+	if (!(*cgroup_path))
+		return -ENOMEM;
+
+	ret = task_cgroup_path(current, *cgroup_path, PATH_MAX);
+	if (ret < 0) {
+		kfree(*cgroup_path);
+		*cgroup_path = NULL;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(scm_get_current_cgroup_path);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index ab0be13..b638083 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1344,6 +1344,7 @@ static void unix_destruct_scm(struct sk_buff *skb)
 	if (UNIXCB(skb).scm) {
 		scm.procinfo.procinfo = UNIXSCM(skb).procinfo;
 		scm.procinfo.len = UNIXSCM(skb).procinfo_len;
+		scm.cgroup_path = UNIXSCM(skb).cgroup_path;
 	}
 	if (UNIXCB(skb).fp)
 		unix_detach_fds(&scm, skb);
@@ -1420,6 +1421,14 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 			return -ENOMEM;
 	}
 
+	UNIXSCM(skb).cgroup_path = NULL;
+	if (scm->cgroup_path) {
+		UNIXSCM(skb).cgroup_path = kstrdup(scm->cgroup_path,
+						   GFP_KERNEL);
+		if (!UNIXSCM(skb).cgroup_path)
+			return -ENOMEM;
+	}
+
 	skb->destructor = unix_destruct_scm;
 	return err;
 }
@@ -1443,6 +1452,7 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
 		UNIXSCM(skb).sessionid = audit_get_sessionid(current);
 		UNIXSCM(skb).procinfo_len = scm_get_current_procinfo(
 			&UNIXSCM(skb).procinfo);
+		scm_get_current_cgroup_path(&UNIXSCM(skb).cgroup_path);
 	}
 }
 
@@ -1849,6 +1859,11 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 						 GFP_KERNEL),
 					 UNIXSCM(skb).procinfo_len);
 		}
+		if (UNIXSCM(skb).cgroup_path) {
+			scm_set_cgroup_path(siocb->scm,
+					    kstrdup(UNIXSCM(skb).cgroup_path,
+						    GFP_KERNEL));
+		}
 	}
 	unix_set_secdata(siocb->scm, skb);
 
@@ -2042,6 +2057,11 @@ again:
 						GFP_KERNEL),
 						UNIXSCM(skb).procinfo_len);
 				}
+				if (UNIXSCM(skb).cgroup_path) {
+					scm_set_cgroup_path(siocb->scm,
+							    kstrdup(UNIXSCM(skb).cgroup_path,
+							    GFP_KERNEL));
+				}
 			}
 			check_creds = 1;
 		}
-- 
1.8.3.1
