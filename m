From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Fri, 22 Nov 2013 15:33:22 +0100
Message-ID: <528F6B32.5050103@6wind.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com> <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com> <20131121121246.GD31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Saurabh Mohan <saurabh.mohan@vyatta.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:64658 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755445Ab3KVOd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 09:33:26 -0500
Received: by mail-wg0-f51.google.com with SMTP id l18so1221298wgh.30
        for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 06:33:25 -0800 (PST)
In-Reply-To: <20131121121246.GD31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2013 01:12 PM, Steffen Klassert wrote:
 > On Wed, Nov 06, 2013 at 09:05:53AM +0100, Christophe Gouault wrote:
 >>
 >> @@ -133,7 +134,13 @@ static int vti_rcv(struct sk_buff *skb)
 >>            * only match policies with this mark.
 >>            */
 >>           skb->mark = be32_to_cpu(tunnel->parms.o_key);
 >> +        /* The packet is decrypted, but not yet decapsulated.
 >> +         * Temporarily make network_header point to the inner header
 >> +         * for policy check.
 >> +         */
 >> +        skb_reset_network_header(skb);
 >>           ret = xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb);
 >
 > If we do it like this, we would do an input policy check even for
 > packets that should be forwarded. I think that's a bit odd.

Admittedly, a forward policy check would be more appropriate for
forwarded traffic.

 > If we really change to match plaintext traffic, we should do
 > it like Fan Du proposed. Remove the policy check here and
 > let the further layers do the policy enforcement. All we
 > have to do is to set the skb mark, then the lookup should
 > match the vti policy.

This solution sounds seductive, however, we must be careful because we
change the skb input device (from the physical interface to the vti
interface). So we are supposed to call skb_scrub_packet as is normally
done when decapsulating a packet from a tunnel. This will reset the skb
secpath and mark, and hence will compromise the deferred inbound policy
check.

 > It is already clear that this packet was IPsec transformed
 > when it enters vti_rcv, so deferring the policy check should
 > be ok.

I had in mind to later support cross netns in vti interfaces like for
ipip tunnels (different netns for the decapsulated and encapsulated
packets). With the deferred inbound policy check, the SA and SP will not
be in the same netns, this will cause problems for the inbound policy check.

Best Regards,
Christophe
