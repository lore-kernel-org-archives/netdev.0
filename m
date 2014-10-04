From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf next 2/3] netfilter: bridge: don't parse ip headers in fwd and output path
Date: Sat,  4 Oct 2014 03:04:29 +0200
Message-ID: <1412384670-17794-3-git-send-email-fw@strlen.de>
References: <1412384670-17794-1-git-send-email-fw@strlen.de>
Cc: bsd@redhat.com, stephen@networkplumber.org, netdev@cger.kernel.org,
	herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
	davidn@davidnewall.com, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1412384670-17794-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We currently call ip_options_compile() for incoming, forwarded,
and outgoing packets.

This prevents ipv4 packets that have ip options set from being processed
by a linux bridge; both for the forward and the local delivery cases.

We first call ip_options_compile() from the pre-routing path.
This will mangle the ipv4 packet, which is already problematic since
it is a layering violation.
But this also will invalidate the ipv4 header checksum.

Since the checksum isn't fixed up, we then drop the packet in the ipv4
input path (for local delivery to the bridge) or when forwarding the
packet (since br_nf_forward_ip invokes br_parse_ip_options(), because it
has checksum error.

For the output path, this is no longer needed either:
previous change added inet_skb_param padding to br_input_skb_cb, so
bridge can no longer overwrite any IPCB data.

With this patch, such packets are not dropped by the bridge anymore,
but they are still corrupted.  This is addressed by next patch.

Cc: Bandan Das <bsd@redhat.com>
Reported-by: David Newall <davidn@davidnewall.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/bridge/br_netfilter.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index fa1270c..56c7ed8 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -718,9 +718,6 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 		nf_bridge->mask |= BRNF_PKT_TYPE;
 	}
 
-	if (pf == NFPROTO_IPV4 && br_parse_ip_options(skb))
-		return NF_DROP;
-
 	/* The physdev module checks on this */
 	nf_bridge->mask |= BRNF_BRIDGED;
 	nf_bridge->physoutdev = skb->dev;
@@ -778,12 +775,9 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 
 	if (skb->protocol == htons(ETH_P_IP) &&
 	    skb->len + nf_bridge_mtu_reduction(skb) > skb->dev->mtu &&
-	    !skb_is_gso(skb)) {
-		if (br_parse_ip_options(skb))
-			/* Drop invalid packet */
-			return NF_DROP;
+	    !skb_is_gso(skb))
 		ret = ip_fragment(skb, br_dev_queue_push_xmit);
-	} else
+	else
 		ret = br_dev_queue_push_xmit(skb);
 
 	return ret;
-- 
2.0.4

