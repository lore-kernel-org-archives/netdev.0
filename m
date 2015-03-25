From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH] cxgb4: Fix frame size warning for 32 bit arch
Date: Wed, 25 Mar 2015 20:01:26 +0530
Message-ID: <1427293886-7859-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:29854 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754562AbbCYO0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 10:26:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes below warning by dynamically allocating memory

All warnings:

   drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c: In function
   'cctrl_tbl_show':
   >> drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c:689:1: warning: the
   >> frame
   >> size of 1028 bytes is larger than 1024 bytes [-Wframe-larger-than=]

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 0918c16..f0285bc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -670,9 +670,13 @@ static int cctrl_tbl_show(struct seq_file *seq, void *v)
 		"0.9375" };
 
 	int i;
-	u16 incr[NMTUS][NCCTRL_WIN];
+	u16 (*incr)[NCCTRL_WIN];
 	struct adapter *adap = seq->private;
 
+	incr = kmalloc(sizeof(*incr) * NMTUS, GFP_KERNEL);
+	if (!incr)
+		return -ENOMEM;
+
 	t4_read_cong_tbl(adap, incr);
 
 	for (i = 0; i < NCCTRL_WIN; ++i) {
@@ -685,6 +689,8 @@ static int cctrl_tbl_show(struct seq_file *seq, void *v)
 			   adap->params.a_wnd[i],
 			   dec_fac[adap->params.b_wnd[i]]);
 	}
+
+	kfree(incr);
 	return 0;
 }
 
-- 
1.7.1
