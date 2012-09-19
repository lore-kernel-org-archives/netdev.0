From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC net-next] netpoll: use static branch
Date: Wed, 19 Sep 2012 13:00:59 -0700
Message-ID: <20120919130059.7b7ebc83@s6510.linuxnetplumber.net>
References: <20120918141014.573734db@nehalam.linuxnetplumber.net>
	<1348030210.11754.7.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47491 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074Ab2ISUBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 16:01:03 -0400
In-Reply-To: <1348030210.11754.7.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Sep 2012 12:50:10 +0800
Cong Wang <amwang@redhat.com> wrote:

> On Tue, 2012-09-18 at 14:10 -0700, Stephen Hemminger wrote:
> > This is an attempt to optimize netpoll when not used.
> > 
> > Since distro's enable everything and netpoll is only occasionally
> > used, improve performance by getting netpoll condition check
> > out of the Rx fastpath.
> > 
> > Compile tested only, I have no real use for netpoll.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > 
> > ---
> >  include/linux/netpoll.h |   28 ++++++++++++++++++++--------
> >  net/core/netpoll.c      |    8 +++++++-
> >  2 files changed, 27 insertions(+), 9 deletions(-)
> > 
> > --- a/include/linux/netpoll.h	2012-09-18 13:25:15.575750004 -0700
> > +++ b/include/linux/netpoll.h	2012-09-18 13:29:16.245323347 -0700
> > @@ -66,10 +66,16 @@ static inline void netpoll_send_skb(stru
> >  
> > 
> >  #ifdef CONFIG_NETPOLL
> > +extern struct static_key netpoll_needed;
> > +
> >  static inline bool netpoll_rx_on(struct sk_buff *skb)
> >  {
> > -	struct netpoll_info *npinfo = rcu_dereference_bh(skb->dev->npinfo);
> > +	struct netpoll_info *npinfo;
> > +
> > +	if (static_key_true(&netpoll_needed))
> > +		return false;
> >  
> 
> I think we should use static_key_false() here, as netpoll is an
> "unlikely" code path.
> 
> Using static branch is a good idea though.
> 
> Thanks.

But static_key_true is just a wrapper around !static_key_false()
