From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] bridge: add netfilter hook for forwarding 802.1D group
 addresses
Date: Fri, 19 Aug 2011 13:58:10 -0700
Message-ID: <20110819135810.1a529ab2@nehalam.ftrdhcpuser.net>
References: <CAF5U64C+WgQhfJL3zfVnvzE7p=G61humQCObHGUxAvY2-MGAFQ@mail.gmail.com>
	<CAF5U64CJTWDn8E9+XVLFsdaSbiu-4Rd9XmxZq7ReziRNZviO6Q@mail.gmail.com>
	<20110812154545.79d8313f@nehalam.ftrdhcpuser.net>
	<CAF5U64B_fb2tFMLHmK+zw3n6gmq+bYDyFnXhLE0ayssK5m+THA@mail.gmail.com>
	<20110815150501.3a6cc432@nehalam.ftrdhcpuser.net>
	<CAEJpZP0fOydMMbgquAud7dfwcO28BXAMzAwnMjSZO6TvEjxgpQ@mail.gmail.com>
	<20110818081019.4b9bb79e@nehalam.ftrdhcpuser.net>
	<CAEJpZP2FGhPmTi0+eS+QRhj4y+aqfQHnEUrjmOOLHUay1SuAKg@mail.gmail.com>
	<20110818093941.5ebf716b@nehalam.ftrdhcpuser.net>
	<20110819022731.GC180151@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nick Carter <ncarter100@gmail.com>,
	Ed Swierk <eswierk@bigswitch.com>, netdev@vger.kernel.org,
	bridge@linux-foundation.org, netfilter-devel@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110819022731.GC180151@jupiter.n2.diac24.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IEEE standard expects that link local multicast packets will not
be forwarded by a bridge. But there are cases like 802.1X which may
require that packets be forwarded. For maximum flexibilty implement
this via netfilter.

The netfilter chain is slightly different from other chains in that
if packet is ACCEPTED by the chain, it means it should be forwarded.
And if the packet verdict result is DROP, the packet is processed
as a local packet. The default result for this chain is DROP and
therefore users who do not install any rules will get the same
result as before; ie. packets are only processed on the local host
and not forwarded.

Spanning Tree Packets are treated specially and do not
go through the new chain.

This code is conceptual design concept only. It compiles but
hasn't been tested.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/netfilter_bridge.h      |    5 ++++-
 net/bridge/br_input.c                 |   15 ++++++++++++---
 net/bridge/netfilter/ebtable_filter.c |   18 ++++++++++++++++--
 3 files changed, 32 insertions(+), 6 deletions(-)

--- a/include/linux/netfilter_bridge.h	2011-08-19 13:11:51.972125670 -0700
+++ b/include/linux/netfilter_bridge.h	2011-08-19 13:13:36.452130443 -0700
@@ -22,7 +22,10 @@
 #define NF_BR_POST_ROUTING	4
 /* Not really a hook, but used for the ebtables broute table */
 #define NF_BR_BROUTING		5
-#define NF_BR_NUMHOOKS		6
+/* Packets to link local multicast addresses (01-80-C2-00-00-XX) */
+#define NF_BR_LINK_LOCAL_IN	6
+
+#define NF_BR_NUMHOOKS		7
 
 #ifdef __KERNEL__
 
--- a/net/bridge/br_input.c	2011-08-18 16:12:02.576672548 -0700
+++ b/net/bridge/br_input.c	2011-08-19 13:28:13.696170518 -0700
@@ -166,10 +166,19 @@ rx_handler_result_t br_handle_frame(stru
 		if (skb->protocol == htons(ETH_P_PAUSE))
 			goto drop;
 
-		/* If STP is turned off, then forward */
-		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
-			goto forward;
+		/* If this is Spanning Tree Protocol packet */
+		if (dest[5] == 0) {
+			/* and STP is turned off, then forward */
+			if (p->br->stp_enabled == BR_NO_STP)
+				goto forward;
+		}
+		/* Hook to allow forwarding other group MAC addresses */
+		else if (p->state == BR_STATE_FORWARDING &&
+			 NF_HOOK(NFPROTO_BRIDGE, NF_BR_LINK_LOCAL_IN, skb, skb->dev,
+				 NULL, br_handle_frame_finish))
+			return RX_HANDLER_CONSUMED;	/* forwarded */
 
+		/* Packet will go only to the local host. */
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
 			    NULL, br_handle_local_finish)) {
 			return RX_HANDLER_CONSUMED; /* consumed by filter */
--- a/net/bridge/netfilter/ebtable_filter.c	2011-08-19 13:14:46.232133631 -0700
+++ b/net/bridge/netfilter/ebtable_filter.c	2011-08-19 13:27:33.436168679 -0700
@@ -11,8 +11,10 @@
 #include <linux/netfilter_bridge/ebtables.h>
 #include <linux/module.h>
 
-#define FILTER_VALID_HOOKS ((1 << NF_BR_LOCAL_IN) | (1 << NF_BR_FORWARD) | \
-   (1 << NF_BR_LOCAL_OUT))
+#define FILTER_VALID_HOOKS ((1 << NF_BR_LOCAL_IN) | \
+			    (1 << NF_BR_FORWARD) | \
+			    (1 << NF_BR_LOCAL_OUT) | \
+			    (1 << NF_BR_LINK_LOCAL_IN))
 
 static struct ebt_entries initial_chains[] =
 {
@@ -28,6 +30,10 @@ static struct ebt_entries initial_chains
 		.name	= "OUTPUT",
 		.policy	= EBT_ACCEPT,
 	},
+	{
+		.name	= "LINKLOCAL",
+		.policy = EBT_DROP,
+	},
 };
 
 static struct ebt_replace_kernel initial_table =
@@ -39,6 +45,7 @@ static struct ebt_replace_kernel initial
 		[NF_BR_LOCAL_IN]	= &initial_chains[0],
 		[NF_BR_FORWARD]		= &initial_chains[1],
 		[NF_BR_LOCAL_OUT]	= &initial_chains[2],
+		[NF_BR_LINK_LOCAL_IN]	= &initial_chains[3],
 	},
 	.entries	= (char *)initial_chains,
 };
@@ -95,6 +102,13 @@ static struct nf_hook_ops ebt_ops_filter
 		.hooknum	= NF_BR_LOCAL_OUT,
 		.priority	= NF_BR_PRI_FILTER_OTHER,
 	},
+	{
+		.hook		= ebt_in_hook,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_BRIDGE,
+		.hooknum	= NF_BR_LINK_LOCAL_IN,
+		.priority	= NF_BR_PRI_FILTER_BRIDGED,
+	},
 };
 
 static int __net_init frame_filter_net_init(struct net *net)
