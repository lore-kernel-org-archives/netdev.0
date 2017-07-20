From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/2] net: mvneta: remove bogus use of
Date: Thu, 20 Jul 2017 11:02:22 -0500
Message-ID: <CAL_JsqKTwju4=J=X1kvk=77fE1VddPh2N-wCi3A0mCAu+Qg1mA@mail.gmail.com>
References: <20170720142711.12847-1-robh@kernel.org> <8760en5es2.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        Marcin Wojtas <mw@semihalf.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:60260 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934477AbdGTQCp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Jul 2017 12:02:45 -0400
In-Reply-To: <8760en5es2.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 20, 2017 at 10:06 AM, Gregory CLEMENT
<gregory.clement@free-electrons.com> wrote:
> Hi Rob,
>
>  On jeu., juil. 20 2017, Rob Herring <robh@kernel.org> wrote:
>
> (Adding Marcin in CC who wrote this part of code)
>
>> Nothing sets ever sets data, so it is always NULL. Remove it as this is
>> the only user of data ptr in the whole kernel, and it is going to be
>> removed from struct device_node.
>
> Actually the use of device_node.data ptr is not bogus and it is set in
> mvneta_bm_probe:
> http://elixir.free-electrons.com/linux/latest/source/drivers/net/ethernet/marvell/mvneta_bm.c#L433

Indeed. Looks like some complicated kconfig logic, so I'd not been
able to trigger a build failure nor did 0-day (so far).

> Your patch will break the BM support on this driver. So if you need to
> remove this data ptr, then you have to offer an alternative for it.

How about something like this (WS damaged) patch:

diff --git a/drivers/net/ethernet/marvell/mvneta.c
b/drivers/net/ethernet/marvell/mvneta.c
index 0aab74c2a209..3a3021cb93a7 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -4296,11 +4296,12 @@ static int mvneta_probe(struct platform_device *pdev)

  /* Obtain access to BM resources if enabled and already initialized */
  bm_node = of_parse_phandle(dn, "buffer-manager", 0);
- if (bm_node && bm_node->data) {
- pp->bm_priv = bm_node->data;
+ if (bm_node) {
+ pp->bm_priv = mvneta_bm_get();
  err = mvneta_bm_port_init(pdev, pp);
  if (err < 0) {
  dev_info(&pdev->dev, "use SW buffer management\n");
+ mvneta_bm_put(pp->bm_priv);
  pp->bm_priv = NULL;
  }
  }
@@ -4370,6 +4371,7 @@ static int mvneta_probe(struct platform_device *pdev)
  mvneta_bm_pool_destroy(pp->bm_priv, pp->pool_long, 1 << pp->id);
  mvneta_bm_pool_destroy(pp->bm_priv, pp->pool_short,
        1 << pp->id);
+ mvneta_bm_put(pp->bm_priv);
  }
 err_free_stats:
  free_percpu(pp->stats);
@@ -4411,6 +4413,7 @@ static int mvneta_remove(struct platform_device *pdev)
  mvneta_bm_pool_destroy(pp->bm_priv, pp->pool_long, 1 << pp->id);
  mvneta_bm_pool_destroy(pp->bm_priv, pp->pool_short,
        1 << pp->id);
+ mvneta_bm_put(pp->bm_priv);
  }

  return 0;
diff --git a/drivers/net/ethernet/marvell/mvneta_bm.c
b/drivers/net/ethernet/marvell/mvneta_bm.c
index 466939f8f0cf..276af8aff3c7 100644
--- a/drivers/net/ethernet/marvell/mvneta_bm.c
+++ b/drivers/net/ethernet/marvell/mvneta_bm.c
@@ -392,6 +392,17 @@ static void mvneta_bm_put_sram(struct mvneta_bm *priv)
       MVNETA_BM_BPPI_SIZE);
 }

+struct mvneta_bm *mvneta_bm_get(struct device_node *node)
+{
+ struct platform_device *pdev = of_find_device_by_node(node);
+ return pdev ? platform_get_drvdata(pdev) : NULL;
+}
+
+void mvneta_bm_put(struct mvneta_bm *priv)
+{
+ platform_device_put(priv->pdev);
+}
+
 static int mvneta_bm_probe(struct platform_device *pdev)
 {
  struct device_node *dn = pdev->dev.of_node;
diff --git a/drivers/net/ethernet/marvell/mvneta_bm.h
b/drivers/net/ethernet/marvell/mvneta_bm.h
index a32de432800c..50b27feab666 100644
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
 void mvneta_bm_bufs_free(struct mvneta_bm *priv, struct
mvneta_bm_pool *bm_pool,
@@ -160,6 +163,12 @@ static inline u32 mvneta_bm_pool_get_bp(struct
mvneta_bm *priv,
      (bm_pool->id << MVNETA_BM_POOL_ACCESS_OFFS));
 }
 #else
+static inline struct mvneta_bm *mvneta_bm_get(struct device_node *node)
+{
+ return NULL;
+}
+static inline void mvneta_bm_put(struct mvneta_bm *priv) {}
+
 void mvneta_bm_pool_destroy(struct mvneta_bm *priv,
     struct mvneta_bm_pool *bm_pool, u8 port_map) {}
 void mvneta_bm_bufs_free(struct mvneta_bm *priv, struct
mvneta_bm_pool *bm_pool,
