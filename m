From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 16:42:39 -0400
Message-ID: <1151700159.5270.270.camel@jzny2>
References: <20060630130811.GE14627@postel.suug.ch>
	 <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch>
	 <1151678118.5270.45.camel@jzny2> <20060630163229.GH14627@postel.suug.ch>
	 <20060630171348.GI14627@postel.suug.ch> <44A55CF8.2040509@trash.net>
	 <1151688732.5270.101.camel@jzny2> <20060630174251.GK14627@postel.suug.ch>
	 <1151696083.5270.218.camel@jzny2>  <20060630200812.GM14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:20119 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932149AbWF3Umn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 16:42:43 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FwPp9-0004no-CD
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 16:42:47 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630200812.GM14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 22:08 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-30 15:34

> > So assuming it is taken in mirred (i havent thought of where it is
> > decremented), why would using the ifindex be better?
> 
> The issue exists regardless of mirred/ifb. As soon as the packet is
> queued for the first time we leave netif_receive_skb() and the dev
> reference is dropped. Therefore in order to allow functionality
> like tcf_match_indev() at egress we have to either take a reference
> or ensure that we can catch the unlikely case of the device having
> disappeared. I think everyone would agree to use device pointers
> if only mirred would acquire it.

Thomas, this is certainly more reasonable explanation. 

On Fri, 2006-30-06 at 13:17 -0700, David Miller wrote:

> We have a
> lot of bits of state that sit in the sk_buff but which are used by
> a tiny minority, yet the space consumption is eaten by everyone.
> 
>
> Maybe when the IFB and mirred are in more widespread use we can
> investigate a different approach.
> 

Not unreasonable.
So saving the bits for the majority trumps the need for slightly more
cycles in mirred/ifb until they get more widespread.


> Another part of this issue is that if you use a pointer there is no
> clean place to clean up the input_dev reference within the scope it is
> actually used. 
> 
>
>  The only reliable place is kfree_skb() which is far
> beyond the scope that this ->input_dev thing is used. 
> 

And i cant think of a good place to do it. 

>  We have a lot
> of problems in some parts of the networking because object references
> are held for too long.  One example is all the awful side effects of
> the way the bridge netfilter code holds onto object references for
> long periods of time in the netfilter call chains.
> 
> And we know the refcounting is broken.  And one way we know to fix
> the refcounting without incurring the cost upon everyone is to
> use an interface index and only make the input_dev users eat the
> atomic operation incurred by grabbing the reference.
> 
> And even for the input_dev users, it isn't such a big deal, there
> are other costs already associated with hitting these actions and
> devices that use input_dev, the atomic reference grab there should
> be lost in the noise I think.

Alright guys - lets get the change in. I wish we had this specific
discussion sooner. 

Thomas, can you post your latest incarnation so i can mow comment more
peacefully? ;->

cheers,
jamal




