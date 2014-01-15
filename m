From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 04/10] dcb: use __dev_get_by_name instead of dev_get_by_name to find interface
Date: Wed, 15 Jan 2014 10:23:39 +0800
Message-ID: <1389752625-23189-5-git-send-email-ying.xue@windriver.com>
References: <1389752625-23189-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vfalico@redhat.com>, <john.r.fastabend@intel.com>,
	<stephen@networkplumber.org>, <antonio@meshcoding.com>,
	<dmitry.tarnyagin@lockless.no>, <socketcan@hartkopp.net>,
	<johannes@sipsolutions.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389752625-23189-1-git-send-email-ying.xue@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following call chain indicates that dcb_doit() is protected
under rtnl_lock. So if we use __dev_get_by_name() instead of
dev_get_by_name() to find interface handlers in it, this would
help us avoid to change interface reference counter.

rtnetlink_rcv()
  rtnl_lock()
  netlink_rcv_skb()
    dcb_doit()
  rtnl_unlock()

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/dcb/dcbnl.c |   15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 66fbe19..5536444 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1688,21 +1688,17 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!tb[DCB_ATTR_IFNAME])
 		return -EINVAL;
 
-	netdev = dev_get_by_name(net, nla_data(tb[DCB_ATTR_IFNAME]));
+	netdev = __dev_get_by_name(net, nla_data(tb[DCB_ATTR_IFNAME]));
 	if (!netdev)
 		return -ENODEV;
 
-	if (!netdev->dcbnl_ops) {
-		ret = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!netdev->dcbnl_ops)
+		return -EOPNOTSUPP;
 
 	reply_skb = dcbnl_newmsg(fn->type, dcb->cmd, portid, nlh->nlmsg_seq,
 				 nlh->nlmsg_flags, &reply_nlh);
-	if (!reply_skb) {
-		ret = -ENOBUFS;
-		goto out;
-	}
+	if (!reply_skb)
+		return -ENOBUFS;
 
 	ret = fn->cb(netdev, nlh, nlh->nlmsg_seq, tb, reply_skb);
 	if (ret < 0) {
@@ -1714,7 +1710,6 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ret = rtnl_unicast(reply_skb, net, portid);
 out:
-	dev_put(netdev);
 	return ret;
 }
 
-- 
1.7.9.5
