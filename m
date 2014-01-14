From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 05/10] decnet: use __dev_get_by_index instead of dev_get_by_index to find interface
Date: Tue, 14 Jan 2014 15:41:04 +0800
Message-ID: <1389685269-18600-6-git-send-email-ying.xue@windriver.com>
References: <1389685269-18600-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vfalico@redhat.com>, <john.r.fastabend@intel.com>,
	<stephen@networkplumber.org>, <antonio@meshcoding.com>,
	<dmitry.tarnyagin@lockless.no>, <socketcan@hartkopp.net>,
	<johannes@sipsolutions.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389685269-18600-1-git-send-email-ying.xue@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following call chain we can identify that dn_cache_getroute() is
protected under rtnl_lock. So if we use __dev_get_by_index() instead
of dev_get_by_index() to find interface handlers in it, this would help
us avoid to change interface reference counter.

rtnetlink_rcv()
  rtnl_lock()
    netlink_rcv_skb()
      dn_cache_getroute()
  rtnl_unlock()

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/decnet/dn_route.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index ad2efa5..22390e4 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1666,12 +1666,12 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 
 	if (fld.flowidn_iif) {
 		struct net_device *dev;
-		if ((dev = dev_get_by_index(&init_net, fld.flowidn_iif)) == NULL) {
+		dev = __dev_get_by_index(&init_net, fld.flowidn_iif);
+		if (!dev) {
 			kfree_skb(skb);
 			return -ENODEV;
 		}
 		if (!dev->dn_ptr) {
-			dev_put(dev);
 			kfree_skb(skb);
 			return -ENODEV;
 		}
@@ -1693,8 +1693,6 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		err = dn_route_output_key((struct dst_entry **)&rt, &fld, 0);
 	}
 
-	if (skb->dev)
-		dev_put(skb->dev);
 	skb->dev = NULL;
 	if (err)
 		goto out_free;
-- 
1.7.9.5
