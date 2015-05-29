From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V2 net-next 1/2] hv_netvsc: Allocate the receive buffer from
 the correct NUMA node
Date: Thu, 28 May 2015 17:08:06 -0700
Message-ID: <1432858087-4704-1-git-send-email-kys@microsoft.com>
References: <1432858064-4627-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1432858064-4627-1-git-send-email-kys@microsoft.com>
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

Allocate the receive bufer from the NUMA node assigned to the primary
channel.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
	V2: Specify the tree for this patch.

 drivers/net/hyperv/netvsc.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index b024968..d187965 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -227,13 +227,18 @@ static int netvsc_init_buf(struct hv_device *device)
 	struct netvsc_device *net_device;
 	struct nvsp_message *init_packet;
 	struct net_device *ndev;
+	int node;
 
 	net_device = get_outbound_net_device(device);
 	if (!net_device)
 		return -ENODEV;
 	ndev = net_device->ndev;
 
-	net_device->recv_buf = vzalloc(net_device->recv_buf_size);
+	node = cpu_to_node(device->channel->target_cpu);
+	net_device->recv_buf = vzalloc_node(net_device->recv_buf_size, node);
+	if (!net_device->recv_buf)
+		net_device->recv_buf = vzalloc(net_device->recv_buf_size);
+
 	if (!net_device->recv_buf) {
 		netdev_err(ndev, "unable to allocate receive "
 			"buffer of size %d\n", net_device->recv_buf_size);
-- 
1.7.4.1
