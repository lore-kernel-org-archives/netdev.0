From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: set congestion default through Kconfig
Date: Mon, 18 Sep 2006 21:41:04 -0700
Message-ID: <20060918214104.3824a2e2@localhost.localdomain>
References: <20060918095936.GA6161@outpost.ds9a.nl>
	<20060918.070600.107685035.davem@davemloft.net>
	<20060918154048.GA18240@outpost.ds9a.nl>
	<20060918.115309.88343320.davem@davemloft.net>
	<20060918195224.GA26585@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53933 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964928AbWISElR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 00:41:17 -0400
To: bert hubert <bert.hubert@netherlabs.nl>
In-Reply-To: <20060918195224.GA26585@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bert's attempt was noble
It showed your desire for the truth
A simple path exists

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/ipv4/Kconfig           |   39 +++++++++++++++++++++++++++++++++++++--
 net/ipv4/sysctl_net_ipv4.c |    7 +++++++
 net/ipv4/tcp_cong.c        |    2 +-
 3 files changed, 45 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 90f9136..e922c3a 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -573,12 +573,47 @@ config TCP_CONG_VENO
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
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 19b2071..52b6481 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -129,6 +129,13 @@ static int sysctl_tcp_congestion_control
 	return ret;
 }
 
+static __init void tcp_congestion_default(void)
+{
+	tcp_set_default_congestion_control(CONFIG_DEFAULT_TCP_CONG)
+}
+
+late_initcall(tcp_congestion_default);
+
 
 ctl_table ipv4_table[] = {
         {
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 7ff2e42..af0aca1 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -48,7 +48,7 @@ int tcp_register_congestion_control(stru
 		printk(KERN_NOTICE "TCP %s already registered\n", ca->name);
 		ret = -EEXIST;
 	} else {
-		list_add_rcu(&ca->list, &tcp_cong_list);
+		list_add_tail_rcu(&ca->list, &tcp_cong_list);
 		printk(KERN_INFO "TCP %s registered\n", ca->name);
 	}
 	spin_unlock(&tcp_cong_list_lock);
-- 
1.4.1

