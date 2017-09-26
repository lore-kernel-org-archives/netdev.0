From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net v2] net: dsa: mv88e6xxx: lock mutex when freeing IRQs
Date: Tue, 26 Sep 2017 14:57:21 -0400
Message-ID: <20170926185721.12187-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mv88e6xxx_g2_irq_free locks the registers mutex, but not
mv88e6xxx_g1_irq_free, which results in a stack trace from
assert_reg_lock when unloading the mv88e6xxx module. Fix this.

Fixes: 3460a5770ce9 ("net: dsa: mv88e6xxx: Mask g1 interrupts and free interrupt")
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c6678aa9b4ef..e7ff7483d2fb 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3947,7 +3947,9 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 	if (chip->irq > 0) {
 		if (chip->info->g2_irqs > 0)
 			mv88e6xxx_g2_irq_free(chip);
+		mutex_lock(&chip->reg_lock);
 		mv88e6xxx_g1_irq_free(chip);
+		mutex_unlock(&chip->reg_lock);
 	}
 }
 
-- 
2.14.1
