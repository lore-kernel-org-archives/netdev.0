From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] fou: fix IPv6 Kconfig options
Date: Tue, 31 May 2016 22:42:11 +0200
Message-ID: <1464727353-22489-1-git-send-email-arnd@arndb.de>
Cc: Tom Herbert <tom@herbertland.com>,
	Valentin Rothberg <valentinrothberg@gmail.com>,
	Andreas Ziegler <ziegler@cs.fau.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Kconfig options I added to work around broken compilation ended
up screwing up things more, as I used the wrong symbol to control
compilation of the file, resulting in IPv6 fou support to never be built
into the kernel.

Changing CONFIG_NET_FOU_IPV6_TUNNELS to CONFIG_IPV6_FOU fixes that
problem, I had renamed the symbol in one location but not the other,
and as the file is never being used by other kernel code, this did not
lead to a build failure that I would have caught.

After that fix, another issue with the same patch becomes obvious, as we
'select INET6_TUNNEL', which is related to IPV6_TUNNEL, but not the same,
and this can still cause the original build failure when IPV6_TUNNEL is
not built-in but IPV6_FOU is. The fix is equally trivial, we just need
to select the right symbol.

I have successfully build 350 randconfig kernels with this patch
and verified that the driver is now being built.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Reported-by: Valentin Rothberg <valentinrothberg@gmail.com>
Fixes: fabb13db448e ("fou: add Kconfig options for IPv6 support")
---
 net/ipv6/Kconfig  | 2 +-
 net/ipv6/Makefile | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 994608263260..2343e4f2e0bf 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -239,7 +239,7 @@ config IPV6_FOU
 config IPV6_FOU_TUNNEL
 	tristate
 	default NET_FOU_IP_TUNNELS && IPV6_FOU
-	select INET6_TUNNEL
+	select IPV6_TUNNEL
 
 config IPV6_MULTIPLE_TABLES
 	bool "IPv6: Multiple Routing Tables"
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index d42ca3d1197f..6d8ea099213e 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -42,7 +42,7 @@ obj-$(CONFIG_IPV6_VTI) += ip6_vti.o
 obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
-obj-$(CONFIG_NET_FOU_IPV6_TUNNELS) += fou6.o
+obj-$(CONFIG_IPV6_FOU) += fou6.o
 
 obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o
 obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
-- 
2.7.0
