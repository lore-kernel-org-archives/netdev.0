From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 12/17] net: Allow userns root to control llc,
	netfilter, netlink, packet, and xfrm
Date: Fri, 16 Nov 2012 05:03:07 -0800
Message-ID: <1353070992-5552-12-git-send-email-ebiederm@xmission.com>
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

Allow an unpriviled user who has created a user namespace, and then
created a network namespace to effectively use the new network
namespace, by reducing capable(CAP_NET_ADMIN) and
capable(CAP_NET_RAW) calls to be ns_capable(net->user_ns,
CAP_NET_ADMIN), or capable(net->user_ns, CAP_NET_RAW) calls.

Allow creation of af_key sockets.
Allow creation of llc sockets.
Allow creation of af_packet sockets.

Allow sending xfrm netlink control messages.

Allow binding to netlink multicast groups.
Allow sending to netlink multicast groups.
Allow adding and dropping netlink multicast groups.
Allow sending to all netlink multicast groups and port ids.

Allow reading the netfilter SO_IP_SET socket option.
Allow sending netfilter netlink messages.
Allow setting and getting ip_vs netfilter socket options.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/key/af_key.c                  |    2 +-
 net/llc/af_llc.c                  |    2 +-
 net/netfilter/ipset/ip_set_core.c |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c    |    4 ++--
 net/netfilter/nfnetlink.c         |    2 +-
 net/netlink/af_netlink.c          |    2 +-
 net/packet/af_packet.c            |    2 +-
 net/xfrm/xfrm_user.c              |    2 +-
 8 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 08897a3..5b426a6 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -141,7 +141,7 @@ static int pfkey_create(struct net *net, struct socket *sock, int protocol,
 	struct sock *sk;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index c219000..8870988 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -160,7 +160,7 @@ static int llc_ui_create(struct net *net, struct socket *sock, int protocol,
 	struct sock *sk;
 	int rc = -ESOCKTNOSUPPORT;
 
-	if (!capable(CAP_NET_RAW))
+	if (!ns_capable(net->user_ns, CAP_NET_RAW))
 		return -EPERM;
 
 	if (!net_eq(net, &init_net))
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 778465f..fed899f 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1643,7 +1643,7 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 	void *data;
 	int copylen = *len, ret = 0;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 	if (optval != SO_IP_SET)
 		return -EBADF;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c6cebd5..ec664cb 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2339,7 +2339,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	struct ip_vs_dest_user_kern udest;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_SET_MAX)
@@ -2632,7 +2632,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	BUG_ON(!net);
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_GET_MAX)
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index ffb92c0..58a09b7 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -138,7 +138,7 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	const struct nfnetlink_subsystem *ss;
 	int type, err;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	/* All the messages must at least contain nfgenmsg */
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 4da797f..c8a1eb6 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -612,7 +612,7 @@ retry:
 static inline int netlink_capable(const struct socket *sock, unsigned int flag)
 {
 	return (nl_table[sock->sk->sk_protocol].flags & flag) ||
-	       capable(CAP_NET_ADMIN);
+		ns_capable(sock_net(sock->sk)->user_ns, CAP_NET_ADMIN);
 }
 
 static void
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 94060ed..6d95278 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2478,7 +2478,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	__be16 proto = (__force __be16)protocol; /* weird, but documented */
 	int err;
 
-	if (!capable(CAP_NET_RAW))
+	if (!ns_capable(net->user_ns, CAP_NET_RAW))
 		return -EPERM;
 	if (sock->type != SOCK_DGRAM && sock->type != SOCK_RAW &&
 	    sock->type != SOCK_PACKET)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 421f984..eb872b2 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2349,7 +2349,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	link = &xfrm_dispatch[type];
 
 	/* All operations require privileges, even GET */
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if ((type == (XFRM_MSG_GETSA - XFRM_MSG_BASE) ||
-- 
1.7.5.4
