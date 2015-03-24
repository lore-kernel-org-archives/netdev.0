From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] tipc: fix compile error when
	IPV6=m and TIPC=y
Date: Tue, 24 Mar 2015 16:59:21 +0800
Message-ID: <1427187561-25064-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, marcelo.leitner@gmail.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
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

When IPV6=m and TIPC=y, below error will appear during building kernel
image:

net/tipc/udp_media.c:196:
undefined reference to `ip6_dst_lookup'
make: *** [vmlinux] Error 1

As ip6_dst_lookup() is implemented in IPV6 and IPV6 is compiled as
module, ip6_dst_lookup() is not built-in core kernel image. As a
result, compiler cannot find 'ip6_dst_lookup' reference while
compiling TIPC code into core kernel image.

But with the method introduced by commit 5f81bd2e5d80 ("ipv6: export a
stub for IPv6 symbols used by vxlan"), we can avoid the compile error
through "ipv6_stub" pointer to access ip6_dst_lookup().

Fixes: d0f91938bede ("tipc: add ip/udp media type")
Suggested-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/udp_media.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index ac89101..ef3d7aa 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -193,7 +193,7 @@ static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
 			.saddr = src->ipv6,
 			.flowi6_proto = IPPROTO_UDP
 		};
-		err = ip6_dst_lookup(ub->ubsock->sk, &ndst, &fl6);
+		err = ipv6_stub->ipv6_dst_lookup(ub->ubsock->sk, &ndst, &fl6);
 		if (err)
 			goto tx_error;
 		ttl = ip6_dst_hoplimit(ndst);
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
