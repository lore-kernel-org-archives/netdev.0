From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/1 02/12] wimax/i2400m: fix the bootmode RX deadlock in
	SDIO driver
Date: Wed,  4 Nov 2009 13:39:38 -0800
Message-ID: <5b45bfe5010ae1ddaac463d1bcdb141a4ff4ff66.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org,
	wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
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

From: Cindy H Kao <cindy.h.kao@intel.com>

i2400ms_bus_bm_wait_for_ack() causes a race condition. It happens
because this function clears i2400ms->bm_ack_size before waiting for
an interrupt, which is set by the interrupt service routine i2400ms_rx()
to indicate reception and size of received data; thus, if the interrupt
came right before the clearing/waiting, it is lost.

The fix is clear the bm_ack_size to -EINPROGRESS before we are enabling
the RX interrupt configuration in i2400ms_rx_setup(). Then everytime
when the interrupt service routine i2400ms_rx() is invoked during bootmode,
bm_ack_size is updated with the actual rx_size and it is cleared to
-EINPROGRESS again after the RX data is handled.

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sdio-fw.c |    8 ++++----
 drivers/net/wimax/i2400m/sdio-rx.c |    7 +++++++
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio-fw.c b/drivers/net/wimax/i2400m/sdio-fw.c
index 7d6ec0f..c8dc538 100644
--- a/drivers/net/wimax/i2400m/sdio-fw.c
+++ b/drivers/net/wimax/i2400m/sdio-fw.c
@@ -177,10 +177,6 @@ ssize_t i2400ms_bus_bm_wait_for_ack(struct i2400m *i2400m,
 	d_fnstart(5, dev, "(i2400m %p ack %p size %zu)\n",
 		  i2400m, ack, ack_size);
 
-	spin_lock(&i2400m->rx_lock);
-	i2400ms->bm_ack_size = -EINPROGRESS;
-	spin_unlock(&i2400m->rx_lock);
-
 	result = wait_event_timeout(i2400ms->bm_wfa_wq,
 				    i2400ms->bm_ack_size != -EINPROGRESS,
 				    2 * HZ);
@@ -199,6 +195,10 @@ ssize_t i2400ms_bus_bm_wait_for_ack(struct i2400m *i2400m,
 		size = min(ack_size, i2400ms->bm_ack_size);
 		memcpy(ack, i2400m->bm_ack_buf, size);
 	}
+	/*
+	 * Remember always to clear the bm_ack_size to -EINPROGRESS
+	 * after the RX data is processed
+	 */
 	i2400ms->bm_ack_size = -EINPROGRESS;
 	spin_unlock(&i2400m->rx_lock);
 
diff --git a/drivers/net/wimax/i2400m/sdio-rx.c b/drivers/net/wimax/i2400m/sdio-rx.c
index 321bead..f6ca51a 100644
--- a/drivers/net/wimax/i2400m/sdio-rx.c
+++ b/drivers/net/wimax/i2400m/sdio-rx.c
@@ -234,6 +234,13 @@ int i2400ms_rx_setup(struct i2400ms *i2400ms)
 	init_waitqueue_head(&i2400ms->bm_wfa_wq);
 	spin_lock(&i2400m->rx_lock);
 	i2400ms->bm_wait_result = -EINPROGRESS;
+	/*
+	 * Before we are about to enable the RX interrupt, make sure
+	 * bm_ack_size is cleared to -EINPROGRESS which indicates
+	 * no RX interrupt happened yet or the previous interrupt
+	 * has been handled, we are ready to take the new interrupt
+	 */
+	i2400ms->bm_ack_size = -EINPROGRESS;
 	spin_unlock(&i2400m->rx_lock);
 
 	sdio_claim_host(func);
-- 
1.6.2.5
