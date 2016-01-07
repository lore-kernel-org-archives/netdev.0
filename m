From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Thu,  7 Jan 2016 10:33:09 +0100
Message-ID: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
 Haiyang Zhang <haiyangz@microsoft.com>, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Recent changes to 'struct flow_keys' (e.g commit d34af823ff40 ("net: Add
 VLAN ID to flow_keys")) introduced a performance regression in netvsc
driver. Is problem is, however, not the above mentioned commit but the
fact that netvsc_set_hash() function did some assumptions on the struct
flow_keys data layout and this is wrong. We need to extract the data we
need (src/dst addresses and ports) after the dissect.

The issue could also be solved in a completely different way: as suggested
by Eric instead of our own homegrown netvsc_set_hash() we could use
skb_get_hash() which does more or less the same. Unfortunately, the
testing done by Simon showed that Hyper-V hosts are not happy with our
Jenkins hash, selecting the output queue with the current algorithm based
on Toeplitz hash works significantly better.

Tested-by: Simon Xiao <sixiao@microsoft.com>
Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
This patch is an alternative to Haiyang's "hv_netvsc: Use simple parser
for IPv4 and v6 headers".
---
 drivers/net/hyperv/netvsc_drv.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 409b48e..4dea44e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -238,18 +238,26 @@ static bool netvsc_set_hash(u32 *hash, struct sk_buff *skb)
 {
 	struct flow_keys flow;
 	int data_len;
+	u8 data[sizeof(flow.addrs) + sizeof(flow.ports)];
 
-	if (!skb_flow_dissect_flow_keys(skb, &flow, 0) ||
-	    !(flow.basic.n_proto == htons(ETH_P_IP) ||
-	      flow.basic.n_proto == htons(ETH_P_IPV6)))
+	if (!skb_flow_dissect_flow_keys(skb, &flow, 0))
 		return false;
 
-	if (flow.basic.ip_proto == IPPROTO_TCP)
-		data_len = 12;
+	if (flow.basic.n_proto == htons(ETH_P_IP))
+		data_len = sizeof(flow.addrs.v4addrs);
+	else if (flow.basic.n_proto == htons(ETH_P_IPV6))
+		data_len = sizeof(flow.addrs.v6addrs);
 	else
-		data_len = 8;
+		return false;
+
+	memcpy(data, &flow.addrs, data_len);
+
+	if (flow.basic.ip_proto == IPPROTO_TCP) {
+		memcpy(data + data_len, &flow.ports, sizeof(flow.ports));
+		data_len += sizeof(flow.ports);
+	}
 
-	*hash = comp_hash(netvsc_hash_key, HASH_KEYLEN, &flow, data_len);
+	*hash = comp_hash(netvsc_hash_key, HASH_KEYLEN, data, data_len);
 
 	return true;
 }
-- 
2.4.3
