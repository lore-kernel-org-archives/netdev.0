From: Peter Rosin <peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>
Subject: [PATCH 1/2] misc: atmel-ssc: register as sound DAI if #sound-dai-cells is present
Date: Thu, 1 Dec 2016 12:59:08 +0100
Message-ID: <1480593549-6464-2-git-send-email-peda@axentia.se>
References: <1480593549-6464-1-git-send-email-peda@axentia.se>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Rosin <peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Liam Girdwood <lgirdwood-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>,
        Takashi Iwai <tiwai-IBi9RG/b67k@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org>,
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1480593549-6464-1-git-send-email-peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The SSC is currently not usable with the ASoC simple-audio-card, as
every SSC audio user has to build a platform driver that may do as
little as calling atmel_ssc_set_audio/atmel_ssc_put_audio (which
allocates the SSC and registers a DAI with the ASoC subsystem).

So, have that happen automatically, if the #sound-dai-cells property
is present in devicetree, which it has to be anyway for simple audio
card to work.

Signed-off-by: Peter Rosin <peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>
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
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
