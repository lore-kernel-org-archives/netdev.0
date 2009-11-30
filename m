From: Patrick McHardy <kaber@trash.net>
Subject: ipv4 05/05: add sysctl to accept packets with local source addresses
Date: Mon, 30 Nov 2009 18:55:36 +0100 (MET)
Message-ID: <20091130175536.7555.42760.sendpatchset@x2.localnet>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56508 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbZK3Rza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 12:55:30 -0500
In-Reply-To: <20091130175529.7555.10132.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 35924708110a98ac8407deaef95194ff9d0375d2
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Nov 30 17:48:03 2009 +0100

    ipv4: add sysctl to accept packets with local source addresses
    
    Change fib_validate_source() to accept packets with a local source address when
    the "accept_local" sysctl is set for the incoming inet device. Combined with the
    previous patches, this allows to communicate between multiple local interfaces
    over the wire.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index a0e134d..b319d4f 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -723,6 +723,12 @@ accept_source_route - BOOLEAN
 	default TRUE (router)
 		FALSE (host)
 
+accept_local - BOOLEAN
+	Accept packets with local source addresses. In combination with
+	suitable routing, this can be used to direct packets between two
+	local interfaces over the wire and have them accepted properly.
+	default FALSE
+
 rp_filter - INTEGER
 	0 - No source validation.
 	1 - Strict mode as defined in RFC3704 Strict Reverse Path
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index eecfa55..699e85c 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -83,6 +83,7 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 #define IN_DEV_RPFILTER(in_dev)		IN_DEV_MAXCONF((in_dev), RP_FILTER)
 #define IN_DEV_SOURCE_ROUTE(in_dev)	IN_DEV_ANDCONF((in_dev), \
 						       ACCEPT_SOURCE_ROUTE)
+#define IN_DEV_ACCEPT_LOCAL(in_dev)	IN_DEV_ORCONF((in_dev), ACCEPT_LOCAL)
 #define IN_DEV_BOOTP_RELAY(in_dev)	IN_DEV_ANDCONF((in_dev), BOOTP_RELAY)
 
 #define IN_DEV_LOG_MARTIANS(in_dev)	IN_DEV_ORCONF((in_dev), LOG_MARTIANS)
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 1e4743e..9f047d7 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -490,6 +490,7 @@ enum
 	NET_IPV4_CONF_PROMOTE_SECONDARIES=20,
 	NET_IPV4_CONF_ARP_ACCEPT=21,
 	NET_IPV4_CONF_ARP_NOTIFY=22,
+	NET_IPV4_CONF_ACCEPT_LOCAL=23,
 	__NET_IPV4_CONF_MAX
 };
 
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index b6e7aae..f1d676e 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -220,6 +220,7 @@ static const struct trans_ctl_table trans_net_ipv4_conf_vars_table[] = {
 	{ NET_IPV4_CONF_PROMOTE_SECONDARIES,	"promote_secondaries" },
 	{ NET_IPV4_CONF_ARP_ACCEPT,		"arp_accept" },
 	{ NET_IPV4_CONF_ARP_NOTIFY,		"arp_notify" },
+	{ NET_IPV4_CONF_ACCEPT_LOCAL,		"accept_local" },
 	{}
 };
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index c100709..e312661 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1468,6 +1468,7 @@ static struct devinet_sysctl_table {
 		DEVINET_SYSCTL_RW_ENTRY(SEND_REDIRECTS, "send_redirects"),
 		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_SOURCE_ROUTE,
 					"accept_source_route"),
+		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_LOCAL, "accept_local"),
 		DEVINET_SYSCTL_RW_ENTRY(PROXY_ARP, "proxy_arp"),
 		DEVINET_SYSCTL_RW_ENTRY(MEDIUM_ID, "medium_id"),
 		DEVINET_SYSCTL_RW_ENTRY(BOOTP_RELAY, "bootp_relay"),
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 6c1e56a..32ea949 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -241,16 +241,17 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 			    .iif = oif };
 
 	struct fib_result res;
-	int no_addr, rpf;
+	int no_addr, rpf, accept_local;
 	int ret;
 	struct net *net;
 
-	no_addr = rpf = 0;
+	no_addr = rpf = accept_local = 0;
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
 	if (in_dev) {
 		no_addr = in_dev->ifa_list == NULL;
 		rpf = IN_DEV_RPFILTER(in_dev);
+		accept_local = IN_DEV_ACCEPT_LOCAL(in_dev);
 	}
 	rcu_read_unlock();
 
@@ -260,8 +261,10 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 	net = dev_net(dev);
 	if (fib_lookup(net, &fl, &res))
 		goto last_resort;
-	if (res.type != RTN_UNICAST)
-		goto e_inval_res;
+	if (res.type != RTN_UNICAST) {
+		if (res.type != RTN_LOCAL || !accept_local)
+			goto e_inval_res;
+	}
 	*spec_dst = FIB_RES_PREFSRC(res);
 	fib_combine_itag(itag, &res);
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
