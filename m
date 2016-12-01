From: Peter Rosin <peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>
Subject: [PATCH 2/2] ASoC: atmel: tse850: rely on the ssc to register as a cpu dai by itself
Date: Thu, 1 Dec 2016 12:59:09 +0100
Message-ID: <1480593549-6464-3-git-send-email-peda@axentia.se>
References: <1480593549-6464-1-git-send-email-peda@axentia.se>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Rosin <peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "Mark Rutland" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Liam Girdwood <lgirdwood-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "Mark Brown" <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
        "Arnd Bergmann" <arnd-r2nGTMty4D4@public.gmane.org>,
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

Signed-off-by: Peter Rosin <peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>
---
 .../bindings/sound/axentia,tse850-pcm5142.txt      |  5 ++---
 sound/soc/atmel/tse850-pcm5142.c                   | 23 +++-------------------
 2 files changed, 5 insertions(+), 23 deletions(-)

diff --git a/Documentation/devicetree/bindings/sound/axentia,tse850-pcm5142.txt b/Documentation/devicetree/bindings/sound/axentia,tse850-pcm5142.txt
index 5b9b38f578bb..fd12ecb35b5c 100644
--- a/Documentation/devicetree/bindings/sound/axentia,tse850-pcm5142.txt
+++ b/Documentation/devicetree/bindings/sound/axentia,tse850-pcm5142.txt
@@ -2,8 +2,7 @@ Devicetree bindings for the Axentia TSE-850 audio complex
 
 Required properties:
   - compatible: "axentia,tse850-pcm5142"
-  - axentia,ssc-controller: The phandle of the atmel SSC controller used as
-    cpu dai.
+  - axentia,cpu-dai: The phandle of the cpu dai.
   - axentia,audio-codec: The phandle of the PCM5142 codec.
   - axentia,add-gpios: gpio specifier that controls the mixer.
   - axentia,loop1-gpios: gpio specifier that controls loop relays on channel 1.
@@ -77,7 +76,7 @@ Example:
 	sound {
 		compatible = "axentia,tse850-pcm5142";
 
-		axentia,ssc-controller = <&ssc0>;
+		axentia,cpu-dai = <&ssc0>;
 		axentia,audio-codec = <&codec>;
 
 		axentia,add-gpios = <&pioA 8 GPIO_ACTIVE_LOW>;
diff --git a/sound/soc/atmel/tse850-pcm5142.c b/sound/soc/atmel/tse850-pcm5142.c
index ac6a814c8ecf..a72c7d642026 100644
--- a/sound/soc/atmel/tse850-pcm5142.c
+++ b/sound/soc/atmel/tse850-pcm5142.c
@@ -51,11 +51,7 @@
 #include <sound/soc.h>
 #include <sound/pcm_params.h>
 
-#include "atmel_ssc_dai.h"
-
 struct tse850_priv {
-	int ssc_id;
-
 	struct gpio_desc *add;
 	struct gpio_desc *loop1;
 	struct gpio_desc *loop2;
@@ -329,23 +325,20 @@ static int tse850_dt_init(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
 	struct device_node *codec_np, *cpu_np;
-	struct snd_soc_card *card = &tse850_card;
 	struct snd_soc_dai_link *dailink = &tse850_dailink;
-	struct tse850_priv *tse850 = snd_soc_card_get_drvdata(card);
 
 	if (!np) {
 		dev_err(&pdev->dev, "only device tree supported\n");
 		return -EINVAL;
 	}
 
-	cpu_np = of_parse_phandle(np, "axentia,ssc-controller", 0);
+	cpu_np = of_parse_phandle(np, "axentia,cpu-dai", 0);
 	if (!cpu_np) {
-		dev_err(&pdev->dev, "failed to get dai and pcm info\n");
+		dev_err(&pdev->dev, "failed to get cpu dai\n");
 		return -EINVAL;
 	}
 	dailink->cpu_of_node = cpu_np;
 	dailink->platform_of_node = cpu_np;
-	tse850->ssc_id = of_alias_get_id(cpu_np, "ssc");
 	of_node_put(cpu_np);
 
 	codec_np = of_parse_phandle(np, "axentia,audio-codec", 0);
@@ -415,23 +408,14 @@ static int tse850_probe(struct platform_device *pdev)
 		return ret;
 	}
 
-	ret = atmel_ssc_set_audio(tse850->ssc_id);
-	if (ret != 0) {
-		dev_err(dev,
-			"failed to set SSC %d for audio\n", tse850->ssc_id);
-		goto err_disable_ana;
-	}
-
 	ret = snd_soc_register_card(card);
 	if (ret) {
 		dev_err(dev, "snd_soc_register_card failed\n");
-		goto err_put_audio;
+		goto err_disable_ana;
 	}
 
 	return 0;
 
-err_put_audio:
-	atmel_ssc_put_audio(tse850->ssc_id);
 err_disable_ana:
 	regulator_disable(tse850->ana);
 	return ret;
@@ -443,7 +427,6 @@ static int tse850_remove(struct platform_device *pdev)
 	struct tse850_priv *tse850 = snd_soc_card_get_drvdata(card);
 
 	snd_soc_unregister_card(card);
-	atmel_ssc_put_audio(tse850->ssc_id);
 	regulator_disable(tse850->ana);
 
 	return 0;
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
