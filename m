From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: vrf: avoid gcc-4.6 warning
Date: Tue, 12 Sep 2017 22:10:53 +0200
Message-ID: <20170912201100.3680915-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Julian Anastasov <ja@ssi.bg>,
        Matthias Schiffer <mschiffer@universe-factory.net>,
        Wei Wang <weiwan@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>,
        Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When building an allmodconfig kernel with gcc-4.6, we get a rather
odd warning:

drivers/net/vrf.c: In function ‘vrf_ip6_input_dst’:
drivers/net/vrf.c:964:3: error: initialized field with side-effects overwritten [-Werror]
drivers/net/vrf.c:964:3: error: (near initialization for ‘fl6’) [-Werror]

I have no idea what this warning is even trying to say, but it does
seem like a false positive. Reordering the initialization in to match
the structure definition gets rid of the warning, and might also avoid
whatever gcc thinks is wrong here.

Fixes: 9ff74384600a ("net: vrf: Handle ipv6 multicast and link-local addresses")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/vrf.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 7e19051f3230..9b243e6f3008 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -957,12 +957,12 @@ static void vrf_ip6_input_dst(struct sk_buff *skb, struct net_device *vrf_dev,
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct flowi6 fl6 = {
+		.flowi6_iif     = ifindex,
+		.flowi6_mark    = skb->mark,
+		.flowi6_proto   = iph->nexthdr,
 		.daddr          = iph->daddr,
 		.saddr          = iph->saddr,
 		.flowlabel      = ip6_flowinfo(iph),
-		.flowi6_mark    = skb->mark,
-		.flowi6_proto   = iph->nexthdr,
-		.flowi6_iif     = ifindex,
 	};
 	struct net *net = dev_net(vrf_dev);
 	struct rt6_info *rt6;
-- 
2.9.0
