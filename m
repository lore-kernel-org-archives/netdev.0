From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: set congestion default through Kconfig (v2)
Date: Tue, 19 Sep 2006 13:41:32 -0700
Message-ID: <20060919134132.44d4da5d@localhost.localdomain>
References: <20060918.115309.88343320.davem@davemloft.net>
	<20060918195224.GA26585@outpost.ds9a.nl>
	<20060918214104.3824a2e2@localhost.localdomain>
	<20060919.123352.124082859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bert.hubert@netherlabs.nl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14746 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752066AbWISUlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 16:41:44 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060919.123352.124082859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bert's attempt was noble
It showed your desire for the truth
A simple path existed

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/ipv4/Kconfig           |   39 +++++++++++++++++++++++++++++++++++++--
 net/ipv4/sysctl_net_ipv4.c |    6 ++++++
 net/ipv4/tcp_cong.c        |    2 +-
 3 files changed, 44 insertions(+), 3 deletions(-)

--- net-2.6.19.orig/net/ipv4/Kconfig	2006-09-19 13:11:09.000000000 -0700
+++ net-2.6.19/net/ipv4/Kconfig	2006-09-19 13:20:45.000000000 -0700
@@ -573,12 +573,47 @@
 	loss packets.
 	See http://www.ntu.edu.sg/home5/ZHOU0022/papers/CPFu03a.pdf
 
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
 endmenu
 
-config TCP_CONG_BIC
-	tristate
+config DEFAULT_BIC
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
+
 source "net/ipv4/ipvs/Kconfig"
 
--- net-2.6.19.orig/net/ipv4/sysctl_net_ipv4.c	2006-09-19 13:11:09.000000000 -0700
+++ net-2.6.19/net/ipv4/sysctl_net_ipv4.c	2006-09-19 13:37:04.000000000 -0700
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
--- net-2.6.19.orig/net/ipv4/tcp_cong.c	2006-09-19 13:11:09.000000000 -0700
+++ net-2.6.19/net/ipv4/tcp_cong.c	2006-09-19 13:20:45.000000000 -0700
@@ -48,7 +48,7 @@
 		printk(KERN_NOTICE "TCP %s already registered\n", ca->name);
 		ret = -EEXIST;
 	} else {
-		list_add_rcu(&ca->list, &tcp_cong_list);
+		list_add_tail_rcu(&ca->list, &tcp_cong_list);
 		printk(KERN_INFO "TCP %s registered\n", ca->name);
 	}
 	spin_unlock(&tcp_cong_list_lock);
