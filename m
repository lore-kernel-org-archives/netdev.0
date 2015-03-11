From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 1/2] net: implement dma cache skb allocator
Date: Wed, 11 Mar 2015 08:42:40 -0700
Message-ID: <1426088560.11398.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426009384-11544-1-git-send-email-_govind@gmx.com>
	 <1426009384-11544-2-git-send-email-_govind@gmx.com>
	 <54FF5521.5000007@redhat.com> <alpine.LNX.2.03.1503111359280.3394@ws.cisco>
	 <5500496E.1060701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Govindarajulu Varadarajan <_govind@gmx.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:43040 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285AbbCKPmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 11:42:43 -0400
Received: by igbhn18 with SMTP id hn18so13296407igb.2
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 08:42:42 -0700 (PDT)
In-Reply-To: <5500496E.1060701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 06:55 -0700, Alexander Duyck wrote:

> That definitely helps but still leaves you open since a 257 byte packet
> would be consuming 9K in that case.  Also standard flows with frames of
> 1514 still take a hard hit with a receive buffer size of 9K.

One possible way to deal with this would be to try to use order-2 pages,
(but not compound pages) but break them.

split_page(page, 2);

struct page *page0 = page;
struct page *page1 = page + 1;
struct page *page2 = page + 2;
struct page *page3 = page + 3;


if frame length <= 4096, attach page0 as skb first frag, and free
page[1-3]

If frame length <= 8192 bytes, driver can attach page0 & page1 to the
skb, and free page[2-3]

Otherwise, attach page[0-2] to skb and free page3

Not sure if buddy allocator will be pleased, but worth trying ?
