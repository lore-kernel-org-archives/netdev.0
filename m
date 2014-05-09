From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6] ipv4: fix "conntrack zones" support for defrag user check in ip_expire
Date: Fri,  9 May 2014 12:56:05 +0200
Message-ID: <1399632967-4423-5-git-send-email-pablo@netfilter.org>
References: <1399632967-4423-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1399632967-4423-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasily Averin <vvs@parallels.com>

Defrag user check in ip_expire was not updated after adding support for
"conntrack zones".

This bug manifests as a RFC violation, since the router will send
the icmp time exceeeded message when using conntrack zones.

Signed-off-by: Vasily Averin <vvs@openvz.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/ip_fragment.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index c10a3ce..ed32313 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -232,8 +232,9 @@ static void ip_expire(unsigned long arg)
 		 * "Fragment Reassembly Timeout" message, per RFC792.
 		 */
 		if (qp->user == IP_DEFRAG_AF_PACKET ||
-		    (qp->user == IP_DEFRAG_CONNTRACK_IN &&
-		     skb_rtable(head)->rt_type != RTN_LOCAL))
+		    ((qp->user >= IP_DEFRAG_CONNTRACK_IN) &&
+		     (qp->user <= __IP_DEFRAG_CONNTRACK_IN_END) &&
+		     (skb_rtable(head)->rt_type != RTN_LOCAL)))
 			goto out_rcu_unlock;
 
 
-- 
1.7.10.4

