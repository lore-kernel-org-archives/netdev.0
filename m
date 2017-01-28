From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 1/2] batman-adv: Fix double call of
	dev_queue_xmit
Date: Sat, 28 Jan 2017 11:56:50 +0100
Message-ID: <20170128105651.3061-2-sw@simonwunderlich.de>
References: <20170128105651.3061-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20170128105651.3061-1-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

The net_xmit_eval has side effects because it is not making sure that e
isn't evaluated twice.

    #define net_xmit_eval(e)        ((e) == NET_XMIT_CN ? 0 : (e))

The code requested by David Miller [1]

    return net_xmit_eval(dev_queue_xmit(skb));

will get transformed into

    return ((dev_queue_xmit(skb)) == NET_XMIT_CN ? 0 : (dev_queue_xmit(skb)))

dev_queue_xmit will therefore be tried again (with an already consumed skb)
whenever the return code is not NET_XMIT_CN.

[1] https://lkml.kernel.org/r/20170125.225624.965229145391320056.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org

Fixes: c33705188c49 ("batman-adv: Treat NET_XMIT_CN as transmit successfully")
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/send.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index d9b2889064a6..1489ec27daff 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -77,6 +77,7 @@ int batadv_send_skb_packet(struct sk_buff *skb,
 {
 	struct batadv_priv *bat_priv;
 	struct ethhdr *ethhdr;
+	int ret;
 
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
@@ -115,7 +116,8 @@ int batadv_send_skb_packet(struct sk_buff *skb,
 	 * congestion and traffic shaping, it drops and returns NET_XMIT_DROP
 	 * (which is > 0). This will not be treated as an error.
 	 */
-	return net_xmit_eval(dev_queue_xmit(skb));
+	ret = dev_queue_xmit(skb);
+	return net_xmit_eval(ret);
 send_skb_err:
 	kfree_skb(skb);
 	return NET_XMIT_DROP;
-- 
2.11.0
