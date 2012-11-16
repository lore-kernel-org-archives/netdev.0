From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 11/17] net: Allow userns root to control ipv6
Date: Fri, 16 Nov 2012 05:03:06 -0800
Message-ID: <1353070992-5552-11-git-send-email-ebiederm@xmission.com>
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

Settings that merely control a single network device are allowed.
Either the network device is a logical network device where
restrictions make no difference or the network device is hardware NIC
that has been explicity moved from the initial network namespace.

In general policy and network stack state changes are allowed while
resource control is left unchanged.

Allow the SIOCSIFADDR ioctl to add ipv6 addresses.
Allow the SIOCDIFADDR ioctl to delete ipv6 addresses.
Allow the SIOCADDRT ioctl to add ipv6 routes.
Allow the SIOCDELRT ioctl to delete ipv6 routes.

Allow creation of ipv6 raw sockets.

Allow setting the IPV6_JOIN_ANYCAST socket option.
Allow setting the IPV6_FL_A_RENEW parameter of the IPV6_FLOWLABEL_MGR
socket option.

Allow setting the IPV6_TRANSPARENT socket option.
Allow setting the IPV6_HOPOPTS socket option.
Allow setting the IPV6_RTHDRDSTOPTS socket option.
Allow setting the IPV6_DSTOPTS socket option.
Allow setting the IPV6_IPSEC_POLICY socket option.
Allow setting the IPV6_XFRM_POLICY socket option.

Allow sending packets with the IPV6_2292HOPOPTS control message.
Allow sending packets with the IPV6_2292DSTOPTS control message.
Allow sending packets with the IPV6_RTHDRDSTOPTS control message.

Allow setting the multicast routing socket options on non multicast
routing sockets.

Allow the SIOCADDTUNNEL, SIOCCHGTUNNEL, and SIOCDELTUNNEL ioctls for
setting up, changing and deleting tunnels over ipv6.

Allow the SIOCADDTUNNEL, SIOCCHGTUNNEL, SIOCDELTUNNEL ioctls for
setting up, changing and deleting ipv6 over ipv4 tunnels.

Allow the SIOCADDPRL, SIOCDELPRL, SIOCCHGPRL ioctls for adding,
deleting, and changing the potential router list for ISATAP tunnels.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/ipv6/addrconf.c             |    4 ++--
 net/ipv6/af_inet6.c             |    3 ++-
 net/ipv6/anycast.c              |    2 +-
 net/ipv6/datagram.c             |    6 +++---
 net/ipv6/ip6_flowlabel.c        |    3 ++-
 net/ipv6/ip6_gre.c              |    4 ++--
 net/ipv6/ip6_tunnel.c           |    4 ++--
 net/ipv6/ip6mr.c                |    2 +-
 net/ipv6/ipv6_sockglue.c        |    7 ++++---
 net/ipv6/netfilter/ip6_tables.c |    8 ++++----
 net/ipv6/route.c                |    2 +-
 net/ipv6/sit.c                  |    8 ++++----
 12 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 47c591d..b8e0a62 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2268,7 +2268,7 @@ int addrconf_add_ifaddr(struct net *net, void __user *arg)
 	struct in6_ifreq ireq;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (copy_from_user(&ireq, arg, sizeof(struct in6_ifreq)))
@@ -2287,7 +2287,7 @@ int addrconf_del_ifaddr(struct net *net, void __user *arg)
 	struct in6_ifreq ireq;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (copy_from_user(&ireq, arg, sizeof(struct in6_ifreq)))
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index a974247..19f68b2 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -160,7 +160,8 @@ lookup_protocol:
 	}
 
 	err = -EPERM;
-	if (sock->type == SOCK_RAW && !kern && !capable(CAP_NET_RAW))
+	if (sock->type == SOCK_RAW && !kern &&
+	    !ns_capable(net->user_ns, CAP_NET_RAW))
 		goto out_rcu_unlock;
 
 	sock->ops = answer->ops;
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index cdf02be..0808df6 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -64,7 +64,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	int	ishost = !net->ipv6.devconf_all->forwarding;
 	int	err = 0;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 	if (ipv6_addr_is_multicast(addr))
 		return -EINVAL;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index be2b67d6..2d84f49 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -701,7 +701,7 @@ int datagram_send_ctl(struct net *net, struct sock *sk,
 				err = -EINVAL;
 				goto exit_f;
 			}
