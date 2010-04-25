From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] rps: optimize rps_get_cpu()
Date: Sun, 25 Apr 2010 00:48:42 -0700 (PDT)
Message-ID: <20100425.004842.225645379.davem@davemloft.net>
References: <20100424.225128.52181685.davem@davemloft.net>
	<z2h412e6f7f1004242348ibd5f96a2i7cd0557c37bb0921@mail.gmail.com>
	<20100425.003834.147984813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54169
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751104Ab0DYHsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 03:48:38 -0400
In-Reply-To: <20100425.003834.147984813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 25 Apr 2010 00:38:34 -0700 (PDT)

> From: Changli Gao <xiaosuo@gmail.com>
> Date: Sun, 25 Apr 2010 14:48:49 +0800
> 
>> Are they always aligned to 64-bit boundary? I don't think so.
> 
> If not than TCP stack should be crashing for past 15 years.

Nevermind, currently we only depend upon the addresses in struct sock
being 64-bit aligned not the protocol headers.

It shouldn't be hard to make the protocol header addresses 64-bit
aligned too.  Simply setting the default NET_IP_ALIGN to '6' instead
of '2' ought to be sufficient.

skb->data upon alloc_skb() is 64-bit aligned.

So if we skb_reserve(NET_IP_ALIGN '6'), then we have the ethernet
header (14 bytes).  And since 'saddr' is 12 bytes into struct iphdr it
will be (6 + 14 + 12) == 32 bytes in from the original 64-bit aligned
skb->data.

Therefore, since skb->data is 64-bit aligned, skb->data plus a
multiple of 8 (which 32 is) will also be 64-bit aligned, and that
means iph->saddr will be 64-bit aligned.
