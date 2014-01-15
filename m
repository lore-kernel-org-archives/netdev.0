From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 08/10] caif: __dev_get_by_index instead of dev_get_by_index to find interface
Date: Wed, 15 Jan 2014 10:23:43 +0800
Message-ID: <1389752625-23189-9-git-send-email-ying.xue@windriver.com>
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

The following call chains indicate that chnl_net_open() is under
rtnl_lock protection as __dev_open() is protected by rtnl_lock.
So if __dev_get_by_index() instead of dev_get_by_index() is used
to find interface handler in it, this would help us avoid to change
interface reference counter.

__dev_open()
  chnl_net_open()

Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/caif/chnl_net.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 7344a8f..4589ff67 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -285,7 +285,7 @@ static int chnl_net_open(struct net_device *dev)
 				goto error;
 		}
 
-		lldev = dev_get_by_index(dev_net(dev), llifindex);
+		lldev = __dev_get_by_index(dev_net(dev), llifindex);
 
 		if (lldev == NULL) {
 			pr_debug("no interface?\n");
@@ -307,7 +307,6 @@ static int chnl_net_open(struct net_device *dev)
 		mtu = min_t(int, dev->mtu, lldev->mtu - (headroom + tailroom));
 		mtu = min_t(int, GPRS_PDP_MTU, mtu);
 		dev_set_mtu(dev, mtu);
-		dev_put(lldev);
 
 		if (mtu < 100) {
 			pr_warn("CAIF Interface MTU too small (%d)\n", mtu);
-- 
1.7.9.5
