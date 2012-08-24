From: Cong Wang <amwang@redhat.com>
Subject: Re: Q: what protects dev->napi_list?
Date: Fri, 24 Aug 2012 18:39:13 +0800
Message-ID: <1345804753.11584.43.camel@cr0>
References: <1345801604.11584.24.camel@cr0>
	 <1345803142.29722.20.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sylvain Munaut <s.munaut@whatever-company.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1949 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752217Ab2HXKjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2012 06:39:20 -0400
In-Reply-To: <1345803142.29722.20.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 12:12 +0200, Eric Dumazet wrote:
> On Fri, 2012-08-24 at 17:46 +0800, Cong Wang wrote:
> > Hi,
> > 
> > Sylvain reported a netpoll CPU stall
> > http://marc.info/?l=linux-netdev&m=134563282530588&w=2
> > 
> > I tried to provide some fix for it:
> > http://marc.info/?l=linux-netdev&m=134571069921429&w=2
> > 
> > When reviewing that code, I noticed a problem, it seems dev->napi_list
> > is not protected by any lock? What if the device driver calls
> > netif_napi_del() meanwhile we are iterating &dev->napi_list in
> > poll_napi()? It seems netif_napi_del()/netif_napi_add() are usually
> > called with the RTNL lock held during driver init/uninit, but again
> > poll_napi() doesn't have RTNL lock.
> > 
> 
> Of course poll_napi() cant try to get RTNL (its a mutex by the way)
> 
> There are no problems, since :
> 
> netif_napi_add() is called at device open time (before napi_poll() can
> use it)
> 
> netif_napi_del() at device dismantle time (after making sure napi_poll()
> wont use the device again)

Yeah, but bnx2 driver calls it at other time too, for example
bnx2_change_ring_size() which in turn could be called by
bnx2_set_channels().
