From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 17/21] userns: Convert xt_LOG to print socket kuids and kgids
	as uids and gids
Date: Mon, 13 Aug 2012 13:18:31 -0700
Message-ID: <1344889115-21610-17-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1344889115-21610-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

xt_LOG always writes messages via sb_add via printk.  Therefore when
xt_LOG logs the uid and gid of a socket a packet came from the
values should be converted to be in the initial user namespace.

Thus making xt_LOG as user namespace safe as possible.

Cc: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 init/Kconfig           |    1 -
 net/netfilter/xt_LOG.c |   16 ++++++++++------
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index b44c3a3..c8911eb 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -945,7 +945,6 @@ config UIDGID_CONVERTED
 	depends on NET_9P = n
 	depends on NETFILTER_XT_MATCH_OWNER = n
 	depends on NETFILTER_XT_MATCH_RECENT = n
-	depends on NETFILTER_XT_TARGET_LOG = n
 	depends on AF_RXRPC = n
 	depends on NET_KEY = n
 	depends on DNS_RESOLVER = n
diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index ff5f75f..02a2bf4 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -363,10 +363,12 @@ static void dump_ipv4_packet(struct sbuff *m,
 	/* Max length: 15 "UID=4294967295 " */
 	if ((logflags & XT_LOG_UID) && !iphoff && skb->sk) {
 		read_lock_bh(&skb->sk->sk_callback_lock);
-		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
+		if (skb->sk->sk_socket && skb->sk->sk_socket->file) {
+			const struct cred *cred = skb->sk->sk_socket->file->f_cred;
 			sb_add(m, "UID=%u GID=%u ",
-				skb->sk->sk_socket->file->f_cred->fsuid,
-				skb->sk->sk_socket->file->f_cred->fsgid);
+				from_kuid_munged(&init_user_ns, cred->fsuid),
+				from_kgid_munged(&init_user_ns, cred->fsgid));
+		}
 		read_unlock_bh(&skb->sk->sk_callback_lock);
 	}
 
@@ -719,10 +721,12 @@ static void dump_ipv6_packet(struct sbuff *m,
 	/* Max length: 15 "UID=4294967295 " */
 	if ((logflags & XT_LOG_UID) && recurse && skb->sk) {
 		read_lock_bh(&skb->sk->sk_callback_lock);
-		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
+		if (skb->sk->sk_socket && skb->sk->sk_socket->file) {
+			const struct cred *cred = skb->sk->sk_socket->file->f_cred;
 			sb_add(m, "UID=%u GID=%u ",
-				skb->sk->sk_socket->file->f_cred->fsuid,
-				skb->sk->sk_socket->file->f_cred->fsgid);
+				from_kuid_munged(&init_user_ns, cred->fsuid),
+				from_kgid_munged(&init_user_ns, cred->fsgid));
+		}
 		read_unlock_bh(&skb->sk->sk_callback_lock);
 	}
 
-- 
1.7.5.4
