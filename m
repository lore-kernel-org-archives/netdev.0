From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Q: what protects dev->napi_list?
Date: Fri, 24 Aug 2012 12:12:22 +0200
Message-ID: <1345803142.29722.20.camel@edumazet-glaptop>
References: <1345801604.11584.24.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sylvain Munaut <s.munaut@whatever-company.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41513 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427Ab2HXKM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 06:12:28 -0400
Received: by bkwj10 with SMTP id j10so529065bkw.19
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 03:12:27 -0700 (PDT)
In-Reply-To: <1345801604.11584.24.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 17:46 +0800, Cong Wang wrote:
> Hi,
> 
> Sylvain reported a netpoll CPU stall
> http://marc.info/?l=linux-netdev&m=134563282530588&w=2
> 
> I tried to provide some fix for it:
> http://marc.info/?l=linux-netdev&m=134571069921429&w=2
> 
> When reviewing that code, I noticed a problem, it seems dev->napi_list
> is not protected by any lock? What if the device driver calls
> netif_napi_del() meanwhile we are iterating &dev->napi_list in
> poll_napi()? It seems netif_napi_del()/netif_napi_add() are usually
> called with the RTNL lock held during driver init/uninit, but again
> poll_napi() doesn't have RTNL lock.
> 

Of course poll_napi() cant try to get RTNL (its a mutex by the way)

There are no problems, since :

netif_napi_add() is called at device open time (before napi_poll() can
use it)

netif_napi_del() at device dismantle time (after making sure napi_poll()
wont use the device again)
