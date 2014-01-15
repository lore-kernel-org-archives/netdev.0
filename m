From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 07/10] batman-adv: use __dev_get_by_index instead of dev_get_by_index to find interface
Date: Wed, 15 Jan 2014 10:23:42 +0800
Message-ID: <1389752625-23189-8-git-send-email-ying.xue@windriver.com>
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

The following call chains indicate that batadv_is_on_batman_iface()
is always under rtnl_lock protection as call_netdevice_notifier()
is protected by rtnl_lock. So if __dev_get_by_index() rather than
dev_get_by_index() is used to find interface handler in it, this
would help us avoid to change interface reference counter.

call_netdevice_notifier()
  batadv_hard_if_event()
    batadv_hardif_add_interface()
      batadv_is_valid_iface()
        batadv_is_on_batman_iface()

Cc: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/hard-interface.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 1b12573..3d417d3 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -87,15 +87,13 @@ static bool batadv_is_on_batman_iface(const struct net_device *net_dev)
 		return false;
 
 	/* recurse over the parent device */
-	parent_dev = dev_get_by_index(&init_net, net_dev->iflink);
+	parent_dev = __dev_get_by_index(&init_net, net_dev->iflink);
 	/* if we got a NULL parent_dev there is something broken.. */
 	if (WARN(!parent_dev, "Cannot find parent device"))
 		return false;
 
 	ret = batadv_is_on_batman_iface(parent_dev);
 
-	if (parent_dev)
-		dev_put(parent_dev);
 	return ret;
 }
 
-- 
1.7.9.5
