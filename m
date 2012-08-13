From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 14/21] userns: nfnetlink_log: Report socket uids in the log
	sockets user namespace
Date: Mon, 13 Aug 2012 13:18:28 -0700
Message-ID: <1344889115-21610-14-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

At logging instance creation capture the peer netlink socket's user
namespace. Use the captured peer user namespace when reporting socket
uids to the peer.

The peer socket's user namespace is guaranateed to be valid until the user
closes the netlink socket.  nfnetlink_log removes instances during the final
close of a socket.  __build_packet_message does not get called after an
instance is destroyed.   Therefore it is safe to let the peer netlink socket
take care of the user namespace reference counting for us.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 init/Kconfig                  |    1 -
 net/netfilter/nfnetlink_log.c |   14 ++++++++++----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 07435e0..2660b31 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -947,7 +947,6 @@ config UIDGID_CONVERTED
 	depends on NETFILTER_XT_MATCH_OWNER = n
 	depends on NETFILTER_XT_MATCH_RECENT = n
 	depends on NETFILTER_XT_TARGET_LOG = n
-	depends on NETFILTER_NETLINK_LOG = n
 	depends on AF_RXRPC = n
 	depends on NET_KEY = n
 	depends on DNS_RESOLVER = n
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 169ab59..4142aac 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -55,6 +55,7 @@ struct nfulnl_instance {
 	unsigned int qlen;		/* number of nlmsgs in skb */
 	struct sk_buff *skb;		/* pre-allocatd skb */
 	struct timer_list timer;
+	struct user_namespace *peer_user_ns;	/* User namespace of the peer process */
 	int peer_pid;			/* PID of the peer process */
 
 	/* configurable parameters */
@@ -132,7 +133,7 @@ instance_put(struct nfulnl_instance *inst)
 static void nfulnl_timer(unsigned long data);
 
 static struct nfulnl_instance *
-instance_create(u_int16_t group_num, int pid)
+instance_create(u_int16_t group_num, int pid, struct user_namespace *user_ns)
 {
 	struct nfulnl_instance *inst;
 	int err;
@@ -162,6 +163,7 @@ instance_create(u_int16_t group_num, int pid)
 
 	setup_timer(&inst->timer, nfulnl_timer, (unsigned long)inst);
 
+	inst->peer_user_ns = user_ns;
 	inst->peer_pid = pid;
 	inst->group_num = group_num;
 
@@ -503,8 +505,11 @@ __build_packet_message(struct nfulnl_instance *inst,
 		read_lock_bh(&skb->sk->sk_callback_lock);
 		if (skb->sk->sk_socket && skb->sk->sk_socket->file) {
 			struct file *file = skb->sk->sk_socket->file;
-			__be32 uid = htonl(file->f_cred->fsuid);
-			__be32 gid = htonl(file->f_cred->fsgid);
+			__be32 uid = htonl(from_kuid_munged(inst->peer_user_ns,
+							    file->f_cred->fsuid));
+			__be32 gid = htonl(from_kgid_munged(inst->peer_user_ns,
+							    file->f_cred->fsgid));
+			/* need to unlock here since NLA_PUT may goto */
 			read_unlock_bh(&skb->sk->sk_callback_lock);
 			if (nla_put_be32(inst->skb, NFULA_UID, uid) ||
 			    nla_put_be32(inst->skb, NFULA_GID, gid))
@@ -783,7 +788,8 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 			}
 
 			inst = instance_create(group_num,
-					       NETLINK_CB(skb).pid);
+					       NETLINK_CB(skb).pid,
+					       sk_user_ns(NETLINK_CB(skb).ssk));
 			if (IS_ERR(inst)) {
 				ret = PTR_ERR(inst);
 				goto out;
-- 
1.7.5.4
