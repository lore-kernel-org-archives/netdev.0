From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 10/17] net: Allow userns root to control ipv4
Date: Fri, 16 Nov 2012 05:03:05 -0800
Message-ID: <1353070992-5552-10-git-send-email-ebiederm@xmission.com>
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

In general policy and network stack state changes are allowed
while resource control is left unchanged.

Allow creating raw sockets.
Allow the SIOCSARP ioctl to control the arp cache.
Allow the SIOCSIFFLAG ioctl to allow setting network device flags.
Allow the SIOCSIFADDR ioctl to allow setting a netdevice ipv4 address.
Allow the SIOCSIFBRDADDR ioctl to allow setting a netdevice ipv4 broadcast address.
Allow the SIOCSIFDSTADDR ioctl to allow setting a netdevice ipv4 destination address.
Allow the SIOCSIFNETMASK ioctl to allow setting a netdevice ipv4 netmask.
Allow the SIOCADDRT and SIOCDELRT ioctls to allow adding and deleting ipv4 routes.

Allow the SIOCADDTUNNEL, SIOCCHGTUNNEL and SIOCDELTUNNEL ioctls for
adding, changing and deleting gre tunnels.

Allow the SIOCADDTUNNEL, SIOCCHGTUNNEL and SIOCDELTUNNEL ioctls for
adding, changing and deleting ipip tunnels.

Allow the SIOCADDTUNNEL, SIOCCHGTUNNEL and SIOCDELTUNNEL ioctls for
adding, changing and deleting ipsec virtual tunnel interfaces.

Allow setting the MRT_INIT, MRT_DONE, MRT_ADD_VIF, MRT_DEL_VIF, MRT_ADD_MFC,
MRT_DEL_MFC, MRT_ASSERT, MRT_PIM, MRT_TABLE socket options on multicast routing
sockets.

Allow setting and receiving IPOPT_CIPSO, IP_OPT_SEC, IP_OPT_SID and
arbitrary ip options.

Allow setting IP_SEC_POLICY/IP_XFRM_POLICY ipv4 socket option.
Allow setting the IP_TRANSPARENT ipv4 socket option.
Allow setting the TCP_REPAIR socket option.
Allow setting the TCP_CONGESTION socket option.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/ipv4/af_inet.c              |    3 ++-
 net/ipv4/arp.c                  |    2 +-
 net/ipv4/devinet.c              |    4 ++--
 net/ipv4/fib_frontend.c         |    2 +-
 net/ipv4/ip_gre.c               |    4 ++--
 net/ipv4/ip_options.c           |    6 +++---
 net/ipv4/ip_sockglue.c          |    5 +++--
 net/ipv4/ip_vti.c               |    4 ++--
 net/ipv4/ipip.c                 |    4 ++--
 net/ipv4/ipmr.c                 |    2 +-
 net/ipv4/netfilter/arp_tables.c |    8 ++++----
 net/ipv4/netfilter/ip_tables.c  |    8 ++++----
 net/ipv4/tcp.c                  |    2 +-
 net/ipv4/tcp_cong.c             |    3 ++-
 14 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 766c596..7449bcf 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -346,7 +346,8 @@ lookup_protocol:
 	}
 
 	err = -EPERM;
