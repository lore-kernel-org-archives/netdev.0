From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 7/9] bpf: ixgbe: Report bpf_prog ID during XDP_QUERY_PROG
Date: Tue, 13 Jun 2017 14:08:39 -0700
Message-ID: <20170613210841.509578-8-kafai@fb.com>
References: <20170613210841.509578-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        John Fastabend <john.fastabend@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:49445 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752525AbdFMVIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:08:46 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5DKwbqJ013729
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 14:08:46 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b2nmdgdeg-6
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 14:08:46 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 7b9a14de507c11e7adc70002c9521c9e-587408f0 for <netdev@vger.kernel.org>;        Tue,
 13 Jun 2017 14:08:43 -0700
In-Reply-To: <20170613210841.509578-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to ixgbe to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: John Fastabend <john.fastabend@gmail.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 812319ab77db..37b0e5a741d8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9799,9 +9799,19 @@ static int ixgbe_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
 		return ixgbe_xdp_setup(dev, xdp->prog);
-	case XDP_QUERY_PROG:
-		xdp->prog_attached = !!(adapter->xdp_prog);
+	case XDP_QUERY_PROG: {
+		const struct bpf_prog *xdp_prog;
+
+		xdp_prog = adapter->xdp_prog;
+		if (xdp_prog) {
+			xdp->prog_id = xdp_prog->aux->id;
+			xdp->prog_attached = true;
+		} else {
+			xdp->prog_id = 0;
+			xdp->prog_attached = false;
+		}
 		return 0;
+	}
 	default:
 		return -EINVAL;
 	}
-- 
2.9.3
