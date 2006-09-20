From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: default congestion control menu
Date: Wed, 20 Sep 2006 13:28:06 -0700
Message-ID: <20060920132806.34eadc9e@localhost.localdomain>
References: <20060919214304.GB13543@outpost.ds9a.nl>
	<20060919.154435.102044066.davem@davemloft.net>
	<20060919160202.23390471@localhost.localdomain>
	<20060919.160441.66322371.davem@davemloft.net>
	<20060919162355.3a22fec1@localhost.localdomain>
	<20060920081704.GA1812@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30676 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750821AbWITU2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 16:28:35 -0400
To: bert hubert <bert.hubert@netherlabs.nl>,
	David Miller <davem@davemloft.net>
In-Reply-To: <20060920081704.GA1812@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change how default TCP congestion control is chosen. Don't just use
last installed module, instead allow selection during configuration,
and make sure and use the default regardless of load order.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/ipv4/Kconfig           |   45 ++++++++++++++++++++++++++++++++++++++++-----
 net/ipv4/sysctl_net_ipv4.c |    6 ++++++
 net/ipv4/tcp_cong.c        |    2 +-
 3 files changed, 47 insertions(+), 6 deletions(-)

--- net-2.6.19.orig/net/ipv4/Kconfig	2006-09-19 16:13:02.000000000 -0700
+++ net-2.6.19/net/ipv4/Kconfig	2006-09-20 11:17:45.000000000 -0700
@@ -447,7 +447,7 @@
 	depends on INET_DIAG
 	def_tristate INET_DIAG
 
-config TCP_CONG_ADVANCED
+menuconfig TCP_CONG_ADVANCED
 	bool "TCP: advanced congestion control"
 	---help---
 	  Support for selection of various TCP congestion control
@@ -458,9 +458,7 @@
 
 	  If unsure, say N.
 
-# TCP Reno is builtin (required as fallback)
-menu "TCP congestion control"
-	depends on TCP_CONG_ADVANCED
+if TCP_CONG_ADVANCED
 
 config TCP_CONG_BIC
 	tristate "Binary Increase Congestion (BIC) control"
@@ -573,12 +571,49 @@
 	loss packets.
 	See http://www.ntu.edu.sg/home5/ZHOU0022/papers/CPFu03a.pdf
 
-endmenu
+choice
+	prompt "Default TCP congestion control"
+	default DEFAULT_BIC
+	help
+	  Select the TCP congestion control that will be used by default
+	  for all connections.
+
+	config DEFAULT_BIC
+		bool "Bic" if TCP_CONG_BIC=y
+
+	config DEFAULT_CUBIC
+		bool "Cubic" if TCP_CONG_CUBIC=y
+
+	config DEFAULT_HTCP
+		bool "Htcp" if TCP_CONG_HTCP=y
+
+	config DEFAULT_VEGAS
+		bool "Vegas" if TCP_CONG_VEGAS=y
+
+	config DEFAULT_WESTWOOD
+		bool "Westwood" if TCP_CONG_WESTWOOD=y
+
+	config DEFAULT_RENO
+		bool "Reno"
+
+endchoice
+
+endif
 
 config TCP_CONG_BIC
 	tristate
 	depends on !TCP_CONG_ADVANCED
 	default y
 
+config DEFAULT_TCP_CONG
+	string
+	default "bic" if DEFAULT_BIC
+	default "cubic" if DEFAULT_CUBIC
+	default "htcp" if DEFAULT_HTCP
+	default "vegas" if DEFAULT_VEGAS
+	default "westwood" if DEFAULT_WESTWOOD
+	default "reno" if DEFAULT_RENO
+	default "bic"
+
 source "net/ipv4/ipvs/Kconfig"
 
--- net-2.6.19.orig/net/ipv4/sysctl_net_ipv4.c	2006-09-19 16:13:02.000000000 -0700
+++ net-2.6.19/net/ipv4/sysctl_net_ipv4.c	2006-09-19 16:13:05.000000000 -0700
@@ -129,6 +129,12 @@
 	return ret;
 }
 
+static int __init tcp_congestion_default(void)
+{
+	return tcp_set_default_congestion_control(CONFIG_DEFAULT_TCP_CONG);
+}
+
+late_initcall(tcp_congestion_default);
 
 ctl_table ipv4_table[] = {
         {
--- net-2.6.19.orig/net/ipv4/tcp_cong.c	2006-09-19 16:13:02.000000000 -0700
+++ net-2.6.19/net/ipv4/tcp_cong.c	2006-09-19 16:13:05.000000000 -0700
@@ -48,7 +48,7 @@
 		printk(KERN_NOTICE "TCP %s already registered\n", ca->name);
 		ret = -EEXIST;
 	} else {
-		list_add_rcu(&ca->list, &tcp_cong_list);
+		list_add_tail_rcu(&ca->list, &tcp_cong_list);
 		printk(KERN_INFO "TCP %s registered\n", ca->name);
 	}
 	spin_unlock(&tcp_cong_list_lock);
