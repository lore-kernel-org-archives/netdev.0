From: Paul Stewart <pstew@chromium.org>
Subject: [PATCHv2] ipv6: Create module parameter for use_tempaddr
Date: Wed, 31 Aug 2011 23:03:54 -0700
Message-ID: <20110912212011.7C65B2041D@glenhelen.mtv.corp.google.com>
References: <4E6E62D1.8010108@hp.com>
Cc: davem@davemloft.net, brian.haley@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:31815 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754442Ab1ILVUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 17:20:22 -0400
In-Reply-To: <4E6E62D1.8010108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ipv6 is used as a module, there is no good place to set
the default value for use_tempaddr.  Using sysctl.conf will
set this parameter too early -- before the module is loaded.
To solve this, create a module parameter that will set the
default value of use_tempaddr for all devices.

Signed-off-by: Paul Stewart <pstew@chromium.org>
Cc: davem@davemloft.net
Cc: brian.haley@hp.com
--
v2: Add documentation; move module parameter out of ifdef
---
 Documentation/networking/ipv6.txt |   20 ++++++++++++++++++++
 include/linux/ipv6.h              |    1 +
 net/ipv6/addrconf.c               |    3 +++
 net/ipv6/af_inet6.c               |    4 ++++
 4 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ipv6.txt b/Documentation/networking/ipv6.txt
index 9fd7e21..d7f71e1 100644
--- a/Documentation/networking/ipv6.txt
+++ b/Documentation/networking/ipv6.txt
@@ -70,3 +70,23 @@ disable_ipv6
 
 		No IPv6 addresses will be added to interfaces.
 
+use_tempaddr
+
+	Specifies whether to enable Privacy Extensions for Stateless
+	Address Autoconfiguration (RFC3041) on all interfaces by default.
+
+	The possible values and their effects are:
+
+	0
+		Privacy addresses are not enabled by default.
+
+		This is the default value.
+
+	1
+		Privacy addresses are enabled by default on all interfaces
+		but do not prefer them over normal addresses.
+
+	2
+		Privacy addresses are enabled by default on all interfaces
+		and will be preferred over normal addresses.
+
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 0c99776..0d45a7c 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -178,6 +178,7 @@ struct ipv6_devconf {
 struct ipv6_params {
 	__s32 disable_ipv6;
 	__s32 autoconf;
+	__s32 use_tempaddr;
 };
 extern struct ipv6_params ipv6_defaults;
 #endif
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f012ebd..27314a2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4609,6 +4609,9 @@ static int __net_init addrconf_init_net(struct net *net)
 		/* these will be inherited by all namespaces */
 		dflt->autoconf = ipv6_defaults.autoconf;
 		dflt->disable_ipv6 = ipv6_defaults.disable_ipv6;
+#ifdef CONFIG_IPV6_PRIVACY
+		dflt->use_tempaddr = ipv6_defaults.use_tempaddr;
+#endif
 	}
 
 	net->ipv6.devconf_all = all;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3b5669a..36ee4a5 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -76,6 +76,7 @@ static DEFINE_SPINLOCK(inetsw6_lock);
 struct ipv6_params ipv6_defaults = {
 	.disable_ipv6 = 0,
 	.autoconf = 1,
+	.use_tempaddr = 0,
 };
 
 static int disable_ipv6_mod = 0;
@@ -89,6 +90,9 @@ MODULE_PARM_DESC(disable_ipv6, "Disable IPv6 on all interfaces");
 module_param_named(autoconf, ipv6_defaults.autoconf, int, 0444);
 MODULE_PARM_DESC(autoconf, "Enable IPv6 address autoconfiguration on all interfaces");
 
+module_param_named(use_tempaddr, ipv6_defaults.use_tempaddr, int, 0444);
+MODULE_PARM_DESC(use_tempaddr, "Enable IPv6 address privacy for autoconfiguration by default");
+
 static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
 {
 	const int offset = sk->sk_prot->obj_size - sizeof(struct ipv6_pinfo);
-- 
1.7.3.1
