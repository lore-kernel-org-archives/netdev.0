From: Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/2] net: mvneta: remove bogus use of
Date: Fri, 04 Aug 2017 17:26:50 +0200
Message-ID: <87tw1n73r9.fsf@free-electrons.com>
References: <20170720142711.12847-1-robh@kernel.org>
        <8760en5es2.fsf@free-electrons.com>
        <CAL_JsqKTwju4=J=X1kvk=77fE1VddPh2N-wCi3A0mCAu+Qg1mA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree\@vger.kernel.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Marcin Wojtas <mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL_JsqKTwju4=J=X1kvk=77fE1VddPh2N-wCi3A0mCAu+Qg1mA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
        (Rob Herring's message of "Thu, 20 Jul 2017 11:02:22 -0500")
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rob,
 
 On jeu., juil. 20 2017, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:

> On Thu, Jul 20, 2017 at 10:06 AM, Gregory CLEMENT
> <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> wrote:
>> Hi Rob,
>>
>>  On jeu., juil. 20 2017, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>>
>> (Adding Marcin in CC who wrote this part of code)
>>
>>> Nothing sets ever sets data, so it is always NULL. Remove it as this is
>>> the only user of data ptr in the whole kernel, and it is going to be
>>> removed from struct device_node.
>>
>> Actually the use of device_node.data ptr is not bogus and it is set in
>> mvneta_bm_probe:
>> http://elixir.free-electrons.com/linux/latest/source/drivers/net/ethernet/marvell/mvneta_bm.c#L433
>
> Indeed. Looks like some complicated kconfig logic, so I'd not been
> able to trigger a build failure nor did 0-day (so far).
>
>> Your patch will break the BM support on this driver. So if you need to
>> remove this data ptr, then you have to offer an alternative for it.
>
> How about something like this (WS damaged) patch:

I finally took time to test your patch. There was some missing part
which prevented it to be build, like including linux/of_platform.h, or
providing tub function when CONFIG_MVNETA_BM was not enable.

Also the fact that you still call mvneta_bm_port_init() even if bm_priv
was NULL was not really nice. So I proposed the following patch, that I
tested on a clearfog with and without CONFIG_MVNETA_BM enabled.

>From 03c4028bc1f52d3d214e8506d9f0f66660d3985d Mon Sep 17 00:00:00 2001
From: Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Date: Fri, 4 Aug 2017 17:18:38 +0200
Subject: [PATCH] net: mvneta: remove data pointer usage from device_node
 structure

In order to be able to remove the data pointer from the device_node
structure. We have to modify the way the BM resources are shared between
the mvneta port.

Signed-off-by: Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
---
 drivers/net/ethernet/marvell/mvneta.c    | 18 ++++++++++++------
 drivers/net/ethernet/marvell/mvneta_bm.c | 13 +++++++++++++
 drivers/net/ethernet/marvell/mvneta_bm.h |  8 ++++++--
 3 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 63b6147753fe..fd84447582f7 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -4295,12 +4295,16 @@ static int mvneta_probe(struct platform_device *pdev)
 
        /* Obtain access to BM resources if enabled and already initialized */
        bm_node = of_parse_phandle(dn, "buffer-manager", 0);
-       if (bm_node && bm_node->data) {
-               pp->bm_priv = bm_node->data;
-               err = mvneta_bm_port_init(pdev, pp);
-               if (err < 0) {
-                       dev_info(&pdev->dev, "use SW buffer management\n");
-                       pp->bm_priv = NULL;
+       if (bm_node) {
+               pp->bm_priv = mvneta_bm_get(bm_node);
+               if (pp->bm_priv) {
+                       err = mvneta_bm_port_init(pdev, pp);
+                       if (err < 0) {
+                               dev_info(&pdev->dev,
+                                        "use SW buffer management\n");
+                               mvneta_bm_put(pp->bm_priv);
+                               pp->bm_priv = NULL;
+                       }
                }
        }
        of_node_put(bm_node);
@@ -4369,6 +4373,7 @@ static int mvneta_probe(struct platform_device *pdev)
                mvneta_bm_pool_destroy(pp->bm_priv, pp->pool_long, 1 << pp->id);
                mvneta_bm_pool_destroy(pp->bm_priv, pp->pool_short,
                                       1 << pp->id);
+               mvneta_bm_put(pp->bm_priv);
        }
 err_free_stats:
        free_percpu(pp->stats);
@@ -4410,6 +4415,7 @@ static int mvneta_remove(struct platform_device *pdev)
                mvneta_bm_pool_destroy(pp->bm_priv, pp->pool_long, 1 << pp->id);
                mvneta_bm_pool_destroy(pp->bm_priv, pp->pool_short,
                                       1 << pp->id);
+               mvneta_bm_put(pp->bm_priv);
        }
 
        return 0;
diff --git a/drivers/net/ethernet/marvell/mvneta_bm.c b/drivers/net/ethernet/marvell/mvneta_bm.c
index 466939f8f0cf..01e3152e76c8 100644
--- a/drivers/net/ethernet/marvell/mvneta_bm.c
+++ b/drivers/net/ethernet/marvell/mvneta_bm.c
@@ -18,6 +18,7 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/of.h>
+#include <linux/of_platform.h>
 #include <linux/platform_device.h>
 #include <linux/skbuff.h>
 #include <net/hwbm.h>
@@ -392,6 +393,18 @@ static void mvneta_bm_put_sram(struct mvneta_bm *priv)
                      MVNETA_BM_BPPI_SIZE);
 }
 
