From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Kernel crash - Large UDP packet over IPv6 over UFO-enabled device with TBF qdisc (No corking needed)
Date: Sun, 3 Nov 2013 04:32:07 +0100
Message-ID: <20131103033207.GF30284@order.stressinduktion.org>
References: <4BC5337E23A5EE4A96D91D9DABA8FAE55E440B568D@WP40068.corp.ads>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pshelar@nicira.com,
	dl TSL Vulnerability Research Team
	<tsl-vulnerability-research@telus.com>
To: Saran Neti <Saran.Neti@telus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46117 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab3KCDcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 23:32:09 -0400
Content-Disposition: inline
In-Reply-To: <4BC5337E23A5EE4A96D91D9DABA8FAE55E440B568D@WP40068.corp.ads>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pravin,

Could you have a look at this bug?

On Tue, Oct 29, 2013 at 10:30:34AM -0400, Saran Neti wrote:
> Sending a UDP packet of size larger than MTU over IPv6 over a device that has UFO enabled, and that uses the TBF qdisc causes the kernel to crash. Unlike CVE-2013-4387, this does not require a corked socket and can be remotely triggered by a tftp request. 

It seems it got introduced with this commit:

commit 1e2bd517c108816220f262d7954b697af03b5f9c
Author: Pravin B Shelar <pshelar@nicira.com>
Date:   Thu May 30 06:45:27 2013 +0000

    udp6: Fix udp fragmentation for tunnel traffic.
    
    udp6 over GRE tunnel does not work after to GRE tso changes. GRE
    tso handler passes inner packet but keeps track of outer header
    start in SKB_GSO_CB(skb)->mac_offset.  udp6 fragment need to
    take care of outer header, which start at the mac_offset, while
    adding fragment header.
    This bug is introduced by commit 68c3316311 (GRE: Add TCP
    segmentation offload for GRE).

It seems we don't check for the correct headroom. ->data currently points
to transport_header, so use of skb_headlen seems wrong.

Following diff fixes the problem:

--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -90,7 +90,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 
                /* Check if there is enough headroom to insert fragment header. */
                tnl_hlen = skb_tnl_header_len(skb);
-               if (skb_headroom(skb) < (tnl_hlen + frag_hdr_sz)) {
+               if (skb->mac_header < (tnl_hlen + frag_hdr_sz)) {
                        if (gso_pskb_expand_head(skb, tnl_hlen + frag_hdr_sz))
                                goto out;
                }


Greetings,

  Hannes
