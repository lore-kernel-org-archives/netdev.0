From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH 09/10] net: thunderx: check if memory allocation was successful
Date: Tue, 2 Jun 2015 11:00:26 -0700
Message-ID: <1433268028-23992-10-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	David Daney <david.daney@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a coccinelle warning:

coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/cavium/thunder/nicvf_queues.c:360:1-11: alloc
>> with no test, possible model on line 367

vim +360 drivers/net/ethernet/cavium/thunder/nicvf_queues.c

   354		err = nicvf_alloc_q_desc_mem(nic, &sq->dmem, q_len,
SND_QUEUE_DESC_SIZE,
   355					     NICVF_SQ_BASE_ALIGN_BYTES);
   356		if (err)
   357			return err;
   358
   359		sq->desc = sq->dmem.base;
 > 360		sq->skbuff = kcalloc(q_len, sizeof(u64), GFP_ATOMIC);
   361		sq->head = 0;
   362		sq->tail = 0;
   363		atomic_set(&sq->free_cnt, q_len - 1);
   364		sq->thresh = SND_QUEUE_THRESH;
   365
   366		/* Preallocate memory for TSO segment's header */
 > 367		sq->tso_hdrs = dma_alloc_coherent(&nic->pdev->dev,
   368						  q_len *
TSO_HEADER_SIZE,
   369						  &sq->tso_hdrs_phys,
GFP_KERNEL);
   370		if (!sq->tso_hdrs)

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 8929029..2ed7d1b 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -357,6 +357,8 @@ static int nicvf_init_snd_queue(struct nicvf *nic,
 
 	sq->desc = sq->dmem.base;
 	sq->skbuff = kcalloc(q_len, sizeof(u64), GFP_ATOMIC);
+	if (!sq->skbuff)
+		return -ENOMEM;
 	sq->head = 0;
 	sq->tail = 0;
 	atomic_set(&sq->free_cnt, q_len - 1);
-- 
2.4.1
