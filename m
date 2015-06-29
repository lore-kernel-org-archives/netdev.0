From: Florian Westphal <fw@strlen.de>
Subject: Re: Unable to unregister netdevice after "netfilter: bridge: forward
 IPv6 fragmented packets"
Date: Mon, 29 Jun 2015 20:55:25 +0200
Message-ID: <20150629185525.GF2324@breakpoint.cc>
References: <55916C5D.3080602@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bernhard.thaler@wvnet.at, pablo@netfilter.org,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	bridge@lists.linux-foundation.org,
	xen-devel <xen-devel@lists.xenproject.org>,
	David Vrabel <david.vrabel@citrix.com>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48154 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752567AbbF2Szd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 14:55:33 -0400
Content-Disposition: inline
In-Reply-To: <55916C5D.3080602@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julien Grall <julien.grall@citrix.com> wrote:
> Hi,
> 
> I tried to run the latest Linux tree
> (4a10a91756ef381bced7b88cfb9232f660b92d93) as DOM0 Xen.
> After destroying a guest using network, I got the following
> lines in the DOM0 kernel log:
> 
> unregister_netdevice: waiting for vif1.0 to become free. Usage count = 1
> 
> The bisector pointed the problem after the commit
> efb6de9b4ba0092b2c55f6a52d16294a8a698edd
> "netfilter: bridge: forward IPv6 fragmented packets".

Seems we can leak skb in br_nf_dev_queue_xmit()...  Does this fix the problem?

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index d89f4fa..1a6fa67 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -742,7 +742,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 		struct brnf_frag_data *data;
 
 		if (br_validate_ipv4(skb))
-			return NF_DROP;
+			goto drop;
 
 		IPCB(skb)->frag_max_size = nf_bridge->frag_max_size;
 
@@ -767,7 +767,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 		struct brnf_frag_data *data;
 
 		if (br_validate_ipv6(skb))
-			return NF_DROP;
+			goto drop;
 
 		IP6CB(skb)->frag_max_size = nf_bridge->frag_max_size;
 
@@ -782,12 +782,16 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 
 		if (v6ops)
 			return v6ops->fragment(sk, skb, br_nf_push_frag_xmit);
-		else
-			return -EMSGSIZE;
+
+		kfree_skb(skb);
+		return -EMSGSIZE;
 	}
 #endif
 	nf_bridge_info_free(skb);
 	return br_dev_queue_push_xmit(sk, skb);
+ drop:
+	kfree_skb(skb);
+	return 0;
 }
 
 /* PF_BRIDGE/POST_ROUTING ********************************************/
