From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 5/9] bpf: bnxt: Report bpf_prog ID during XDP_QUERY_PROG
Date: Tue, 13 Jun 2017 14:08:37 -0700
Message-ID: <20170613210841.509578-6-kafai@fb.com>
References: <20170613210841.509578-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        Michael Chan <michael.chan@broadcom.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58725 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754079AbdFMVIu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:08:50 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v5DL6vE7000724
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 14:08:44 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2b24py4ybx-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 14:08:44 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 7b26d26c507c11e7bf0275369c678944-ff93c8f0 for <netdev@vger.kernel.org>;        Tue,
 13 Jun 2017 14:08:43 -0700
In-Reply-To: <20170613210841.509578-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to bnxt to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Michael Chan <michael.chan@broadcom.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
index 8ce793a0d030..841bc9df65b1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -216,10 +216,20 @@ int bnxt_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	case XDP_SETUP_PROG:
 		rc = bnxt_xdp_set(bp, xdp->prog);
 		break;
-	case XDP_QUERY_PROG:
-		xdp->prog_attached = !!bp->xdp_prog;
+	case XDP_QUERY_PROG: {
+		const struct bpf_prog *xdp_prog;
+
+		xdp_prog = bp->xdp_prog;
+		if (xdp_prog) {
+			xdp->prog_id = xdp_prog->aux->id;
+			xdp->prog_attached = true;
+		} else {
+			xdp->prog_id = 0;
+			xdp->prog_attached = false;
+		}
 		rc = 0;
 		break;
+	}
 	default:
 		rc = -EINVAL;
 		break;
-- 
2.9.3
