From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 04 Jun 2012 16:09:18 +0200
Message-ID: <1338818958.2760.1824.camel@edumazet-glaptop>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu>
	 <1337269380.3403.10.camel@edumazet-glaptop> <20120517155621.GK14498@1wt.eu>
	 <1337272404.3403.18.camel@edumazet-glaptop> <20120517164016.GL14498@1wt.eu>
	 <1337273387.3403.24.camel@edumazet-glaptop>
	 <1337276056.3403.37.camel@edumazet-glaptop>
	 <20120604123738.GA28992@redhat.com>
	 <1338815213.2760.1806.camel@edumazet-glaptop>
	 <20120604134138.GA29814@redhat.com>
	 <1338818501.2760.1821.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51847 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134Ab2FDOJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 10:09:23 -0400
Received: by eaak11 with SMTP id k11so1180200eaa.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 07:09:22 -0700 (PDT)
In-Reply-To: <1338818501.2760.1821.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 16:01 +0200, Eric Dumazet wrote:

> Not sure 12 bytes of headroom would be enough (instead of the
> NET_SKB_PAD reserved in netdev_alloc_skb_ip_align(), but what could be
> done indeed is to use the first page as the skb->head, so using
> build_skb() indeed, removing one fragment, one (small) copy and one
> {put|get}_page() pair.

It would also avoid 'pulling' tcp data payload in linear part.

page_to_skb() does :

copy = len;
if (copy > skb_tailroom(skb))
	copy = skb_tailroom(skb);
memcpy(skb_put(skb, copy), p, copy);

This means GRO or TCP coalescing (or splice()) has to handle two
segments to fetch data.
