From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 7/8] netvsc: save pointer to parent netvsc_device in
 channel table
Date: Wed, 19 Jul 2017 11:53:18 -0700
Message-ID: <20170719185319.25871-8-sthemmin@microsoft.com>
References: <20170719185319.25871-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170719185319.25871-1-sthemmin@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Keep back pointer in the per-channel data structure to
avoid any possible RCU related issues when napi poll is
called but netvsc_device is in RCU limbo.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h | 1 +
 drivers/net/hyperv/netvsc.c     | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 0054b6929f6e..d13572879e7e 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -727,6 +727,7 @@ struct net_device_context {
 /* Per channel data */
 struct netvsc_channel {
 	struct vmbus_channel *channel;
+	struct netvsc_device *net_device;
 	const struct vmpacket_descriptor *desc;
 	struct napi_struct napi;
 	struct multi_send_data msd;
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 3c6f3ae520d9..c15640c6fd83 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1224,11 +1224,11 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 {
 	struct netvsc_channel *nvchan
 		= container_of(napi, struct netvsc_channel, napi);
+	struct netvsc_device *net_device = nvchan->net_device;
 	struct vmbus_channel *channel = nvchan->channel;
 	struct hv_device *device = netvsc_channel_to_device(channel);
 	u16 q_idx = channel->offermsg.offer.sub_channel_index;
 	struct net_device *ndev = hv_get_drvdata(device);
-	struct netvsc_device *net_device = net_device_to_netvsc_device(ndev);
 	int work_done = 0;
 
 	/* If starting a new interval */
@@ -1307,6 +1307,7 @@ struct netvsc_device *netvsc_device_add(struct hv_device *device,
 		struct netvsc_channel *nvchan = &net_device->chan_table[i];
 
 		nvchan->channel = device->channel;
+		nvchan->net_device = net_device;
 	}
 
 	/* Enable NAPI handler before init callbacks */
-- 
2.11.0
