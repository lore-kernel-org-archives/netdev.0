From: Bjorn Helgaas <bhelgaas@google.com>
Subject: [PATCH] net/mlx4: Avoid 'may be used uninitialized' warnings
Date: Thu, 14 May 2015 18:17:08 -0500
Message-ID: <20150514231708.13594.13610.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ido Shamay <idos@mellanox.com>, netdev@vger.kernel.org,
	Yishai Hadas <yishaih@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, linux-kernel@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	"David S. Miller" <davem@davemloft.net>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Matan Barak <matanb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:33242 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933134AbbENXRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 19:17:11 -0400
Received: by iebgx4 with SMTP id gx4so74788287ieb.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 16:17:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With a cross-compiler based on gcc-4.9, I see warnings like the following:

  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function 'mlx4_SW2HW_CQ_wrapper':
  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:3048:10: error: 'cq' may be used uninitialized in this function [-Werror=maybe-uninitialized]
    cq->mtt = mtt;

I think the warning is spurious because we only use cq when
cq_res_start_move_to() returns zero, and it always initializes *cq in that
case.  The srq case is similar.  But maybe gcc isn't smart enough to figure
that out.

Initialize cq and srq explicitly to avoid the warnings.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index c7f28bf..cdd32f4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -3187,7 +3187,7 @@ int mlx4_SW2HW_CQ_wrapper(struct mlx4_dev *dev, int slave,
 	int cqn = vhcr->in_modifier;
 	struct mlx4_cq_context *cqc = inbox->buf;
 	int mtt_base = cq_get_mtt_addr(cqc) / dev->caps.mtt_entry_sz;
-	struct res_cq *cq;
+	struct res_cq *cq = NULL;
 	struct res_mtt *mtt;
 
 	err = cq_res_start_move_to(dev, slave, cqn, RES_CQ_HW, &cq);
@@ -3223,7 +3223,7 @@ int mlx4_HW2SW_CQ_wrapper(struct mlx4_dev *dev, int slave,
 {
 	int err;
 	int cqn = vhcr->in_modifier;
-	struct res_cq *cq;
+	struct res_cq *cq = NULL;
 
 	err = cq_res_start_move_to(dev, slave, cqn, RES_CQ_ALLOCATED, &cq);
 	if (err)
@@ -3362,7 +3362,7 @@ int mlx4_SW2HW_SRQ_wrapper(struct mlx4_dev *dev, int slave,
 	int err;
 	int srqn = vhcr->in_modifier;
 	struct res_mtt *mtt;
-	struct res_srq *srq;
+	struct res_srq *srq = NULL;
 	struct mlx4_srq_context *srqc = inbox->buf;
 	int mtt_base = srq_get_mtt_addr(srqc) / dev->caps.mtt_entry_sz;
 
@@ -3406,7 +3406,7 @@ int mlx4_HW2SW_SRQ_wrapper(struct mlx4_dev *dev, int slave,
 {
 	int err;
 	int srqn = vhcr->in_modifier;
-	struct res_srq *srq;
+	struct res_srq *srq = NULL;
 
 	err = srq_res_start_move_to(dev, slave, srqn, RES_SRQ_ALLOCATED, &srq);
 	if (err)
