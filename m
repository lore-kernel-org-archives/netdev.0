From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Tue, 10 Jul 2012 16:02:11 +0200
Message-ID: <1341928931.3265.5263.camel@edumazet-glaptop>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	 <1341474192.2583.3299.camel@edumazet-glaptop>
	 <CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	 <1341477192.2583.3415.camel@edumazet-glaptop>
	 <CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	 <1341481760.2583.3579.camel@edumazet-glaptop>
	 <CACVXFVNYwNrdWS_EiQ4O0-ou369AQ2tB4qbvmzY1rt5T3QnyUw@mail.gmail.com>
	 <1341842043.3265.2914.camel@edumazet-glaptop>
	 <CACVXFVNdiwVn1Mo--N4N0HdYrEJizExtd_cppT4tS=mjog2PKw@mail.gmail.com>
	 <1341895143.3265.4049.camel@edumazet-glaptop>
	 <CACVXFVPgqtSN3BrEXRxSv4yxaxCni495SxZNXBmYQpagmxk2tQ@mail.gmail.com>
	 <1341908908.3265.4508.camel@edumazet-glaptop>
	 <CACVXFVM-fhQJX+EFNoFSnuVAjqfRM7OjzbQML7H+tMEjxG7Rug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:65395 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235Ab2GJOCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 10:02:16 -0400
Received: by eeit10 with SMTP id t10so4702460eei.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 07:02:14 -0700 (PDT)
In-Reply-To: <CACVXFVM-fhQJX+EFNoFSnuVAjqfRM7OjzbQML7H+tMEjxG7Rug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am kind of annoyed you sent on netdev a copy of a _private_ mail.

Next time, make sure you dont do that without my consent.

On Tue, 2012-07-10 at 21:37 +0800, Ming Lei wrote:

> Could you explain why the truesize of SKB is 8KB for single
> 1500bytes frame?
> 

Because the driver uses skb_alloc(4096) for example ?

I don't know, you don't tell us the driver.


Goal is to have skb->head points to a 2048 bytes area, so truesize
should be 2048 + sizeof(sk_buff)  (including struct shared_info)

> I observed it is 2560bytes for RX SKBs inside asix_rx_fixup with
> rx_urb_size of 2048 on beagle-xm.
> 

Thats because using 2048 bytes for the urb buffer (excluding
shared_info) means you need :

2048 + sizeof(struct shared_info) + sizeof(sk_buff) = 2560

In fact 2048 + sizeof(struct shared_info) means a full 4096 area is
used.

You have 2560 on recent kernels because the way netdev_alloc_frag()
works.

Thats why copybreak can actually saves ram. Since it is adding a copy,
we try to use it only on slow devices.
