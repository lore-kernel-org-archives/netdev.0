From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC net-next 1/8] xdp: pass XDP flags into install handlers
Date: Fri, 16 Jun 2017 16:57:39 -0700
Message-ID: <20170616235746.16337-2-jakub.kicinski@netronome.com>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, kafai@fb.com, daniel@iogearbox.net,
        netoptimizer@brouer.com, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34640 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751869AbdFPX6Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 19:58:25 -0400
Received: by mail-pf0-f174.google.com with SMTP id s66so28833338pfs.1
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 16:58:24 -0700 (PDT)
In-Reply-To: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass XDP flags to the xdp ndo.  This will allow drivers to look
at the mode flags and make decisions about offload.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
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
index b8d6dd9e8b5c..a04db264aa1c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6953,7 +6953,7 @@ bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op,
 }
 
 static int dev_xdp_install(struct net_device *dev, xdp_op_t xdp_op,
-			   struct netlink_ext_ack *extack,
+			   struct netlink_ext_ack *extack, u32 flags,
 			   struct bpf_prog *prog)
 {
 	struct netdev_xdp xdp;
@@ -6961,6 +6961,7 @@ static int dev_xdp_install(struct net_device *dev, xdp_op_t xdp_op,
 	memset(&xdp, 0, sizeof(xdp));
 	xdp.command = XDP_SETUP_PROG;
 	xdp.extack = extack;
+	xdp.flags = flags;
 	xdp.prog = prog;
 
 	return xdp_op(dev, &xdp);
@@ -7005,7 +7006,7 @@ int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 			return PTR_ERR(prog);
 	}
 
-	err = dev_xdp_install(dev, xdp_op, extack, prog);
+	err = dev_xdp_install(dev, xdp_op, extack, flags, prog);
 	if (err < 0 && prog)
 		bpf_prog_put(prog);
 
-- 
2.11.0
