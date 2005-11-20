From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH -mm2] net: Fix compiler-error on dgrs.c when !CONFIG_PCI
Date: Sun, 20 Nov 2005 21:24:14 +1100
Message-ID: <E1EdmMo-00020b-00@gondolin.me.apana.org.au>
References: <20051120014408.20407.66374.sendpatchset@thinktank.campus.ltu.se>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	ricknu-0@student.ltu.se, netdev@vger.kernel.org, jgarzik@pobox.com,
	ashutosh.naik@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751214AbVKTKYq@vger.kernel.org>
To: ricknu-0@student.ltu.se (Richard Knutsson)
In-Reply-To: <20051120014408.20407.66374.sendpatchset@thinktank.campus.ltu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Knutsson <ricknu-0@student.ltu.se> wrote:
> 
> diff -Narup a/drivers/net/dgrs.c b/drivers/net/dgrs.c
> --- a/drivers/net/dgrs.c        2005-11-19 20:17:51.000000000 +0100
> +++ b/drivers/net/dgrs.c        2005-11-19 20:29:52.000000000 +0100
> @@ -1458,6 +1458,8 @@ static struct pci_driver dgrs_pci_driver
>        .probe = dgrs_pci_probe,
>        .remove = __devexit_p(dgrs_pci_remove),
> };
> +#else
> +static struct pci_driver dgrs_pci_driver = {};
> #endif

How about something like this?

[NETDRV] dgrs: Fix compiler-error on dgrs.c when !CONFIG_PCI

The previous patch on this driver removed the #ifdef CONFIG_PCI
around the pci_register_driver call in order to avoid a warning
about an unused variable.  This produces an error since the PCI
driver object is undefined if CONFIG_PCI is not set.

Instead of doing that, we should simply make sure that the
cardcount variable is always used.

The following patch does this by making inline function wrappers
to do the actual registration/deregistration.

This problem was reported by Richard Knutsson.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/dgrs.c b/drivers/net/dgrs.c
--- a/drivers/net/dgrs.c
+++ b/drivers/net/dgrs.c
@@ -1458,6 +1458,25 @@ static struct pci_driver dgrs_pci_driver
 	.probe = dgrs_pci_probe,
 	.remove = __devexit_p(dgrs_pci_remove),
 };
+
+static inline int dgrs_register_pci(void)
+{
+	return pci_register_driver(&dgrs_pci_driver);
+}
+
+static inline void dgrs_unregister_pci(void)
+{
+	pci_unregister_driver(&dgrs_pci_driver);
+}
+#else
+static inline int dgrs_register_pci(void)
+{
+	return 0;
+}
+
+static inline int dgrs_unregister_pci(void)
+{
+}
 #endif
 
 
@@ -1520,6 +1539,25 @@ static struct eisa_driver dgrs_eisa_driv
 		.remove = __devexit_p(dgrs_eisa_remove),
 	}
 };
+
+static inline int dgrs_register_eisa(void)
+{
+	return eisa_driver_register(&dgrs_eisa_driver);
+}
+
+static inline void dgrs_unregister_eisa(void)
+{
+	eisa_driver_unregister(&dgrs_eisa_driver);
+}
+#else
+static inline int dgrs_register_eisa(void)
+{
+	return 0;
+}
+
+static inline void dgrs_unregister_eisa(void)
+{
+}
 #endif
 
 /*
@@ -1590,25 +1628,21 @@ static int __init dgrs_init_module (void
 	/*
 	 *	Find and configure all the cards
 	 */
-#ifdef CONFIG_EISA
-	cardcount = eisa_driver_register(&dgrs_eisa_driver);
+	cardcount = dgrs_register_eisa();
 	if (cardcount < 0)
 		return cardcount;
-#endif
-	cardcount = pci_register_driver(&dgrs_pci_driver);
-	if (cardcount)
+	cardcount = dgrs_register_pci();
+	if (cardcount < 0) {
+		dgrs_unregister_eisa();
 		return cardcount;
+	}
 	return 0;
 }
 
 static void __exit dgrs_cleanup_module (void)
 {
-#ifdef CONFIG_EISA
-	eisa_driver_unregister (&dgrs_eisa_driver);
-#endif
-#ifdef CONFIG_PCI
-	pci_unregister_driver (&dgrs_pci_driver);
-#endif
+	dgrs_unregister_pci();
+	dgrs_unregister_eisa();
 }
 
 module_init(dgrs_init_module);
