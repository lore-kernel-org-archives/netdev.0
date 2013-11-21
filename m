From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: rework recvmsg handler msg_name and msg_namelen logic
Date: Thu, 21 Nov 2013 02:23:03 +0100
Message-ID: <20131121012303.GC32587@order.stressinduktion.org>
References: <20131121003828.GA32587@order.stressinduktion.org> <1384995760.2164.33.camel@joe-AO722> <20131121010729.GB32587@order.stressinduktion.org> <1384996730.10637.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56045 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754349Ab3KUBXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 20:23:04 -0500
Content-Disposition: inline
In-Reply-To: <1384996730.10637.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 20, 2013 at 05:18:50PM -0800, Eric Dumazet wrote:
> On Thu, 2013-11-21 at 02:07 +0100, Hannes Frederic Sowa wrote:
> > On Wed, Nov 20, 2013 at 05:02:40PM -0800, Joe Perches wrote:
> > > On Thu, 2013-11-21 at 01:38 +0100, Hannes Frederic Sowa wrote:
> > > > This patch now always passes msg->msg_namelen as 0. recvmsg handlers must
> > > > set msg_namelen to the proper size <= sizeof(struct sockaddr_storage)
> > > > to return msg_name to the user.
> > > []
> > > > This change does not alter the user visible error logic as we ignore
> > > > msg_namelen as long as msg_name is NULL.
> > > > 
> > > > Also remove two unnecessary curly brackets in ___sys_recvmsg and change
> > > > comments to netdev style.
> > > 
> > > Perhaps take the opportunity to remove the unnecessary casts of
> > > struct msghdr.msg_name as it's a void *.
> > > 
> > > And there's one other oddity about setting a known NULL to NULL.
> > > 
> > > Maybe fix in a follow-on patch?
> > 
> > No, that is easily done in this one. I'll send a v2 shortly.
> > 
> > Thanks!
> > 
> 
> In move_addr_to_user() there is this strange test :
> 
>         if (len > klen)
>                 len = klen;
>         if (len < 0 || len > sizeof(struct sockaddr_storage))
>                 return -EINVAL;
> 
> I would suggest to instead use :
> 
> if (len < 0)
> 	return -EINVAL;
> BUG_ON(len > sizeof(struct sockaddr_storage));
> 
> To catch if some protocols are using more than 128 bytes.
> 
> We can then remove the BUG_ON() later.

I actually started adding a handful BUILD_BUG_ONs on my branch as I don't know
if we will catch all corner-cases at runtime by the users and planed that for
net-next. But it is better to get such a check in as early as possible, so
I'll include it in v2.

Thanks!