-	if (sock->type == SOCK_RAW && !kern && !capable(CAP_NET_RAW))
+	if (sock->type == SOCK_RAW && !kern &&
+	    !ns_capable(net->user_ns, CAP_NET_RAW))
 		goto out_rcu_unlock;
 
 	err = -EAFNOSUPPORT;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 4780045..ce6fbdf 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1161,7 +1161,7 @@ int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	switch (cmd) {
 	case SIOCDARP:
 	case SIOCSARP:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 	case SIOCGARP:
 		err = copy_from_user(&r, arg, sizeof(struct arpreq));
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index ae95f64..f75f4f6 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -729,7 +729,7 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 
 	case SIOCSIFFLAGS:
 		ret = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto out;
 		break;
 	case SIOCSIFADDR:	/* Set interface address (and family) */
@@ -737,7 +737,7 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	case SIOCSIFDSTADDR:	/* Set the destination address */
 	case SIOCSIFNETMASK: 	/* Set the netmask for the interface */
 		ret = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto out;
 		ret = -EINVAL;
 		if (sin->sin_family != AF_INET)
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index bce4541..784716a 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -488,7 +488,7 @@ int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	switch (cmd) {
 	case SIOCADDRT:		/* Add a route */
 	case SIOCDELRT:		/* Delete a route */
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		if (copy_from_user(&rt, arg, sizeof(rt)))
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7240f8e..6acd774 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1082,7 +1082,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCADDTUNNEL:
 	case SIOCCHGTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		err = -EFAULT;
@@ -1157,7 +1157,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	case SIOCDELTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		if (dev == ign->fb_tunnel_dev) {
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 1dc01f9..f6289bf 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -409,7 +409,7 @@ int ip_options_compile(struct net *net,
 					optptr[2] += 8;
 					break;
 				      default:
-					if (!skb && !capable(CAP_NET_RAW)) {
+					if (!skb && !ns_capable(net->user_ns, CAP_NET_RAW)) {
 						pp_ptr = optptr + 3;
 						goto error;
 					}
@@ -445,7 +445,7 @@ int ip_options_compile(struct net *net,
 				opt->router_alert = optptr - iph;
 			break;
 		      case IPOPT_CIPSO:
-			if ((!skb && !capable(CAP_NET_RAW)) || opt->cipso) {
+			if ((!skb && !ns_capable(net->user_ns, CAP_NET_RAW)) || opt->cipso) {
 				pp_ptr = optptr;
 				goto error;
 			}
@@ -458,7 +458,7 @@ int ip_options_compile(struct net *net,
 		      case IPOPT_SEC:
 		      case IPOPT_SID:
 		      default:
-			if (!skb && !capable(CAP_NET_RAW)) {
+			if (!skb && !ns_capable(net->user_ns, CAP_NET_RAW)) {
 				pp_ptr = optptr;
 				goto error;
 			}
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 5eea4a8..796c2ae 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -980,13 +980,14 @@ mc_msf_out:
 	case IP_IPSEC_POLICY:
 	case IP_XFRM_POLICY:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 			break;
 		err = xfrm_user_policy(sk, optname, optval, optlen);
 		break;
 
 	case IP_TRANSPARENT:
-		if (!!val && !capable(CAP_NET_RAW) && !capable(CAP_NET_ADMIN)) {
+		if (!!val && !ns_capable(sock_net(sk)->user_ns, CAP_NET_RAW) &&
+		    !ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)) {
 			err = -EPERM;
 			break;
 		}
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 1831092..d14d93a 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -497,7 +497,7 @@ vti_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCADDTUNNEL:
 	case SIOCCHGTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		err = -EFAULT;
@@ -562,7 +562,7 @@ vti_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	case SIOCDELTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		if (dev == ipn->fb_tunnel_dev) {
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index e15b452..692ff04 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -664,7 +664,7 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCADDTUNNEL:
 	case SIOCCHGTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		err = -EFAULT;
@@ -724,7 +724,7 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	case SIOCDELTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		if (dev == ipn->fb_tunnel_dev) {
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 6168c4d..adf3d34 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1213,7 +1213,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 
 	if (optname != MRT_INIT) {
 		if (sk != rcu_access_pointer(mrt->mroute_sk) &&
-		    !capable(CAP_NET_ADMIN))
+		    !ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EACCES;
 	}
 
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 97e61ea..3ea4127 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1533,7 +1533,7 @@ static int compat_do_arpt_set_ctl(struct sock *sk, int cmd, void __user *user,
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -1677,7 +1677,7 @@ static int compat_do_arpt_get_ctl(struct sock *sk, int cmd, void __user *user,
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -1698,7 +1698,7 @@ static int do_arpt_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -1722,7 +1722,7 @@ static int do_arpt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 170b1fd..17c5e06 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1846,7 +1846,7 @@ compat_do_ipt_set_ctl(struct sock *sk,	int cmd, void __user *user,
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -1961,7 +1961,7 @@ compat_do_ipt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -1983,7 +1983,7 @@ do_ipt_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -2008,7 +2008,7 @@ do_ipt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 197c000..e9f55a5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2303,7 +2303,7 @@ void tcp_sock_destruct(struct sock *sk)
 
 static inline bool tcp_can_repair_sock(const struct sock *sk)
 {
-	return capable(CAP_NET_ADMIN) &&
+	return ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN) &&
 		((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_ESTABLISHED));
 }
 
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 1432cdb..baf2861 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -259,7 +259,8 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
 	if (!ca)
 		err = -ENOENT;
 
-	else if (!((ca->flags & TCP_CONG_NON_RESTRICTED) || capable(CAP_NET_ADMIN)))
+	else if (!((ca->flags & TCP_CONG_NON_RESTRICTED) ||
+		   ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)))
 		err = -EPERM;
 
 	else if (!try_module_get(ca->owner))
-- 
1.7.5.4
