From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net] net: dsa: mv88e6xxx: lock mutex when freeing IRQs
Date: Tue, 26 Sep 2017 13:48:37 -0400
Message-ID: <20170926174837.15999-1-vivien.didelot@savoirfairelinux.com>
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
index c6678aa9b4ef..b4359e4e5165 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -338,9 +338,11 @@ static void mv88e6xxx_g1_irq_free(struct mv88e6xxx_chip *chip)
 	int irq, virq;
 	u16 mask;
 
+	mutex_lock(&chip->reg_lock);
 	mv88e6xxx_g1_read(chip, MV88E6XXX_G1_CTL1, &mask);
 	mask |= GENMASK(chip->g1_irq.nirqs, 0);
 	mv88e6xxx_g1_write(chip, MV88E6XXX_G1_CTL1, mask);
+	mutex_unlock(&chip->reg_lock);
 
 	free_irq(chip->irq, chip);
 
-- 
2.14.1
