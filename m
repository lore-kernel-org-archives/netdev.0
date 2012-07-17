From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4] pch_gbe: Fix the checksum fill to the error
 location
Date: Tue, 17 Jul 2012 10:48:33 +0200
Message-ID: <1342514913.2626.277.camel@edumazet-glaptop>
References: <40680C535D6FE6498883F1640FACD44D011432D4@ka-exchange-1.kontronamerica.local>
	 <1342508968.2626.148.camel@edumazet-glaptop>
	 <50051C83.7020504@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Cress <andy.cress@us.kontron.com>, netdev@vger.kernel.org
To: Zhong Hongbo <hongbo.zhong@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45230 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330Ab2GQIsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 04:48:40 -0400
Received: by eaak11 with SMTP id k11so55139eaa.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 01:48:39 -0700 (PDT)
In-Reply-To: <50051C83.7020504@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 16:04 +0800, Zhong Hongbo wrote:

> Hi Eric,
> 
> When forwarding network packages at the network layer, the variable
> value of skb->transport_header is unknown. In my test, the variable
> value of skb->transport_header is equal to skb->network_header. So
> When you count the checksum as following:
> 
> offset = skb_transport_offset(skb);
> 
> skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
> We should only count the TCP checksum, But it maybe include IP part.
> 
> tcp_hdr(skb)->check = csum_tcpudp_magic(iph->saddr, iph->daddr,
> skb->len - offset, IPPROTO_TCP, skb->csum);
> We should fill the checksum in TCP package, But maybe fill it in other
> location and cover the useful information, such as source ip.
> 
> So We should count the TCP checksum and fill it in the correct
> location. Or else the forwarding network package will be drop for the
> error checksum.
> 



So maybe you should instead test 

if (skb->ip_summed == CHECKSUM_PARTIAL) {
	...
	skb_checksum_start_offset(skb); /* is valid */
}
