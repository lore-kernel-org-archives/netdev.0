From: chenweilong <chenweilong@huawei.com>
Subject: [PATCH 3.10] ipv6: reallocate addrconf router for ipv6 address, when
 lo device up
Date: Tue, 12 Aug 2014 19:53:46 +0800
Message-ID: <53EA004A.9020300@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<stable@vger.kernel.org>, Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Gao feng" <gaofeng@cn.fujitsu.com>, Li Zefan <lizefan@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Please queue this patch for stable 3.10 kernels.

Thanks.

====================
commit 33d99113b1102c2d2f8603b9ba72d89d915c13f5 upstream.

commit 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
"net IPv6 : Fix broken IPv6 routing table after loopback down-up"
allocates addrconf router for ipv6 address when lo device up.
but commit a881ae1f625c599b460cc8f8a7fcb1c438f699ad
"ipv6:don't call addrconf_dst_alloc again when enable lo" breaks
this behavior.

Since the addrconf router is moved to the garbage list when
lo device down, we should release this router and rellocate
a new one for ipv6 address when lo device up.

This patch solves bug 67951 on bugzilla
https://bugzilla.kernel.org/show_bug.cgi?id=67951

change from v1:
use ip6_rt_put to repleace ip6_del_rt, thanks Hannes!
change code style, suggested by Sergei.

CC: Sabrina Dubroca <sd@queasysnail.net>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
Reported-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
[weilong: s/ip6_rt_put/dst_release]
Signed-off-by: Chen Weilong <chenweilong@huawei.com>
Signed-off-by: Li Zefan <lizefan@huawei.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 net/ipv6/addrconf.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f976c38..be58760 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2438,8 +2438,18 @@ static void init_loopback(struct net_device *dev)
 			if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
 				continue;

-			if (sp_ifa->rt)
-				continue;
+			if (sp_ifa->rt) {
+				/* This dst has been added to garbage list when
+				 * lo device down, release this obsolete dst and
+				 * reallocate a new router for ifa.
+				 */
+				if (sp_ifa->rt->dst.obsolete > 0) {
+					dst_release(&sp_ifa->rt->dst);
+					sp_ifa->rt = NULL;
+				} else {
+					continue;
+				}
+			}

 			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, 0);

-- 
1.7.12
