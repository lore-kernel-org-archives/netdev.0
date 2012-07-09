From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Mon, 09 Jul 2012 15:54:03 +0200
Message-ID: <1341842043.3265.2914.camel@edumazet-glaptop>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	 <1341474192.2583.3299.camel@edumazet-glaptop>
	 <CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	 <1341477192.2583.3415.camel@edumazet-glaptop>
	 <CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	 <1341481760.2583.3579.camel@edumazet-glaptop>
	 <CACVXFVNYwNrdWS_EiQ4O0-ou369AQ2tB4qbvmzY1rt5T3QnyUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51116 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679Ab2GINyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 09:54:08 -0400
Received: by eaak11 with SMTP id k11so4336739eaa.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 06:54:07 -0700 (PDT)
In-Reply-To: <CACVXFVNYwNrdWS_EiQ4O0-ou369AQ2tB4qbvmzY1rt5T3QnyUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-09 at 21:23 +0800, Ming Lei wrote:

> Looks the patch replaces skb_clone with netdev_alloc_skb_ip_align and
> introduces extra copies on incoming data, so would you mind explaining
> it in a bit detail? And why is skb_clone not OK for the purpose?

Problem with cloning is that some paths will have to make a private copy
of the skb.

So you dont see the cost here in the driver, but later in upper stacks.

Since this driver defaults to a huge RX area of more than 16Kbytes,
a copy to a much smaller skb (we call this 'copybreak' in our jargon )
is more than welcome to avoid OOM problems anyway.

TCP coalescing (skb_try_coalesce) for example wont work for cloned skbs,
so TCP receive window will close pretty fast, and performance sucks in
lossy environments (like the Internet)

Actually, since this driver lies about skb->truesize, a single UDP frame
consumes 32Kbytes of memory, escaping normal memory limits we have in
kernel by a factor of 64. Thats pretty bad, especially for a beagle
board.
