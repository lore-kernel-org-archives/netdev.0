From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/8] ipv4: Kill can_sleep arg to ip_route_output_flow()
Date: Tue, 01 Mar 2011 15:11:30 -0800 (PST)
Message-ID: <20110301.151130.70201816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48513
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757082Ab1CAXKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:10:53 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 4F70C24C087
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2011 15:11:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This boolean state is now available in the flow flags.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/hw/cxgb3/iwch_cm.c |    2 +-
 drivers/infiniband/hw/cxgb4/cm.c      |    2 +-
 drivers/scsi/cxgbi/libcxgbi.c         |    2 +-
 include/net/route.h                   |    6 +++---
 net/dccp/ipv4.c                       |    2 +-
 net/ipv4/af_inet.c                    |    2 +-
 net/ipv4/inet_connection_sock.c       |    2 +-
 net/ipv4/ip_output.c                  |    2 +-
 net/ipv4/raw.c                        |    2 +-
 net/ipv4/route.c                      |    7 ++++---
 net/ipv4/udp.c                        |    2 +-
 net/l2tp/l2tp_ip.c                    |    2 +-
 12 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index c7f776c..e654285 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -354,7 +354,7 @@ static struct rtable *find_route(struct t3cdev *dev, __be32 local_ip,
 			  }
 	};
 
-	if (ip_route_output_flow(&init_net, &rt, &fl, NULL, false))
+	if (ip_route_output_flow(&init_net, &rt, &fl, NULL))
 		return NULL;
 	return rt;
 }
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 5542c99..7e0484f 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -331,7 +331,7 @@ static struct rtable *find_route(struct c4iw_dev *dev, __be32 local_ip,
 			  }
 	};
 
-	if (ip_route_output_flow(&init_net, &rt, &fl, NULL, false))
+	if (ip_route_output_flow(&init_net, &rt, &fl, NULL))
 		return NULL;
 	return rt;
 }
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index fabca75..261aa81 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -470,7 +470,7 @@ static struct rtable *find_route_ipv4(__be32 saddr, __be32 daddr,
 			}
 	};
 
-	if (ip_route_output_flow(&init_net, &rt, &fl, NULL, false))
+	if (ip_route_output_flow(&init_net, &rt, &fl, NULL))
 		return NULL;
 
 	return rt;
diff --git a/include/net/route.h b/include/net/route.h
index 1be5c05..923e670 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -120,7 +120,7 @@ extern void		rt_cache_flush(struct net *net, int how);
 extern void		rt_cache_flush_batch(struct net *net);
 extern int		__ip_route_output_key(struct net *, struct rtable **, const struct flowi *flp);
 extern int		ip_route_output_key(struct net *, struct rtable **, struct flowi *flp);
-extern int		ip_route_output_flow(struct net *, struct rtable **rp, struct flowi *flp, struct sock *sk, bool can_sleep);
+extern int		ip_route_output_flow(struct net *, struct rtable **rp, struct flowi *flp, struct sock *sk);
 
 extern int ip_route_input_common(struct sk_buff *skb, __be32 dst, __be32 src,
 				 u8 tos, struct net_device *devin, bool noref);
@@ -198,7 +198,7 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 		*rp = NULL;
 	}
 	security_sk_classify_flow(sk, &fl);
-	return ip_route_output_flow(net, rp, &fl, sk, can_sleep);
+	return ip_route_output_flow(net, rp, &fl, sk);
 }
 
 static inline int ip_route_newports(struct rtable **rp, u8 protocol,
@@ -222,7 +222,7 @@ static inline int ip_route_newports(struct rtable **rp, u8 protocol,
 		ip_rt_put(*rp);
 		*rp = NULL;
 		security_sk_classify_flow(sk, &fl);
-		return ip_route_output_flow(sock_net(sk), rp, &fl, sk, false);
+		return ip_route_output_flow(sock_net(sk), rp, &fl, sk);
 	}
 	return 0;
 }
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 3d4b82f..a8ff955 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -475,7 +475,7 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 			  };
 
 	security_skb_classify_flow(skb, &fl);
