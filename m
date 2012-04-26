From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] allow skb->head to point/alias to first skb frag
Date: Thu, 26 Apr 2012 10:10:54 +0200
Message-ID: <1335427854.2775.15.camel@edumazet-glaptop>
References: <alpine.DEB.2.00.1204241026410.735@wel-95.cs.helsinki.fi>
	 <20120424.041018.1514311596818654005.davem@davemloft.net>
	 <alpine.DEB.2.00.1204241113020.735@wel-95.cs.helsinki.fi>
	 <20120424.042546.2154907239944513463.davem@davemloft.net>
	 <alpine.DEB.2.00.1204241131580.735@wel-95.cs.helsinki.fi>
	 <1335257803.5205.133.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	Netdev <netdev@vger.kernel.org>, therbert@google.com,
	ncardwell@google.com, maze@google.com,
	Yuchung Cheng <ycheng@google.com>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49321 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754263Ab2DZILB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 04:11:01 -0400
Received: by bkuw12 with SMTP id w12so734484bku.19
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 01:11:00 -0700 (PDT)
In-Reply-To: <1335257803.5205.133.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-24 at 10:56 +0200, Eric Dumazet wrote:

> Really I have many doubts about GRO today.

Particularly if a NIC driver provides linear skbs :
Resulting gro skb is a list of skbs, no memory savings, and many cache
line misses when copying to userland.

Maybe we could have a new kind of skb head allocation/setup, pointing to
a frag of 2048 bytes instead of a kmalloc() blob.

Right now, a fragged skb used 3 blocks of memory :

1) struct sk_buff
2) a bloc of 512 or 1024 or 2048 bytes of memory (skb->head)
3) a frag of 2048 (or PAGE_SIZE/2 or PAGE_SIZE)

While a linear skb has :

1) struct sk_buff
2) a bloc of 512 or 1024 or 2048 bytes of memory (skb->head) from
kmalloc()


Idea would have :

1) struct sk_buff
2) skb->head points to frag (aliasing, no memory allocation)
3) frag of 2048 (or PAGE_SIZE/2 or PAGE_SIZE)

Or the reverse (no frag so that skb is considered as linea), but special
code to 'allow' this skb head be considered as a frag when needed
(splice() code, or GRO merge, or TCP coalescing)


That would make GRO (and TCP coalescing) much more efficient, since the
resulting aggregated skb would be :
1) struct sk_buff
2) skb->head points to 1st frag (aliasing, no memory allocation)
3) array of [1..16] frags
