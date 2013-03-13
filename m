From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: [PATCH] net/core: another bug fix related to dst_neigh_lookup/dst_neigh_lookup_skb
Date: Wed, 13 Mar 2013 16:40:49 +0800
Message-ID: <CAABZP2xsVauGarKa1yfWOHAmi9Z+B+Au3ZYa-QkM1hA4b4PypA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stable@vger.kernel.org, trivial@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:59545 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab3CMIku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 04:40:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I do a
/home/zzy/linux-stable#find . -name "*.c"|xargs grep -A 2 dst_neigh_lookup
and find that there are two places in drivers/infiniband/hw/cxgb4/cm.c
do not treat the error return of dst_neigh_lookup/dst_neigh_lookup_skb

Signed-off-by: Zhouyi Zhou <zhouzhouyi <at> gmail.com>

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 565bfb1..b5d6c4a 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1575,6 +1575,12 @@ static int c4iw_reconnect(struct c4iw_ep *ep)

        neigh = dst_neigh_lookup(ep->dst,
                        &ep->com.cm_id->remote_addr.sin_addr.s_addr);
+       if (!neigh) {
+               pr_err("%s - cannot alloc l2e.\n", __func__);
+               err = -ENOMEM;
+               goto fail4;
+       }
+
        /* get a l2t entry */
        if (neigh->dev->flags & IFF_LOOPBACK) {
                PDBG("%s LOOPBACK\n", __func__);
@@ -3052,7 +3058,11 @@ static int rx_pkt(struct c4iw_dev *dev, struct
sk_buff *skb)
        }
        dst = &rt->dst;
        neigh = dst_neigh_lookup_skb(dst, skb);
-
+       if (!neigh){
+               pr_err("%s - failed to allocate l2t entry!\n",
+                      __func__);
+               goto free_dst;
+       }
        if (neigh->dev->flags & IFF_LOOPBACK) {
                pdev = ip_dev_find(&init_net, iph->daddr);
                e = cxgb4_l2t_get(dev->rdev.lldi.l2t, neigh,

Thanks for your review
