From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 6/7] netvsc: Initialize 64-bit stats seqcount
Date: Tue,  1 Aug 2017 12:11:11 -0700
Message-ID: <20170801191113.8754-7-f.fainelli@gmail.com>
References: <20170801191113.8754-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
 Stephen Hemminger <sthemmin@microsoft.com>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 open list <linux-kernel@vger.kernel.org>, edumazet@google.com,
 "open list:Hyper-V CORE AND DRIVERS" <devel@linuxdriverproject.org>,
 davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170801191113.8754-1-f.fainelli@gmail.com>
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

On 32-bit hosts and with CONFIG_DEBUG_LOCK_ALLOC we should be seeing a
lockdep splat indicating this seqcount is not correctly initialized, fix
that. In commit 6c80f3fc2398 ("netvsc: report per-channel stats in
ethtool statistics") netdev_alloc_pcpu_stats() was removed in favor of
open-coding the 64-bits statistics, except that u64_stats_init() was
missed.

Fixes: 6c80f3fc2398 ("netvsc: report per-channel stats in ethtool statistics")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/hyperv/netvsc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 0a9167dd72fb..96f90c75d1b7 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1302,6 +1302,8 @@ int netvsc_device_add(struct hv_device *device,
 		struct netvsc_channel *nvchan = &net_device->chan_table[i];
 
 		nvchan->channel = device->channel;
+		u64_stats_init(&nvchan->tx_stats.syncp);
+		u64_stats_init(&nvchan->rx_stats.syncp);
 	}
 
 	/* Enable NAPI handler before init callbacks */
-- 
2.9.3
