From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH-next] netfilter: don't use module_init/exit in core IPV4 code
Date: Mon, 13 Jan 2014 13:35:47 -0500
Message-ID: <1389638147-30399-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netfilter@vger.kernel.org>, <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:50826 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbaAMSgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 13:36:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The file net/ipv4/netfilter.o is created based on whether
CONFIG_NETFILTER is set.  However that is defined as a bool, and
hence this file with the core netfilter hooks will never be
modular.  So using module_init as an alias for __initcall can be
somewhat misleading.

Fix this up now, so that we can relocate module_init from
init.h into module.h in the future.  If we don't do this, we'd
have to add module.h to obviously non-modular code, and that
would be a worse thing.  Also add an inclusion of init.h, as
that was previously implicit here in the netfilter.c file.

Note that direct use of __initcall is discouraged, vs. one
of the priority categorized subgroups.  As __initcall gets
mapped onto device_initcall, our use of subsys_initcall (which
seems to make sense for netfilter code) will thus change this
registration from level 6-device to level 4-subsys (i.e. slightly
earlier).  However no observable impact of that small difference
has been observed during testing, or is expected. (i.e. the
location of the netfilter messages in dmesg remains unchanged
with respect to all the other surrounding messages.)

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index c3e0adea9c27..e1237a64b14e 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -7,6 +7,7 @@
 #include <linux/kernel.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/init.h>
 #include <linux/ip.h>
 #include <linux/skbuff.h>
 #include <linux/gfp.h>
@@ -203,5 +204,5 @@ static void __exit ipv4_netfilter_fini(void)
 	nf_unregister_afinfo(&nf_ip_afinfo);
 }
 
-module_init(ipv4_netfilter_init);
-module_exit(ipv4_netfilter_fini);
+subsys_initcall(ipv4_netfilter_init);
+__exitcall(ipv4_netfilter_fini);
-- 
1.8.5.2
