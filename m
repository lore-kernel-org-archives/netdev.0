From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] ipv6: Split from and expires field in dst_entry out
 of union [net-next]
Date: Tue, 19 Feb 2013 13:55:58 -0800
Message-ID: <1361310958.19353.164.camel@edumazet-glaptop>
References: <1361231718.19353.117.camel@edumazet-glaptop>
	 <1361305694-8303-1-git-send-email-nhorman@tuxdriver.com>
	 <1361308665.19353.161.camel@edumazet-glaptop>
	 <20130219214934.GD31871@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>, Jiri Bohac <jbohac@suse.cz>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:38650 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933545Ab3BSV4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 16:56:00 -0500
Received: by mail-pa0-f48.google.com with SMTP id hz10so3659229pad.7
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 13:56:00 -0800 (PST)
In-Reply-To: <20130219214934.GD31871@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-19 at 16:49 -0500, Neil Horman wrote:
> On Tue, Feb 19, 2013 at 01:17:45PM -0800, Eric Dumazet wrote:
> > On Tue, 2013-02-19 at 15:28 -0500, Neil Horman wrote:
> > 
> > >  static inline void rt6_update_expires(struct rt6_info *rt, int timeout)
> > >  {
> > >  	if (!(rt->rt6i_flags & RTF_EXPIRES)) {
> > > -		if (rt->dst.from)
> > > -			dst_release(rt->dst.from);
> > > +		dst_release(rt->dst.from);
> > >  		/* dst_set_expires relies on expires == 0 
> > >  		 * if it has not been set previously.
> > >  		 */
> > >  		rt->dst.expires = 0;
> > > +		rt6->dst.from = NULL;
> > >  	}
> > >  
> > 
> > Sorry you didnt really address the problem, only reduce the race window.
> > 
> I kinda had a feeling you would say that, but the only other solution I see here
> is to either introduce some locking to protect the from pointer, or two revert
> the patch that introduced the from pointer alltogether, neither of which sounds
> appealing to me.  I suppose we could use an xchng to atomically update the from
> pointer, so there was only ever one context that was able to free it in
> rt6_update_path.  Does that seem reasonable to you?

I believe the setting of rt6->dst.from is safe :
It should be done at :
- dst creation time, when we are the only user.
- dst destry time, when we are the only user.

We only have to do the dst_release() at the right place, when we are the
last user of the dst.

So rt6_update_expires() should not mess with rt6->dst.from at all.
