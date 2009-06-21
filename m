From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] fix NULL pointer + success return in route lookup path
Date: Sun, 21 Jun 2009 13:11:41 -0400
Message-ID: <20090621171141.GA2893@localhost.localdomain>
References: <20090619171814.GE18237@hmsreliant.think-freely.org> <4A3CD7EC.2040904@gmail.com> <4A3D10BD.3050301@gmail.com> <20090620.164748.227654288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, mbizon@freebox.fr,
	dada1@cosmosbay.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46921 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbZFURLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2009 13:11:55 -0400
Content-Disposition: inline
In-Reply-To: <20090620.164748.227654288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 20, 2009 at 04:47:48PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sat, 20 Jun 2009 18:39:25 +0200
> 
> > Jarek Poplawski wrote, On 06/20/2009 02:37 PM:
> > 
> >> Neil Horman wrote, On 06/19/2009 07:18 PM:
> >> 
> >>> Don't drop route if we're not caching	
> > 
> > ...
> > 
> >>>  route.c |   14 ++++++++++++--
> >>>  1 file changed, 12 insertions(+), 2 deletions(-)
> >>>
> >>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> >>> index cd76b3c..65b3a8b 100644
> >>> --- a/net/ipv4/route.c
> >>> +++ b/net/ipv4/route.c
> >>> @@ -1085,8 +1085,16 @@ restart:
> >>>  	now = jiffies;
> >>>  
> >>>  	if (!rt_caching(dev_net(rt->u.dst.dev))) {
> >>> -		rt_drop(rt);
> > 
> > 
> > One more question: if this rt is assigned to an skb, there is only
> > skb_dst_drop() in kfree_skb(), but it seems we skip rt_free() part,
> > or I miss something?
> 
> This whole code path was buggy, if it returns success it should
> do as the normal success code path does which is assign for
> non-SKB case to *rp, or skb_dst_set().

So I'm a bit confused.  I see how my patch corrects the path we take through
rt_intern_hash, doing the same thing that we normally do in the success case.
What I don't see is how we clean up those dst entries when we're done with them.
Since their not placed in the route cache (assuming rt_caching returns zero),
then don't we have a leak, since the garbage collector will never see it in the
cache to reap.

Assuming thats the case, I was thinking about closing that leak by setting
DST_NOHASH in rt_intern_hash for any dst_entry that was submitted when
rt_caching returns zero.  Then in skb_dst_drop, we can check for dst->_refcnt
== 0, and if flags & DST_NOHASH is true, then we can call dst_free on it.  Or
does that remove the dst_entry before a caller might be done with it in some
cases?

Thoughts welcome and appreciated.

Thanks!
Neil

