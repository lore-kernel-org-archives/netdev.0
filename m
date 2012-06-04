From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 04 Jun 2012 21:52:59 +0200
Message-ID: <1338839579.2760.1932.camel@edumazet-glaptop>
References: <1337273387.3403.24.camel@edumazet-glaptop>
	 <1337276056.3403.37.camel@edumazet-glaptop>
	 <20120604123738.GA28992@redhat.com>
	 <1338815213.2760.1806.camel@edumazet-glaptop>
	 <20120604134138.GA29814@redhat.com>
	 <1338818501.2760.1821.camel@edumazet-glaptop>
	 <20120604141731.GA30226@redhat.com>
	 <1338822064.2760.1834.camel@edumazet-glaptop>
	 <20120604181623.GF32205@redhat.com>
	 <1338838185.2760.1899.camel@edumazet-glaptop>
	 <20120604194330.GA1648@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53486 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146Ab2FDTxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 15:53:05 -0400
Received: by bkcji2 with SMTP id ji2so3952968bkc.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 12:53:03 -0700 (PDT)
In-Reply-To: <20120604194330.GA1648@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 22:43 +0300, Michael S. Tsirkin wrote:
> On Mon, Jun 04, 2012 at 09:29:45PM +0200, Eric Dumazet wrote:
> > On Mon, 2012-06-04 at 21:16 +0300, Michael S. Tsirkin wrote:
> > 
> > > Yes but if a tcp socket then hangs on, on one of the fragments,
> > > while the other has been freed, the whole page is still
> > > never reused, right?
> > > 
> > > Doesn't this mean truesize should be 4K?
> > > 
> > 
> > Yes, or more exactly PAGE_SIZE, but then performance would really go
> > down on machines with 64KB pages.
> > Maybe we should make the whole frag
> > head idea enabled only for PAGE_SIZE=4096.
> > 
> > Not sure we want to track precise truesize, as the minimum truesize is
> > SKB_DATA_ALIGN(length + NET_SKB_PAD) + SKB_DATA_ALIGN(sizeof(struct
> > skb_shared_info)) (64 + 64 + 320) = 448
> > 
> > Its not like buggy drivers that used truesize = length
> > 
> > 
> 
> Interesting. But where's the threshold?
> 

It all depends on the global limit you have on your machine.

If you allow tcp memory to use 10% of ram, then a systematic x4 error
would allow it to use 40% of ram. Mabe not enough to crash.

Now you have to find a real workload able to hit this limit for real...

But, if you "allow" a driver to claim a truesize of 1 (instead of 4096),
you can reach the limit and OOM faster

You know, even the current page stored for each socket (sk_sndmsg_page)
can be a problem if you setup 1.000.000 tcp sockets. That can consume
4GB of ram (added to inode/sockets themselves)
This is not really taken into account right now...
