From: David Howells <dhowells@redhat.com>
Subject: [PATCH 55/59] CRED: Wrap task credential accesses in the UNIX socket
	protocol
Date: Wed, 27 Aug 2008 14:50:26 +0100
Message-ID: <20080827135026.19980.10926.stgit@warthog.procyon.org.uk>
References: <20080827134541.19980.61042.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org,
	David Howells <dhowells@redhat.com>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080827134541.19980.61042.stgit@warthog.procyon.org.uk>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wrap access to task credentials so that they can be separated more easily from
the task_struct during the introduction of COW creds.

Change most current->(|e|s|fs)[ug]id to current_(|e|s|fs)[ug]id().

Change some task->e?[ug]id to task_e?[ug]id().  In some places it makes more
sense to use RCU directly rather than a convenient wrapper; these will be
addressed by later patches.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: James Morris <jmorris@namei.org>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Cc: netdev@vger.kernel.org
---

 net/unix/af_unix.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)


diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 3c3e6e2..d6e2019 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -467,8 +467,7 @@ static int unix_listen(struct socket *sock, int backlog)
 	sk->sk_state		= TCP_LISTEN;
 	/* set credentials so connect can copy them */
 	sk->sk_peercred.pid	= task_tgid_vnr(current);
-	sk->sk_peercred.uid	= current->euid;
-	sk->sk_peercred.gid	= current->egid;
+	current_euid_egid(&sk->sk_peercred.uid, &sk->sk_peercred.gid);
 	err = 0;
 
 out_unlock:
@@ -1126,8 +1125,7 @@ restart:
 	newsk->sk_state		= TCP_ESTABLISHED;
 	newsk->sk_type		= sk->sk_type;
 	newsk->sk_peercred.pid	= task_tgid_vnr(current);
-	newsk->sk_peercred.uid	= current->euid;
-	newsk->sk_peercred.gid	= current->egid;
+	current_euid_egid(&newsk->sk_peercred.uid, &newsk->sk_peercred.gid);
 	newu = unix_sk(newsk);
 	newsk->sk_sleep		= &newu->peer_wait;
 	otheru = unix_sk(other);
@@ -1187,8 +1185,9 @@ static int unix_socketpair(struct socket *socka, struct socket *sockb)
 	unix_peer(ska)=skb;
 	unix_peer(skb)=ska;
 	ska->sk_peercred.pid = skb->sk_peercred.pid = task_tgid_vnr(current);
-	ska->sk_peercred.uid = skb->sk_peercred.uid = current->euid;
-	ska->sk_peercred.gid = skb->sk_peercred.gid = current->egid;
+	current_euid_egid(&skb->sk_peercred.uid, &skb->sk_peercred.gid);
+	ska->sk_peercred.uid = skb->sk_peercred.uid;
+	ska->sk_peercred.gid = skb->sk_peercred.gid;
 
 	if (ska->sk_type != SOCK_DGRAM) {
 		ska->sk_state = TCP_ESTABLISHED;

