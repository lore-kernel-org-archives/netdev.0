From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] connector: export cn_already_initialized.
Date: Sat, 6 May 2006 12:40:45 +0400
Message-ID: <20060506084045.GA16558@2ka.mipt.ru>
References: <20060504122421.GA8576@2ka.mipt.ru> <20060505.171646.65488074.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:11174 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751287AbWEFIlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 May 2006 04:41:00 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060505.171646.65488074.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 05, 2006 at 05:16:46PM -0700, David S. Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Thu, 4 May 2006 16:24:22 +0400
> 
> > No in-kernel users require it to be exported, so if you do think it
> > should not be exported I will force external module changes.
> 
> What are the alternatives?

This flag shows that connector has finished it's initialization and now
it's calbacks can be safely added. In-kernel users (like various
accountings) which are initialized first (like fs) use that flag to
check if connector can be added or not.

Some external patches, which can be built both as static build and as
module just check that value, and thus will fail with unresolved symbol
when cn and module are built as modules.

The right set of operations should be following:
If external module is loaded and cn is not loaded or compiled into the
kernel, insmod will just fail with unresolved symbol (cn_add_callback and others),
if cn is already loaded or was built into the tree, then it has been 
initialized already and there is no need to check that value, external
module should be just loaded.

I think the right solution is to call external init functions after cn
init function, but it's ordering is not always known.

While writing this I've thought another solution, when
cn_add_callback() will just return -EINPROGRESS or other special error, 
which means that it is too early to call it and it must be run later.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 3589707..f852e68 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -308,6 +308,9 @@ int cn_add_callback(struct cb_id *id, ch
 	int err;
 	struct cn_dev *dev = &cdev;
 
+	if (!cn_already_initialized)
+		return -EINPROGRESS;
+
 	err = cn_queue_add_callback(dev->cbdev, name, id, callback);
 	if (err)
 		return err;
@@ -456,6 +459,8 @@ static int __init cn_init(void)
 			sock_release(dev->nls->sk_socket);
 		return -EINVAL;
 	}
+	
+	cn_already_initialized = 1;
 
 	err = cn_add_callback(&dev->id, "connector", &cn_callback);
 	if (err) {
@@ -465,8 +470,6 @@ static int __init cn_init(void)
 		return -EINVAL;
 	}
 
-	cn_already_initialized = 1;
-
 	return 0;
 }
 

-- 
	Evgeniy Polyakov
