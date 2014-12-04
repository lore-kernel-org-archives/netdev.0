From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipip6 - integer underrun when handlince icmpv4 unreachable
 messages
Date: Thu, 4 Dec 2014 09:56:29 +0100
Message-ID: <20141204085628.GG6390@secunet.com>
References: <546A6E04.30603@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <roque@di.fc.ul.p>,
	<kuznet@ms2.inr.ac.ru>, <r.venning@telstra.com>, <nate@thebog.net>
To: Alexander Wetzel <alexander.wetzel@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50803 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753233AbaLDI4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2014 03:56:37 -0500
Content-Disposition: inline
In-Reply-To: <546A6E04.30603@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 17, 2014 at 10:52:04PM +0100, Alexander Wetzel wrote:
> Hello netdev,
> 
> the current code to translate icmpv4 "destination unreachable" packets
> to icmpv6 is later generating an integer underrun when calling
> icmpv6_send, by later calling skb_network_header_len and subtracting a
> bigger number from a lower one.

I'd guess the call to skb_network_header_len() in _decode_session6()
is the problematic one, right?

> 
> The issue is not visible for vanilla kernels and works correctly from
> a user perspective, but a kernel with the PAX patches and enabled
> "size overflow protection" will panic immediately when it's getting an
> icmpv4 destination unreachable packet back for an encapsulated ipv6
> packet. (Remote tunnel endpoint not reachable.)
> 
> I think I've tracked the issue down and can show you the problem with
> the code... as I understand it as non-programmer greping the sources
> and googeling functions. I was even able to find a fix which passes
> the functionality test, but I'm unqualified to rate the correctness of
> it and so are reaching out to you for that.
> 
> What happens (output of printk's) with transport_header and
> network_header around "skb_reset_network_header" is described below
> the function.
> 
> Near the end of the mail there are two links to the gentoo bug tracker
> and pax forum, suggesting to put this forward to the lkml/netdev for
> review, also including more details on the panics.
> 
> So here the function "ipip6_err_gen_icmpv6_unreach" from
> net/ipv6/sit.c with some remarks and one new line which seems to fix
> the problem:
> 
> ************************************************************************
> static int ipip6_err_gen_icmpv6_unreach(struct sk_buff *skb)
> {
>         int ihl = ((const struct iphdr *)skb->data)->ihl*4;
>         struct rt6_info *rt;
>         struct sk_buff *skb2;
> 
>         if (!pskb_may_pull(skb, ihl + sizeof(struct ipv6hdr) + 8))
>                 return 1;
> 
> // we clone the ipv4 skb in skb2 to prepare the icmpv6 packet
>         skb2 = skb_clone(skb, GFP_ATOMIC);
> 
>         if (!skb2)
>                 return 1;
> 
> // we clean up the cloned skb2
>         skb_dst_drop(skb2);
>         skb_pull(skb2, ihl);
> // The network header is reset
>         skb_reset_network_header(skb2);
> 
> //THE PROPOSED FIX: The following line is NOT in the current code
>         skb_reset_transport_header(skb2);

This will make your panic with PAX go away, but the offset to
the transport header is still wrong. Also, it is not just the
sit tunnel that has this problem. All ipv6 tunnels are affected.

I think the easiest is to fix it in _decode_session6().
Could you please try the patch below?

Subject: [PATCH] xfrm6: Fix transport header offset in _decode_session6.

skb->transport_header might not be valid when we do a reverse
decode because the ipv6 tunnel error handlers don't update it
to the inner transport header. This leads to a wrong offset
calculation and to wrong layer 4 informations. We fix this
by using the size of the ipv6 header as the first offset.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_policy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index ac49f84..576fc42 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -130,8 +130,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 {
 	struct flowi6 *fl6 = &fl->u.ip6;
 	int onlyproto = 0;
-	u16 offset = skb_network_header_len(skb);
 	const struct ipv6hdr *hdr = ipv6_hdr(skb);
+	u16 offset = sizeof(*hdr);
 	struct ipv6_opt_hdr *exthdr;
 	const unsigned char *nh = skb_network_header(skb);
 	u8 nexthdr = nh[IP6CB(skb)->nhoff];
-- 
1.9.1
