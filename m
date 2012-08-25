From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Q: what protects dev->napi_list?
Date: Sat, 25 Aug 2012 08:49:34 +0200
Message-ID: <1345877374.19483.88.camel@edumazet-glaptop>
References: <1345801604.11584.24.camel@cr0>
	 <1345803142.29722.20.camel@edumazet-glaptop>
	 <1345804753.11584.43.camel@cr0>
	 <1345807778.29722.98.camel@edumazet-glaptop>
	 <1345874922.14276.14.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sylvain Munaut <s.munaut@whatever-company.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38556 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753473Ab2HYGtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 02:49:39 -0400
Received: by weyx8 with SMTP id x8so1403168wey.19
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 23:49:38 -0700 (PDT)
In-Reply-To: <1345874922.14276.14.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-08-25 at 14:08 +0800, Cong Wang wrote:
> On Fri, 2012-08-24 at 13:29 +0200, Eric Dumazet wrote:
> > On Fri, 2012-08-24 at 18:39 +0800, Cong Wang wrote:
> > > 
> > > Yeah, but bnx2 driver calls it at other time too, for example
> > > bnx2_change_ring_size() which in turn could be called by
> > > bnx2_set_channels().
> > 
> > Then at this point, device is stopped, or should be.
> > 
> 
> But poll_napi() is still iterating the dev->napi_list, could anyone
> stops it?
> 
> IOW, the following race condition may happen:
> 
> static void poll_napi(struct net_device *dev)
> {               
>         struct napi_struct *napi;
>         int budget = 16;
>                 
>         WARN_ON_ONCE(!irqs_disabled());
>                 
>         list_for_each_entry(napi, &dev->napi_list, dev_list) {
>                 local_irq_enable();
> 
> 				//<-- Another process may call
> 				//bnx2_change_ring_size() to del
> 				//napi from dev, on other CPU.
> 
>                 local_irq_disable();
>         }
> }
> 
> 

Are you trying to say netpoll is buggy ?

Thats the first time I ear that !

Just kidding.

I repeat again : If bnx2_change_ring_size() is called while netconsole
is able to enter poll_napi(), then netpoll is buggy and should be fixed.

napi_list is manipulated under a mutex protection, and there is no way
netpoll can use a mutex. Same mutex protection for all other netdevice
management, so even calling start_xmit() should be forbidden in this
state.

Therefore, netpoll must be disabled while a device is reconfigured.
