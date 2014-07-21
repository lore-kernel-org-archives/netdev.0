From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] tun: stop tx queue when limit is hit
Date: Mon, 21 Jul 2014 10:56:39 +0200
Message-ID: <1405932999.10255.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405882285-3072-1-git-send-email-fw@strlen.de>
	 <20140720.223313.1589952322700027038.davem@davemloft.net>
	 <20140721065419.GB21375@breakpoint.cc>
	 <20140721083106.GC21375@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mst@redhat.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:39417 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497AbaGUI4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 04:56:53 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so3720732wib.3
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 01:56:51 -0700 (PDT)
In-Reply-To: <20140721083106.GC21375@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-07-21 at 10:31 +0200, Florian Westphal wrote:
> Florian Westphal <fw@strlen.de> wrote:
> > David Miller <davem@davemloft.net> wrote:
> > > From: Florian Westphal <fw@strlen.de>
> > > Date: Sun, 20 Jul 2014 20:51:25 +0200
> > > 
> > > > Currently tun just frees the skb and returns NETDEV_TX_OK
> > > > when queue length exceeds txqlen.
> > > > 
> > > > This causes severe packetloss and unneeded resource
> > > > consumption on host when sending to vm connected via tun.
> > > > 
> > > > Instead, lets stop the transmit queue and start it once
> > > > packets are consumed from the queue.  This allows the network
> > > > stack to control applications that send data via tun device.
> > > 
> > > I strongly suspect the current behavior is intentional, see
> > > commit:
> > > 
> > > commit 5d097109257c03a71845729f8db6b5770c4bbedc
> > > Author: Michael S. Tsirkin <mst@redhat.com>
> > > Date:   Mon Dec 3 10:07:14 2012 +0000
> > > 
> > >     tun: only queue packets on device
> > 
> > Looks like you're right :-/
> > 
> > Alright, please ignore my patch.
> > 
> > That being said, the current behaviour isn't ideal either.
> > 
> > It took me quite some time to realize that packetloss
> > was on the sender side inside tun driver and not on the receiver
> > vm.  Not stopping the queue was a bit ... unexpected.
> 
> Michael, do you think we could restore the 'stop queue' default
> behaviour?
> 
> Looking at your changelog, the only concern seems to be the
> 'packets never consumed'/'receiver is stuck forever' case.
> 
> What about reverting 5d097109257c03a7184, and then adding some
> type of tun watchdog that will zap the rcv queue + tx queue wakeup?
> 
> That should be quite noisy if we combine it with the WARN_ON
> you usually get when (physical) NIC driver detect stalled tx unit.
> 
> What do you think?

Note that this patch had the ability to choose the behavior (drop or
back pressure)

 http://patchwork.ozlabs.org/patch/338951/ ?
