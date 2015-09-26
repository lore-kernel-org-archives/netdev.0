From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink: Add netlink_bound helper and use it in netlink_getname
Date: Sun, 27 Sep 2015 03:49:16 +0800
Message-ID: <20150926194916.GA18975@gondor.apana.org.au>
References: <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150924.121142.870602292135442487.davem@davemloft.net>
 <20150924200510.GE25415@mtj.duckdns.org>
 <20150925014327.GA3725@gondor.apana.org.au>
 <20150925150113.GD4449@mtj.duckdns.org>
 <20150926131621.GA16724@gondor.apana.org.au>
 <20150926180903.GD3572@htj.duckdns.org>
 <20150926194110.GA18815@gondor.apana.org.au>
 <20150926194554.GE3572@htj.duckdns.org>
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
In-Reply-To: <20150926194554.GE3572@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 26, 2015 at 03:45:54PM -0400, Tejun Heo wrote:
> Hello, Herbert.
> 
> On Sun, Sep 27, 2015 at 03:41:10AM +0800, Herbert Xu wrote:
> > Thread 1			Thread 2
> > sendmsg				getsockname
> > 	netlink_autobind		netlink_getname
> > 
> > Thread 2 should not have to do anything special to guarantee that
> > getsockname does not return garbage.  It must either be the bound
> > portid if the autobind completed in thread 1 and is visible or it
> > should return zero.
> > 
> > As it stands thread 2 may see a portid belonging to somebody else
> > if it catches the autobind in thread 1 trying different portids
> > while roving.
> 
> If the fact that thread 1 finished autobind isn't visible to thread 2,
> it's valid for getsockname to return zero.  No ordering between the
> two operations is defined.  If the fact that thread 1 finished
> autobind is visible to thread 2, ordering is defined and because
> ordering is transitive, by that very ordering, the port number is
> visible to thread 2 too as long as thread 1 does proper barriering.

If the autobind is not complete then netlink_getname must return
zero rather than some garbage portid that belongs to somebody
else's socket.  That's what we did before any of this lockless
code was introduced.

If you don't check nlk->bound then you may return garbage.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
