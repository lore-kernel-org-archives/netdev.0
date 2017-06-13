From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 08/10] bpf: nfp: Report bpf_prog ID during XDP_QUERY_PROG
Date: Mon, 12 Jun 2017 18:00:23 -0700
Message-ID: <20170613010025.2983342-9-kafai@fb.com>
References: <20170613010025.2983342-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46871 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752927AbdFMBAa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 21:00:30 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5D0wZqG019368
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:30 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b22a1rr4x-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:30 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 b0bc71a64fd311e7bb7877a337fa907c-71b328f0 for <netdev@vger.kernel.org>;        Mon,
 12 Jun 2017 18:00:28 -0700
In-Reply-To: <20170613010025.2983342-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to nfp to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 49d1756d6a8e..e4d175853dc7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3254,9 +3254,16 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
 		return nfp_net_xdp_setup(nn, xdp);
-	case XDP_QUERY_PROG:
-		xdp->prog_attached = !!nn->dp.xdp_prog;
+	case XDP_QUERY_PROG: {
+		const struct bpf_prog *xdp_prog;
+
+		xdp_prog = READ_ONCE(nn->dp.xdp_prog);
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
