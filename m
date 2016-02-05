From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net] hv_netvsc: Restore needed_headroom request
Date: Fri,  5 Feb 2016 17:29:08 +0100
Message-ID: <1454689748-29095-1-git-send-email-vkuznets@redhat.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit c0eb454034aa ("hv_netvsc: Don't ask for additional head room in the
skb") got rid of needed_headroom setting for the driver. With the change I
hit the following issue trying to use ptkgen module:

[   57.522021] kernel BUG at net/core/skbuff.c:1128!
[   57.522021] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
...
[   58.721068] Call Trace:
[   58.721068]  [<ffffffffa0144e86>] netvsc_start_xmit+0x4c6/0x8e0 [hv_netvsc]
...
[   58.721068]  [<ffffffffa02f87fc>] ? pktgen_finalize_skb+0x25c/0x2a0 [pktgen]
[   58.721068]  [<ffffffff814f5760>] ? __netdev_alloc_skb+0xc0/0x100
[   58.721068]  [<ffffffffa02f9907>] pktgen_thread_worker+0x257/0x1920 [pktgen]

Basically, we're calling skb_cow_head(skb, RNDIS_AND_PPI_SIZE) and crash on
    if (skb_shared(skb))
        BUG();

We probably need to restore needed_headroom setting (but shrunk to
RNDIS_AND_PPI_SIZE as we don't need more) to request the required headroom
space. In theory, it should not give us performance penalty.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc_drv.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 1d3a665..98e34fe 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1089,6 +1089,9 @@ static int netvsc_probe(struct hv_device *dev,
 	net->ethtool_ops = &ethtool_ops;
 	SET_NETDEV_DEV(net, &dev->device);
 
+	/* We always need headroom for rndis header */
+	net->needed_headroom = RNDIS_AND_PPI_SIZE;
+
 	/* Notify the netvsc driver of the new device */
 	memset(&device_info, 0, sizeof(device_info));
 	device_info.ring_size = ring_size;
-- 
2.5.0
