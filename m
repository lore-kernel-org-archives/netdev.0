From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 03/11] netfilter: don't use module_init/exit in core IPV4 code
Date: Sun, 31 May 2015 20:54:04 -0400
Message-ID: <1433120052-18281-4-git-send-email-paul.gortmaker@windriver.com>
References: <1433120052-18281-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433120052-18281-1-git-send-email-paul.gortmaker@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

As for the module_exit, rather than replace it with __exitcall,
we simply remove it, since it appears only UML does anything
with those, and even for UML, there is no relevant cleanup
to be done here.

Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/ipv4/netfilter.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 65de0684e22a..61eafc9b4545 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -197,11 +197,4 @@ static int __init ipv4_netfilter_init(void)
 {
 	return nf_register_afinfo(&nf_ip_afinfo);
 }
-
-static void __exit ipv4_netfilter_fini(void)
-{
-	nf_unregister_afinfo(&nf_ip_afinfo);
-}
-
-module_init(ipv4_netfilter_init);
-module_exit(ipv4_netfilter_fini);
+subsys_initcall(ipv4_netfilter_init);
-- 
2.2.1
