From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 13/21] userns: Teach inet_diag to work with user namespaces
Date: Mon, 13 Aug 2012 13:18:27 -0700
Message-ID: <1344889115-21610-13-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

Compute the user namespace of the socket that we are replying to
and translate the kuids of reported sockets into that user namespace.

Cc: Andrew Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/inet_diag.h |    1 +
 init/Kconfig              |    1 -
 net/ipv4/inet_diag.c      |   21 +++++++++++++++------
 net/ipv4/udp_diag.c       |    5 ++++-
 4 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index f1362b5..e788c18 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -159,6 +159,7 @@ struct inet_diag_handler {
 struct inet_connection_sock;
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
+			      struct user_namespace *user_ns,
 			      u32 pid, u32 seq, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh);
 void inet_diag_dump_icsk(struct inet_hashinfo *h, struct sk_buff *skb,
diff --git a/init/Kconfig b/init/Kconfig
index 8447e0c..07435e0 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -950,7 +950,6 @@ config UIDGID_CONVERTED
 	depends on NETFILTER_NETLINK_LOG = n
 	depends on AF_RXRPC = n
 	depends on NET_KEY = n
-	depends on INET_DIAG = n
 	depends on DNS_RESOLVER = n
 
 	# Filesystems
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 570e61f..8bc005b 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -69,6 +69,7 @@ static inline void inet_diag_unlock_handler(
 
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
+			      struct user_namespace *user_ns,		      	
 			      u32 pid, u32 seq, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh)
 {
@@ -124,7 +125,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	}
 #endif
 
-	r->idiag_uid = sock_i_uid(sk);
+	r->idiag_uid = from_kuid_munged(user_ns, sock_i_uid(sk));
 	r->idiag_inode = sock_i_ino(sk);
 
 	if (ext & (1 << (INET_DIAG_MEMINFO - 1))) {
@@ -199,11 +200,12 @@ EXPORT_SYMBOL_GPL(inet_sk_diag_fill);
 
 static int inet_csk_diag_fill(struct sock *sk,
 			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
+			      struct user_namespace *user_ns,
 			      u32 pid, u32 seq, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh)
 {
 	return inet_sk_diag_fill(sk, inet_csk(sk),
-			skb, req, pid, seq, nlmsg_flags, unlh);
+			skb, req, user_ns, pid, seq, nlmsg_flags, unlh);
 }
 
 static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
@@ -256,14 +258,16 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 }
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
-			struct inet_diag_req_v2 *r, u32 pid, u32 seq, u16 nlmsg_flags,
+			struct inet_diag_req_v2 *r,
+			struct user_namespace *user_ns,
+			u32 pid, u32 seq, u16 nlmsg_flags,
 			const struct nlmsghdr *unlh)
 {
 	if (sk->sk_state == TCP_TIME_WAIT)
 		return inet_twsk_diag_fill((struct inet_timewait_sock *)sk,
 					   skb, r, pid, seq, nlmsg_flags,
 					   unlh);
-	return inet_csk_diag_fill(sk, skb, r, pid, seq, nlmsg_flags, unlh);
+	return inet_csk_diag_fill(sk, skb, r, user_ns, pid, seq, nlmsg_flags, unlh);
 }
 
 int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_skb,
@@ -311,6 +315,7 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_s
 	}
 
 	err = sk_diag_fill(sk, rep, req,
+			   sk_user_ns(NETLINK_CB(in_skb).ssk),
 			   NETLINK_CB(in_skb).pid,
 			   nlh->nlmsg_seq, 0, nlh);
 	if (err < 0) {
@@ -551,6 +556,7 @@ static int inet_csk_diag_dump(struct sock *sk,
 		return 0;
 
 	return inet_csk_diag_fill(sk, skb, r,
+				  sk_user_ns(NETLINK_CB(cb->skb).ssk),
 				  NETLINK_CB(cb->skb).pid,
 				  cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
@@ -591,7 +597,9 @@ static int inet_twsk_diag_dump(struct inet_timewait_sock *tw,
 }
 
 static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
-			      struct request_sock *req, u32 pid, u32 seq,
+			      struct request_sock *req,
+			      struct user_namespace *user_ns,
+			      u32 pid, u32 seq,
 			      const struct nlmsghdr *unlh)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
@@ -625,7 +633,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	r->idiag_expires = jiffies_to_msecs(tmo);
 	r->idiag_rqueue = 0;
 	r->idiag_wqueue = 0;
-	r->idiag_uid = sock_i_uid(sk);
+	r->idiag_uid = from_kuid_munged(user_ns, sock_i_uid(sk));
 	r->idiag_inode = 0;
 #if IS_ENABLED(CONFIG_IPV6)
 	if (r->idiag_family == AF_INET6) {
@@ -702,6 +710,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 			}
 
 			err = inet_diag_fill_req(skb, sk, req,
+					       sk_user_ns(NETLINK_CB(cb->skb).ssk),
 					       NETLINK_CB(cb->skb).pid,
 					       cb->nlh->nlmsg_seq, cb->nlh);
 			if (err < 0) {
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 16d0960..d2f336e 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -24,7 +24,9 @@ static int sk_diag_dump(struct sock *sk, struct sk_buff *skb,
 	if (!inet_diag_bc_sk(bc, sk))
 		return 0;
 
-	return inet_sk_diag_fill(sk, NULL, skb, req, NETLINK_CB(cb->skb).pid,
+	return inet_sk_diag_fill(sk, NULL, skb, req,
+			sk_user_ns(NETLINK_CB(cb->skb).ssk),
+			NETLINK_CB(cb->skb).pid,
 			cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
 
@@ -69,6 +71,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 		goto out;
 
 	err = inet_sk_diag_fill(sk, NULL, rep, req,
+			   sk_user_ns(NETLINK_CB(in_skb).ssk),
 			   NETLINK_CB(in_skb).pid,
 			   nlh->nlmsg_seq, 0, nlh);
 	if (err < 0) {
-- 
1.7.5.4
