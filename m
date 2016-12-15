From: Mark Brown <broonie@kernel.org>
Subject: Applied "misc: atmel-ssc: register as sound DAI if #sound-dai-cells is present" to the asoc tree
Date: Thu, 15 Dec 2016 12:20:56 +0000
Message-ID: <E1cHV1s-0000cB-9B@debutante>
References: <1480593549-6464-2-git-send-email-peda@axentia.se>
Cc: Rob Herring <robh@kernel.org>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Mark Brown <broonie@kernel.org>, linux-kernel@vger.kernel.org,
        Mark Rutland <mark.rutland@arm.com>,
        devicetree@vger.kernel.org, alsa-devel@alsa-project.org,
        Arnd Bergmann <arnd@arndb.de>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Takashi Iwai <tiwai@suse.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Liam Girdwood <lgirdwood@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Brown <broonie@kernel.org>, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Peter Rosin <peda@axentia.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480593549-6464-2-git-send-email-peda@axentia.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch

   misc: atmel-ssc: register as sound DAI if #sound-dai-cells is present

has been applied to the asoc tree at

   git://git.kernel.org/pub/scm/linux/kernel/git/broonie/sound.git 

All being well this means that it will be integrated into the linux-next
tree (usually sometime in the next 24 hours) and sent to Linus during
the next merge window (or sooner if it is a bug fix), however if
problems are discovered then the patch may be dropped or reverted.  

You may get further e-mails resulting from automated or manual testing
and review of the tree, please engage with people reporting problems and
send followup patches addressing any issues that are reported if needed.

If any updates are required or you are submitting further changes they
should be sent as incremental updates against current git, existing
patches will not be replaced.

Please add any relevant lists and maintainers to the CCs when replying
to this mail.

Thanks,
Mark

>From e8314d7d53c8b050aac2828a5de5f28a997b468b Mon Sep 17 00:00:00 2001
From: Peter Rosin <peda@axentia.se>
Date: Tue, 6 Dec 2016 20:22:36 +0100
Subject: [PATCH] misc: atmel-ssc: register as sound DAI if #sound-dai-cells is
 present

The SSC is currently not usable with the ASoC simple-audio-card, as
every SSC audio user has to build a platform driver that may do as
little as calling atmel_ssc_set_audio/atmel_ssc_put_audio (which
allocates the SSC and registers a DAI with the ASoC subsystem).

So, have that happen automatically, if the #sound-dai-cells property
is present in devicetree, which it has to be anyway for simple audio
card to work.

Signed-off-by: Peter Rosin <peda@axentia.se>
Acked-by: Rob Herring <robh@kernel.org>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Signed-off-by: Mark Brown <broonie@kernel.org>
---
 .../devicetree/bindings/misc/atmel-ssc.txt         |  2 +
 drivers/misc/atmel-ssc.c                           | 50 ++++++++++++++++++++++
 include/linux/atmel-ssc.h                          |  1 +
 3 files changed, 53 insertions(+)

diff --git a/Documentation/devicetree/bindings/misc/atmel-ssc.txt b/Documentation/devicetree/bindings/misc/atmel-ssc.txt
index efc98ea1f23d..f8629bb73945 100644
--- a/Documentation/devicetree/bindings/misc/atmel-ssc.txt
+++ b/Documentation/devicetree/bindings/misc/atmel-ssc.txt
@@ -24,6 +24,8 @@ Optional properties:
        this parameter to choose where the clock from.
      - By default the clock is from TK pin, if the clock from RK pin, this
        property is needed.
+  - #sound-dai-cells: Should contain <0>.
+     - This property makes the SSC into an automatically registered DAI.
 
 Examples:
 - PDC transfer:
diff --git a/drivers/misc/atmel-ssc.c b/drivers/misc/atmel-ssc.c
index 0516ecda54d3..b2a0340f277e 100644
--- a/drivers/misc/atmel-ssc.c
+++ b/drivers/misc/atmel-ssc.c
@@ -20,6 +20,8 @@
 
 #include <linux/of.h>
 
+#include "../../sound/soc/atmel/atmel_ssc_dai.h"
+
 /* Serialize access to ssc_list and user count */
 static DEFINE_SPINLOCK(user_lock);
 static LIST_HEAD(ssc_list);
@@ -145,6 +147,49 @@ static inline const struct atmel_ssc_platform_data * __init
 		platform_get_device_id(pdev)->driver_data;
 }
 
+#ifdef CONFIG_SND_ATMEL_SOC_SSC
+static int ssc_sound_dai_probe(struct ssc_device *ssc)
+{
+	struct device_node *np = ssc->pdev->dev.of_node;
+	int ret;
+	int id;
+
+	ssc->sound_dai = false;
+
+	if (!of_property_read_bool(np, "#sound-dai-cells"))
+		return 0;
+
+	id = of_alias_get_id(np, "ssc");
+	if (id < 0)
+		return id;
+
+	ret = atmel_ssc_set_audio(id);
+	ssc->sound_dai = !ret;
+
+	return ret;
+}
+
+static void ssc_sound_dai_remove(struct ssc_device *ssc)
+{
+	if (!ssc->sound_dai)
+		return;
+
+	atmel_ssc_put_audio(of_alias_get_id(ssc->pdev->dev.of_node, "ssc"));
+}
+#else
+static inline int ssc_sound_dai_probe(struct ssc_device *ssc)
+{
+	if (of_property_read_bool(ssc->pdev->dev.of_node, "#sound-dai-cells"))
+		return -ENOTSUPP;
+
+	return 0;
+}
+
+static inline void ssc_sound_dai_remove(struct ssc_device *ssc)
+{
+}
+#endif
+
 static int ssc_probe(struct platform_device *pdev)
 {
 	struct resource *regs;
@@ -204,6 +249,9 @@ static int ssc_probe(struct platform_device *pdev)
 	dev_info(&pdev->dev, "Atmel SSC device at 0x%p (irq %d)\n",
 			ssc->regs, ssc->irq);
 
+	if (ssc_sound_dai_probe(ssc))
+		dev_err(&pdev->dev, "failed to auto-setup ssc for audio\n");
+
 	return 0;
 }
 
@@ -211,6 +259,8 @@ static int ssc_remove(struct platform_device *pdev)
 {
 	struct ssc_device *ssc = platform_get_drvdata(pdev);
 
+	ssc_sound_dai_remove(ssc);
+
 	spin_lock(&user_lock);
 	list_del(&ssc->list);
 	spin_unlock(&user_lock);
diff --git a/include/linux/atmel-ssc.h b/include/linux/atmel-ssc.h
index 7c0f6549898b..fdb545101ede 100644
--- a/include/linux/atmel-ssc.h
+++ b/include/linux/atmel-ssc.h
@@ -20,6 +20,7 @@ struct ssc_device {
 	int			user;
 	int			irq;
 	bool			clk_from_rk_pin;
+	bool			sound_dai;
 };
 
 struct ssc_device * __must_check ssc_request(unsigned int ssc_num);
-- 
2.11.0
