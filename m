From: Cong Wang <amwang@redhat.com>
Subject: Re: Q: what protects dev->napi_list?
Date: Sat, 25 Aug 2012 14:08:42 +0800
Message-ID: <1345874922.14276.14.camel@cr0>
References: <1345801604.11584.24.camel@cr0>
	 <1345803142.29722.20.camel@edumazet-glaptop>
	 <1345804753.11584.43.camel@cr0>
	 <1345807778.29722.98.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sylvain Munaut <s.munaut@whatever-company.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25321 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732Ab2HYGIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2012 02:08:50 -0400
In-Reply-To: <1345807778.29722.98.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 13:29 +0200, Eric Dumazet wrote:
> On Fri, 2012-08-24 at 18:39 +0800, Cong Wang wrote:
> > 
> > Yeah, but bnx2 driver calls it at other time too, for example
> > bnx2_change_ring_size() which in turn could be called by
> > bnx2_set_channels().
> 
> Then at this point, device is stopped, or should be.
> 

But poll_napi() is still iterating the dev->napi_list, could anyone
stops it?

IOW, the following race condition may happen:

static void poll_napi(struct net_device *dev)
{               
        struct napi_struct *napi;
        int budget = 16;
                
        WARN_ON_ONCE(!irqs_disabled());
                
        list_for_each_entry(napi, &dev->napi_list, dev_list) {
                local_irq_enable();

				//<-- Another process may call
				//bnx2_change_ring_size() to del
				//napi from dev, on other CPU.

                local_irq_disable();
        }
}
