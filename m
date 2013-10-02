From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] tcp: shrink tcp6_timewait_sock by one cache
 line
Date: Wed, 02 Oct 2013 07:57:10 -0700
Message-ID: <1380725830.19002.100.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380711604.19002.78.camel@edumazet-glaptop.roam.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B736F@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60293 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753878Ab3JBO5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 10:57:12 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so989787pbb.19
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 07:57:11 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B736F@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 13:08 +0100, David Laight wrote:
> > -	tmo = tw->tw_ttd - jiffies;
> > +	tmo = tw->tw_ttd - (u32)jiffies;
> 
> Do you need any of these (u32) casts?
> The compiler will almost certainly use 32bit arithmetic (on 32bit systems at least)
> because the 'as if' rule lets if use the smaller type.

I wanted to clearly show the intent of the code.

Some compilers might warnings here.

> 
> > +		tw->tw_ttd = (u32)(jiffies + (slot << INET_TWDR_RECYCLE_TICK));
> 
> If that (u32) cast is needed in order to avoid 64bit maths, it is in the wrong place.

I want to make sure no compiler will complain for potential losses of
precision.

Note we have :

include/net/tcp.h:691:#define tcp_time_stamp            ((__u32)(jiffies))

But this could change if we want 100us resolution for TCP timestamps at
one point.

In this code, we want HZ units, but truncated to 32bits.

Adding a 

#define jiffies32   ((u32)jiffies)

might do the trick, but lot of pain for such a trivial patch.
