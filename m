From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 1/4] I/OAT: fix channel resources free for not allocated
	channels
Date: Fri, 07 Nov 2008 12:45:52 +0100
Message-ID: <20081107114525.25190.7557.stgit@linux.site>
References: <20081107114325.25190.5419.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tom.s.picard@intel.com, mark_rustad@Xiotech.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable@kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55577 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752366AbYKGL5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 06:57:17 -0500
In-Reply-To: <20081107114325.25190.5419.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Sosnowski <maciej.sosnowski@intel.com>

If the ioatdma driver is loaded but not used it does not allocate descriptors.
Before it frees channel resources it should first be sure
that they have been previously allocated.

Cc: <stable@kernel.org>
Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Tested-by: Tom Picard <tom.s.picard@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 drivers/dma/ioat_dma.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index b0438c4..687eef7 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -807,6 +807,12 @@ static void ioat_dma_free_chan_resources
 	struct ioat_desc_sw *desc, *_desc;
 	int in_use_descs = 0;
 
+	/* Before freeing channel resources first check 
+	 * if they have been previously allocated for this channel.
+	 */
+	if (ioat_chan->desccount == 0)
+		return;
+
 	tasklet_disable(&ioat_chan->cleanup_task);
 	ioat_dma_memcpy_cleanup(ioat_chan);
 
@@ -869,6 +875,7 @@ static void ioat_dma_free_chan_resources
 	ioat_chan->last_completion = ioat_chan->completion_addr = 0;
 	ioat_chan->pending = 0;
 	ioat_chan->dmacount = 0;
+	ioat_chan->desccount = 0;
 	ioat_chan->watchdog_completion = 0;
 	ioat_chan->last_compl_desc_addr_hw = 0;
 	ioat_chan->watchdog_tcp_cookie =

