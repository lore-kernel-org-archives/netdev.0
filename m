From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 22/29] net_dma: poll for a descriptor after allocation failure
Date: Thu, 03 Sep 2009 19:32:22 -0700
Message-ID: <20090904023221.32667.70000.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932891AbZIDCeu@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handle descriptor allocation failures by polling for a descriptor.  The
driver will force forward progress when polled.  In the best case this
polling interval will be the time it takes for one dma memcpy
transaction to complete.  In the worst case, channel hang, we will need
to wait 100ms for the cleanup watchdog to fire (ioatdma driver).

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/iovlock.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/dma/iovlock.c b/drivers/dma/iovlock.c
index 9f6fe46..c0a272c 100644
--- a/drivers/dma/iovlock.c
+++ b/drivers/dma/iovlock.c
@@ -183,6 +183,11 @@ dma_cookie_t dma_memcpy_to_iovec(struct dma_chan *chan, struct iovec *iov,
 					iov_byte_offset,
 					kdata,
 					copy);
+			/* poll for a descriptor slot */
+			if (unlikely(dma_cookie < 0)) {
+				dma_async_issue_pending(chan);
+				continue;
+			}
 
 			len -= copy;
 			iov[iovec_idx].iov_len -= copy;
@@ -248,6 +253,11 @@ dma_cookie_t dma_memcpy_pg_to_iovec(struct dma_chan *chan, struct iovec *iov,
 					page,
 					offset,
 					copy);
+			/* poll for a descriptor slot */
+			if (unlikely(dma_cookie < 0)) {
+				dma_async_issue_pending(chan);
+				continue;
+			}
 
 			len -= copy;
 			iov[iovec_idx].iov_len -= copy;
