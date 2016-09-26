From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 2/6] fib: introduce FIB info offload flag helpers
Date: Mon, 26 Sep 2016 12:52:30 +0200
Message-ID: <1474887154-6286-3-git-send-email-jiri@resnulli.us>
References: <1474887154-6286-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com, kaber@trash.net, john@phrozen.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35646 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966086AbcIZKwk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 06:52:40 -0400
Received: by mail-wm0-f68.google.com with SMTP id 133so13480182wmq.2
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 03:52:39 -0700 (PDT)
In-Reply-To: <1474887154-6286-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

These helpers are to be used in case someone offloads the FIB entry. The
result is that if the entry is offloaded to at least one device, the
offload flag is set.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 include/net/ip_fib.h      | 13 +++++++++++++
 net/switchdev/switchdev.c |  4 ++--
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 116a9c0..ffccf17 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -123,6 +123,7 @@ struct fib_info {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int			fib_weight;
 #endif
+	unsigned int		fib_offload_cnt;
 	struct rcu_head		rcu;
 	struct fib_nh		fib_nh[0];
 #define fib_dev		fib_nh[0].nh_dev
@@ -174,6 +175,18 @@ struct fib_result_nl {
 
 __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
 
+static inline void fib_info_offload_inc(struct fib_info *fi)
+{
+	fi->fib_offload_cnt++;
+	fi->fib_flags |= RTNH_F_OFFLOAD;
+}
+
+static inline void fib_info_offload_dec(struct fib_info *fi)
+{
+	if (--fi->fib_offload_cnt == 0)
+		fi->fib_flags &= ~RTNH_F_OFFLOAD;
+}
+
 #define FIB_RES_SADDR(net, res)				\
 	((FIB_RES_NH(res).nh_saddr_genid ==		\
 	  atomic_read(&(net)->ipv4.dev_addr_genid)) ?	\
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 10b8193..abd8d2a 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1216,7 +1216,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	ipv4_fib.obj.orig_dev = dev;
 	err = switchdev_port_obj_add(dev, &ipv4_fib.obj);
 	if (!err)
-		fi->fib_flags |= RTNH_F_OFFLOAD;
+		fib_info_offload_inc(fi);
 
 	return err == -EOPNOTSUPP ? 0 : err;
 }
@@ -1260,7 +1260,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	ipv4_fib.obj.orig_dev = dev;
 	err = switchdev_port_obj_del(dev, &ipv4_fib.obj);
 	if (!err)
-		fi->fib_flags &= ~RTNH_F_OFFLOAD;
+		fib_info_offload_dec(fi);
 
 	return err == -EOPNOTSUPP ? 0 : err;
 }
-- 
2.5.5
