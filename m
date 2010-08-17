From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2 resend] netfilter: ipt_REJECT can't send TCP reset
Date: Tue, 17 Aug 2010 15:26:10 +0800
Message-ID: <1282029970-3111-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
v2: updated changelog
 net/ipv4/netfilter/ipt_REJECT.c |    1 +
 1 file changed, 1 insertion(+)
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
 
