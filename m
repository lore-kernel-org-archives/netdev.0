From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net-next] hns_enet: use cpumask_var_t for on-stack mask
Date: Thu,  2 Feb 2017 15:49:24 +0100
Message-ID: <20170202145017.3761604-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        Kejian Yan <yankejian@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>,
        Qianqian Xie <xieqianqian@huawei.com>,
        Sheng Li <lisheng011@huawei.com>,
        lipeng <lipeng321@huawei.com>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On large SMP builds, we can run into a build warning:

drivers/net/ethernet/hisilicon/hns/hns_enet.c: In function 'hns_set_irq_affinity.isra.27':
drivers/net/ethernet/hisilicon/hns/hns_enet.c:1242:1: warning: the frame size of 1032 bytes is larger than 1024 bytes [-Wframe-larger-than=]

The solution here is to use cpumask_var_t, which can use dynamic
allocation when CONFIG_CPUMASK_OFFSTACK is enabled.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index f7b75e96c1c3..fefe371e5907 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1202,43 +1202,48 @@ static void hns_set_irq_affinity(struct hns_nic_priv *priv)
 	struct hns_nic_ring_data *rd;
 	int i;
 	int cpu;
-	cpumask_t mask;
+	cpumask_var_t mask;
+
+	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
+		return;
 
 	/*diffrent irq banlance for 16core and 32core*/
 	if (h->q_num == num_possible_cpus()) {
 		for (i = 0; i < h->q_num * 2; i++) {
 			rd = &priv->ring_data[i];
 			if (cpu_online(rd->queue_index)) {
-				cpumask_clear(&mask);
+				cpumask_clear(mask);
 				cpu = rd->queue_index;
-				cpumask_set_cpu(cpu, &mask);
+				cpumask_set_cpu(cpu, mask);
 				(void)irq_set_affinity_hint(rd->ring->irq,
-							    &mask);
+							    mask);
 			}
 		}
 	} else {
 		for (i = 0; i < h->q_num; i++) {
 			rd = &priv->ring_data[i];
 			if (cpu_online(rd->queue_index * 2)) {
-				cpumask_clear(&mask);
+				cpumask_clear(mask);
 				cpu = rd->queue_index * 2;
-				cpumask_set_cpu(cpu, &mask);
+				cpumask_set_cpu(cpu, mask);
 				(void)irq_set_affinity_hint(rd->ring->irq,
-							    &mask);
+							    mask);
 			}
 		}
 
 		for (i = h->q_num; i < h->q_num * 2; i++) {
 			rd = &priv->ring_data[i];
 			if (cpu_online(rd->queue_index * 2 + 1)) {
-				cpumask_clear(&mask);
+				cpumask_clear(mask);
 				cpu = rd->queue_index * 2 + 1;
-				cpumask_set_cpu(cpu, &mask);
+				cpumask_set_cpu(cpu, mask);
 				(void)irq_set_affinity_hint(rd->ring->irq,
-							    &mask);
+							    mask);
 			}
 		}
 	}
+
+	free_cpumask_var(mask);
 }
 
 static int hns_nic_init_irq(struct hns_nic_priv *priv)
-- 
2.9.0
