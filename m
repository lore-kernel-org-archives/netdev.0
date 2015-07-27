From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 06/16] net: Tx via VRF device
Date: Mon, 27 Jul 2015 12:30:59 -0600
Message-ID: <1438021869-49186-7-git-send-email-dsa@cumulusnetworks.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38571 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865AbbG0SdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:33:01 -0400
Received: by iggf3 with SMTP id f3so89046752igg.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 11:33:00 -0700 (PDT)
In-Reply-To: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If out device is enslaved to a VRF device we want packets to go through the
VRF master device first. This allows for example iptables rules and tc rules
to be configured on the VRF as a whole as well as the option for rules on
specific netdevices. This is accomplished by updating the dev in the dst to
point to the VRF device if it is enslaved.

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8119896e1159..050a3c1d89ba 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1903,6 +1903,23 @@ int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 }
 EXPORT_SYMBOL(ip_route_input_noref);
 
+/* if out device is enslaved to a VRF device update dst to
+ * send through it
+ */
+static void rt_use_vrf_dev(struct rtable *rth, struct net_device *dev_out)
+{
+#if IS_ENABLED(CONFIG_NET_VRF)
+	int ifindex = vrf_master_dev_ifindex(dev_out);
+	struct net_device *mdev;
+
+	mdev = dev_get_by_index(dev_net(dev_out), ifindex);
+	if (mdev) {
+		dev_put(rth->dst.dev);
+		rth->dst.dev = mdev;
+	}
+#endif
+}
+
 /* called with rcu_read_lock() */
 static struct rtable *__mkroute_output(const struct fib_result *res,
 				       const struct flowi4 *fl4, int orig_oif,
@@ -2008,6 +2025,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	}
 
 	rt_set_nexthop(rth, fl4->daddr, res, fnhe, fi, type, 0);
+	rt_use_vrf_dev(rth, dev_out);
 
 	return rth;
 }
-- 
2.3.2 (Apple Git-55)
