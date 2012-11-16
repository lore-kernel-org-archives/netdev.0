From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 17/17] net: Make CAP_NET_BIND_SERVICE per user
	namespace
Date: Fri, 16 Nov 2012 05:03:12 -0800
Message-ID: <1353070992-5552-17-git-send-email-ebiederm@xmission.com>
References: <87d2zd8zwn.fsf@xmission.com>
	<1353070992-5552-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353070992-5552-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

Allow privileged users in any user namespace to bind to
privileged sockets in network namespaces they control.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/ipv4/af_inet.c  |    6 ++++--
 net/ipv6/af_inet6.c |    2 +-
 net/sctp/socket.c   |    8 +++++---
 3 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7449bcf..6a76956 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -474,6 +474,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct sockaddr_in *addr = (struct sockaddr_in *)uaddr;
 	struct sock *sk = sock->sk;
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
 	unsigned short snum;
 	int chk_addr_ret;
 	int err;
@@ -497,7 +498,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out;
 	}
 
-	chk_addr_ret = inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);
+	chk_addr_ret = inet_addr_type(net, addr->sin_addr.s_addr);
 
 	/* Not specified by any standard per-se, however it breaks too
 	 * many applications when removed.  It is unfortunate since
@@ -517,7 +518,8 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	snum = ntohs(addr->sin_port);
 	err = -EACCES;
-	if (snum && snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
+	if (snum && snum < PROT_SOCK &&
+	    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE))
 		goto out;
 
 	/*      We keep a pair of addresses. rcv_saddr is the one
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 19f68b2..5d4e45e 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -283,7 +283,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		return -EINVAL;
 
 	snum = ntohs(addr->sin6_port);
-	if (snum && snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
+	if (snum && snum < PROT_SOCK && !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
 	lock_sock(sk);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 59d16ea..e4a362d 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -336,6 +336,7 @@ static struct sctp_af *sctp_sockaddr_af(struct sctp_sock *opt,
 /* Bind a local address either to an endpoint or to an association.  */
 SCTP_STATIC int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 {
+	struct net *net = sock_net(sk);
 	struct sctp_sock *sp = sctp_sk(sk);
 	struct sctp_endpoint *ep = sp->ep;
 	struct sctp_bind_addr *bp = &ep->base.bind_addr;
@@ -379,7 +380,8 @@ SCTP_STATIC int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 		}
 	}
 
-	if (snum && snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
+	if (snum && snum < PROT_SOCK &&
+	    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
 	/* See if the address matches any of the addresses we may have
@@ -1162,7 +1164,7 @@ static int __sctp_connect(struct sock* sk,
 				 * be permitted to open new associations.
 				 */
 				if (ep->base.bind_addr.port < PROT_SOCK &&
-				    !capable(CAP_NET_BIND_SERVICE)) {
+				    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE)) {
 					err = -EACCES;
 					goto out_free;
 				}
@@ -1791,7 +1793,7 @@ SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 			 * associations.
 			 */
 			if (ep->base.bind_addr.port < PROT_SOCK &&
-			    !capable(CAP_NET_BIND_SERVICE)) {
+			    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE)) {
 				err = -EACCES;
 				goto out_unlock;
 			}
-- 
1.7.5.4
