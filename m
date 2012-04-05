From: Li Yu <raise.sail@gmail.com>
Subject: [PATCH net-next] rps: introduce a new sysctl switch rps_workaround_buggy_driver
Date: Thu, 05 Apr 2012 18:31:00 +0800
Message-ID: <4F7D7464.7040503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:34317 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753874Ab2DEKbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 06:31:10 -0400
Received: by yhmm54 with SMTP id m54so598714yhm.19
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 03:31:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We encountered a buggy NIC driver or hardware/firmware, it keeps
non-zero constant skb->rxhash for long time, so if we enabled RPS,
the targeted CPU keeps same for long time too.

This patch introduces a sysctl switch to workaround for such problem,
if the switch was on, RPS core discards the skb->rxhash that is
computed by NIC hardware.

Hope this patch also can help others, thanks.

Signed-off-by Li Yu <bingtian.ly@taobao.com>

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 192250b..4c28ce0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -628,9 +628,13 @@ extern unsigned int   skb_find_text(struct sk_buff
*skb, unsigned int from,
 				    unsigned int to, struct ts_config *config,
 				    struct ts_state *state);

+extern int rps_workaround_buggy_driver;
 extern void __skb_get_rxhash(struct sk_buff *skb);
 static inline __u32 skb_get_rxhash(struct sk_buff *skb)
 {
+	if (unlikely(rps_workaround_buggy_driver))
+		skb->rxhash = 0;
+
 	if (!skb->rxhash)
 		__skb_get_rxhash(skb);

diff --git a/net/core/dev.c b/net/core/dev.c
index 723a406..9d1e728 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -176,6 +176,8 @@
 #define PTYPE_HASH_SIZE	(16)
 #define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)

+int rps_workaround_buggy_driver = 0;
+
 static DEFINE_SPINLOCK(ptype_lock);
 static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
 static struct list_head ptype_all __read_mostly;	/* Taps */
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 0c28508..065ea7c 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -172,6 +172,13 @@ static struct ctl_table net_core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= rps_sock_flow_sysctl
 	},
+	{
+		.procname	= "rps_workaround_buggy_driver",
+		.data		= &rps_workaround_buggy_driver,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 #endif
 #endif /* CONFIG_NET */
 	{
