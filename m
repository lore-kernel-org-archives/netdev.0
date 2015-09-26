From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink: Add netlink_bound helper and use it in netlink_getname
Date: Sun, 27 Sep 2015 03:41:10 +0800
Message-ID: <20150926194110.GA18815@gondor.apana.org.au>
References: <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150924.121142.870602292135442487.davem@davemloft.net>
 <20150924200510.GE25415@mtj.duckdns.org>
 <20150925014327.GA3725@gondor.apana.org.au>
 <20150925150113.GD4449@mtj.duckdns.org>
 <20150926131621.GA16724@gondor.apana.org.au>
 <20150926180903.GD3572@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150926180903.GD3572@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 26, 2015 at 02:09:03PM -0400, Tejun Heo wrote:
>
> > @@ -1628,7 +1632,7 @@ static int netlink_getname(struct socket *sock, struct sockaddr *addr,
> >  		nladdr->nl_pid = nlk->dst_portid;
> >  		nladdr->nl_groups = netlink_group_mask(nlk->dst_group);
> >  	} else {
> > -		nladdr->nl_pid = nlk->portid;
> > +		nladdr->nl_pid = netlink_bound(nlk) ? nlk->portid : 0;
> >  		nladdr->nl_groups = nlk->groups ? nlk->groups[0] : 0;
> >  	}
> >  	return 0;
> 
> So, this is really weird because netlink_getname() doens't participate
> in the autobind race and thus it's perfectly fine for it to not worry
> about whether ->bound is set or the memory barrier - whoever its
> caller may be, the caller is of course responsible for ensuring that
> the port is bound and visible if it expects to read back the number -
> ie. if the caller doesn't know (in memory ordering sense) that
> bind/connect/sendmsg succeeded, it of course can't expect to reliably
> read back the port number.  getname never needed the barrier.  The
> above is shifting synchronization from the source to its users.  This
> is a bad thing to do.

Thread 1			Thread 2
sendmsg				getsockname
	netlink_autobind		netlink_getname

Thread 2 should not have to do anything special to guarantee that
getsockname does not return garbage.  It must either be the bound
portid if the autobind completed in thread 1 and is visible or it
should return zero.

As it stands thread 2 may see a portid belonging to somebody else
if it catches the autobind in thread 1 trying different portids
while roving.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
