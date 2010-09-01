From: Bandan Das <bandan.das@stratus.com>
Subject: Re: [PATCH net-next-2.6] net/ipv4: push IP options to CB in
 ip_fragment
Date: Wed, 1 Sep 2010 12:57:43 -0400
Message-ID: <20100901165743.GB17843@stratus.com>
References: <20100830200917.GA10754@stratus.com>
 <1283204118.2405.32.camel@edumazet-laptop>
 <20100830232147.GB10754@stratus.com>
 <1283232031.2405.38.camel@edumazet-laptop>
 <20100831082444.GB29281@gondor.apana.org.au>
 <1283246271.2550.35.camel@edumazet-laptop>
 <20100831123641.GA31017@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bunk@kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Bandan Das <bandan.das@stratus.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.stratus.com ([134.111.1.17]:55237 "EHLO
	mailhub4.stratus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244Ab0IAQ6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 12:58:45 -0400
Content-Disposition: inline
In-Reply-To: <20100831123641.GA31017@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On  0, Herbert Xu <herbert@gondor.hengli.com.au> wrote:
> On Tue, Aug 31, 2010 at 11:17:51AM +0200, Eric Dumazet wrote:
> >
> > Once again, the IP stack -> bridge -> IP stack flow bites us,
> > because bridge likes to dirty IPCB.
> 
> OK, so we're talking about a locally transmitted packet, with
> IP options leaving the IP stack, entering bridging, and then
> reentering the IP stack?
> 
> In that case the packet should no longer be treated as an IP
> packet when it enters the bridge.  So if it did have options
> and we want to support that in bridging then we need to parse
> IP options there as my comment suggested.

Ok. So, I am not sure if re-exporting ip_compile_options is a 
good idea nor am I sure if replicating its behavior in a different 
function is.  It was removed from the list of exported symbols way
back in 2005. 

commit 0742fd53a3774781255bd1e471e7aa2e4a82d5f7
Author: Adrian Bunk <bunk@stusta.de>
Date:   Tue Aug 9 19:35:47 2005 -0700

    [IPV4]: possible cleanups
    
    This patch contains the following possible cleanups:
    - make needlessly global code static
    - #if 0 the following unused global function:
      - xfrm4_state.c: xfrm4_state_fini
    - remove the following unneeded EXPORT_SYMBOL's:
      - ip_output.c: ip_finish_output
      - ip_output.c: sysctl_ip_default_ttl
      - fib_frontend.c: ip_dev_find
      - inetpeer.c: inet_peer_idlock
      - ip_options.c: ip_options_compile
      - ip_options.c: ip_options_undo
      - net/core/request_sock.c: sysctl_max_syn_backlog

But, nevertheless, I moved the call to ip_options_compile to 
br_nf_dev_queue_xmit(). Does something like this look ok ?
(Previously sent patch : http://www.spinics.net/lists/kernel/msg1077537.html)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 2c911c0..de44271 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -759,9 +759,21 @@ static unsigned int br_nf_forward_arp(unsigned int hook, struct sk_buff *skb,
 #if defined(CONFIG_NF_CONNTRACK_IPV4) || defined(CONFIG_NF_CONNTRACK_IPV4_MODULE)
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
+       struct ip_options *opt;
+       struct iphdr *iph;
+       struct net_device *dev = skb->dev;
+
        if (skb->nfct != NULL && skb->protocol == htons(ETH_P_IP) &&
            skb->len + nf_bridge_mtu_reduction(skb) > skb->dev->mtu &&
-           !skb_is_gso(skb))
+           !skb_is_gso(skb)) {
+               iph = ip_hdr(skb);
+               opt = &(IPCB(skb)->opt);
+               opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
+               if (ip_options_compile(dev_net(dev), opt, skb)){
+                       IP_INC_STATS(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
+                       memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+               }
+       }
                return ip_fragment(skb, br_dev_queue_push_xmit);
        else
                return br_dev_queue_push_xmit(skb);
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index ba9836c..72fe82c 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -466,7 +466,7 @@ error:
        }
        return -EINVAL;
 }
-
+EXPORT_SYMBOL(ip_options_compile);
 
 /*
  *     Undo all the changes done by ip_options_compile().
