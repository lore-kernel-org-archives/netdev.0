From: David Windsor <dwindsor@gmail.com>
Subject: [RFC][PATCH] nfsd: add +1 to reference counting scheme for struct nfsd4_session
Date: Thu,  9 Feb 2017 02:38:21 -0500
Message-ID: <1486625901-10094-1-git-send-email-dwindsor@gmail.com>
Cc: kernel-hardening@lists.openwall.com,
	bfields@fieldses.org,
	jlayton@poochiereds.net,
	keescook@chromium.org,
	elena.reshetova@intel.com,
	dwindsor@gmail.com
To: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <kernel-hardening-return-6536-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
List-Id: netdev.vger.kernel.org

In furtherance of the KSPP effort to add overflow protection to kernel
reference counters, a new type (refcount_t) and API have been created.
Part of the refcount_t API is refcount_inc(), which will not increment a
refcount_t variable if its value is 0 (as this would indicate a possible
use-after-free condition). 

In auditing the kernel for refcounting corner cases, we've come across the
case of struct nfsd4_session.  

>From fs/nfsd/state.h:

/*
 * Representation of a v4.1+ session. These are refcounted in a similar 
 * fashion to the nfs4_client. References are only taken when the server
 * is actively working on the object (primarily during the processing of
 * compounds).
 */
struct nfsd4_session {
    atomic_t se_ref;
    ...
};


>From fs/nfsd/nfs4state.c:

static void init_session(..., struct nfsd4_session *new, ...)
{
    ...
    atomic_set(&new->se_ref, 0);
    ...
}
 
Since nfsd4_session objects are initialized with refcount = 0, subsequent
increments will fail using the new refcount_t API.

Being largely unfamiliar with this subsystem's garbage collection
mechanism, I'm unsure how to best fix this.  Attached is a patch that
performs a logical +1 on struct nfsd4_session's reference counting
scheme.

If this is the correct route to take, I will resubmit this patch with
updated comments for how struct nfsd4_session is refcounted (see the above
comment from fs/nsfd/state.h).  This is in preparation for the previously
mentioned refcount_t API series.

Thanks,
David Windsor

Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 fs/nfsd/nfs4state.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a0dee8a..b0f3010 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -196,7 +196,7 @@ static void nfsd4_put_session_locked(struct nfsd4_session *ses)
 
 	lockdep_assert_held(&nn->client_lock);
 
-	if (atomic_dec_and_test(&ses->se_ref) && is_session_dead(ses))
+	if (!atomic_add_unless(&ses->se_ref, -1, 1) && is_session_des(ses))
 		free_session(ses);
 	put_client_renew_locked(clp);
 }
@@ -1645,7 +1645,7 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
 	new->se_flags = cses->flags;
 	new->se_cb_prog = cses->callback_prog;
 	new->se_cb_sec = cses->cb_sec;
-	atomic_set(&new->se_ref, 0);
+	atomic_set(&new->se_ref, 1);
 	idx = hash_sessionid(&new->se_sessionid);
 	list_add(&new->se_hash, &nn->sessionid_hashtbl[idx]);
 	spin_lock(&clp->cl_lock);
@@ -1792,7 +1792,7 @@ free_client(struct nfs4_client *clp)
 		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
 				se_perclnt);
 		list_del(&ses->se_perclnt);
-		WARN_ON_ONCE(atomic_read(&ses->se_ref));
+		WARN_ON_ONCE((atomic_read(&ses->se_ref) > 1));
 		free_session(ses);
 	}
 	rpc_destroy_wait_queue(&clp->cl_cb_waitq);
-- 
2.7.4
