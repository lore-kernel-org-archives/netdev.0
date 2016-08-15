From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net v2 5/5] hv_netvsc: fix bonding devices check in netvsc_netdev_event()
Date: Mon, 15 Aug 2016 17:48:43 +0200
Message-ID: <1471276123-24264-6-git-send-email-vkuznets@redhat.com>
References: <1471276123-24264-1-git-send-email-vkuznets@redhat.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471276123-24264-1-git-send-email-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bonding driver sets IFF_BONDING on both master (the bonding device) and
slave (the real NIC) devices and in netvsc_netdev_event() we want to skip
master devices only. Currently, there is an uncertainty when a slave
interface is removed: if bonding module comes first in netdev_chain it
clears IFF_BONDING flag on the netdev and netvsc_netdev_event() correctly
handles NETDEV_UNREGISTER event, but in case netvsc comes first on the
chain it sees the device with IFF_BONDING still attached and skips it. As
we still hold vf_netdev pointer to the device we crash on the next inject.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc_drv.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 62a4e6e..3ba29fc 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1482,8 +1482,13 @@ static int netvsc_netdev_event(struct notifier_block *this,
 {
 	struct net_device *event_dev = netdev_notifier_info_to_dev(ptr);
 
-	/* Avoid Vlan, Bonding dev with same MAC registering as VF */
-	if (event_dev->priv_flags & (IFF_802_1Q_VLAN | IFF_BONDING))
+	/* Avoid Vlan dev with same MAC registering as VF */
+	if (event_dev->priv_flags & IFF_802_1Q_VLAN)
+		return NOTIFY_DONE;
+
+	/* Avoid Bonding master dev with same MAC registering as VF */
+	if (event_dev->priv_flags & IFF_BONDING &&
+	    event_dev->flags & IFF_MASTER)
 		return NOTIFY_DONE;
 
 	switch (event) {
-- 
2.7.4
