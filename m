From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH 1/2] net: phy: leds: Clear phy_num_led_triggers on failure to avoid crash
Date: Tue, 24 Jan 2017 16:41:09 +0100
Message-ID: <1485272470-3497-2-git-send-email-geert+renesas@glider.be>
References: <1485272470-3497-1-git-send-email-geert+renesas@glider.be>
Cc: Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?q?Magnus=20=C3=96berg?= <magnus.oberg@westermo.se>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>,
        Zach Brown <zach.brown@ni.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1485272470-3497-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

phy_attach_direct() ignores errors returned by
phy_led_triggers_register(). I think that's OK, as LED triggers can be
considered a non-critical feature.

However, this causes problems later:
  - phy_led_trigger_change_speed() will access the array
    phy_device.phy_led_triggers, which has been freed in the error path
    of phy_led_triggers_register(), which may lead to a crash.

  - phy_led_triggers_unregister() will access the same array, leading to
    crashes during s2ram or poweroff, like:

	Unable to handle kernel NULL pointer dereference at virtual address
	00000000
	...
	[<c04116d4>] (__list_del_entry_valid) from [<c05e8948>] (led_trigger_unregister+0x34/0xcc)
	[<c05e8948>] (led_trigger_unregister) from [<c05336c4>] (phy_led_triggers_unregister+0x28/0x34)
	[<c05336c4>] (phy_led_triggers_unregister) from [<c0531d44>] (phy_detach+0x30/0x74)
	[<c0531d44>] (phy_detach) from [<c0538bdc>] (sh_eth_close+0x64/0x9c)
	[<c0538bdc>] (sh_eth_close) from [<c04d4ce0>] (dpm_run_callback+0x48/0xc8)

    or:

	list_del corruption. prev->next should be dede6540, but was 2e323931
	------------[ cut here ]------------
	kernel BUG at lib/list_debug.c:52!
	...
	[<c02f6d70>] (__list_del_entry_valid) from [<c0425168>] (led_trigger_unregister+0x34/0xcc)
	[<c0425168>] (led_trigger_unregister) from [<c03a05a0>] (phy_led_triggers_unregister+0x28/0x34)
	[<c03a05a0>] (phy_led_triggers_unregister) from [<c039ec04>] (phy_detach+0x30/0x74)
	[<c039ec04>] (phy_detach) from [<c03a4fc0>] (sh_eth_close+0x6c/0xa4)
	[<c03a4fc0>] (sh_eth_close) from [<c0483234>] (__dev_close_many+0xac/0xd0)

To fix this, clear phy_device.phy_num_led_triggers in the error path of
phy_led_triggers_register() fails.

Note that the "No phy led trigger registered for speed" message will
still be printed on link speed changes, which is a good cue that
something went wrong with the LED triggers.

Fixes: 2e0bc452f4721520 ("net: phy: leds: add support for led triggers on phy link state change")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
Alternatively, phy_attach_direct() could consider
phy_led_triggers_register() failures as fatal, so
phy_led_trigger_change_speed() and phy_led_triggers_unregister() are
never called afterwards.

Exposed by commit 4567d686f5c6d955 ("phy: increase size of
MII_BUS_ID_SIZE and bus_id"), which caused duplicate trigger names.
---
 drivers/net/phy/phy_led_triggers.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy_led_triggers.c b/drivers/net/phy/phy_led_triggers.c
index fa62bdf2f52694de..3f619e7371e97d8a 100644
--- a/drivers/net/phy/phy_led_triggers.c
+++ b/drivers/net/phy/phy_led_triggers.c
@@ -102,8 +102,10 @@ int phy_led_triggers_register(struct phy_device *phy)
 					    sizeof(struct phy_led_trigger) *
 						   phy->phy_num_led_triggers,
 					    GFP_KERNEL);
-	if (!phy->phy_led_triggers)
-		return -ENOMEM;
+	if (!phy->phy_led_triggers) {
+		err = -ENOMEM;
+		goto out_clear;
+	}
 
 	for (i = 0; i < phy->phy_num_led_triggers; i++) {
 		err = phy_led_trigger_register(phy, &phy->phy_led_triggers[i],
@@ -120,6 +122,8 @@ int phy_led_triggers_register(struct phy_device *phy)
 	while (i--)
 		phy_led_trigger_unregister(&phy->phy_led_triggers[i]);
 	devm_kfree(&phy->mdio.dev, phy->phy_led_triggers);
+out_clear:
+	phy->phy_num_led_triggers = 0;
 	return err;
 }
 EXPORT_SYMBOL_GPL(phy_led_triggers_register);
-- 
1.9.1
