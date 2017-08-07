From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 11/16] nfp: change flows in apps that offload ndo_setup_tc
Date: Mon,  7 Aug 2017 10:15:27 +0200
Message-ID: <20170807081532.32760-12-jiri@resnulli.us>
References: <20170807081532.32760-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33361 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752419AbdHGIPw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:15:52 -0400
Received: by mail-wm0-f66.google.com with SMTP id q189so152543wmd.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 01:15:52 -0700 (PDT)
In-Reply-To: <20170807081532.32760-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Change the flows a bit in preparation of follow-up changes in
ndo_setup_tc args. Also, change the error code to align with the rest of
the drivers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/main.c       | 16 ++++++----------
 drivers/net/ethernet/netronome/nfp/flower/offload.c | 10 +++-------
 2 files changed, 9 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index 7888808..d7975dc 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -126,19 +126,15 @@ static int nfp_bpf_setup_tc(struct nfp_app *app, struct net_device *netdev,
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
-	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
-		return -EOPNOTSUPP;
-	if (proto != htons(ETH_P_ALL))
+	if (type != TC_SETUP_CLSBPF || !nfp_net_ebpf_capable(nn) ||
+	    TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	    proto != htons(ETH_P_ALL))
 		return -EOPNOTSUPP;
 
-	if (type == TC_SETUP_CLSBPF && nfp_net_ebpf_capable(nn)) {
-		if (!nn->dp.bpf_offload_xdp)
-			return nfp_net_bpf_offload(nn, tc->cls_bpf);
-		else
-			return -EBUSY;
-	}
+	if (nn->dp.bpf_offload_xdp)
+		return -EBUSY;
 
-	return -EINVAL;
+	return nfp_net_bpf_offload(nn, tc->cls_bpf);
 }
 
 static bool nfp_bpf_tc_busy(struct nfp_app *app, struct nfp_net *nn)
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index d045cf8..58af438 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -388,14 +388,10 @@ int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
 			enum tc_setup_type type, u32 handle, __be16 proto,
 			struct tc_to_netdev *tc)
 {
-	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
+	if (type != TC_SETUP_CLSFLOWER ||
+	    TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	    !eth_proto_is_802_3(proto))
 		return -EOPNOTSUPP;
 
-	if (!eth_proto_is_802_3(proto))
-		return -EOPNOTSUPP;
-
-	if (type != TC_SETUP_CLSFLOWER)
-		return -EINVAL;
-
 	return nfp_flower_repr_offload(app, netdev, tc->cls_flower);
 }
-- 
2.9.3
