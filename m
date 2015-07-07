From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH v2] net/bridge: Use __in6_dev_get rather than
	in6_dev_get in br_validate_ipv6
Date: Tue, 7 Jul 2015 15:55:21 +0100
Message-ID: <1436280921-2795-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com, fw@strlen.de,
	linux-kernel@vger.kernel.org, Julien Grall <julien.grall@citrix.com>,
	Bob Liu <bob.liu@oracle.com>, Bernhard Thaler <bernhard.thaler@wvnet.at>
To: <xen-devel@lists.xenproject.org>, <pablo@netfilter.org>,
	<kaber@trash.net>, <kadlec@blackhole.kfki.hu>,
	<stephen@networkplumber.org>,
	<davem@davemloft.net>, <netfilter-devel@vger.kernel.org>,
	<coreteam@netfilter.org>, <bridge@lists.linux-foundation.org>,
	<netdev@vger.kernel.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

The commit efb6de9b4ba0092b2c55f6a52d16294a8a698edd "netfilter: bridge:
forward IPv6 fragmented packets" introduced a new function
br_validate_ipv6 which take a reference on the inet6 device. Although,
the reference is not released at the end.

This will result to the impossibility to destroy any netdevice using
ipv6 and bridge.

It's possible to directly retrieve the inet6 device without taking a
reference as all netfilter hooks are protected by rcu_read_lock via
nf_hook_slow.

Spotted while trying to destroy a Xen guest on the upstream Linux:
"unregister_netdevice: waiting for vif1.0 to become free. Usage count = 1"

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Cc: Bernhard Thaler <bernhard.thaler@wvnet.at>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: fw@strlen.de
Cc: ian.campbell@citrix.com
Cc: wei.liu2@citrix.com
Cc: Bob Liu <bob.liu@oracle.com>

---
    Note that it's impossible to create new guest after this message.
    I'm not sure if it's normal.

    Changes in v2:
        - Don't take a reference to inet6.
        - This was "net/bridge: Add missing in6_dev_put in
        br_validate_ipv6" [0]

    [0] https://lkml.org/lkml/2015/7/3/443
---
 net/bridge/br_netfilter_ipv6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_netfilter_ipv6.c b/net/bridge/br_netfilter_ipv6.c
index 6d12d26..13b7d1e 100644
--- a/net/bridge/br_netfilter_ipv6.c
+++ b/net/bridge/br_netfilter_ipv6.c
@@ -104,7 +104,7 @@ int br_validate_ipv6(struct sk_buff *skb)
 {
 	const struct ipv6hdr *hdr;
 	struct net_device *dev = skb->dev;
-	struct inet6_dev *idev = in6_dev_get(skb->dev);
+	struct inet6_dev *idev = __in6_dev_get(skb->dev);
 	u32 pkt_len;
 	u8 ip6h_len = sizeof(struct ipv6hdr);
 
-- 
2.1.4
