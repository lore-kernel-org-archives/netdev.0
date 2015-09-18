From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3] netlink: Fix autobind race condition that leads to
 zero port ID
Date: Fri, 18 Sep 2015 09:37:19 -0400
Message-ID: <20150918133719.GB10877@mtj.duckdns.org>
References: <20150917022909.GA22754@htj.duckdns.org>
 <20150917030845.GA19162@gondor.apana.org.au>
 <20150917034134.GA19327@gondor.apana.org.au>
 <CAHA+R7OdJyZiidHarKhp-U6R5fkHj=5KjugK=XoWj=q4D8krxw@mail.gmail.com>
 <20150917051503.GA19978@gondor.apana.org.au>
 <20150917113034.GA14471@htj.duckdns.org>
 <20150918063609.GA31747@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>, kafai@fb.com,
	kernel-team <kernel-team@fb.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Pirko <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150918063609.GA31747@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Herbert.

On Fri, Sep 18, 2015 at 02:36:10PM +0800, Herbert Xu wrote:
> On Thu, Sep 17, 2015 at 07:30:34AM -0400, Tejun Heo wrote:
> >
> > Maybe add that this led to a deadlock and add a Link tag to this
> > thread?
> 
> I'll add a note about the deadlock but I don't like Link tags
> because websites die and you can always just google the patch
> subject.

That's why we use http://lkml.kernel.org/r/MSG_ID links.

> > > +	nlk_sk(sk)->bound = !!portid;
> > 
> > !! isn't necessasry and this creates ordering between two stores.
> 
> !! was necessary because we're going from a u32 to a bool.

bool casting actually collapses the source value to a boolean value.
No need for casting regardless of data type.

> @@ -1076,17 +1076,19 @@ static int netlink_insert(struct sock *sk, u32 portid)
>  	    unlikely(atomic_read(&table->hash.nelems) >= UINT_MAX))
>  		goto err;
>  
> -	nlk_sk(sk)->portid = portid;
> +	nlk_sk(sk)->rhash_portid = portid;
>  	sock_hold(sk);
>  
>  	err = __netlink_insert(table, sk);
>  	if (err) {
>  		if (err == -EEXIST)
>  			err = -EADDRINUSE;
> -		nlk_sk(sk)->portid = 0;
>  		sock_put(sk);
> +		goto err;
>  	}
>  
> +	nlk_sk(sk)->portid = portid;

So, this doesn't necessarily make the ordering problem go away.  The
hash lookup would be fine but imagine a code path like the following.

	rcu_read_lock();
	sock = rhash lookup(some port number);
	do some operation which may use sock->portid;
	rcu_read_unlock();

Now, that some operation may see 0 as the port number.  I don't think
you can avoid doing some type of memory barrier operations if you
wanna gate autobind w/o grabbing locks.

Thanks.

-- 
tejun
