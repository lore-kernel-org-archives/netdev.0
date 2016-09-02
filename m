From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH] net: ti: cpmac: Fix compiler warning due to type confusion
Date: Fri, 2 Sep 2016 15:22:48 +0100
Message-ID: <20160902142248.3553-1-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Burton <paul.burton@imgtec.com>,
        <linux-kernel@vger.kernel.org>
To: Florian Fainelli <florian@openwrt.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:49943 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932252AbcIBOXX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 10:23:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cpmac_start_xmit() used the max() macro on skb->len (an unsigned int)
and ETH_ZLEN (a signed int literal). This led to the following compiler
warning:

  In file included from include/linux/list.h:8:0,
                   from include/linux/module.h:9,
                   from drivers/net/ethernet/ti/cpmac.c:19:
  drivers/net/ethernet/ti/cpmac.c: In function 'cpmac_start_xmit':
  include/linux/kernel.h:748:17: warning: comparison of distinct pointer
  types lacks a cast
    (void) (&_max1 == &_max2);  \
                   ^
  drivers/net/ethernet/ti/cpmac.c:560:8: note: in expansion of macro 'max'
    len = max(skb->len, ETH_ZLEN);
          ^

On top of this, it assigned the result of the max() macro to a signed
integer whilst all further uses of it result in it being cast to varying
widths of unsigned integer.

Fix this up by using max_t to ensure the comparison is performed as
unsigned integers, and for consistency change the type of the len
variable to unsigned int.

Signed-off-by: Paul Burton <paul.burton@imgtec.com>

---

 drivers/net/ethernet/ti/cpmac.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 7eef45e..b1454bd 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -547,7 +547,8 @@ fatal_error:
 
 static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	int queue, len;
+	int queue;
+	unsigned int len;
 	struct cpmac_desc *desc;
 	struct cpmac_priv *priv = netdev_priv(dev);
 
@@ -557,7 +558,7 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(skb_padto(skb, ETH_ZLEN)))
 		return NETDEV_TX_OK;
 
-	len = max(skb->len, ETH_ZLEN);
+	len = max_t(unsigned int, skb->len, ETH_ZLEN);
 	queue = skb_get_queue_mapping(skb);
 	netif_stop_subqueue(dev, queue);
 
-- 
2.9.3
