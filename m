From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 05/11] net/mlx5e: Support RX multi-packet
 WQE (Striding RQ)
Date: Mon, 18 Apr 2016 07:17:13 -0700
Message-ID: <1460989033.10638.120.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
	 <1460928725-18741-6-git-send-email-saeedm@mellanox.com>
	 <1460939371.10638.97.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1460983695.10638.113.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CALzJLG_W9SkgMBQp86P0WDknw4Kc=DCBrvpPemAUbRX=r4r8Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:33334 "EHLO
	mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbcDRORY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 10:17:24 -0400
Received: by mail-vk0-f54.google.com with SMTP id n62so105539002vkb.0
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 07:17:23 -0700 (PDT)
In-Reply-To: <CALzJLG_W9SkgMBQp86P0WDknw4Kc=DCBrvpPemAUbRX=r4r8Yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-18 at 16:05 +0300, Saeed Mahameed wrote:
> On Mon, Apr 18, 2016 at 3:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Sun, 2016-04-17 at 17:29 -0700, Eric Dumazet wrote:
> >
> >>
> >> If really you need to allocate physically contiguous memory, have you
> >> considered converting the order-5 pages into 32 order-0 ones ?
> >
> > Search for split_page() call sites for examples.
> >
> >
> 
> Thanks Eric, we are already evaluating split_page as we speak.
> 
> We did look but could not find any specific alloc_pages API that
> allocates many physically contiguous pages with order0 ! so we assume
> it is ok to use split_page.

Note: I have no idea of split_page() performance :

Buddy page allocator has to aggregate pages into order-5, then we would
undo the work, touching 32 cache lines.

You might first benchmark a simple loop doing 

loop 10,000,000 times
 Order-5 allocation
 split into 32 order-0
 free 32 pages


Another idea would be to have a way to control max number of order-5
pages that a port would be using.

Since driver always own a ref on a order-5 pages, idea would be to
maintain a circular ring of up to XXX such pages, so that we can detect
an abnormal use and fallback to order-0 immediately.
