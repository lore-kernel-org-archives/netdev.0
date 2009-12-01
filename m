From: jamal <hadi@cyberus.ca>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Tue, 01 Dec 2009 08:34:48 -0500
Message-ID: <1259674488.3168.45.camel@bigi>
References: <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
	 <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi>
	 <20091128151515.GA20476@sch.bme.hu> <4B1145F1.3090704@trash.net>
	 <1259424278.3864.16.camel@bigi> <4B1158CE.90803@trash.net>
	 <1259429774.3864.41.camel@bigi> <20091128190500.GB12264@sch.bme.hu>
	 <1259437442.3864.61.camel@bigi>  <20091129203508.GB18259@sch.bme.hu>
	 <1259583359.873.17.camel@bigi>  <1259585129.3992.13.camel@nienna.balabit>
	 <1259589577.873.30.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-wAtv8NvMtlz9PEA7JFB0"
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	Patrick McHardy <kaber@trash.net>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f197.google.com ([209.85.212.197]:33275 "EHLO
	mail-vw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbZLANeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 08:34:50 -0500
Received: by vws35 with SMTP id 35so1503148vws.4
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2009 05:34:56 -0800 (PST)
In-Reply-To: <1259589577.873.30.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wAtv8NvMtlz9PEA7JFB0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2009-11-30 at 08:59 -0500, jamal wrote:

> [I could move the check into fib_validate, but that would punish other
> users with a few extra cycles]. 

As in the following patch (gleaned from Patrick's patch on send to self)

cheers,
jamal


--=-wAtv8NvMtlz9PEA7JFB0
Content-Disposition: attachment; filename="fib-val-sysctl2"
Content-Type: text/x-patch; name="fib-val-sysctl2"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index ad27c7d..9cd0bcf 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -83,6 +83,7 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 #define IN_DEV_FORWARD(in_dev)		IN_DEV_CONF_GET((in_dev), FORWARDING)
 #define IN_DEV_MFORWARD(in_dev)		IN_DEV_ANDCONF((in_dev), MC_FORWARDING)
 #define IN_DEV_RPFILTER(in_dev)		IN_DEV_MAXCONF((in_dev), RP_FILTER)
+#define IN_DEV_SRC_VMARK(in_dev)    	IN_DEV_ORCONF((in_dev), SRC_VMARK)
 #define IN_DEV_SOURCE_ROUTE(in_dev)	IN_DEV_ANDCONF((in_dev), \
 						       ACCEPT_SOURCE_ROUTE)
 #define IN_DEV_BOOTP_RELAY(in_dev)	IN_DEV_ANDCONF((in_dev), BOOTP_RELAY)
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 1e4743e..843f71b 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -490,6 +490,7 @@ enum
 	NET_IPV4_CONF_PROMOTE_SECONDARIES=20,
 	NET_IPV4_CONF_ARP_ACCEPT=21,
 	NET_IPV4_CONF_ARP_NOTIFY=22,
+	NET_IPV4_CONF_SRC_VMARK=23,
 	__NET_IPV4_CONF_MAX
 };
 
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index b6e7aae..469193c 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -220,6 +220,7 @@ static const struct trans_ctl_table trans_net_ipv4_conf_vars_table[] = {
 	{ NET_IPV4_CONF_PROMOTE_SECONDARIES,	"promote_secondaries" },
 	{ NET_IPV4_CONF_ARP_ACCEPT,		"arp_accept" },
 	{ NET_IPV4_CONF_ARP_NOTIFY,		"arp_notify" },
+	{ NET_IPV4_CONF_SRC_VMARK,		"src_valid_mark" },
 	{}
 };
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5df2f6a..0030e73 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1450,6 +1450,7 @@ static struct devinet_sysctl_table {
 		DEVINET_SYSCTL_RW_ENTRY(SEND_REDIRECTS, "send_redirects"),
 		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_SOURCE_ROUTE,
 					"accept_source_route"),
+		DEVINET_SYSCTL_RW_ENTRY(SRC_VMARK, "src_valid_mark"),
 		DEVINET_SYSCTL_RW_ENTRY(PROXY_ARP, "proxy_arp"),
 		DEVINET_SYSCTL_RW_ENTRY(MEDIUM_ID, "medium_id"),
 		DEVINET_SYSCTL_RW_ENTRY(BOOTP_RELAY, "bootp_relay"),
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index aa00398..b489135 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -241,16 +241,19 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 			    .iif = oif };
 
 	struct fib_result res;
-	int no_addr, rpf;
+	int no_addr, rpf, validate_mark;
 	int ret;
 	struct net *net;
 
-	no_addr = rpf = 0;
+	no_addr = rpf = validate_mark = 0;
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
 	if (in_dev) {
 		no_addr = in_dev->ifa_list == NULL;
 		rpf = IN_DEV_RPFILTER(in_dev);
+		validate_mark = IN_DEV_SRC_VMARK(in_dev);
+		if (!validate_mark)
+			mark = 0;
 	}
 	rcu_read_unlock();
 

--=-wAtv8NvMtlz9PEA7JFB0--

