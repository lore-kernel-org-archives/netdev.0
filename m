From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 15/19] net: hns: bug fix about led control logic when
 link down
Date: Tue, 21 Jun 2016 11:56:35 +0800
Message-ID: <1466481399-70080-16-git-send-email-Yisen.Zhuang@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, andrew@lunn.ch, fengguang.wu@intel.com,
 liguozhu@huawei.com, arnd@arndb.de, charles.chenxin@huawei.com,
 linux-kernel@vger.kernel.org, linuxarm@huawei.com, geliangtang@163.com,
 huangdaode@hisilicon.com, netdev@vger.kernel.org,
 andriy.shevchenko@linux.intel.com, linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
 <yankejian@huawei.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

The default driver sets anchor led bit to 0 when link down,
actually, the anchor bit should be set to 1, so fixes it when
link status is down.
Secondly, change the return value of cpld_set_led_id to 0, which
means leave the cpld to control led blink frequece other than the
driver itself.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index aff9d77..8473287 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -86,9 +86,10 @@ static void hns_cpld_set_led(struct hns_mac_cb *mac_cb, int link_status,
 			mac_cb->cpld_led_value = value;
 		}
 	} else {
-		dsaf_write_syscon(mac_cb->cpld_ctrl, mac_cb->cpld_ctrl_reg,
-				  CPLD_LED_DEFAULT_VALUE);
-		mac_cb->cpld_led_value = CPLD_LED_DEFAULT_VALUE;
+		value = (mac_cb->cpld_led_value) & (0x1 << DSAF_LED_ANCHOR_B);
+		dsaf_write_syscon(mac_cb->cpld_ctrl,
+				  mac_cb->cpld_ctrl_reg, value);
+		mac_cb->cpld_led_value = value;
 	}
 }
 
@@ -114,7 +115,7 @@ static int cpld_set_led_id(struct hns_mac_cb *mac_cb,
 			     CPLD_LED_ON_VALUE);
 		dsaf_write_syscon(mac_cb->cpld_ctrl, mac_cb->cpld_ctrl_reg,
 				  mac_cb->cpld_led_value);
-		return 2;
+		break;
 	case HNAE_LED_INACTIVE:
 		dsaf_set_bit(mac_cb->cpld_led_value, DSAF_LED_ANCHOR_B,
 			     CPLD_LED_DEFAULT_VALUE);
@@ -122,7 +123,8 @@ static int cpld_set_led_id(struct hns_mac_cb *mac_cb,
 				  mac_cb->cpld_led_value);
 		break;
 	default:
-		break;
+		dev_err(mac_cb->dev, "invalid led state: %d!", status);
+		return -EINVAL;
 	}
 
 	return 0;
-- 
1.9.1
