From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 7/7] igb: only recycle page if it is on our numa
	node
Date: Thu, 12 Nov 2009 20:38:35 -0800
Message-ID: <20091113043834.1240.42310.stgit@localhost.localdomain>
References: <20091113043604.1240.80142.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:42671
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755864AbZKMEiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 23:38:51 -0500
In-Reply-To: <20091113043604.1240.80142.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch makes it so that we only recycle pages when they are from the
local NUMA node.  Non-local pages are freed and replaced with locally
allocated pages.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 9911b3a..0cab5e2 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4952,6 +4952,7 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
 	struct sk_buff *skb;
 	bool cleaned = false;
 	int cleaned_count = 0;
+	int current_node = numa_node_id();
 	unsigned int total_bytes = 0, total_packets = 0;
 	unsigned int i;
 	u32 staterr;
@@ -5006,7 +5007,8 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
 						buffer_info->page_offset,
 						length);
 
-			if (page_count(buffer_info->page) != 1)
+			if ((page_count(buffer_info->page) != 1) ||
+			    (page_to_nid(buffer_info->page) != current_node))
 				buffer_info->page = NULL;
 			else
 				get_page(buffer_info->page);

