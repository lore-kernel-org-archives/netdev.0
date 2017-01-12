From: Krister Johansen <kjlx@templeofstupid.com>
Subject: [PATCH v2 net-next] Introduce a sysctl that modifies the value of
 PROT_SOCK.
Date: Wed, 11 Jan 2017 22:52:25 -0800
Message-ID: <20170112065225.GB2345@templeofstupid.com>
References: <20161231125505.7f0c7dff@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:58204 "EHLO
        homiemail-a40.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750722AbdALGw1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 01:52:27 -0500
Received: from homiemail-a40.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a40.g.dreamhost.com (Postfix) with ESMTP id 16DF46002920
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 22:52:27 -0800 (PST)
Received: from kmjvbox (c-73-70-90-212.hsd1.ca.comcast.net [73.70.90.212])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a40.g.dreamhost.com (Postfix) with ESMTPSA id E4A7A6002911
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 22:52:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161231125505.7f0c7dff@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add net.ipv4.ip_unprotected_port_start, which is a per namespace sysctl
that denotes the first unprotected inet port in the namespace.  To
disable all protected ports set this to zero.  It also checks for
overlap with the local port range.  The protected and local range may
not overlap.

The use case for this change is to allow containerized processes to bind
to priviliged ports, but prevent them from ever being allowed to modify
their container's network configuration.  The latter is accomplished by
ensuring that the network namespace is not a child of the user
namespace.  This modification was needed to allow the container manager
to disable a namespace's priviliged port restrictions without exposing
control of the network namespace to processes in the user namespace.

Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
---
 include/net/ip.h               | 10 +++++++++
 include/net/netns/ipv4.h       |  1 +
 net/ipv4/af_inet.c             |  5 ++++-
 net/ipv4/sysctl_net_ipv4.c     | 50 +++++++++++++++++++++++++++++++++++++++++-
 net/ipv6/af_inet6.c            |  3 ++-
 net/netfilter/ipvs/ip_vs_ctl.c |  7 +++---
 net/sctp/socket.c              | 10 +++++----
 security/selinux/hooks.c       |  3 ++-
 8 files changed, 77 insertions(+), 12 deletions(-)

Changes v1 -> v2:

Remove LOWPORT_SYSCTL config option.  This is now always enabled as long
as CONFIG_SYSCTL is.

diff --git a/include/net/ip.h b/include/net/ip.h
index ab6761a..bf264a8 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -263,11 +263,21 @@ static inline bool sysctl_dev_name_is_allowed(const char *name)
 	return strcmp(name, "default") != 0  && strcmp(name, "all") != 0;
 }
 
+static inline int inet_prot_sock(struct net *net)
+{
+	return net->ipv4.sysctl_ip_prot_sock;
+}
+
 #else
 static inline int inet_is_local_reserved_port(struct net *net, int port)
 {
 	return 0;
 }
+
+static inline int inet_prot_sock(struct net *net)
+{
+	return PROT_SOCK;
+}
 #endif
 
 __be32 inet_current_timestamp(void);
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 8e3f5b6..e365732 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -135,6 +135,7 @@ struct netns_ipv4 {
 
 #ifdef CONFIG_SYSCTL
 	unsigned long *sysctl_local_reserved_ports;
+	int sysctl_ip_prot_sock;
 #endif
 
 #ifdef CONFIG_IP_MROUTE
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index aae410b..28fe8da 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -479,7 +479,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	snum = ntohs(addr->sin_port);
 	err = -EACCES;
-	if (snum && snum < PROT_SOCK &&
+	if (snum && snum < inet_prot_sock(net) &&
 	    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE))
 		goto out;
 
@@ -1700,6 +1700,9 @@ static __net_init int inet_init_net(struct net *net)
 	net->ipv4.sysctl_ip_default_ttl = IPDEFTTL;
 	net->ipv4.sysctl_ip_dynaddr = 0;
 	net->ipv4.sysctl_ip_early_demux = 1;
+#ifdef CONFIG_SYSCTL
+	net->ipv4.sysctl_ip_prot_sock = PROT_SOCK;
+#endif
 
 	return 0;
 }
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 134d8e1..6ad3b39 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -35,6 +35,8 @@ static int ip_local_port_range_min[] = { 1, 1 };
 static int ip_local_port_range_max[] = { 65535, 65535 };
 static int tcp_adv_win_scale_min = -31;
 static int tcp_adv_win_scale_max = 31;
+static int ip_protected_port_min;
+static int ip_protected_port_max = 65535;
 static int ip_ttl_min = 1;
 static int ip_ttl_max = 255;
 static int tcp_syn_retries_min = 1;
