From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4] pch_gbe: Fix the checksum fill to the error
 location
Date: Tue, 17 Jul 2012 09:09:28 +0200
Message-ID: <1342508968.2626.148.camel@edumazet-glaptop>
References: <40680C535D6FE6498883F1640FACD44D011432D4@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Zhong Hongbo <hongbo.zhong@windriver.com>
To: Andy Cress <andy.cress@us.kontron.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55518 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764Ab2GQHJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 03:09:34 -0400
Received: by eaak11 with SMTP id k11so23086eaa.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 00:09:33 -0700 (PDT)
In-Reply-To: <40680C535D6FE6498883F1640FACD44D011432D4@ka-exchange-1.kontronamerica.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-16 at 13:03 -0700, Andy Cress wrote:
> Author: Zhong Hongbo <hongbo.zhong@windriver.com>
> 
> Due to some unknown hardware limitations the pch_gbe hardware cannot
> calculate checksums when the length of network package is less
> than 64 bytes, where we will surprisingly encounter a problem of
> the destination IP incorrectly changed.
> 
> When forwarding network packages at the network layer the IP packages
> won't be relayed to the upper transport layer and analyzed there,
> consequently, skb->transport_header pointer will be mistakenly remained
> the same as that of skb->network_header, resulting in TCP checksum
> wrongly
> filled into the field of destination IP in IP header.
> 
> We can fix this issue by manually calculate the offset of the TCP
> checksum
>  and update it accordingly.
> 
> We would normally use the skb_checksum_start_offset(skb) here, but in
> this
> case it is sometimes -2 (csum_start=0 - skb_headroom=2 => -2), hence the
> manual calculation.
> 
> Signed-off-by: Zhong Hongbo <hongbo.zhong@windriver.com>
> Merged-by: Andy Cress <andy.cress@us.kontron.com>


Hmm... I fail to understand why you care about NIC doing checksums,
while pch_gbe_tx_queue() make a _copy_ of each outgoing
packets.

There _must_ be a way to avoid most of these copies (ie not touching
payload), only mess with the header to insert these 2 nul bytes ?

/* [Header:14][payload] ---> [Header:14][paddong:2][payload]    */

So at device setup : dev->needed_headroom = 2;

and in xmit,

	if (skb_headroom(skb) < 2) {
		struct sk_buff *skb_new;

		skb_new = skb_realloc_headroom(skb, 2);
		if (!skb_new) { handle error }
		consume_skb(skb);
		skb = skb_new;
	}
	ptr = skb_push(skb, 2);
	memmove(ptr, ptr + 2, ETH_HLEN);
	ptr[ETH_HLEN] = 0;
	ptr[ETH_HLEN + 1] = 0;
