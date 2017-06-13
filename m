From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 05/10] bpf: bnxt: Report bpf_prog ID during XDP_QUERY_PROG
Date: Mon, 12 Jun 2017 18:00:20 -0700
Message-ID: <20170613010025.2983342-6-kafai@fb.com>
References: <20170613010025.2983342-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        Michael Chan <michael.chan@broadcom.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51629 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753136AbdFMBA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 21:00:29 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5D10OpU012035
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b21t10v4a-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:28 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 b077dfd24fd311e7bd720002c991e86a-81f3b8f0 for <netdev@vger.kernel.org>;        Mon,
 12 Jun 2017 18:00:27 -0700
In-Reply-To: <20170613010025.2983342-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to bnxt to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Michael Chan <michael.chan@broadcom.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
index 8ce793a0d030..5bf1c7ddb378 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -216,10 +216,17 @@ int bnxt_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	case XDP_SETUP_PROG:
 		rc = bnxt_xdp_set(bp, xdp->prog);
 		break;
-	case XDP_QUERY_PROG:
-		xdp->prog_attached = !!bp->xdp_prog;
+	case XDP_QUERY_PROG: {
+		const struct bpf_prog *xdp_prog;
+
+		xdp_prog = READ_ONCE(bp->xdp_prog);
+		if (xdp_prog)
+			xdp->prog_id = xdp_prog->aux->id;
+		else
+			xdp->prog_id = 0;
 		rc = 0;
 		break;
+	}
 	default:
 		rc = -EINVAL;
 		break;
-- 
2.9.3
