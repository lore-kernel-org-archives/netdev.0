From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] iptables: new strict host model match
Date: Thu, 26 Feb 2009 17:52:47 -0800
Message-ID: <20090226175247.5e56910f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37413 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751929AbZB0Bwv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 20:52:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a simple little iptables match that can be used to create the Strong
End System model, that router and other non-Linux customers expect. There
are management and other applications that use ping and expect to only get
a response when the interface with that address is up. Normally, a Linux
system will respond to a packet that arrives for any of the system addresses
independent of which link it arrives on.

The module can be used on the INPUT chain like:

# iptables -P INPUT DROP
# iptables -A INPUT -m strict -j ACCEPT


---
 net/ipv4/devinet.c              |    1 
 net/ipv4/netfilter/Kconfig      |   12 ++++++++
 net/ipv4/netfilter/Makefile     |    1 
 net/ipv4/netfilter/ipt_strict.c |   56 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 70 insertions(+)

--- a/net/ipv4/netfilter/Kconfig	2009-02-26 17:47:03.000000000 -0800
+++ b/net/ipv4/netfilter/Kconfig	2009-02-26 17:47:08.000000000 -0800
@@ -92,6 +92,18 @@ config IP_NF_MATCH_ECN
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP_NF_MATCH_STRICT
+       tristate '"strict end system" match support'
+	depends on NETFILTER_ADVANCED
+	help
+	  This option adds a 'strict' match, which allows you to
+	  match only packets that arrive with the destinaton address matching
+	  an IP address on the incoming interface. This can be used to implement
+	  Strong End System model as defined in Internet Host Requirements
+	  (RFC1122).
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config IP_NF_MATCH_TTL
 	tristate '"ttl" match support'
 	depends on NETFILTER_ADVANCED
--- a/net/ipv4/netfilter/Makefile	2009-02-26 17:46:37.000000000 -0800
+++ b/net/ipv4/netfilter/Makefile	2009-02-26 17:47:08.000000000 -0800
@@ -51,6 +51,7 @@ obj-$(CONFIG_IP_NF_SECURITY) += iptable_
 obj-$(CONFIG_IP_NF_MATCH_ADDRTYPE) += ipt_addrtype.o
 obj-$(CONFIG_IP_NF_MATCH_AH) += ipt_ah.o
 obj-$(CONFIG_IP_NF_MATCH_ECN) += ipt_ecn.o
+obj-$(CONFIG_IP_NF_MATCH_STRICT) += ipt_strict.o
 
 # targets
 obj-$(CONFIG_IP_NF_TARGET_CLUSTERIP) += ipt_CLUSTERIP.o
--- a/net/ipv4/devinet.c	2009-02-26 17:46:37.000000000 -0800
+++ b/net/ipv4/devinet.c	2009-02-26 17:47:08.000000000 -0800
@@ -230,6 +230,7 @@ int inet_addr_onlink(struct in_device *i
 	rcu_read_unlock();
 	return 0;
 }
+EXPORT_SYMBOL_GPL(inet_addr_onlink);
 
 static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 			 int destroy, struct nlmsghdr *nlh, u32 pid)
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/net/ipv4/netfilter/ipt_strict.c	2009-02-26 17:52:19.000000000 -0800
@@ -0,0 +1,56 @@
+/* IP tables module for matching packets not routed to incoming interface
+ *
+ * (C) 2009 by Stephen Hemminger <shemminger@vyatta.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/if.h>
+#include <linux/inetdevice.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+
+MODULE_AUTHOR("Stephen Hemminger <shemminger@vyatta.com>");
+MODULE_DESCRIPTION("Xtables: Strict End System match");
+MODULE_LICENSE("GPL");
+
+static bool strict_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+{
+	struct in_device *in_dev;
+	bool ret;
+
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(skb->dev);
+	ret = (in_dev && inet_addr_onlink(in_dev, ip_hdr(skb)->daddr, 0));
+	rcu_read_unlock();
+
+	return ret;
+}
+
+static struct xt_match strict_mt_reg __read_mostly = {
+	.name		= "strict",
+	.family		= NFPROTO_IPV4,
+	.match		= strict_mt,
+	.matchsize	= 0,
+	.me		= THIS_MODULE,
+};
+
+static int __init strict_mt_init(void)
+{
+	return xt_register_match(&strict_mt_reg);
+}
+
+static void __exit strict_mt_exit(void)
+{
+	xt_unregister_match(&strict_mt_reg);
+}
+
+module_init(strict_mt_init);
+module_exit(strict_mt_exit);
