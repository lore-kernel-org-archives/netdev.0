From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] igb: Correctly get protocol information
Date: Fri, 07 Mar 2008 10:32:13 -0800
Message-ID: <20080307183213.23174.76224.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Mitch Williams <mitch.a.williams@intel.com>

We can't look at the socket to get protocol information. We should
instead look directly at the packet, and hope there are no IPv6
option headers.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/igb/igb_main.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 6a1f230..928ce82 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -31,7 +31,6 @@
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
 #include <linux/netdevice.h>
-#include <linux/tcp.h>
 #include <linux/ipv6.h>
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
@@ -2484,10 +2483,24 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
 		tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			if (skb->protocol == htons(ETH_P_IP))
+			switch (skb->protocol) {
+			case __constant_htons(ETH_P_IP):
 				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
-			if (skb->sk && (skb->sk->sk_protocol == IPPROTO_TCP))
-				tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
+				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
+				break;
+			case __constant_htons(ETH_P_IPV6):
+				/* XXX what about other V6 headers?? */
+				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
+					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
+				break;
+			default:
+				if (unlikely(net_ratelimit()))
+					dev_warn(&adapter->pdev->dev,
+					    "partial checksum but proto=%x!\n",
+					    skb->protocol);
+				break;
+			}
 		}
 
 		context_desc->type_tucmd_mlhl = cpu_to_le32(tu_cmd);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
