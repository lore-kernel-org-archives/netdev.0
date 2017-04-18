From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: calculate L4 checksums also for GSO case
 before encrypting packets
Date: Tue, 18 Apr 2017 11:09:19 +0200
Message-ID: <20170418090919.GD30104@secunet.com>
References: <1491849727-32008-1-git-send-email-aatteka@ovn.org>
 <20170411070755.GW5092@secunet.com>
 <CAMQa7Biajree5Kc1fOWQN42R1UDDGp7ZevZZRtUMZOKDWTk-Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ansis Atteka <aatteka@ovn.org>, <netdev@vger.kernel.org>
To: Ansis Atteka <ansisatteka@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:44564 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755947AbdDRJJa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 05:09:30 -0400
Content-Disposition: inline
In-Reply-To: <CAMQa7Biajree5Kc1fOWQN42R1UDDGp7ZevZZRtUMZOKDWTk-Vw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 07:45:08PM -0700, Ansis Atteka wrote:
> On 11 April 2017 at 00:07, Steffen Klassert <steffen.klassert@secunet.com>
> wrote:
> >
> > What's wrong with the checksum provided by the GSO layer and
> > why we have to do this unconditionally here?
> >
> 
> I believe with "GSO layer" you meant the skb_gso_segment() function
> invocation from xfrm_output_gso()?
> 
> If so, then the problem with that is that the list of the skb's returned by
> that function could be in CHECKSUM_PARTIAL state if skb came from a UDP
> tunnel such as Geneve:

This should not happen. We don't announce checksum capabilities,
so the GSO layer should generate the full checksum.

__skb_udp_tunnel_segment() and udp4_ufo_fragment() add the
NETIF_F_HW_CSUM flag to features. This is certainly wrong
if the packet undergoes an IPsec transformation.

I don't have a testcase for this, so not sure if this is
your problem. Could you try the (untested) patch below?

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index b2be1d9..cc0c89c 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -74,7 +74,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	 * outer one so strip the existing checksum feature flags and
 	 * instead set the flag based on our outer checksum offload value.
 	 */
-	if (remcsum || ufo) {
+	if ((remcsum || ufo) && !(skb_dst(skb) && dst_xfrm(skb_dst(skb)))) {
 		features &= ~NETIF_F_CSUM_MASK;
 		if (!need_csum || offload_csum)
 			features |= NETIF_F_HW_CSUM;
@@ -238,7 +238,7 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 	 * due to the fact that we have already done the checksum in
 	 * software prior to segmenting the frame.
 	 */
-	if (!skb->encap_hdr_csum)
+	if (!skb->encap_hdr_csum && !(skb_dst(skb) && dst_xfrm(skb_dst(skb))))
 		features |= NETIF_F_HW_CSUM;
 
 	/* Fragment the skb. IP headers of the fragments are updated in
