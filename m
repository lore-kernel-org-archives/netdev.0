From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net-next 2/2] ping: move ping_group_range out of CONFIG_SYSCTL
Date: Tue,  6 May 2014 11:02:50 -0700
Message-ID: <1399399370-7849-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1399399370-7849-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:52055 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbaEFSDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 14:03:03 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so826674pad.2
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 11:03:02 -0700 (PDT)
In-Reply-To: <1399399370-7849-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

Similarly, when CONFIG_SYSCTL is not set, ping_group_range should still
work, just that no one can change it. Therefore we should move it out of
sysctl_net_ipv4.c. And, it should not share the same seqlock with
ip_local_port_range.

BTW, rename it to ->ping_group_range instead.

Cc: David S. Miller <davem@davemloft.net>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Reported-by: Stefan de Konink <stefan@konink.de>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/netns/ipv4.h   |  7 ++++++-
 net/ipv4/af_inet.c         |  8 ++++++++
 net/ipv4/ping.c            |  6 +++---
 net/ipv4/sysctl_net_ipv4.c | 13 +++----------
 4 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 3d95cd4..b2704fd0 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -20,6 +20,11 @@ struct local_ports {
 	int		range[2];
 };
 
+struct ping_group_range {
+	seqlock_t	lock;
+	kgid_t		range[2];
+};
+
 struct netns_ipv4 {
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*forw_hdr;
@@ -72,7 +77,7 @@ struct netns_ipv4 {
 	int sysctl_ip_no_pmtu_disc;
 	int sysctl_ip_fwd_use_pmtu;
 
-	kgid_t sysctl_ping_group_range[2];
+	struct ping_group_range ping_group_range;
 
 	atomic_t dev_addr_genid;
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cccc8e4..6d6dd34 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1658,6 +1658,14 @@ static __net_init int inet_init_net(struct net *net)
 	seqlock_init(&net->ipv4.ip_local_ports.lock);
 	net->ipv4.ip_local_ports.range[0] =  32768;
 	net->ipv4.ip_local_ports.range[1] =  61000;
+
+	seqlock_init(&net->ipv4.ping_group_range.lock);
+	/*
+	 * Sane defaults - nobody may create ping sockets.
+	 * Boot scripts should set this to distro-specific group.
+	 */
+	net->ipv4.ping_group_range.range[0] = make_kgid(&init_user_ns, 1);
+	net->ipv4.ping_group_range.range[1] = make_kgid(&init_user_ns, 0);
 	return 0;
 }
 
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 347bdde..044a0dd 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -236,15 +236,15 @@ exit:
 static void inet_get_ping_group_range_net(struct net *net, kgid_t *low,
 					  kgid_t *high)
 {
-	kgid_t *data = net->ipv4.sysctl_ping_group_range;
+	kgid_t *data = net->ipv4.ping_group_range.range;
 	unsigned int seq;
 
 	do {
-		seq = read_seqbegin(&net->ipv4.ip_local_ports.lock);
+		seq = read_seqbegin(&net->ipv4.ping_group_range.lock);
 
 		*low = data[0];
 		*high = data[1];
-	} while (read_seqretry(&net->ipv4.ip_local_ports.lock, seq));
+	} while (read_seqretry(&net->ipv4.ping_group_range.lock, seq));
 }
 
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index a116c41..5cde8f2 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -87,7 +87,7 @@ static void inet_get_ping_group_range_table(struct ctl_table *table, kgid_t *low
 {
 	kgid_t *data = table->data;
 	struct net *net =
-		container_of(table->data, struct net, ipv4.sysctl_ping_group_range);
+		container_of(table->data, struct net, ipv4.ping_group_range.range);
 	unsigned int seq;
 	do {
 		seq = read_seqbegin(&net->ipv4.ip_local_ports.lock);
@@ -102,7 +102,7 @@ static void set_ping_group_range(struct ctl_table *table, kgid_t low, kgid_t hig
 {
 	kgid_t *data = table->data;
 	struct net *net =
-		container_of(table->data, struct net, ipv4.sysctl_ping_group_range);
+		container_of(table->data, struct net, ipv4.ping_group_range.range);
 	write_seqlock(&net->ipv4.ip_local_ports.lock);
 	data[0] = low;
 	data[1] = high;
@@ -805,7 +805,7 @@ static struct ctl_table ipv4_net_table[] = {
 	},
 	{
 		.procname	= "ping_group_range",
-		.data		= &init_net.ipv4.sysctl_ping_group_range,
+		.data		= &init_net.ipv4.ping_group_range.range,
 		.maxlen		= sizeof(gid_t)*2,
 		.mode		= 0644,
 		.proc_handler	= ipv4_ping_group_range,
@@ -858,13 +858,6 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 			table[i].data += (void *)net - (void *)&init_net;
 	}
 
-	/*
-	 * Sane defaults - nobody may create ping sockets.
-	 * Boot scripts should set this to distro-specific group.
-	 */
-	net->ipv4.sysctl_ping_group_range[0] = make_kgid(&init_user_ns, 1);
-	net->ipv4.sysctl_ping_group_range[1] = make_kgid(&init_user_ns, 0);
-
 	net->ipv4.ipv4_hdr = register_net_sysctl(net, "net/ipv4", table);
 	if (net->ipv4.ipv4_hdr == NULL)
 		goto err_reg;
-- 
1.8.3.1
