From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] ipv4: register igmp_notifier even when !CONFIG_PROC_FS
Date: Fri, 10 Jan 2014 16:09:45 -0800
Message-ID: <1389398985-16198-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:52696 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaAKAJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 19:09:49 -0500
Received: by mail-pd0-f180.google.com with SMTP id q10so5227616pdj.11
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 16:09:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We still need this notifier even when we don't config
PROC_FS.

It should be rare to have a kernel without PROC_FS,
so just for completeness.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/include/net/ip.h b/include/net/ip.h
index 5356644..4fcc6dc 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -90,7 +90,7 @@ struct packet_type;
 struct rtable;
 struct sockaddr;
 
-int igmp_mc_proc_init(void);
+int igmp_mc_init(void);
 
 /*
  *	Functions provided by ip.c
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 84c4329..bcbf33e 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2762,6 +2762,7 @@ static struct pernet_operations igmp_net_ops = {
 	.init = igmp_net_init,
 	.exit = igmp_net_exit,
 };
+#endif
 
 static int igmp_netdev_event(struct notifier_block *this,
 			     unsigned long event, void *ptr)
@@ -2785,8 +2786,9 @@ static struct notifier_block igmp_notifier = {
 	.notifier_call = igmp_netdev_event,
 };
 
-int __init igmp_mc_proc_init(void)
+int __init igmp_mc_init(void)
 {
+#if defined(CONFIG_PROC_FS)
 	int err;
 
 	err = register_pernet_subsys(&igmp_net_ops);
@@ -2800,5 +2802,7 @@ int __init igmp_mc_proc_init(void)
 reg_notif_fail:
 	unregister_pernet_subsys(&igmp_net_ops);
 	return err;
-}
+#else
+	return register_netdevice_notifier(&igmp_notifier);
 #endif
+}
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index df18461..535a515 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1551,7 +1551,7 @@ void __init ip_init(void)
 	ip_rt_init();
 	inet_initpeers();
 
-#if defined(CONFIG_IP_MULTICAST) && defined(CONFIG_PROC_FS)
-	igmp_mc_proc_init();
+#if defined(CONFIG_IP_MULTICAST)
+	igmp_mc_init();
 #endif
 }
