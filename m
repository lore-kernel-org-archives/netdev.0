From: Tejun Heo <tj@kernel.org>
Subject: Re: netlink: Add netlink_bound helper and use it in netlink_getname
Date: Sat, 26 Sep 2015 14:09:03 -0400
Message-ID: <20150926180903.GD3572@htj.duckdns.org>
References: <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150924.121142.870602292135442487.davem@davemloft.net>
 <20150924200510.GE25415@mtj.duckdns.org>
 <20150925014327.GA3725@gondor.apana.org.au>
 <20150925150113.GD4449@mtj.duckdns.org>
 <20150926131621.GA16724@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:34644 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbbIZSJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 14:09:08 -0400
Content-Disposition: inline
In-Reply-To: <20150926131621.GA16724@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Herbert.

On Sat, Sep 26, 2015 at 09:16:21PM +0800, Herbert Xu wrote:
> You misunderstood what I wrote.  I was not basing this on whether
> user-space transitions contained a barrier, but on the fact that
> the next syscall must recheck nlk->bound before using nlk->portid.

But that isn't what you wrote in the comment.

	/* No need for barriers here as we return to user-space without
	 * using any of the bound attributes.
	 */

> In fact thanks to your email I now realise that my fix to the
> getsockname problem is wrong.  Instead of adding a barrier to
> netlink_connect I should be adding a nlk->bound check to getname.

I don't know, man.  This thread almost feels surreal at this point.

> @@ -1628,7 +1632,7 @@ static int netlink_getname(struct socket *sock, struct sockaddr *addr,
>  		nladdr->nl_pid = nlk->dst_portid;
>  		nladdr->nl_groups = netlink_group_mask(nlk->dst_group);
>  	} else {
> -		nladdr->nl_pid = nlk->portid;
> +		nladdr->nl_pid = netlink_bound(nlk) ? nlk->portid : 0;
>  		nladdr->nl_groups = nlk->groups ? nlk->groups[0] : 0;
>  	}
>  	return 0;

So, this is really weird because netlink_getname() doens't participate
in the autobind race and thus it's perfectly fine for it to not worry
about whether ->bound is set or the memory barrier - whoever its
caller may be, the caller is of course responsible for ensuring that
the port is bound and visible if it expects to read back the number -
ie. if the caller doesn't know (in memory ordering sense) that
bind/connect/sendmsg succeeded, it of course can't expect to reliably
read back the port number.  getname never needed the barrier.  The
above is shifting synchronization from the source to its users.  This
is a bad thing to do.

Thanks.

-- 
tejun
