From: Andreas Ruprecht <rupran@einserver.de>
Subject: [PATCH v2] net: netfilter: Fix undefined reference to nf_nat_redirect_* functions
Date: Wed, 26 Nov 2014 10:35:37 +0100
Message-ID: <1416994537-1592-1-git-send-email-rupran@einserver.de>
References: <1416928034-10882-1-git-send-email-rupran@einserver.de>
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andreas Ruprecht <rupran@einserver.de>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:51417 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbaKZJgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 04:36:08 -0500
Received: by mail-wg0-f43.google.com with SMTP id l18so3135850wgh.30
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 01:36:06 -0800 (PST)
In-Reply-To: <1416928034-10882-1-git-send-email-rupran@einserver.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a configuration with CONFIG_NFT_NAT and
CONFIG_NETFILTER_XT_TARGET_REDIRECT enabled, undefined references to
nf_nat_redirect_ipv{4,6}() can occur, when the corresponding options
CONFIG_NF_NAT_REDIRECT_IPV4 or CONFIG_NF_NAT_REDIRECT_IPV6 are not
enabled.

net/built-in.o: In function `redirect_tg4':
xt_REDIRECT.c:(.text+0x6d001): undefined reference to `nf_nat_redirect_ipv4'
net/built-in.o: In function `redirect_tg6':
xt_REDIRECT.c:(.text+0x6d021): undefined reference to `nf_nat_redirect_ipv6'

This is because the file xt_REDIRECT.c is compiled when
CONFIG_NETFILTER_XT_TARGET_REDIRECT is enabled, which only depends
on CONFIG_NF_NAT. This option is invisible and can only be selected by
other Kconfig options. In this particular case, it is selected by
CONFIG_NFT_NAT.

This patch changes the dependency for CONFIG_NETFILTER_XT_TARGET_REDIRECT
to only make it visible if at least one of
{CONFIG_NF_NAT_REDIRECT_IPV4, CONFIG_NF_NAT_REDIRECT_IPV6} are enabled.

Additionally it is necessary to provide stubs for the
nf_nat_redirect_ipv{4,6} functions in case the header is included but
the corresponding Kconfig feature is not enabled.

Changes:
v2: Correct capitalization for CONFIG_NF_NAT_REDIRECT_IPV4 in comment.

Signed-off-by: Andreas Ruprecht <rupran@einserver.de>
---
 include/net/netfilter/ipv4/nf_nat_redirect.h | 14 ++++++++++++++
 include/net/netfilter/ipv6/nf_nat_redirect.h | 13 +++++++++++++
 net/netfilter/Kconfig                        |  2 +-
 3 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/include/net/netfilter/ipv4/nf_nat_redirect.h b/include/net/netfilter/ipv4/nf_nat_redirect.h
index 19e1df3a0a4d..56a506dd55cc 100644
--- a/include/net/netfilter/ipv4/nf_nat_redirect.h
+++ b/include/net/netfilter/ipv4/nf_nat_redirect.h
@@ -1,9 +1,23 @@
 #ifndef _NF_NAT_REDIRECT_IPV4_H_
 #define _NF_NAT_REDIRECT_IPV4_H_
 
+#include <linux/netfilter.h>
+
+#ifdef CONFIG_NF_NAT_REDIRECT_IPV4
 unsigned int
 nf_nat_redirect_ipv4(struct sk_buff *skb,
 		     const struct nf_nat_ipv4_multi_range_compat *mr,
 		     unsigned int hooknum);
 
+#else /* CONFIG_NF_NAT_REDIRECT_IPV4 */
+
+unsigned int
+nf_nat_redirect_ipv4(struct sk_buff *skb,
+		     const struct nf_nat_ipv4_multi_range_compat *mr,
+		     unsigned int hooknum)
+{
+	return NF_ACCEPT;
+}
+#endif /* CONFIG_NF_NAT_REDIRECT_IPV4 */
+
 #endif /* _NF_NAT_REDIRECT_IPV4_H_ */
diff --git a/include/net/netfilter/ipv6/nf_nat_redirect.h b/include/net/netfilter/ipv6/nf_nat_redirect.h
index 1ebdffc461cc..4db9351120ec 100644
--- a/include/net/netfilter/ipv6/nf_nat_redirect.h
+++ b/include/net/netfilter/ipv6/nf_nat_redirect.h
@@ -1,8 +1,21 @@
 #ifndef _NF_NAT_REDIRECT_IPV6_H_
 #define _NF_NAT_REDIRECT_IPV6_H_
 
+#include <linux/netfilter.h>
+
+#ifdef CONFIG_NF_NAT_REDIRECT_IPV6
 unsigned int
 nf_nat_redirect_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
 		     unsigned int hooknum);
 
+#else /* CONFIG_NF_NAT_REDIRECT_IPV6 */
+
+unsigned int
+nf_nat_redirect_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
+		     unsigned int hooknum)
+{
+	return NF_ACCEPT;
+}
+#endif /* CONFIG_NF_NAT_REDIRECT_IPV6 */
+
 #endif /* _NF_NAT_REDIRECT_IPV6_H_ */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index be8db270aa77..0972851cce03 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -844,7 +844,7 @@ config NETFILTER_XT_TARGET_RATEEST
 
 config NETFILTER_XT_TARGET_REDIRECT
 	tristate "REDIRECT target support"
-	depends on NF_NAT
+	depends on NF_NAT_IPV4 || NF_NAT_IPV6
 	select NF_NAT_REDIRECT_IPV4 if NF_NAT_IPV4
 	select NF_NAT_REDIRECT_IPV6 if NF_NAT_IPV6
 	---help---
-- 
1.9.1
