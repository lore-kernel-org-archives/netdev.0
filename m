From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: x25: fix one potential use-after-free issue
Date: Mon, 15 May 2017 14:47:01 -0400 (EDT)
Message-ID: <20170515.144701.1280299270304471194.davem@davemloft.net>
References: <1494821569-18572-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.hendry@gmail.com, nhorman@tuxdriver.com,
        linux-x25@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: xiaolou4617@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494821569-18572-1-git-send-email-xiaolou4617@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: linzhang <xiaolou4617@gmail.com>
Date: Mon, 15 May 2017 12:12:49 +0800

> The function x25_init is not properly unregister related resources
> on error handler.It is will result in kernel oops if x25_init init
> failed, so add right unregister call on error handler.
> 
> Signed-off-by: linzhang <xiaolou4617@gmail.com>

I think we need to go a bit further and make x25_register_sysctl()
properly check for and return failure.

Something like:

diff --git a/include/net/x25.h b/include/net/x25.h
index c383aa4..6d30a01 100644
--- a/include/net/x25.h
+++ b/include/net/x25.h
@@ -298,10 +298,10 @@ void x25_check_rbuf(struct sock *);
 
 /* sysctl_net_x25.c */
 #ifdef CONFIG_SYSCTL
-void x25_register_sysctl(void);
+int x25_register_sysctl(void);
 void x25_unregister_sysctl(void);
 #else
-static inline void x25_register_sysctl(void) {};
+static inline int x25_register_sysctl(void) { return 0; };
 static inline void x25_unregister_sysctl(void) {};
 #endif /* CONFIG_SYSCTL */
 
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 8b911c2..b7d6614 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1808,12 +1808,17 @@ static int __init x25_init(void)
 
 	pr_info("Linux Version 0.2\n");
 
-	x25_register_sysctl();
+	rc = x25_register_sysctl();
+	if (rc)
+		goto out_dev;
+
 	rc = x25_proc_init();
 	if (rc != 0)
-		goto out_dev;
+		goto out_sysctl;
 out:
 	return rc;
+out_sysctl:
+	x25_unregister_sysctl();
 out_dev:
 	unregister_netdevice_notifier(&x25_dev_notifier);
 out_sock:
diff --git a/net/x25/sysctl_net_x25.c b/net/x25/sysctl_net_x25.c
index a06dfe1..ba078c8 100644
--- a/net/x25/sysctl_net_x25.c
+++ b/net/x25/sysctl_net_x25.c
@@ -73,9 +73,12 @@ static struct ctl_table x25_table[] = {
 	{ },
 };
 
-void __init x25_register_sysctl(void)
+int __init x25_register_sysctl(void)
 {
 	x25_table_header = register_net_sysctl(&init_net, "net/x25", x25_table);
+	if (!x25_table_header)
+		return -ENOMEM;
+	return 0;
 }
 
 void x25_unregister_sysctl(void)
