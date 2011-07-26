From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 09/14] user ns: convert ipv6 to targeted capabilities
Date: Tue, 26 Jul 2011 18:58:32 +0000
Message-ID: <1311706717-7398-10-git-send-email-serge@hallyn.com>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Cc: dhowells@redhat.com, ebiederm@xmission.com,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	akpm@osdl.org, "Serge E. Hallyn" <serge.hallyn@canonical.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Serge E. Hallyn <serge.hallyn@canonical.com>

Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv6/addrconf.c             |    4 ++--
 net/ipv6/af_inet6.c             |    6 ++++--
 net/ipv6/datagram.c             |    6 +++---
 net/ipv6/ip6_flowlabel.c        |   24 ++++++++++++++----------
 net/ipv6/ip6_tunnel.c           |    4 ++--
 net/ipv6/ip6mr.c                |    2 +-
 net/ipv6/ipv6_sockglue.c        |    7 ++++---
 net/ipv6/netfilter/ip6_tables.c |    8 ++++----
 net/ipv6/route.c                |    2 +-
 net/ipv6/sit.c                  |   10 +++++-----
 10 files changed, 40 insertions(+), 33 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a06c53c..6b93e3b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2228,7 +2228,7 @@ int addrconf_add_ifaddr(struct net *net, void __user *arg)
 	struct in6_ifreq ireq;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (copy_from_user(&ireq, arg, sizeof(struct in6_ifreq)))
@@ -2247,7 +2247,7 @@ int addrconf_del_ifaddr(struct net *net, void __user *arg)
 	struct in6_ifreq ireq;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (copy_from_user(&ireq, arg, sizeof(struct in6_ifreq)))
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3b5669a..1854ffe 100644
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
@@ -281,7 +282,8 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		return -EINVAL;
 
 	snum = ntohs(addr->sin6_port);