-	if (ip_route_output_flow(net, &rt, &fl, sk, false)) {
+	if (ip_route_output_flow(net, &rt, &fl, sk)) {
 		IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
 	}
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7d90fe0..44513bb 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1174,7 +1174,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 	};
 
 	security_sk_classify_flow(sk, &fl);
-	err = ip_route_output_flow(sock_net(sk), &rt, &fl, sk, false);
+	err = ip_route_output_flow(sock_net(sk), &rt, &fl, sk);
 }
 	if (!err)
 		sk_setup_caps(sk, &rt->dst);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 0caeb69..7f85d4a 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -369,7 +369,7 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	struct net *net = sock_net(sk);
 
 	security_req_classify_flow(req, &fl);
-	if (ip_route_output_flow(net, &rt, &fl, sk, false))
+	if (ip_route_output_flow(net, &rt, &fl, sk))
 		goto no_route;
 	if (opt && opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
 		goto route_err;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e6905c5..68dbe2d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -355,7 +355,7 @@ int ip_queue_xmit(struct sk_buff *skb)
 			 * itself out.
 			 */
 			security_sk_classify_flow(sk, &fl);
-			if (ip_route_output_flow(sock_net(sk), &rt, &fl, sk, false))
+			if (ip_route_output_flow(sock_net(sk), &rt, &fl, sk))
 				goto no_route;
 		}
 		sk_setup_caps(sk, &rt->dst);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index e8e8613..d7a2d1e 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -564,7 +564,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		}
 
 		security_sk_classify_flow(sk, &fl);
-		err = ip_route_output_flow(sock_net(sk), &rt, &fl, sk, true);
+		err = ip_route_output_flow(sock_net(sk), &rt, &fl, sk);
 	}
 	if (err)
 		goto done;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1ac3eca..7846265 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2720,7 +2720,7 @@ static int ipv4_dst_blackhole(struct net *net, struct rtable **rp, struct flowi
 }
 
 int ip_route_output_flow(struct net *net, struct rtable **rp, struct flowi *flp,
-			 struct sock *sk, bool can_sleep)
+			 struct sock *sk)
 {
 	int err;
 
@@ -2733,7 +2733,8 @@ int ip_route_output_flow(struct net *net, struct rtable **rp, struct flowi *flp,
 		if (!flp->fl4_dst)
 			flp->fl4_dst = (*rp)->rt_dst;
 		err = __xfrm_lookup(net, (struct dst_entry **)rp, flp, sk,
-				    can_sleep ? XFRM_LOOKUP_WAIT : 0);
+				    ((flp->flags & FLOWI_FLAG_CAN_SLEEP) ?
+				     XFRM_LOOKUP_WAIT : 0));
 		if (err == -EREMOTE)
 			err = ipv4_dst_blackhole(net, rp, flp);
 
@@ -2746,7 +2747,7 @@ EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
 int ip_route_output_key(struct net *net, struct rtable **rp, struct flowi *flp)
 {
-	return ip_route_output_flow(net, rp, flp, NULL, false);
+	return ip_route_output_flow(net, rp, flp, NULL);
 }
 EXPORT_SYMBOL(ip_route_output_key);
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c6bcc93..ed9a5b7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -922,7 +922,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		struct net *net = sock_net(sk);
 
 		security_sk_classify_flow(sk, &fl);
-		err = ip_route_output_flow(net, &rt, &fl, sk, true);
+		err = ip_route_output_flow(net, &rt, &fl, sk);
 		if (err) {
 			if (err == -ENETUNREACH)
 				IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 7744a8e..5381ceb 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -489,7 +489,7 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 			 * itself out.
 			 */
 			security_sk_classify_flow(sk, &fl);
-			if (ip_route_output_flow(sock_net(sk), &rt, &fl, sk, false))
+			if (ip_route_output_flow(sock_net(sk), &rt, &fl, sk))
 				goto no_route;
 		}
 		sk_setup_caps(sk, &rt->dst);
-- 
1.7.4.1

