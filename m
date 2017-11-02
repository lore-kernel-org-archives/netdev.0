From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 5/8] nfp: bpf: fall back to core NIC app if BPF not selected
Date: Thu,  2 Nov 2017 01:31:33 -0700
Message-ID: <20171102083136.2096-6-jakub.kicinski@netronome.com>
References: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:49054 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755437AbdKBIc0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:32:26 -0400
Received: by mail-pg0-f68.google.com with SMTP id v78so4438220pgb.5
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 01:32:26 -0700 (PDT)
In-Reply-To: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If kernel config does not include BPF just replace the BPF
app handler with the handler for basic NIC.  The BPF app
will now be built only if BPF infrastructure is selected
in kernel config.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile      | 4 ++--
 drivers/net/ethernet/netronome/nfp/bpf/offload.c | 3 ---
 drivers/net/ethernet/netronome/nfp/nfp_app.c     | 4 ++++
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index bd3b2bd408bc..9e8d30cb1517 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -27,8 +27,6 @@ nfp-objs := \
 	    nfp_net_sriov.o \
 	    nfp_netvf_main.o \
 	    nfp_port.o \
-	    bpf/main.o \
-	    bpf/offload.o \
 	    nic/main.o
 
 ifeq ($(CONFIG_NFP_APP_FLOWER),y)
@@ -44,6 +42,8 @@ endif
 
 ifeq ($(CONFIG_BPF_SYSCALL),y)
 nfp-objs += \
+	    bpf/main.o \
+	    bpf/offload.o \
 	    bpf/verifier.o \
 	    bpf/jit.o
 endif
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
index 63c8f7847054..6d576f631392 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
@@ -150,9 +150,6 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	unsigned int max_mtu;
 	int ret;
 
-	if (!IS_ENABLED(CONFIG_BPF_SYSCALL))
-		return -EOPNOTSUPP;
-
 	ret = nfp_net_bpf_get_act(nn, cls_bpf);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.c b/drivers/net/ethernet/netronome/nfp/nfp_app.c
index 085c5151c601..3644d74fe304 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.c
@@ -44,7 +44,11 @@
 
 static const struct nfp_app_type *apps[] = {
 	[NFP_APP_CORE_NIC]	= &app_nic,
+#ifdef CONFIG_BPF_SYSCALL
 	[NFP_APP_BPF_NIC]	= &app_bpf,
+#else
+	[NFP_APP_BPF_NIC]	= &app_nic,
+#endif
 #ifdef CONFIG_NFP_APP_FLOWER
 	[NFP_APP_FLOWER_NIC]	= &app_flower,
 #endif
-- 
2.14.1
