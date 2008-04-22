From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: physmap and "request_module: runaway loop modprobe net-pf-1"
Date: Tue, 22 Apr 2008 13:37:11 +0100
Message-ID: <1208867831.9212.582.camel@pmac.infradead.org>
References: <97a0a9ac0803112235l157706adoa84b131549a46049@mail.gmail.com>
	 <20080311225926.6515e18c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Gordon Farquharson <gordonfarquharson@gmail.com>,
	linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:42062 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945AbYDVMhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 08:37:17 -0400
In-Reply-To: <20080311225926.6515e18c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-03-11 at 22:59 -0700, Andrew Morton wrote:
> Now, af_unix_init() uses module_init(), which is really __initcall(), which
> is really device_initcall() (ug, don't ask).

... which is really __define_initcall("6", ...);.

> So you can do what you're sugesting here by locating the caller/callers of
> parse_mtd_partitions() and marking them late_initcall().

Better still, just initialise af_unix earlier so that it's there before
any normal drivers which happen to call request_module(). Since core
network stuff is initialised with subsys_initcall() which is really
__define_initcall("4", ...), we can initialise af_unix with
fs_initcall() which is really __define_initcall("5", ...).


---
[AF_UNIX] Initialise UNIX sockets before general device initcalls

When drivers call request_module(), it tries to do something with UNIX
sockets and triggers a 'runaway loop modprobe net-pf-1' warning. Avoid
this by initialising AF_UNIX support earlier.

Signed-off-by: David Woodhouse <dwmw2@infradead.org>

--- linux-2.6.24.ppc/net/unix/af_unix.c~	2008-04-13 13:38:25.000000000 +0100
+++ linux-2.6.24.ppc/net/unix/af_unix.c	2008-04-22 13:01:45.000000000 +0100
@@ -2193,7 +2193,11 @@ static void __exit af_unix_exit(void)
 	unregister_pernet_subsys(&unix_net_ops);
 }
 
-module_init(af_unix_init);
+/* Earlier than device_initcall() so that other drivers invoking
+   request_module() don't end up in a loop when modprobe tries
+   to use a UNIX socket. But later than subsys_initcall() because
+   we depend on stuff initialised there */
+fs_initcall(af_unix_init);
 module_exit(af_unix_exit);
 
 MODULE_LICENSE("GPL");


-- 
dwmw2