-	if (snum && snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
+	if (snum && snum < PROT_SOCK &&
+	    !ns_capable(sock_net(sk)->user_ns, CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
 	lock_sock(sk);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 1656033..7e38d8f 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -694,7 +694,7 @@ int datagram_send_ctl(struct net *net,
 				err = -EINVAL;
 				goto exit_f;
 			}
-			if (!capable(CAP_NET_RAW)) {
+			if (!ns_capable(net->user_ns, CAP_NET_RAW)) {
 				err = -EPERM;
 				goto exit_f;
 			}
@@ -714,7 +714,7 @@ int datagram_send_ctl(struct net *net,
 				err = -EINVAL;
 				goto exit_f;
 			}
-			if (!capable(CAP_NET_RAW)) {
+			if (!ns_capable(net->user_ns, CAP_NET_RAW)) {
 				err = -EPERM;
 				goto exit_f;
 			}
@@ -739,7 +739,7 @@ int datagram_send_ctl(struct net *net,
 				err = -EINVAL;
 				goto exit_f;
 			}
-			if (!capable(CAP_NET_RAW)) {
+			if (!ns_capable(net->user_ns, CAP_NET_RAW)) {
 				err = -EPERM;
 				goto exit_f;
 			}
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index f3caf1b..4726c02 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -294,21 +294,22 @@ struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions * opt_space,
 	return opt_space;
 }
 
-static unsigned long check_linger(unsigned long ttl)
+static unsigned long check_linger(unsigned long ttl, struct user_namespace *ns)
 {
 	if (ttl < FL_MIN_LINGER)
 		return FL_MIN_LINGER*HZ;
-	if (ttl > FL_MAX_LINGER && !capable(CAP_NET_ADMIN))
+	if (ttl > FL_MAX_LINGER && !ns_capable(ns, CAP_NET_ADMIN))
 		return 0;
 	return ttl*HZ;
 }
 
-static int fl6_renew(struct ip6_flowlabel *fl, unsigned long linger, unsigned long expires)
+static int fl6_renew(struct ip6_flowlabel *fl, unsigned long linger,
+		     unsigned long expires, struct user_namespace *ns)
 {
-	linger = check_linger(linger);
+	linger = check_linger(linger, ns);
 	if (!linger)
 		return -EPERM;
-	expires = check_linger(expires);
+	expires = check_linger(expires, ns);
 	if (!expires)
 		return -EPERM;
 	fl->lastuse = jiffies;
@@ -375,7 +376,7 @@ fl_create(struct net *net, struct in6_flowlabel_req *freq, char __user *optval,
 
 	fl->fl_net = hold_net(net);
 	fl->expires = jiffies;
-	err = fl6_renew(fl, freq->flr_linger, freq->flr_expires);
+	err = fl6_renew(fl, freq->flr_linger, freq->flr_expires, net->user_ns);
 	if (err)
 		goto done;
 	fl->share = freq->flr_share;
@@ -425,7 +426,7 @@ static int mem_check(struct sock *sk)
 	if (room <= 0 ||
 	    ((count >= FL_MAX_PER_SOCK ||
 	      (count > 0 && room < FL_MAX_SIZE/2) || room < FL_MAX_SIZE/4) &&
-	     !capable(CAP_NET_ADMIN)))
+	     !ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)))
 		return -ENOBUFS;
 
 	return 0;
@@ -507,17 +508,20 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 		read_lock_bh(&ip6_sk_fl_lock);
 		for (sfl = np->ipv6_fl_list; sfl; sfl = sfl->next) {
 			if (sfl->fl->label == freq.flr_label) {
-				err = fl6_renew(sfl->fl, freq.flr_linger, freq.flr_expires);
+				err = fl6_renew(sfl->fl, freq.flr_linger, freq.flr_expires,
+						net->user_ns);
 				read_unlock_bh(&ip6_sk_fl_lock);
 				return err;
 			}
 		}
 		read_unlock_bh(&ip6_sk_fl_lock);
 
-		if (freq.flr_share == IPV6_FL_S_NONE && capable(CAP_NET_ADMIN)) {
+		if (freq.flr_share == IPV6_FL_S_NONE &&
+		    ns_capable(net->user_ns, CAP_NET_ADMIN)) {
 			fl = fl_lookup(net, freq.flr_label);
 			if (fl) {
-				err = fl6_renew(fl, freq.flr_linger, freq.flr_expires);
+				err = fl6_renew(fl, freq.flr_linger, freq.flr_expires,
+						net->user_ns);
 				fl_release(fl);
 				return err;
 			}
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 36c2842..1a98c23 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1269,7 +1269,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCADDTUNNEL:
 	case SIOCCHGTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			break;
 		err = -EFAULT;
 		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p)))
@@ -1304,7 +1304,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		break;
 	case SIOCDELTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			break;
 
 		if (dev == ip6n->fb_tnl_dev) {
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 705c828..1649ccd 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1582,7 +1582,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 		return -ENOENT;
 
 	if (optname != MRT6_INIT) {
-		if (sk != mrt->mroute6_sk && !capable(CAP_NET_ADMIN))
+		if (sk != mrt->mroute6_sk && !ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EACCES;
 	}
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 9cb191e..196b099 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -343,7 +343,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		break;
 
 	case IPV6_TRANSPARENT:
-		if (!capable(CAP_NET_ADMIN)) {
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN)) {
 			retv = -EPERM;
 			break;
 		}
@@ -381,7 +381,8 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 
 		/* hop-by-hop / destination options are privileged option */
 		retv = -EPERM;
-		if (optname != IPV6_RTHDR && !capable(CAP_NET_RAW))
+		if (optname != IPV6_RTHDR &&
+		    !ns_capable(net->user_ns, CAP_NET_RAW))
 			break;
 
 		opt = ipv6_renew_options(sk, np->opt, optname,
@@ -725,7 +726,7 @@ done:
 	case IPV6_IPSEC_POLICY:
 	case IPV6_XFRM_POLICY:
 		retv = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		retv = xfrm_user_policy(sk, optname, optval, optlen);
 		break;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 94874b0..7fce7d8 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1869,7 +1869,7 @@ compat_do_ip6t_set_ctl(struct sock *sk, int cmd, void __user *user,
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -1984,7 +1984,7 @@ compat_do_ip6t_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -2006,7 +2006,7 @@ do_ip6t_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -2031,7 +2031,7 @@ do_ip6t_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e8987da..2a64c67 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1929,7 +1929,7 @@ int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	switch(cmd) {
 	case SIOCADDRT:		/* Add a route */
 	case SIOCDELRT:		/* Delete a route */
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 		err = copy_from_user(&rtmsg, arg,
 				     sizeof(struct in6_rtmsg));
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 07bf108..402e2a5 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -308,7 +308,7 @@ static int ipip6_tunnel_get_prl(struct ip_tunnel *t,
 	/* For simple GET or for root users,
 	 * we try harder to allocate.
 	 */
-	kp = (cmax <= 1 || capable(CAP_NET_ADMIN)) ?
+	kp = (cmax <= 1 || ns_capable(dev_net(t->dev)->user_ns, CAP_NET_ADMIN)) ?
 		kcalloc(cmax, sizeof(*kp), GFP_KERNEL) :
 		NULL;
 
@@ -926,7 +926,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCADDTUNNEL:
 	case SIOCCHGTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		err = -EFAULT;
@@ -985,7 +985,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	case SIOCDELTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		if (dev == sitn->fb_tunnel_dev) {
@@ -1018,7 +1018,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCDELPRL:
 	case SIOCCHGPRL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			goto done;
 		err = -EINVAL;
 		if (dev == sitn->fb_tunnel_dev)
@@ -1047,7 +1047,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCCHG6RD:
 	case SIOCDEL6RD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		err = -EFAULT;
-- 
1.7.4.1
