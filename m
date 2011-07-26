From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 13/14] userns: net: make many network capable calls targeted
Date: Tue, 26 Jul 2011 18:58:36 +0000
Message-ID: <1311706717-7398-14-git-send-email-serge@hallyn.com>
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

When privilege is protected a namespaced network resource, then having
the required privilege targed toward the user namespace which owns the
resource suffices.

As with other patches, a big concern here is that we be cleanly separating
the cases where privilege protects a network resource from cases where
privilege can lead to laxer constraints on input and, subsequently,
the ability to corrupt, crash, or own the host kernel.

Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
 net/8021q/vlan.c                  |   12 ++++++------
 net/bridge/br_ioctl.c             |   22 +++++++++++-----------
 net/bridge/br_sysfs_br.c          |    8 ++++----
 net/bridge/br_sysfs_if.c          |    2 +-
 net/bridge/netfilter/ebtables.c   |    8 ++++----
 net/core/ethtool.c                |    2 +-
 net/ipv4/arp.c                    |    2 +-
 net/ipv4/devinet.c                |    4 ++--
 net/ipv4/fib_frontend.c           |    2 +-
 net/ipv4/ip_options.c             |    6 +++---
 net/ipv4/ip_sockglue.c            |    4 ++--
 net/ipv4/ipip.c                   |    4 ++--
 net/ipv4/ipmr.c                   |    2 +-
 net/ipv4/netfilter/arp_tables.c   |    8 ++++----
 net/ipv4/netfilter/ip_tables.c    |    8 ++++----
 net/netfilter/ipset/ip_set_core.c |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c    |    4 ++--
 net/packet/af_packet.c            |    2 +-
 18 files changed, 51 insertions(+), 51 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 8970ba1..7d12f63 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -558,7 +558,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 	switch (args.cmd) {
 	case SET_VLAN_INGRESS_PRIORITY_CMD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		vlan_dev_set_ingress_priority(dev,
 					      args.u.skb_priority,
@@ -568,7 +568,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 
 	case SET_VLAN_EGRESS_PRIORITY_CMD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		err = vlan_dev_set_egress_priority(dev,
 						   args.u.skb_priority,
@@ -577,7 +577,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 
 	case SET_VLAN_FLAG_CMD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		err = vlan_dev_change_flags(dev,
 					    args.vlan_qos ? args.u.flag : 0,
@@ -586,7 +586,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 
 	case SET_VLAN_NAME_TYPE_CMD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		if ((args.u.name_type >= 0) &&
 		    (args.u.name_type < VLAN_NAME_TYPE_HIGHEST)) {
@@ -602,14 +602,14 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 
 	case ADD_VLAN_CMD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		err = register_vlan_device(dev, args.u.VID);
 		break;
 
 	case DEL_VLAN_CMD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		unregister_vlan_dev(dev, NULL);
 		err = 0;
diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index 7222fe1..c82f9cb 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -88,7 +88,7 @@ static int add_del_if(struct net_bridge *br, int ifindex, int isadd)
 	struct net_device *dev;
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	dev = __dev_get_by_index(dev_net(br->dev), ifindex);
@@ -178,25 +178,25 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	}
 
 	case BRCTL_SET_BRIDGE_FORWARD_DELAY:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		return br_set_forward_delay(br, args[1]);
 
 	case BRCTL_SET_BRIDGE_HELLO_TIME:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		return br_set_hello_time(br, args[1]);
 
 	case BRCTL_SET_BRIDGE_MAX_AGE:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		return br_set_max_age(br, args[1]);
 
 	case BRCTL_SET_AGEING_TIME:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		br->ageing_time = clock_t_to_jiffies(args[1]);
@@ -236,14 +236,14 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	}
 
 	case BRCTL_SET_BRIDGE_STP_STATE:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		br_stp_set_enabled(br, args[1]);
 		return 0;
 
 	case BRCTL_SET_BRIDGE_PRIORITY:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
@@ -256,7 +256,7 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		struct net_bridge_port *p;
 		int ret;
 
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
@@ -273,7 +273,7 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		struct net_bridge_port *p;
 		int ret;
 
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
@@ -330,7 +330,7 @@ static int old_deviceless(struct net *net, void __user *uarg)
 	{
 		char buf[IFNAMSIZ];
 
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		if (copy_from_user(buf, (void __user *)args[1], IFNAMSIZ))
@@ -360,7 +360,7 @@ int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd, void __user *uar
 	{
 		char buf[IFNAMSIZ];
 
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		if (copy_from_user(buf, uarg, IFNAMSIZ))
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 68b893e..7f4fa3a 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -36,7 +36,7 @@ static ssize_t store_bridge_parm(struct device *d,
 	unsigned long val;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	val = simple_strtoul(buf, &endp, 0);
@@ -132,7 +132,7 @@ static ssize_t store_stp_state(struct device *d,
 	char *endp;
 	unsigned long val;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	val = simple_strtoul(buf, &endp, 0);
@@ -267,7 +267,7 @@ static ssize_t store_group_addr(struct device *d,
 	unsigned new_addr[6];
 	int i;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (sscanf(buf, "%x:%x:%x:%x:%x:%x",
@@ -304,7 +304,7 @@ static ssize_t store_flush(struct device *d,
 {
 	struct net_bridge *br = to_bridge(d);
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	br_fdb_flush(br);
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 6229b62..9cb4d2e 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -209,7 +209,7 @@ static ssize_t brport_store(struct kobject * kobj,
 	char *endp;
 	unsigned long val;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(p->br->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	val = simple_strtoul(buf, &endp, 0);
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 2b5ca1a..c403c45 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1462,7 +1462,7 @@ static int do_ebt_set_ctl(struct sock *sk,
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch(cmd) {
@@ -1484,7 +1484,7 @@ static int do_ebt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	struct ebt_replace tmp;
 	struct ebt_table *t;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (copy_from_user(&tmp, user, sizeof(tmp)))
@@ -2275,7 +2275,7 @@ static int compat_do_ebt_set_ctl(struct sock *sk,
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -2298,7 +2298,7 @@ static int compat_do_ebt_get_ctl(struct sock *sk, int cmd,
 	struct compat_ebt_replace tmp;
 	struct ebt_table *t;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	/* try real handler in case userland supplied needed padding */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 6cdba5f..56878bf 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1676,7 +1676,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GFEATURES:
 		break;
 	default:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 	}
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 96a164a..023ad24 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1175,7 +1175,7 @@ int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	switch (cmd) {
 	case SIOCDARP:
 	case SIOCSARP:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 	case SIOCGARP:
 		err = copy_from_user(&r, arg, sizeof(struct arpreq));
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 37b3c18..3683d37 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -728,7 +728,7 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 
 	case SIOCSIFFLAGS:
 		ret = -EACCES;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto out;
 		break;
 	case SIOCSIFADDR:	/* Set interface address (and family) */
@@ -736,7 +736,7 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	case SIOCSIFDSTADDR:	/* Set the destination address */
 	case SIOCSIFNETMASK: 	/* Set the netmask for the interface */
 		ret = -EACCES;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto out;
 		ret = -EINVAL;
 		if (sin->sin_family != AF_INET)
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 92fc5f6..8f34a07 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -437,7 +437,7 @@ int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	switch (cmd) {
 	case SIOCADDRT:		/* Add a route */
 	case SIOCDELRT:		/* Delete a route */
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
 		if (copy_from_user(&rt, arg, sizeof(rt)))
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index ec93335..21df700 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -396,7 +396,7 @@ int ip_options_compile(struct net *net,
 					optptr[2] += 8;
 					break;
 				      default:
-					if (!skb && !capable(CAP_NET_RAW)) {
+					if (!skb && !ns_capable(net->user_ns, CAP_NET_RAW)) {
 						pp_ptr = optptr + 3;
 						goto error;
 					}
@@ -432,7 +432,7 @@ int ip_options_compile(struct net *net,
 				opt->router_alert = optptr - iph;
 			break;
 		      case IPOPT_CIPSO:
-			if ((!skb && !capable(CAP_NET_RAW)) || opt->cipso) {
+			if ((!skb && !ns_capable(net->user_ns, CAP_NET_RAW)) || opt->cipso) {
 				pp_ptr = optptr;
 				goto error;
 			}
@@ -445,7 +445,7 @@ int ip_options_compile(struct net *net,
 		      case IPOPT_SEC:
 		      case IPOPT_SID:
 		      default:
-			if (!skb && !capable(CAP_NET_RAW)) {
+			if (!skb && !ns_capable(net->user_ns, CAP_NET_RAW)) {
 				pp_ptr = optptr;
 				goto error;
 			}
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index ab0c9ef..972c65f 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -955,13 +955,13 @@ mc_msf_out:
 	case IP_IPSEC_POLICY:
 	case IP_XFRM_POLICY:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 			break;
 		err = xfrm_user_policy(sk, optname, optval, optlen);
 		break;
 
 	case IP_TRANSPARENT:
-		if (!capable(CAP_NET_ADMIN)) {
+		if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)) {
 			err = -EPERM;
 			break;
 		}
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 378b20b..6725832 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -629,7 +629,7 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCADDTUNNEL:
 	case SIOCCHGTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		err = -EFAULT;
@@ -689,7 +689,7 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	case SIOCDELTUNNEL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
 
 		if (dev == ipn->fb_tunnel_dev) {
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 58e8791..309aa0c 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1204,7 +1204,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 
 	if (optname != MRT_INIT) {
 		if (sk != rcu_dereference_raw(mrt->mroute_sk) &&
-		    !capable(CAP_NET_ADMIN))
+		    !ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EACCES;
 	}
 
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index fd7a3f6..acc908f 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1534,7 +1534,7 @@ static int compat_do_arpt_set_ctl(struct sock *sk, int cmd, void __user *user,
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -1678,7 +1678,7 @@ static int compat_do_arpt_get_ctl(struct sock *sk, int cmd, void __user *user,
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -1699,7 +1699,7 @@ static int do_arpt_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -1723,7 +1723,7 @@ static int do_arpt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 24e556e..72f2cde 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1847,7 +1847,7 @@ compat_do_ipt_set_ctl(struct sock *sk,	int cmd, void __user *user,
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -1962,7 +1962,7 @@ compat_do_ipt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -1984,7 +1984,7 @@ do_ipt_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
@@ -2009,7 +2009,7 @@ do_ipt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 {
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index d7e86ef..38d69a5 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1596,7 +1596,7 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 	void *data;
 	int copylen = *len, ret = 0;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 	if (optval != SO_IP_SET)
 		return -EBADF;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index be43fd8..7eda0eb 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2284,7 +2284,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	struct ip_vs_dest_user *udest_compat;
 	struct ip_vs_dest_user_kern udest;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_SET_MAX)
@@ -2566,7 +2566,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	BUG_ON(!net);
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_GET_MAX)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c698cec..c2e6bb6 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1793,7 +1793,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	__be16 proto = (__force __be16)protocol; /* weird, but documented */
 	int err;
 
-	if (!capable(CAP_NET_RAW))
+	if (!ns_capable(net->user_ns, CAP_NET_RAW))
 		return -EPERM;
 	if (sock->type != SOCK_DGRAM && sock->type != SOCK_RAW &&
 	    sock->type != SOCK_PACKET)
-- 
1.7.4.1
