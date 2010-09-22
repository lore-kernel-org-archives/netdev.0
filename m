From: kaber@trash.net
Subject: [PATCH 3/6] netfilter: fix ipt_REJECT TCP RST routing for indev == outdev
Date: Wed, 22 Sep 2010 09:17:31 +0200
Message-ID: <1285139854-11827-4-git-send-email-kaber@trash.net>
References: <1285139854-11827-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1285139854-11827-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

ip_route_me_harder can't create the route cache when the outdev is the same
with the indev for the skbs whichout a valid protocol set.

__mkroute_input functions has this check:
1998         if (skb->protocol != htons(ETH_P_IP)) {
1999                 /* Not IP (i.e. ARP). Do not create route, if it is
2000                  * invalid for proxy arp. DNAT routes are always valid.
2001                  *
2002                  * Proxy arp feature have been extended to allow, ARP
2003                  * replies back to the same interface, to support
2004                  * Private VLAN switch technologies. See arp.c.
2005                  */
2006                 if (out_dev == in_dev &&
2007                     IN_DEV_PROXY_ARP_PVLAN(in_dev) == 0) {
2008                         err = -EINVAL;
2009                         goto cleanup;
2010                 }
2011         }

This patch gives the new skb a valid protocol to bypass this check. In order
to make ipt_REJECT work with bridges, you also need to enable ip_forward.

This patch also fixes a regression. When we used skb_copy_expand(), we
didn't have this issue stated above, as the protocol was properly set.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ipt_REJECT.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index b254daf..43eec80 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -112,6 +112,7 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	/* ip_route_me_harder expects skb->dst to be set */
 	skb_dst_set_noref(nskb, skb_dst(oldskb));
 
+	nskb->protocol = htons(ETH_P_IP);
 	if (ip_route_me_harder(nskb, addr_type))
 		goto free_nskb;
 
-- 
1.7.1

