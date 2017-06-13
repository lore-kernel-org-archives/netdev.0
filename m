From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 09/10] bpf: qede: Report bpf_prog ID during XDP_QUERY_PROG
Date: Mon, 12 Jun 2017 18:00:24 -0700
Message-ID: <20170613010025.2983342-10-kafai@fb.com>
References: <20170613010025.2983342-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        <Mintz@devbig738.prn1.facebook.com>, Yuval <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36524 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753122AbdFMBAa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 21:00:30 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5D0vTr3032218
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:30 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2b21528tsp-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:30 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 b0e916344fd311e7bc860002c95209d8-773368f0 for <netdev@vger.kernel.org>;        Mon,
 12 Jun 2017 18:00:28 -0700
In-Reply-To: <20170613010025.2983342-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to qede to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Mintz, Yuval <Yuval.Mintz@cavium.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/qlogic/qede/qede_filter.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index 13955a3bd3b3..26b652ae5ec1 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -1035,9 +1035,16 @@ int qede_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
 		return qede_xdp_set(edev, xdp->prog);
-	case XDP_QUERY_PROG:
-		xdp->prog_attached = !!edev->xdp_prog;
+	case XDP_QUERY_PROG: {
+		const struct bpf_prog *xdp_prog;
+
+		xdp_prog = READ_ONCE(edev->xdp_prog);
+		if (xdp_prog)
+			xdp->prog_id = xdp_prog->aux->id;
+		else
+			xdp->prog_id = 0;
 		return 0;
+	}
 	default:
 		return -EINVAL;
 	}
-- 
2.9.3
