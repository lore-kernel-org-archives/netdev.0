From: Arnd Bergmann <arnd@arndb.de>
Subject: [RESEND PATCH 1/3] net: hns: fix uninitialized data use
Date: Fri, 24 Mar 2017 23:02:49 +0100
Message-ID: <20170324220250.2193128-3-arnd@arndb.de>
References: <20170324220250.2193128-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Lijun Ou <oulijun@huawei.com>,
        "Wei Hu(Xavier)" <xavier.huwei@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>,
        Kejian Yan <yankejian@huawei.com>,
        Qianqian Xie <xieqianqian@huawei.com>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:54782 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753140AbdCXWDi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 18:03:38 -0400
In-Reply-To: <20170324220250.2193128-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When dev_dbg() is enabled, we print uninitialized data, as gcc-7.0.1
now points out:

ethernet/hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_set_promisc_tcam':
ethernet/hisilicon/hns/hns_dsaf_main.c:2947:75: error: 'tbl_tcam_data.low.val' may be used uninitialized in this function [-Werror=maybe-uninitialized]
ethernet/hisilicon/hns/hns_dsaf_main.c:2947:75: error: 'tbl_tcam_data.high.val' may be used uninitialized in this function [-Werror=maybe-uninitialized]

We also pass the data into hns_dsaf_tcam_mc_cfg(), which might later
use it (not sure about that), so it seems safer to just always initialize
the tbl_tcam_data structure.

Fixes: 1f5fa2dd1cfa ("net: hns: fix for promisc mode in HNS driver")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 90dbda792614..cd93657abe87 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -2924,10 +2924,11 @@ void hns_dsaf_set_promisc_tcam(struct dsaf_device *dsaf_dev,
 	/* find the tcam entry index for promisc */
 	entry_index = dsaf_promisc_tcam_entry(port);
 
+	memset(&tbl_tcam_data, 0, sizeof(tbl_tcam_data));
+	memset(&tbl_tcam_mask, 0, sizeof(tbl_tcam_mask));
+
 	/* config key mask */
 	if (enable) {
-		memset(&tbl_tcam_data, 0, sizeof(tbl_tcam_data));
-		memset(&tbl_tcam_mask, 0, sizeof(tbl_tcam_mask));
 		dsaf_set_field(tbl_tcam_data.low.bits.port_vlan,
 			       DSAF_TBL_TCAM_KEY_PORT_M,
 			       DSAF_TBL_TCAM_KEY_PORT_S, port);
-- 
2.9.0
