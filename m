From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: How to best consolidate list of skbs (msdu) for receive?
Date: Thu, 27 Feb 2014 14:31:45 -0800
Message-ID: <1393540305.26794.47.camel@edumazet-glaptop2.roam.corp.google.com>
References: <530F85AE.8060002@candelatech.com>
	  <CAGVrzcajmuGQRi84WqWrxyUK2+xG1+b7EMTwRk4WpsDnp0B7qQ@mail.gmail.com>
	 <1393536113.26794.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <530FB348.2070701@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:44669 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbaB0Wbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 17:31:47 -0500
In-Reply-To: <530FB348.2070701@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-27 at 13:51 -0800, Ben Greear wrote:

> That said, the code below appears to work, even if it is
> not as efficient as it might be?
> 
> 			if (msdu_chaining) {
> 				struct sk_buff *next = msdu_head->next;
> 				struct sk_buff *to_free = next;
> 				int space;
> 				static int do_once = 1;
> 				msdu_head->next = NULL;
> 
> 				if (unlikely(do_once)) {
> 					ath10k_warn("htt rx msdu_chaining detected %d\n",
> 						    msdu_chaining);
> 					do_once = 0;
> 				}
> 
> 				while (next) {
> 					space = next->len - skb_tailroom(msdu_head);
> 
> 					if ((space > 0) &&
> 					    (pskb_expand_head(msdu_head, 0, space, GFP_ATOMIC) < 0)) {
> 						/* TODO:  bump some rx-oom error stat */
> 						goto outside_continue;
> 					}
> 					skb_copy_from_linear_data(next, skb_put(msdu_head, next->len),
> 								  next->len);
> 					next = next->next;
> 				}

Yep, this is very inefficient , you might copy data very often in
pskb_expand_head(), then in skb_copy_from_linear_data()

Also, if total length is big, you end up doing high order allocations,
since you generate a linear skb. This might fail under memory pressure.

What is the maximal skb->len of resulting skb ?