-			if (!capable(CAP_NET_RAW)) {
+			if (!ns_capable(net->user_ns, CAP_NET_RAW)) {
 				err = -EPERM;
 				goto exit_f;
 			}
@@ -721,7 +721,7 @@ int datagram_send_ctl(struct net *net, struct sock *sk,
 				err = -EINVAL;
 				goto exit_f;
 			}
-			if (!capable(CAP_NET_RAW)) {
+			if (!ns_capable(net->user_ns, CAP_NET_RAW)) {
 				err = -EPERM;
 				goto exit_f;
 			}
@@ -746,7 +746,7 @@ int datagram_send_ctl(struct net *net, struct sock *sk,
 				err = -EINVAL;
 				goto exit_f;
 			}
-			if (!capable(CAP_NET_RAW)) {
+			if (!ns_capable(net->user_ns, CAP_NET_RAW)) {
 				err = -EPERM;
 				goto exit_f;
 			}
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 90bbefb..29124b7 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -519,7 +519,8 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 		}
 		read_unlock_bh(&ip6_sk_fl_lock);
 
-		if (freq.flr_share == IPV6_FL_S_NONE && capable(CAP_NET_ADMIN)) {
+		if (freq.flr_share == IPV6_FL_S_NONE &&
+		    ns_capable(net->user_ns, CAP_NET_ADMIN)) {
 			fl = fl_lookup(net, freq.flr_label);
 			if (fl) {
 				err = fl6_renew(fl, freq.flr_linger, freq.flr_expires);
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 0185679..f822527 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1161,7 +1161,7 @@ static int ip6gre_tunnel_ioctl(struct net_device *dev,
 	case SIOCADDTUNNEL:
 	case SIOCCHGTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		err = -EFAULT;
@@ -1209,7 +1209,7 @@ static int ip6gre_tunnel_ioctl(struct net_device *dev,
 
 	case SIOCDELTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		if (dev == ign->fb_tunnel_dev) {
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index cb7e2de..9140def 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1325,7 +1325,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCADDTUNNEL:
 	case SIOCCHGTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		err = -EFAULT;
 		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p)))
@@ -1362,7 +1362,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		break;
 	case SIOCDELTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 
 		if (dev == ip6n->fb_tnl_dev) {
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index f7c7c63..d7330f8 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1583,7 +1583,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 		return -ENOENT;
 
 	if (optname != MRT6_INIT) {
-		if (sk != mrt->mroute6_sk && !capable(CAP_NET_ADMIN))
+		if (sk != mrt->mroute6_sk && !ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EACCES;
 	}
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index ba6d13d..2429889 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -343,7 +343,8 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		break;
 
 	case IPV6_TRANSPARENT:
-		if (valbool && !capable(CAP_NET_ADMIN) && !capable(CAP_NET_RAW)) {
+		if (valbool && !ns_capable(net->user_ns, CAP_NET_ADMIN) &&
+		    !ns_capable(net->user_ns, CAP_NET_RAW)) {
 			retv = -EPERM;
 			break;
 		}
@@ -381,7 +382,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 
 		/* hop-by-hop / destination options are privileged option */
 		retv = -EPERM;
-		if (optname != IPV6_RTHDR && !capable(CAP_NET_RAW))
+		if (optname != IPV6_RTHDR && !ns_capable(net->user_ns, CAP_NET_RAW))
 			break;
 
 		opt = ipv6_renew_options(sk, np->opt, optname,
@@ -754,7 +755,7 @@ done:
 	case IPV6_IPSEC_POLICY:
 	case IPV6_XFRM_POLICY:
 		retv = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		retv = xfrm_user_policy(sk, optname, optval, optlen);
 		break;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index d7cb045..636a296 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1856,7 +1856,7 @@ compat_do_ip6t_set_ctl(struct sock *sk, int cmd, void __user *user,
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -1971,7 +1971,7 @@ compat_do_ip6t_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -1993,7 +1993,7 @@ do_ip6t_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -2018,7 +2018,7 @@ do_ip6t_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 2a98397..be2c173 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1987,7 +1987,7 @@ int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	switch(cmd) {
 	case SIOCADDRT:		/* Add a route */
 	case SIOCDELRT:		/* Delete a route */
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 		err = copy_from_user(&rtmsg, arg,
 				     sizeof(struct in6_rtmsg));
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3ed54ff..df92301 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -966,7 +966,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCADDTUNNEL:
 	case SIOCCHGTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		err = -EFAULT;
@@ -1025,7 +1025,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	case SIOCDELTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		if (dev == sitn->fb_tunnel_dev) {
@@ -1058,7 +1058,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCDELPRL:
 	case SIOCCHGPRL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 		err = -EINVAL;
 		if (dev == sitn->fb_tunnel_dev)
@@ -1087,7 +1087,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCCHG6RD:
 	case SIOCDEL6RD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		err = -EFAULT;
-- 
1.7.5.4
