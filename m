From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [net-qed] question about potential null pointer dereference
Date: Tue, 30 May 2017 12:42:52 -0500
Message-ID: <20170530124252.Horde.ZtBHOOxQIQFInhiQILVtpD_@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>,
        everest-linux-l2@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello everybody,

While looking into Coverity ID 1362293 I ran into the following piece  
of code at drivers/net/ethernet/qlogic/qed/qed_sriov.c:3863:

3863static int
3864qed_iov_configure_min_tx_rate(struct qed_dev *cdev, int vfid, u32 rate)
3865{
3866        struct qed_vf_info *vf;
3867        u8 vport_id;
3868        int i;
3869
3870        for_each_hwfn(cdev, i) {
3871                struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
3872
3873                if (!qed_iov_pf_sanity_check(p_hwfn, vfid)) {
3874                        DP_NOTICE(p_hwfn,
3875                                  "SR-IOV sanity check failed,  
can't set min rate\n");
3876                        return -EINVAL;
3877                }
3878        }
3879
3880        vf = qed_iov_get_vf_info(QED_LEADING_HWFN(cdev), (u16)vfid, true);
3881        vport_id = vf->vport_id;
3882
3883        return qed_configure_vport_wfq(cdev, vport_id, rate);
3884}

The issue here is that in case function qed_iov_get_vf_info() at line  
3880, returns NULL, a NULL pointer dereference will take place at line  
3881.

Maybe a patch like the following could be applied in order to avoid  
any potential NULL pointer dereference:

index 71e392f..6bf1f0e2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -3878,6 +3878,9 @@ qed_iov_configure_min_tx_rate(struct qed_dev  
*cdev, int vfid, u32 rate)
         }

         vf = qed_iov_get_vf_info(QED_LEADING_HWFN(cdev), (u16)vfid, true);
+       if (!vf)
+               return -EINVAL;
+
         vport_id = vf->vport_id;

         return qed_configure_vport_wfq(cdev, vport_id, rate);


What do you think?

I'd really appreciate any comment on this.

Thank you!
--
Gustavo A. R. Silva
