From: Dan Williams <dan.j.williams@intel.com>
Subject: [GIT PATCH] ioat2: fix performance regression
Date: Wed, 13 Oct 2010 16:03:44 -0700
Message-ID: <20101013230248.32594.35857.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jiang <dave.jiang@intel.com>,
	Linus Walleij <linus.walleij@stericsson.com>,
	netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, stable@kernel.org,
	Richard Scobie <richard@sauce.co.nz>
To: akpm@linux-foundation.org, torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14513 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753542Ab0JMXAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 19:00:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0793448 "DMAENGINE: generic channel status v2" changed the interface for
how dma channel progress is retrieved.  It inadvertently exported an internal
helper function ioat_tx_status() instead of ioat_dma_tx_status().  The latter
polls the hardware to get the latest completion state, while the helper just
evaluates the current state without touching hardware.  The effect is that we
end up waiting for completion timeouts or descriptor allocation errors before
the completion state is updated.

iperf (before fix):
[SUM]  0.0-41.3 sec   364 MBytes  73.9 Mbits/sec

iperf (after fix):
[SUM]  0.0- 4.5 sec   499 MBytes   940 Mbits/sec

This is a regression starting with 2.6.35.

Cc: <stable@kernel.org>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Linus Walleij <linus.walleij@stericsson.com>
Cc: Maciej Sosnowski <maciej.sosnowski@intel.com>
Reported-by: Richard Scobie <richard@sauce.co.nz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
Late breaking fix that can hopefully get into 2.6.36.  I will queue a
cleanup to clarify this confusing naming convention for 2.6.37.

Also available via git:

  git://git.kernel.org/pub/scm/linux/kernel/git/djbw/async_tx.git fixes

Dan Williams (1):
      ioat2: fix performance regression

 drivers/dma/ioat/dma_v2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/dma/ioat/dma_v2.c b/drivers/dma/ioat/dma_v2.c
index 216f9d3..effd140 100644
--- a/drivers/dma/ioat/dma_v2.c
+++ b/drivers/dma/ioat/dma_v2.c
@@ -879,7 +879,7 @@ int __devinit ioat2_dma_probe(struct ioatdma_device *device, int dca)
 	dma->device_issue_pending = ioat2_issue_pending;
 	dma->device_alloc_chan_resources = ioat2_alloc_chan_resources;
 	dma->device_free_chan_resources = ioat2_free_chan_resources;
-	dma->device_tx_status = ioat_tx_status;
+	dma->device_tx_status = ioat_dma_tx_status;
 
 	err = ioat_probe(device);
 	if (err)

