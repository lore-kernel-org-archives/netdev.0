From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning (v2)
Date: Tue, 12 Jan 2010 17:23:11 -0800
Message-ID: <20100112172311.1bc4bab2@nehalam>
References: <20100112085633.GB6628@ff.dom.local>
	<20100112.014218.112731835.davem@davemloft.net>
	<20100112.025620.210305029.davem@davemloft.net>
	<20100112081513.0175d579@nehalam>
	<20100112180430.GA3355@del.dom.local>
	<20100112101306.6a67c0a5@nehalam>
	<20100112182447.GB3355@del.dom.local>
	<20100112104945.462cf205@nehalam>
	<20100112191611.GC3355@del.dom.local>
	<20100112112314.6d3b37d0@nehalam>
	<20100112195004.GD3355@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mikem@ring3k.org,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org,
	mbreuer@majjas.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40690 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929Ab0AMBX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2010 20:23:28 -0500
In-Reply-To: <20100112195004.GD3355@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jan 2010 20:50:04 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Tue, Jan 12, 2010 at 11:23:14AM -0800, Stephen Hemminger wrote:
> > On Tue, 12 Jan 2010 20:16:11 +0100
> > Jarek Poplawski <jarkao2@gmail.com> wrote:
> > 
> > > > 
> > > > What is supposed to happen:
> > > >   * restart sky2_restart calls napi_disable while cleaning  
> > > 
> > > Yes, but it's after the detach; similarly to sky2_suspend().
> > > (I'm not sure how safe vs such re-enabling is sky2_set_ringparam().
> > 
> > set_ringparam happens under rtnl_lock() so reset and ringparams can't
> > conflict.
> 
> I didn't mean reset. I meant tx (dev_queue_xmit()) during ringparams.

sky2_detach does
   tx_lock
   netif_detach() -- stops the queue
   tx_unlock

So if another CPU was about to send, it will have to wait
behind the tx_global_lock, and then it will see the queue as frozen.

BUT, you prod me to look harder and there is a race with
softirq (bottom half) here that needs to be fixed.


   
