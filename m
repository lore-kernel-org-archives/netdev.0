From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next] libcxgbi/cxgb4i : Fix ipv6 build failure caught with randconfig
Date: Tue, 12 Aug 2014 14:54:41 -0700
Message-ID: <1407880481-22352-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hch@infradead.org, kxie@chelsio.com,
	manojmalviya@chelsio.com, jim.epost@gmail.com,
	sfr@canb.auug.org.au, Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:45467
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752782AbaHLVzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 17:55:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previous guard of IS_ENABLED(CONFIG_IPV6) is not sufficient when cxgbi drivers
are built into kernel but ipv6 is not. Change guard to only enable when either
ipv6 is built-in or both are modules.

Fixes: e81fbf6cd652 ("libcxgbi:cxgb4i Guard ipv6 code with a config check")
Fixes: fc8d0590d914 ("libcxgbi: Add ipv6 api to driver")
Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 13 +++++++------
 drivers/scsi/cxgbi/libcxgbi.c      |  9 ++++++---
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 79788a12712d..b5eb7c5f4529 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1289,7 +1289,7 @@ static int init_act_open(struct cxgbi_sock *csk)
 
 	if (csk->csk_family == AF_INET)
 		daddr = &csk->daddr.sin_addr.s_addr;
-#if IS_ENABLED(CONFIG_IPV6)
+#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
 	else if (csk->csk_family == AF_INET6)
 		daddr = &csk->daddr6.sin6_addr;
 #endif
@@ -1635,7 +1635,7 @@ static int cxgb4i_ddp_init(struct cxgbi_device *cdev)
 	return 0;
 }
 
-#if IS_ENABLED(CONFIG_IPV6)
+#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
 static int cxgbi_inet6addr_handler(struct notifier_block *this,
 				   unsigned long event, void *data)
 {
@@ -1756,7 +1756,8 @@ static void cxgbi_update_clip(struct cxgbi_device *cdev)
 	}
 	rcu_read_unlock();
 }
-#endif /* IS_ENABLED(CONFIG_IPV6) */
+#endif /* defined(CONFIG_IPV6) ||
+ (defined(CONFIG_IPV6_MODULE) && defined(MODULE)) */
 
 static void *t4_uld_add(const struct cxgb4_lld_info *lldi)
 {
@@ -1876,7 +1877,7 @@ static int t4_uld_state_change(void *handle, enum cxgb4_state state)
 	switch (state) {
 	case CXGB4_STATE_UP:
 		pr_info("cdev 0x%p, UP.\n", cdev);
-#if IS_ENABLED(CONFIG_IPV6)
+#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
 		cxgbi_update_clip(cdev);
 #endif
 		/* re-initialize */
@@ -1910,7 +1911,7 @@ static int __init cxgb4i_init_module(void)
 		return rc;
 	cxgb4_register_uld(CXGB4_ULD_ISCSI, &cxgb4i_uld_info);
 
-#if IS_ENABLED(CONFIG_IPV6)
+#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
 	register_inet6addr_notifier(&cxgbi_inet6addr_notifier);
 #endif
 	return 0;
@@ -1918,7 +1919,7 @@ static int __init cxgb4i_init_module(void)
 
 static void __exit cxgb4i_exit_module(void)
 {
-#if IS_ENABLED(CONFIG_IPV6)
+#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
 	unregister_inet6addr_notifier(&cxgbi_inet6addr_notifier);
 #endif
 	cxgb4_unregister_uld(CXGB4_ULD_ISCSI);
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index d65df6dc106f..6e56c40040c2 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -560,6 +560,8 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 	}
 
 	cdev = cxgbi_device_find_by_netdev(ndev, &port);
+	if (!cdev)
+		cdev = cxgbi_device_find_by_mac(ndev, &port);
 	if (!cdev) {
 		pr_info("dst %pI4, %s, NOT cxgbi device.\n",
 			&daddr->sin_addr.s_addr, ndev->name);
@@ -602,7 +604,7 @@ err_out:
 	return ERR_PTR(err);
 }
 
-#if IS_ENABLED(CONFIG_IPV6)
+#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
 static struct rt6_info *find_route_ipv6(const struct in6_addr *saddr,
 					const struct in6_addr *daddr)
 {
@@ -717,7 +719,8 @@ rel_rt:
 err_out:
 	return ERR_PTR(err);
 }
-#endif /* IS_ENABLED(CONFIG_IPV6) */
+#endif /* defined(CONFIG_IPV6) ||
+ (defined(CONFIG_IPV6_MODULE) && defined(MODULE)) */
 
 void cxgbi_sock_established(struct cxgbi_sock *csk, unsigned int snd_isn,
 			unsigned int opt)
@@ -2640,7 +2643,7 @@ struct iscsi_endpoint *cxgbi_ep_connect(struct Scsi_Host *shost,
 
 	if (dst_addr->sa_family == AF_INET) {
 		csk = cxgbi_check_route(dst_addr);
-#if IS_ENABLED(CONFIG_IPV6)
+#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
 	} else if (dst_addr->sa_family == AF_INET6) {
 		csk = cxgbi_check_route6(dst_addr);
 #endif
-- 
2.0.4
