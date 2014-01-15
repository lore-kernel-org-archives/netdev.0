From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 06/10] vxlan: use __dev_get_by_index instead of dev_get_by_index to find interface
Date: Wed, 15 Jan 2014 10:23:41 +0800
Message-ID: <1389752625-23189-7-git-send-email-ying.xue@windriver.com>
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

The following call chains indicate that vxlan_fdb_parse() is
under rtnl_lock protection. So if we use __dev_get_by_index()
instead of dev_get_by_index() to find interface handler in it,
this would help us avoid to change interface reference counter.

rtnetlink_rcv()
  rtnl_lock()
  netlink_rcv_skb()
    rtnl_fdb_add()
      vxlan_fdb_add()
        vxlan_fdb_parse()
  rtnl_unlock()

rtnetlink_rcv()
  rtnl_lock()
  netlink_rcv_skb()
    rtnl_fdb_del()
      vxlan_fdb_del()
        vxlan_fdb_parse()
  rtnl_unlock()

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 481f85d..8c40802 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -741,10 +741,9 @@ static int vxlan_fdb_parse(struct nlattr *tb[], struct vxlan_dev *vxlan,
 		if (nla_len(tb[NDA_IFINDEX]) != sizeof(u32))
 			return -EINVAL;
 		*ifindex = nla_get_u32(tb[NDA_IFINDEX]);
-		tdev = dev_get_by_index(net, *ifindex);
+		tdev = __dev_get_by_index(net, *ifindex);
 		if (!tdev)
 			return -EADDRNOTAVAIL;
-		dev_put(tdev);
 	} else {
 		*ifindex = 0;
 	}
-- 
1.7.9.5
