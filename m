From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v3] tipc: fix undefined
	__ipv6_sock_mc_join compile error
Date: Wed, 11 Mar 2015 15:51:13 +0800
Message-ID: <1426060274-2930-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, willemb@google.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, kbuild-all@01.org,
	fengguang.wu@intel.com
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When CONFIG_IPV6 option is disabled, below error will appear while
building TIPC module:

ERROR: "__ipv6_sock_mc_join" [net/tipc/tipc.ko] undefined!
make[1]: *** [__modpost] Error 1
make: *** [net/tipc/tipc.ko] Error 1

This is because we don't check whether or not the CONFIG_IPV6 is
enabled when calling __ipv6_sock_mc_join().

In addition, especially when TIPC=y, TIPC_MEDIA_UDP=y, and IPV6=m, TIPC
module is also unable to be successfully built. Therefore, we add a
dependency condition like (IPV6=y || IPV6=n) to avoid the error.

Fixes: d0f91938bede ("tipc: add ip/udp media type")
Reported-by: Wu Fengguang <fengguang.wu@intel.com>
Cc: Kbuild test robot <kbuild-all@01.org>
Cc: Willem de Bruijn <willemb@google.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
v3:
  - Move the new dependency from TIPC to TIPC_MEDIA_UDP, which is
    suggested by Willem and David
  - Change IPV6 of new dependency to IPV6=y
  - Change initial err value from 0 to -EAFNOSUPPORT suggested by
    Willem
v2:
  - Fix another compile error when TIPC=y, TIPC_MEDIA_UDP=y, and IPV6=m

 net/tipc/Kconfig     |    1 +
 net/tipc/udp_media.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index c25a3a1..5bb8fc9 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -29,6 +29,7 @@ config TIPC_MEDIA_IB
 config TIPC_MEDIA_UDP
 	bool "IP/UDP media type support"
 	depends on TIPC
+	depends on (IPV6=y || IPV6=n)
 	select NET_UDP_TUNNEL
 	help
 	  Saying Y here will enable support for running TIPC over IP/UDP
diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index fc2fb11..ee0329d 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -148,7 +148,7 @@ static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
 			     struct tipc_bearer *b,
 			     struct tipc_media_addr *dest)
 {
-	int ttl, err = 0;
+	int ttl, err = -EAFNOSUPPORT;
 	struct udp_bearer *ub;
 	struct udp_media_addr *dst = (struct udp_media_addr *)&dest->value;
 	struct udp_media_addr *src = (struct udp_media_addr *)&b->addr.value;
@@ -247,10 +247,12 @@ static int enable_mcast(struct udp_bearer *ub, struct udp_media_addr *remote)
 		mreqn.imr_multiaddr = remote->ipv4;
 		mreqn.imr_ifindex = ub->ifindex;
 		err = __ip_mc_join_group(sk, &mreqn);
+#if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		if (!ipv6_addr_is_multicast(&remote->ipv6))
 			return 0;
 		err = __ipv6_sock_mc_join(sk, ub->ifindex, &remote->ipv6);
+#endif
 	}
 	return err;
 }
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