+struct mvneta_bm *mvneta_bm_get(struct device_node *node)
+{
+       struct platform_device *pdev = of_find_device_by_node(node);
+
+       return pdev ? platform_get_drvdata(pdev) : NULL;
+}
+
+void mvneta_bm_put(struct mvneta_bm *priv)
+{
+       platform_device_put(priv->pdev);
+}
+
 static int mvneta_bm_probe(struct platform_device *pdev)
 {
        struct device_node *dn = pdev->dev.of_node;
diff --git a/drivers/net/ethernet/marvell/mvneta_bm.h b/drivers/net/ethernet/marvell/mvneta_bm.h
index a32de432800c..daa9a91d2708 100644
--- a/drivers/net/ethernet/marvell/mvneta_bm.h
+++ b/drivers/net/ethernet/marvell/mvneta_bm.h
@@ -134,6 +134,9 @@ void *mvneta_frag_alloc(unsigned int frag_size);
 void mvneta_frag_free(unsigned int frag_size, void *data);
 
 #if IS_ENABLED(CONFIG_MVNETA_BM)
+struct mvneta_bm *mvneta_bm_get(struct device_node *node);
+void mvneta_bm_put(struct mvneta_bm *priv);
+
 void mvneta_bm_pool_destroy(struct mvneta_bm *priv,
                            struct mvneta_bm_pool *bm_pool, u8 port_map);
 void mvneta_bm_bufs_free(struct mvneta_bm *priv, struct mvneta_bm_pool *bm_pool,
@@ -176,7 +179,8 @@ static inline void mvneta_bm_pool_put_bp(struct mvneta_bm *priv,
                                         dma_addr_t buf_phys_addr) {}
 
 static inline u32 mvneta_bm_pool_get_bp(struct mvneta_bm *priv,
-                                       struct mvneta_bm_pool *bm_pool)
-{ return 0; }
+                               struct mvneta_bm_pool *bm_pool) { return 0; }
+struct mvneta_bm *mvneta_bm_get(struct device_node *node) {return NULL; }
+void mvneta_bm_put(struct mvneta_bm *priv) {}
 #endif /* CONFIG_MVNETA_BM */
 #endif
-- 
2.13.2



>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c
> b/drivers/net/ethernet/marvell/mvneta.c
> index 0aab74c2a209..3a3021cb93a7 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -4296,11 +4296,12 @@ static int mvneta_probe(struct platform_device *pdev)
>
>   /* Obtain access to BM resources if enabled and already initialized */
>   bm_node = of_parse_phandle(dn, "buffer-manager", 0);
> - if (bm_node && bm_node->data) {
> - pp->bm_priv = bm_node->data;
> + if (bm_node) {
> + pp->bm_priv = mvneta_bm_get();
>   err = mvneta_bm_port_init(pdev, pp);
>   if (err < 0) {
>   dev_info(&pdev->dev, "use SW buffer management\n");
> + mvneta_bm_put(pp->bm_priv);
>   pp->bm_priv = NULL;
>   }
>   }
> @@ -4370,6 +4371,7 @@ static int mvneta_probe(struct platform_device *pdev)
>   mvneta_bm_pool_destroy(pp->bm_priv, pp->pool_long, 1 << pp->id);
>   mvneta_bm_pool_destroy(pp->bm_priv, pp->pool_short,
>         1 << pp->id);
> + mvneta_bm_put(pp->bm_priv);
>   }
>  err_free_stats:
>   free_percpu(pp->stats);
> @@ -4411,6 +4413,7 @@ static int mvneta_remove(struct platform_device *pdev)
>   mvneta_bm_pool_destroy(pp->bm_priv, pp->pool_long, 1 << pp->id);
>   mvneta_bm_pool_destroy(pp->bm_priv, pp->pool_short,
>         1 << pp->id);
> + mvneta_bm_put(pp->bm_priv);
>   }
>
>   return 0;
> diff --git a/drivers/net/ethernet/marvell/mvneta_bm.c
> b/drivers/net/ethernet/marvell/mvneta_bm.c
> index 466939f8f0cf..276af8aff3c7 100644
> --- a/drivers/net/ethernet/marvell/mvneta_bm.c
> +++ b/drivers/net/ethernet/marvell/mvneta_bm.c
> @@ -392,6 +392,17 @@ static void mvneta_bm_put_sram(struct mvneta_bm *priv)
>        MVNETA_BM_BPPI_SIZE);
>  }
>
> +struct mvneta_bm *mvneta_bm_get(struct device_node *node)
> +{
> + struct platform_device *pdev = of_find_device_by_node(node);
> + return pdev ? platform_get_drvdata(pdev) : NULL;
> +}
> +
> +void mvneta_bm_put(struct mvneta_bm *priv)
> +{
> + platform_device_put(priv->pdev);
> +}
> +
>  static int mvneta_bm_probe(struct platform_device *pdev)
>  {
>   struct device_node *dn = pdev->dev.of_node;
> diff --git a/drivers/net/ethernet/marvell/mvneta_bm.h
> b/drivers/net/ethernet/marvell/mvneta_bm.h
> index a32de432800c..50b27feab666 100644
> --- a/drivers/net/ethernet/marvell/mvneta_bm.h
> +++ b/drivers/net/ethernet/marvell/mvneta_bm.h
> @@ -134,6 +134,9 @@ void *mvneta_frag_alloc(unsigned int frag_size);
>  void mvneta_frag_free(unsigned int frag_size, void *data);
>
>  #if IS_ENABLED(CONFIG_MVNETA_BM)
> +struct mvneta_bm *mvneta_bm_get(struct device_node *node);
> +void mvneta_bm_put(struct mvneta_bm *priv);
> +
>  void mvneta_bm_pool_destroy(struct mvneta_bm *priv,
>      struct mvneta_bm_pool *bm_pool, u8 port_map);
>  void mvneta_bm_bufs_free(struct mvneta_bm *priv, struct
> mvneta_bm_pool *bm_pool,
> @@ -160,6 +163,12 @@ static inline u32 mvneta_bm_pool_get_bp(struct
> mvneta_bm *priv,
>       (bm_pool->id << MVNETA_BM_POOL_ACCESS_OFFS));
>  }
>  #else
> +static inline struct mvneta_bm *mvneta_bm_get(struct device_node *node)
> +{
> + return NULL;
> +}
> +static inline void mvneta_bm_put(struct mvneta_bm *priv) {}
> +
>  void mvneta_bm_pool_destroy(struct mvneta_bm *priv,
>      struct mvneta_bm_pool *bm_pool, u8 port_map) {}
>  void mvneta_bm_bufs_free(struct mvneta_bm *priv, struct
> mvneta_bm_pool *bm_pool,

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
