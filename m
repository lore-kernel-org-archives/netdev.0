From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 03/25] wimax/i2400m: fix insufficient size of Tx buffer
	for 12 payload of 1400 MTU.
Date: Fri, 14 May 2010 14:45:02 -0700
Message-ID: <570eb0ea65db625e0b11ca97f4ae857bc1193250.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Prasanna S. Panchamukhi" <prasannax.s.panchamukhi@intel.com>
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

From: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>

This patch increases the Tx buffer size so as to accommodate 12 payloads
of 1408 (1400 MTU 16 bytes aligned). Currently Tx buffer is 32 KiB which
is insufficient to accommodate 12 payloads of 1408 size.
This patch
 - increases I2400M_TX_BUF_SIZE from 32KiB to 64KiB
 - Adds a BUILD_BUG_ON if the calculated buffer size based
   on the given MTU exceeds the I2400M_TX_BUF_SIZE.

Below is how we calculate the size of the Tx buffer.
Payload + 4 bytes prefix for each payload (1400 MTU 16 bytes boundary aligned)
		= (1408 + sizeof(struct i2400m_pl_data_hdr)) * I2400M_TX_PLD_MAX
Adding 16 byte message header = + sizeof(struct i2400m_msg_hdr)
Aligning to 256 byte boundary
Total Tx buffer = (((((1408 + sizeof(struct i2400m_pl_data_hdr))
		* I2400M_TX_PLD_MAX )+ sizeof(struct i2400m_msg_hdr))
		/ 256) + 1) * 256 * 2

Signed-off-by: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/tx.c |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index fab27e4..8561c07 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -258,8 +258,10 @@ enum {
 	 * Doc says maximum transaction is 16KiB. If we had 16KiB en
 	 * route and 16KiB being queued, it boils down to needing
 	 * 32KiB.
+	 * 32KiB is insufficient for 1400 MTU, hence increasing
+	 * tx buffer size to 64KiB.
 	 */
-	I2400M_TX_BUF_SIZE = 32768,
+	I2400M_TX_BUF_SIZE = 65536,
 	/**
 	 * Message header and payload descriptors have to be 16
 	 * aligned (16 + 4 * N = 16 * M). If we take that average sent
@@ -274,6 +276,19 @@ enum {
 	I2400M_TX_PLD_SIZE = sizeof(struct i2400m_msg_hdr)
 	+ I2400M_TX_PLD_MAX * sizeof(struct i2400m_pld),
 	I2400M_TX_SKIP = 0x80000000,
+	/*
+	 * 16 byte aligned MAX_MTU + 4 byte payload prefix.
+	 */
+	I2400M_MAX_MTU_ALIGN = 16,
+	I2400M_TX_PDU_SIZE = I2400M_MAX_MTU % I2400M_MAX_MTU_ALIGN
+	+ I2400M_MAX_MTU + sizeof(struct i2400m_pl_data_hdr),
+	 /*
+	  * 256 byte aligned toal size of 12 PDUs including msg header,
+	  */
+	I2400M_TX_PDU_ALIGN = 256,
+	I2400M_TX_PDU_TOTAL_SIZE = ((I2400M_TX_PDU_SIZE * I2400M_TX_PLD_MAX
+	+ sizeof(struct i2400m_msg_hdr))/I2400M_TX_PDU_ALIGN + 1)
+	* I2400M_TX_PDU_ALIGN * 2,
 };
 
 #define TAIL_FULL ((void *)~(unsigned long)NULL)
@@ -874,6 +889,8 @@ int i2400m_tx_setup(struct i2400m *i2400m)
 	INIT_WORK(&i2400m->wake_tx_ws, i2400m_wake_tx_work);
 
 	i2400m->tx_sequence = 0;
+	 /* Warn if the calculated buffer size exceeds I2400M_TX_BUF_SIZE. */
+	BUILD_BUG_ON(I2400M_TX_PDU_TOTAL_SIZE > I2400M_TX_BUF_SIZE);
 	i2400m->tx_buf = kmalloc(I2400M_TX_BUF_SIZE, GFP_KERNEL);
 	if (i2400m->tx_buf == NULL)
 		result = -ENOMEM;
-- 
1.6.6.1
