From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] connector: export cn_already_initialized.
Date: Mon, 19 Jun 2006 09:30:35 +0400
Message-ID: <20060619053031.GA17406@2ka.mipt.ru>
References: <20060504122421.GA8576@2ka.mipt.ru> <20060505.171646.65488074.davem@davemloft.net> <20060506084045.GA16558@2ka.mipt.ru> <20060516.161406.23276754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:20205 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750726AbWFSFap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2006 01:30:45 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060516.161406.23276754.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2006 at 04:14:06PM -0700, David S. Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Sat, 6 May 2006 12:40:45 +0400
> 
> > Some external patches, which can be built both as static build and as
> > module just check that value, and thus will fail with unresolved symbol
> > when cn and module are built as modules.
> > 
> > The right set of operations should be following:
> > If external module is loaded and cn is not loaded or compiled into the
> > kernel, insmod will just fail with unresolved symbol (cn_add_callback and others),
> > if cn is already loaded or was built into the tree, then it has been 
> > initialized already and there is no need to check that value, external
> > module should be just loaded.
> > 
> > I think the right solution is to call external init functions after cn
> > init function, but it's ordering is not always known.
> 
> In-kernel build of connector subsystem can be handled by
> making cn_init a "subsystem_init()", it will then be setup
> before any possible static or modular reference as long as
> those modules use module_init().
> 
> For modular case of connector, dependency of module on connector
> module should handle all ordering issues, making any ordering
> issue take care of itself.

Attached patch declares connector init function as subsys_init()
and returns -EAGAIN in case connector is not initialized yet.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 505677f..d1d964f 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -306,6 +306,9 @@ int cn_add_callback(struct cb_id *id, ch
 	int err;
 	struct cn_dev *dev = &cdev;
 
+	if (!cn_already_initialized)
+		return -EAGAIN;
+
 	err = cn_queue_add_callback(dev->cbdev, name, id, callback);
 	if (err)
 		return err;
@@ -433,7 +436,7 @@ static void cn_callback(void *data)
 	up(&notify_lock);
 }
 
-static int __init cn_init(void)
+static int __devinit cn_init(void)
 {
 	struct cn_dev *dev = &cdev;
 	int err;
@@ -454,21 +458,22 @@ static int __init cn_init(void)
 			sock_release(dev->nls->sk_socket);
 		return -EINVAL;
 	}
+	
+	cn_already_initialized = 1;
 
 	err = cn_add_callback(&dev->id, "connector", &cn_callback);
 	if (err) {
+		cn_already_initialized = 0;
 		cn_queue_free_dev(dev->cbdev);
 		if (dev->nls->sk_socket)
 			sock_release(dev->nls->sk_socket);
 		return -EINVAL;
 	}
 
-	cn_already_initialized = 1;
-
 	return 0;
 }
 
-static void __exit cn_fini(void)
+static void __devexit cn_fini(void)
 {
 	struct cn_dev *dev = &cdev;
 
@@ -480,7 +485,7 @@ static void __exit cn_fini(void)
 		sock_release(dev->nls->sk_socket);
 }
 
-module_init(cn_init);
+subsys_initcall(cn_init);
 module_exit(cn_fini);
 
 EXPORT_SYMBOL_GPL(cn_add_callback);

-- 
	Evgeniy Polyakov
