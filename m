From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/3] net: hns: avoid gcc-7.0.1 warning for uninitialized data
Date: Thu, 23 Mar 2017 15:55:50 +0100
Message-ID: <20170323145610.54695-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Daode Huang <huangdaode@hisilicon.com>,
        Qianqian Xie <xieqianqian@huawei.com>,
        Kejian Yan <yankejian@huawei.com>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        oulijun <oulijun@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hns_dsaf_set_mac_key() calls dsaf_set_field() on an uninitialized field,
which will then change only a few of its bits, causing a warning with
the latest gcc:

hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_set_mac_uc_entry':
hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
   (origin) &= (~(mask)); \
            ^~
hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_set_mac_mc_entry':
hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_add_mac_mc_port':
hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_del_mac_entry':
hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_rm_mac_addr':
hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_del_mac_mc_port':
hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_get_mac_uc_entry':
hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_get_mac_mc_entry':
hisilicon/hns/hns_dsaf_reg.h:1046:12: error: 'mac_key.low.bits.port_vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]

The code is actually correct since we always set all 16 bits of the
port_vlan field, but gcc correctly points out that the first
access does contain uninitialized data.

This initializes the field to zero first before setting the
individual bits.

Fixes: 5483bfcb169c ("net: hns: modify tcam table and set mac key")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 90dbda792614..1ec6d4bb6044 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -1519,6 +1519,7 @@ static void hns_dsaf_set_mac_key(
 	mac_key->high.bits.mac_3 = addr[3];
 	mac_key->low.bits.mac_4 = addr[4];
 	mac_key->low.bits.mac_5 = addr[5];
+	mac_key->low.bits.port_vlan = 0;
 	dsaf_set_field(mac_key->low.bits.port_vlan, DSAF_TBL_TCAM_KEY_VLAN_M,
 		       DSAF_TBL_TCAM_KEY_VLAN_S, vlan_id);
 	dsaf_set_field(mac_key->low.bits.port_vlan, DSAF_TBL_TCAM_KEY_PORT_M,
-- 
2.9.0
