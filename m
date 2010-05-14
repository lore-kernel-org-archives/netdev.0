From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 01/25] wimax/i2400m: fix incorrect return -ESHUTDOWN
	when there is no Tx buffer available
Date: Fri, 14 May 2010 14:45:00 -0700
Message-ID: <4818d14de36228a749f714b450a85c1b35542e6f.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Prasanna S.Panchamukhi" <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org,
	wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: Prasanna S.Panchamukhi <prasannax.s.panchamukhi@intel.com>

i2400m_tx() routine was returning -ESHUTDOWN even when there was no Tx buffer
available. This patch fixes the i2400m_tx() to return -ESHUTDOWN only when
the device is down(i2400m->tx_buf is NULL) and also to return -ENOSPC
when there is no Tx buffer. Error seen in the kernel log.
kernel: i2400m_sdio mmc0:0001:1: can't send message 0x5606: -108
kernel: i2400m_sdio mmc0:0001:1: Failed to issue 'Enter power save'command: -108

Signed-off-by: Prasanna S.Panchamukhi <prasannax.s.panchamukhi@intel.com>
---
 drivers/net/wimax/i2400m/tx.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index 6db909e..fab27e4 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -643,9 +643,11 @@ int i2400m_tx(struct i2400m *i2400m, const void *buf, size_t buf_len,
 	 * current one is out of payload slots or we have a singleton,
 	 * close it and start a new one */
 	spin_lock_irqsave(&i2400m->tx_lock, flags);
-	result = -ESHUTDOWN;
-	if (i2400m->tx_buf == NULL)
+	/* If tx_buf is NULL, device is shutdown */
+	if (i2400m->tx_buf == NULL) {
+		result = -ESHUTDOWN;
 		goto error_tx_new;
+	}
 try_new:
 	if (unlikely(i2400m->tx_msg == NULL))
 		i2400m_tx_new(i2400m);
-- 
1.6.6.1
