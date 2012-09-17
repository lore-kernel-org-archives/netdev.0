From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Mon, 17 Sep 2012 19:02:06 +0200
Message-ID: <1347901326.26523.149.camel@edumazet-glaptop>
References: <1347868144.26523.71.camel@edumazet-glaptop>
	 <20120917.121243.1665284878800146060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40488 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584Ab2IQRCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 13:02:12 -0400
Received: by bkwj10 with SMTP id j10so2646250bkw.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 10:02:11 -0700 (PDT)
In-Reply-To: <20120917.121243.1665284878800146060.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-17 at 12:12 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 17 Sep 2012 09:49:04 +0200
> 
> > 2) Use order-3 pages (or order-0 pages if page size is >= 32768)
> 
> We could do with an audit to make sure drivers (and the stack in
> general) can handle SKB frags of length > PAGE_SIZE.
> 
> I have no idea whether such problems might actually exist, but
> I can say it's a case that gets not so much testing.

I did a (quick) audit and it appears some NIC have limits like 16KB,
but they have helpers to support this, since some arches have
PAGE_SIZE=65536

ixgbe is an example, although it might need some tweaking if this code
path was not tested.

On the other hand, bnx2x has some special code to linearize too
fragmented skbs (in bnx2x_pkt_req_lin(), if skb_shinfo(skb)->nr_frags >=
10)

By the way I did more performance tests, and the speedup is more close
of 20 %

A driver already exports a dev->gso_max_size, dev->gso_max_segs, I guess
it could export a dev->max_seg_order (default to 0)
