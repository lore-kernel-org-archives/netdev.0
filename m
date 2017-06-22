From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/8] xdp: pass XDP flags into install handlers
Date: Wed, 21 Jun 2017 18:25:03 -0700
Message-ID: <20170622012510.5286-2-jakub.kicinski@netronome.com>
References: <20170622012510.5286-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kafai@fb.com, daniel@iogearbox.net,
        davem@davemloft.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33310 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752017AbdFVBZ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 21:25:57 -0400
Received: by mail-pg0-f42.google.com with SMTP id f127so1225955pgc.0
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 18:25:57 -0700 (PDT)
In-Reply-To: <20170622012510.5286-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass XDP flags to the xdp ndo.  This will allow drivers to look
at the mode flags and make decisions about offload.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/netdevice.h | 1 +
 net/core/dev.c            | 5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7c7118b3bd69..b194817631de 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -820,6 +820,7 @@ struct netdev_xdp {
 	union {
 		/* XDP_SETUP_PROG */
 		struct {
+			u32 flags;
 			struct bpf_prog *prog;
 			struct netlink_ext_ack *extack;
 		};
diff --git a/net/core/dev.c b/net/core/dev.c
index df7637733e3c..09f9e99f4a3e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6951,7 +6951,7 @@ bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op,
 }
 
 static int dev_xdp_install(struct net_device *dev, xdp_op_t xdp_op,
-			   struct netlink_ext_ack *extack,
+			   struct netlink_ext_ack *extack, u32 flags,
 			   struct bpf_prog *prog)
 {
 	struct netdev_xdp xdp;
@@ -6959,6 +6959,7 @@ static int dev_xdp_install(struct net_device *dev, xdp_op_t xdp_op,
 	memset(&xdp, 0, sizeof(xdp));
 	xdp.command = XDP_SETUP_PROG;
 	xdp.extack = extack;
+	xdp.flags = flags;
 	xdp.prog = prog;
 
 	return xdp_op(dev, &xdp);
@@ -7003,7 +7004,7 @@ int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 			return PTR_ERR(prog);
 	}
 
-	err = dev_xdp_install(dev, xdp_op, extack, prog);
+	err = dev_xdp_install(dev, xdp_op, extack, flags, prog);
 	if (err < 0 && prog)
 		bpf_prog_put(prog);
 
-- 
2.11.0
