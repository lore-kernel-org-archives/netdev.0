From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 4/9] bpf: virtio_net: Report bpf_prog ID during XDP_QUERY_PROG
Date: Thu, 15 Jun 2017 17:29:12 -0700
Message-ID: <20170616002917.2976329-5-kafai@fb.com>
References: <20170616002917.2976329-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Jason Wang <jasowang@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:52086 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751955AbdFPA3W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 20:29:22 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5G0NVJF012868
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:21 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b3xk714ae-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:21 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 d5d80208522a11e7b41d0002c95209d8-a6f408f0 for <netdev@vger.kernel.org>;        Thu,
 15 Jun 2017 17:29:18 -0700
In-Reply-To: <20170616002917.2976329-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to virtio_net to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jason Wang <jasowang@redhat.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/virtio_net.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 1f8c15cb63b0..4f49c3dab124 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1955,16 +1955,18 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog,
 	return err;
 }
 
-static bool virtnet_xdp_query(struct net_device *dev)
+static u32 virtnet_xdp_query(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	const struct bpf_prog *xdp_prog;
 	int i;
 
 	for (i = 0; i < vi->max_queue_pairs; i++) {
-		if (vi->rq[i].xdp_prog)
-			return true;
+		xdp_prog = rtnl_dereference(vi->rq[i].xdp_prog);
+		if (xdp_prog)
+			return xdp_prog->aux->id;
 	}
-	return false;
+	return 0;
 }
 
 static int virtnet_xdp(struct net_device *dev, struct netdev_xdp *xdp)
@@ -1973,7 +1975,8 @@ static int virtnet_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	case XDP_SETUP_PROG:
 		return virtnet_xdp_set(dev, xdp->prog, xdp->extack);
 	case XDP_QUERY_PROG:
-		xdp->prog_attached = virtnet_xdp_query(dev);
+		xdp->prog_id = virtnet_xdp_query(dev);
+		xdp->prog_attached = !!xdp->prog_id;
 		return 0;
 	default:
 		return -EINVAL;
-- 
2.9.3
