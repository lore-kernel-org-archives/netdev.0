From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net-next] ipv6: add support for NETDEV_RESEND_IGMP event
Date: Tue, 28 Mar 2017 14:49:16 -0400
Message-ID: <1490726956-25965-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33766 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753130AbdC1St1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 14:49:27 -0400
Received: by mail-qk0-f195.google.com with SMTP id p22so13661714qka.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 11:49:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for NETDEV_RESEND_IGMP event similar
to how it works for IPv4.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/net/ndisc.h |  2 ++
 net/ipv6/af_inet6.c |  8 +++++++-
 net/ipv6/mcast.c    | 50 +++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 58 insertions(+), 2 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 8a02146..1036c90 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -439,8 +439,10 @@ void ndisc_update(const struct net_device *dev, struct neighbour *neigh,
  *	IGMP
  */
 int igmp6_init(void);
+int igmp6_late_init(void);
 
 void igmp6_cleanup(void);
+void igmp6_late_cleanup(void);
 
 int igmp6_event_query(struct sk_buff *skb);
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index a9a9553..1635d21 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -1005,6 +1005,10 @@ static int __init inet6_init(void)
 	if (err)
 		goto seg6_fail;
 
+	err = igmp6_late_init();
+	if (err)
+		goto igmp6_late_err;
+
 #ifdef CONFIG_SYSCTL
 	err = ipv6_sysctl_register();
 	if (err)
@@ -1015,8 +1019,10 @@ static int __init inet6_init(void)
 
 #ifdef CONFIG_SYSCTL
 sysctl_fail:
-	seg6_exit();
+	igmp6_late_cleanup();
 #endif
+igmp6_late_err:
+	seg6_exit();
 seg6_fail:
 	calipso_exit();
 calipso_fail:
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 1bdc703..f8730a3 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2463,7 +2463,6 @@ static void mld_ifc_event(struct inet6_dev *idev)
 	mld_ifc_start_timer(idev, 1);
 }
 
-
 static void igmp6_timer_handler(unsigned long data)
 {
 	struct ifmcaddr6 *ma = (struct ifmcaddr6 *) data;
@@ -2599,6 +2598,44 @@ void ipv6_mc_destroy_dev(struct inet6_dev *idev)
 	write_unlock_bh(&idev->lock);
 }
 
+static void ipv6_mc_rejoin_groups(struct inet6_dev *idev)
+{
+	struct ifmcaddr6 *pmc;
+
+	ASSERT_RTNL();
+
+	if (mld_in_v1_mode(idev)) {
+		read_lock_bh(&idev->lock);
+		for (pmc = idev->mc_list; pmc; pmc = pmc->next)
+			igmp6_join_group(pmc);
+		read_unlock_bh(&idev->lock);
+	} else
+		mld_send_report(idev, NULL);
+}
+
+static int ipv6_mc_netdev_event(struct notifier_block *this,
+				unsigned long event,
+				void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct inet6_dev *idev = __in6_dev_get(dev);
+
+	switch (event) {
+	case NETDEV_RESEND_IGMP:
+		if (idev)
+			ipv6_mc_rejoin_groups(idev);
+		break;
+	default:
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block igmp6_netdev_notifier = {
+	.notifier_call = ipv6_mc_netdev_event,
+};
+
 #ifdef CONFIG_PROC_FS
 struct igmp6_mc_iter_state {
 	struct seq_net_private p;
@@ -2970,7 +3007,18 @@ int __init igmp6_init(void)
 	return register_pernet_subsys(&igmp6_net_ops);
 }
 
+int __init igmp6_late_init(void)
+{
+	return register_netdevice_notifier(&igmp6_netdev_notifier);
+}
+
 void igmp6_cleanup(void)
 {
 	unregister_pernet_subsys(&igmp6_net_ops);
 }
+
+void igmp6_late_cleanup(void)
+{
+	unregister_netdevice_notifier(&igmp6_netdev_notifier);
+}
+
-- 
2.7.4
