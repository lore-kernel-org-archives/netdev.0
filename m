From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [BUG] 2.6.3 + hp100 -> Oops
Date: Wed, 18 Feb 2004 12:40:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040218124034.05c9f6aa@dell_ss3.pdx.osdl.net>
References: <20040218201559.GA31872@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Linux kernel mailing list
 <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040218201559.GA31872@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This should fix the problem... The multi-bus probe logic error handling was
botched.

diff -Nru a/drivers/net/hp100.c b/drivers/net/hp100.c
--- a/drivers/net/hp100.c	Wed Feb 18 12:39:41 2004
+++ b/drivers/net/hp100.c	Wed Feb 18 12:39:41 2004
@@ -3043,14 +3043,27 @@
 	int err;
 
 	err = hp100_isa_init();
-
+	if (err && err != -ENODEV)
+		goto out;
 #ifdef CONFIG_EISA
-	err |= eisa_driver_register(&hp100_eisa_driver);
+	err = eisa_driver_register(&hp100_eisa_driver);
+	if (err && err != -ENODEV) 
+		goto out2;
 #endif
 #ifdef CONFIG_PCI
-	err |= pci_module_init(&hp100_pci_driver);
+	err = pci_module_init(&hp100_pci_driver);
+	if (err && err != -ENODEV) 
+		goto out3;
 #endif
+ out:
 	return err;
+ out3:
+#ifdef CONFIG_EISA
+	eisa_driver_unregister (&hp100_eisa_driver);
+ out2:
+#endif
+	hp100_isa_cleanup();
+	goto out;
 }
 
 
