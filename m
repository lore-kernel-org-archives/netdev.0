From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] qlcnic: fix a timeout loop
Date: Tue, 15 Dec 2015 16:56:16 +0300
Message-ID: <20151215135616.GA18851@mwanda>
References: <BLUPR11MB0114ED16EBE57CC01FD9797393EE0@BLUPR11MB0114.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Dept-GELinuxNICDev@qlogic.com,
	Manish Chopra <manish.chopra@qlogic.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BLUPR11MB0114ED16EBE57CC01FD9797393EE0@BLUPR11MB0114.namprd11.prod.outlook.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The problem here is that at the end of the loop we test for if
idc->vnic_wait_limit is zero, but since idc->vnic_wait_limit-- is a
post-op, it actually ends up set to (u8)-1.  I have fixed this by
moving the decrement inside the loop.

Fixes: 486a5bc77a4a ('qlcnic: Add support for 83xx suspend and resume.')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: different color on the bikeshed

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
index be7d7a6..b1a452f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
@@ -246,7 +246,8 @@ int qlcnic_83xx_check_vnic_state(struct qlcnic_adapter *adapter)
 	u32 state;
 
 	state = QLCRDX(ahw, QLC_83XX_VNIC_STATE);
-	while (state != QLCNIC_DEV_NPAR_OPER && idc->vnic_wait_limit--) {
+	while (state != QLCNIC_DEV_NPAR_OPER && idc->vnic_wait_limit) {
+		idc->vnic_wait_limit--;
 		msleep(1000);
 		state = QLCRDX(ahw, QLC_83XX_VNIC_STATE);
 	}
