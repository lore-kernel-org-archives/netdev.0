From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net-next: ipv6: ndisc: allocate a ndisc socket per
 inet6_dev
Date: Mon, 25 Jun 2012 12:41:18 +0200
Message-ID: <1340620878.10893.26.camel@edumazet-glaptop>
References: <D8C50530D6022F40A817A35C40CC06A70B34E34D44@DUBX7MCDUB01.EMEA.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Menny_Hamburger@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38620 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755553Ab2FYKlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 06:41:22 -0400
Received: by bkcji2 with SMTP id ji2so2967880bkc.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 03:41:21 -0700 (PDT)
In-Reply-To: <D8C50530D6022F40A817A35C40CC06A70B34E34D44@DUBX7MCDUB01.EMEA.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-25 at 11:26 +0100, Menny_Hamburger@Dell.com wrote:
> From: mennyh <Menny_Hamburger@Dell.com>
> 
>  When an IPV6 network discovery packet does not get sent by the NIC, 
>  either because there is some S/W issue or a H/W problem with the NIC, NDP will stop
>  working and will not be able to send ndisc packets via other NICs on the machine.
>  The reason for this that there is only one global socket assigned per network for network discovery
>  (net->ipv6.ndisc_sk), and  when this socket is busy, NDP cannot be serviced by 
>  other NICS. 
>  
>  This patch adds a kernel configuration option IPV6_NDISC_SOCKET_PER_INTERFACE, 
>  which when enabled the kernel will allocate a network discovery socket per inet6_dev on creation,
>  instead of a single socket per network.
> 
> Signed-off-by: mennyh <Menny_Hamburger@Dell.com>
> ---

You obviously didn't see my patch to address this problem ?

I was waiting your feedback and you post this wrong patch instead ?

This sucks.

Test this instead. Please ?


diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 69a6330..f149d85 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -429,7 +429,6 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	int hlen = LL_RESERVED_SPACE(dev);
 	int tlen = dev->needed_tailroom;
 	int len;
-	int err;
 	u8 *opt;
 
 	if (!dev->addr_len)
@@ -439,15 +438,10 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (llinfo)
 		len += ndisc_opt_addr_space(dev);
 
-	skb = sock_alloc_send_skb(sk,
-				  (MAX_HEADER + sizeof(struct ipv6hdr) +
-				   len + hlen + tlen),
-				  1, &err);
-	if (!skb) {
-		ND_PRINTK(0, err, "ND: %s failed to allocate an skb, err=%d\n",
-			  __func__, err);
+	skb = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + len + hlen + tlen,
+			GFP_ATOMIC);
+	if (!skb)
 		return NULL;
-	}
 
 	skb_reserve(skb, hlen);
 	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
@@ -1550,16 +1544,10 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 
 	hlen = LL_RESERVED_SPACE(dev);
 	tlen = dev->needed_tailroom;
-	buff = sock_alloc_send_skb(sk,
-				   (MAX_HEADER + sizeof(struct ipv6hdr) +
-				    len + hlen + tlen),
-				   1, &err);
-	if (buff == NULL) {
-		ND_PRINTK(0, err,
-			  "Redirect: %s failed to allocate an skb, err=%d\n",
-			  __func__, err);
+	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + len + hlen + tlen,
+			 GFP_ATOMIC);
+	if (!buff)
 		goto release;
-	}
 
 	skb_reserve(buff, hlen);
 	ip6_nd_hdr(sk, buff, dev, &saddr_buf, &ipv6_hdr(skb)->saddr,
