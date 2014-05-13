From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 4/5] ieee802154: don't ignore
	"to" argument in unbound dgram sendmsg
Date: Tue, 13 May 2014 19:24:05 +0200
Message-ID: <1400001846-5349-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400001846-5349-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1400001846-5349-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

For some reason, unconnected 802.15.4 dgram sockets ignore the destination
argument of sendmsg(), while bound sockets use it. Instead, send packets
to the destination given by the user, and default to the connected
destination only if no explicit target is given.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 net/ieee802154/dgram.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 2fefe12..525f18a 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -211,6 +211,7 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct sk_buff *skb;
 	struct ieee802154_mac_cb *cb;
 	struct dgram_sock *ro = dgram_sk(sk);
+	struct ieee802154_addr dst_addr;
 	int hlen, tlen;
 	int err;
 
@@ -254,8 +255,16 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 	cb->type = IEEE802154_FC_TYPE_DATA;
 	cb->ackreq = ro->want_ack;
 
-	err = dev_hard_header(skb, dev, ETH_P_IEEE802154, &ro->dst_addr,
-			ro->bound ? &ro->src_addr : NULL, size);
+	if (msg->msg_name) {
+		DECLARE_SOCKADDR(struct sockaddr_ieee802154*, daddr, msg->msg_name);
+
+		ieee802154_addr_from_sa(&dst_addr, &daddr->addr);
+	} else {
+		dst_addr = ro->dst_addr;
+	}
+
+	err = dev_hard_header(skb, dev, ETH_P_IEEE802154, &dst_addr,
+			      ro->bound ? &ro->src_addr : NULL, size);
 	if (err < 0)
 		goto out_skb;
 
-- 
1.7.9.5


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
