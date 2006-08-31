From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [IPV6] MIP6: Fix to update IP6CB when cloned skbuff is received at HAO. (Re: [PATCH 23/44] [IPV6]: Allow to replace skbuff by TLV parser.)
Date: Thu, 31 Aug 2006 21:05:41 +0900
Message-ID: <200608312105.41650.nakam@linux-ipv6.org>
References: <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <20060823.192009.35356948.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:4258 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1751578AbWHaMFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 08:05:44 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060823.192009.35356948.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Thu, 24 Aug 2006 00:02:24 +0900
> 
> > In receiving Mobile IPv6 home address option which is a TLV carried
> > by destination options header, kernel will try to mangle source adderss
> > of packet. Think of cloned skbuff it is required to replace it by
> > the parser just like routing header case.
> > This is a framework to achieve that to allow TLV parser to replace
> > inbound skbuff pointer.
> > 
> > Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Applied to net-2.6.19, thanks a lot.
> 

I've found issue about the patch above.
This is a fix for it, to update IP6CB when cloned skbuff is received at HAO.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/ipv6/exthdrs.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index f4c7629..ec93a1d 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -233,9 +233,14 @@ static int ipv6_dest_hao(struct sk_buff 
 
 	if (skb_cloned(skb)) {
 		struct sk_buff *skb2 = skb_copy(skb, GFP_ATOMIC);
+		struct inet6_skb_parm *opt2;
+
 		if (skb2 == NULL)
 			goto discard;
 
+		opt2 = IP6CB(skb2);
+		memcpy(opt2, opt, sizeof(*opt2));
+
 		kfree_skb(skb);
 
 		/* update all variable using below by copied skbuff */
@@ -296,6 +301,7 @@ #endif
 	if (ip6_parse_tlv(tlvprocdestopt_lst, skbp)) {
 		skb = *skbp;
 		skb->h.raw += ((skb->h.raw[1]+1)<<3);
+		opt = IP6CB(skb);
 #ifdef CONFIG_IPV6_MIP6
 		opt->nhoff = dstbuf;
 #else
@@ -690,6 +696,7 @@ int ipv6_parse_hopopts(struct sk_buff **
 	if (ip6_parse_tlv(tlvprochopopt_lst, skbp)) {
 		skb = *skbp;
 		skb->h.raw += (skb->h.raw[1]+1)<<3;
+		opt = IP6CB(skb);
 		opt->nhoff = sizeof(struct ipv6hdr);
 		return 1;
 	}
-- 
1.4.2

