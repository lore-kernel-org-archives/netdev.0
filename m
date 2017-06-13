From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 04/10] bpf: virtio_net: Report bpf_prog ID during XDP_QUERY_PROG
Date: Mon, 12 Jun 2017 18:00:19 -0700
Message-ID: <20170613010025.2983342-5-kafai@fb.com>
References: <20170613010025.2983342-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Jason Wang <jasowang@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51628 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753100AbdFMBA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 21:00:29 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5D10ICq012027
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b21t10v49-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:28 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 affcbf284fd311e793c30002c991e86a-7ef358f0 for <netdev@vger.kernel.org>;        Mon,
 12 Jun 2017 18:00:26 -0700
In-Reply-To: <20170613010025.2983342-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to virtio_net to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jason Wang <jasowang@redhat.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/virtio_net.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 1f8c15cb63b0..8e2d9e32dcda 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1955,16 +1955,18 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog,
 	return err;
 }
 
-static bool virtnet_xdp_query(struct net_device *dev)
+static u32 virtnet_xdp_query(struct net_device *dev)
 {
+	const struct bpf_prog *xdp_prog;
 	struct virtnet_info *vi = netdev_priv(dev);
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
@@ -1973,7 +1975,7 @@ static int virtnet_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	case XDP_SETUP_PROG:
 		return virtnet_xdp_set(dev, xdp->prog, xdp->extack);
 	case XDP_QUERY_PROG:
-		xdp->prog_attached = virtnet_xdp_query(dev);
+		xdp->prog_id = virtnet_xdp_query(dev);
 		return 0;
 	default:
 		return -EINVAL;
-- 
2.9.3
