From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH] net/bridge: Add missing in6_dev_put in br_validate_ipv6
Date: Fri, 3 Jul 2015 19:01:31 +0100
Message-ID: <1435946491-11148-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>,
	"Julien Grall" <julien.grall@citrix.com>,
	Bernhard Thaler <bernhard.thaler@wvnet.at>,
	Pablo Neira Ayuso <pablo@netfilter.org>, <fw@strlen.de>,
	<ian.campbell@citrix.com>, <wei.liu2@citrix.com>
To: <stephen@networkplumber.org>, <davem@davemloft.net>,
	<bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The commit efb6de9b4ba0092b2c55f6a52d16294a8a698edd "netfilter: bridge:
forward IPv6 fragmented packets" introduced a new function
br_validate_ipv6 which take a reference on the inet6 device. Although,
the reference is not released at the end.

This will result to the impossibility to destroy any netdevice using
ipv6 and bridge.

Spotted while trying to destroy a Xen guest on the upstream Linux:
"unregister_netdevice: waiting for vif1.0 to become free. Usage count = 1"

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Cc: Bernhard Thaler <bernhard.thaler@wvnet.at>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: fw@strlen.de
Cc: ian.campbell@citrix.com
Cc: wei.liu2@citrix.com

---
    Note that it's impossible to create new guest after this message.
    I'm not sure if it's normal.
---
 net/bridge/br_netfilter_ipv6.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/bridge/br_netfilter_ipv6.c b/net/bridge/br_netfilter_ipv6.c
index 6d12d26..7046e19 100644
--- a/net/bridge/br_netfilter_ipv6.c
+++ b/net/bridge/br_netfilter_ipv6.c
@@ -140,11 +140,16 @@ int br_validate_ipv6(struct sk_buff *skb)
 	/* No IP options in IPv6 header; however it should be
 	 * checked if some next headers need special treatment
 	 */
+
+	in6_dev_put(idev);
+
 	return 0;
 
 inhdr_error:
 	IP6_INC_STATS_BH(dev_net(dev), idev, IPSTATS_MIB_INHDRERRORS);
 drop:
+	in6_dev_put(idev);
+
 	return -1;
 }
 
-- 
2.1.4