@@ -79,7 +81,12 @@ static int ipv4_local_port_range(struct ctl_table *table, int write,
 	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
 
 	if (write && ret == 0) {
-		if (range[1] < range[0])
+		/* Ensure that the upper limit is not smaller than the lower,
+		 * and that the lower does not encroach upon the protected
+		 * port limit.
+		 */
+		if ((range[1] < range[0]) ||
+		    (range[0] < net->ipv4.sysctl_ip_prot_sock))
 			ret = -EINVAL;
 		else
 			set_local_port_range(net, range);
@@ -88,6 +95,40 @@ static int ipv4_local_port_range(struct ctl_table *table, int write,
 	return ret;
 }
 
+/* Validate changes from /proc interface. */
+static int ipv4_protected_ports(struct ctl_table *table, int write,
+				void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct net *net = container_of(table->data, struct net,
+	    ipv4.sysctl_ip_prot_sock);
+	int ret;
+	int pports;
+	int range[2];
+	struct ctl_table tmp = {
+		.data = &pports,
+		.maxlen = sizeof(pports),
+		.mode = table->mode,
+		.extra1 = &ip_protected_port_min,
+		.extra2 = &ip_protected_port_max,
+	};
+
+	pports = net->ipv4.sysctl_ip_prot_sock;
+
+	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+
+	if (write && ret == 0) {
+		inet_get_local_port_range(net, &range[0], &range[1]);
+		/* Ensure that the local port range doesn't overlap with the
+		 * protected port range.
+		 */
+		if (range[0] < pports)
+			ret = -EINVAL;
+		else
+			net->ipv4.sysctl_ip_prot_sock = pports;
+	}
+
+	return ret;
+}
 
 static void inet_get_ping_group_range_table(struct ctl_table *table, kgid_t *low, kgid_t *high)
 {
@@ -971,6 +1012,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname	= "ip_unprotected_port_start",
+		.maxlen		= sizeof(int),
+		.data		= &init_net.ipv4.sysctl_ip_prot_sock,
+		.mode		= 0644,
+		.proc_handler	= ipv4_protected_ports,
+	},
 	{ }
 };
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index aa42123..04db406 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -302,7 +302,8 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		return -EINVAL;
 
 	snum = ntohs(addr->sin6_port);
-	if (snum && snum < PROT_SOCK && !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE))
+	if (snum && snum < inet_prot_sock(net) &&
+	    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
 	lock_sock(sk);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 55e0169..8b7416f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -426,10 +426,9 @@ ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u32 fwmark, __u16 protocol
 	 */
 	svc = __ip_vs_service_find(ipvs, af, protocol, vaddr, vport);
 
-	if (svc == NULL
-	    && protocol == IPPROTO_TCP
-	    && atomic_read(&ipvs->ftpsvc_counter)
-	    && (vport == FTPDATA || ntohs(vport) >= PROT_SOCK)) {
+	if (!svc && protocol == IPPROTO_TCP &&
+	    atomic_read(&ipvs->ftpsvc_counter) &&
+	    (vport == FTPDATA || ntohs(vport) >= inet_prot_sock(ipvs->net))) {
 		/*
 		 * Check if ftp service entry exists, the packet
 		 * might belong to FTP data connections.
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 318c678..2723f4a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -360,7 +360,7 @@ static int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 		}
 	}
 
-	if (snum && snum < PROT_SOCK &&
+	if (snum && snum < inet_prot_sock(net) &&
 	    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
@@ -1152,8 +1152,10 @@ static int __sctp_connect(struct sock *sk,
 				 * accept new associations, but it SHOULD NOT
 				 * be permitted to open new associations.
 				 */
-				if (ep->base.bind_addr.port < PROT_SOCK &&
-				    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE)) {
+				if (ep->base.bind_addr.port <
+				    inet_prot_sock(net) &&
+				    !ns_capable(net->user_ns,
+				    CAP_NET_BIND_SERVICE)) {
 					err = -EACCES;
 					goto out_free;
 				}
@@ -1818,7 +1820,7 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 			 * but it SHOULD NOT be permitted to open new
 			 * associations.
 			 */
-			if (ep->base.bind_addr.port < PROT_SOCK &&
+			if (ep->base.bind_addr.port < inet_prot_sock(net) &&
 			    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE)) {
 				err = -EACCES;
 				goto out_unlock;
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index c7c6619..53cb6da 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4365,7 +4365,8 @@ static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, in
 
 			inet_get_local_port_range(sock_net(sk), &low, &high);
 
-			if (snum < max(PROT_SOCK, low) || snum > high) {
+			if (snum < max(inet_prot_sock(sock_net(sk)), low) ||
+			    snum > high) {
 				err = sel_netport_sid(sk->sk_protocol,
 						      snum, &sid);
 				if (err)
-- 
2.7.4
