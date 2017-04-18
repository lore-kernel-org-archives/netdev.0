From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] net/mlx4: suppress 'may be used uninitialized' warning
Date: Mon, 17 Apr 2017 23:21:35 -0700
Message-ID: <20170418062135.76698-1-gthelen@google.com>
Cc: Ido Shamay <idos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

gcc 4.8.4 complains that mlx4_SW2HW_MPT_wrapper() uses an uninitialized
'mpt' variable:
  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function 'mlx4_SW2HW_MPT_wrapper':
  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2802:12: warning: 'mpt' may be used uninitialized in this function [-Wmaybe-uninitialized]
     mpt->mtt = mtt;

I think this warning is a false complaint.  mpt is only used when
mr_res_start_move_to() return zero, and in all such cases it initializes
mpt.  But apparently gcc cannot see that.

Initialize mpt to avoid the warning.

Signed-off-by: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index d8d5d161b8c7..4aa29ee93013 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2749,7 +2749,7 @@ int mlx4_SW2HW_MPT_wrapper(struct mlx4_dev *dev, int slave,
 	int err;
 	int index = vhcr->in_modifier;
 	struct res_mtt *mtt;
-	struct res_mpt *mpt;
+	struct res_mpt *mpt = NULL;
 	int mtt_base = mr_get_mtt_addr(inbox->buf) / dev->caps.mtt_entry_sz;
 	int phys;
 	int id;
-- 
2.12.2.762.g0e3151a226-goog

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
