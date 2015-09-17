From: Tejun Heo <tj@kernel.org>
Subject: Re: Possible netlink autobind regression
Date: Thu, 17 Sep 2015 07:30:34 -0400
Message-ID: <20150917113034.GA14471@htj.duckdns.org>
References: <20150917022909.GA22754@htj.duckdns.org>
 <20150917030845.GA19162@gondor.apana.org.au>
 <20150917034134.GA19327@gondor.apana.org.au>
 <CAHA+R7OdJyZiidHarKhp-U6R5fkHj=5KjugK=XoWj=q4D8krxw@mail.gmail.com>
 <20150917051503.GA19978@gondor.apana.org.au>
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
In-Reply-To: <20150917051503.GA19978@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Herbert.

On Thu, Sep 17, 2015 at 01:15:03PM +0800, Herbert Xu wrote:
> netlink: Fix autobind race condition that leads to zero port ID
> 
> The commit c0bb07df7d981e4091432754e30c9c720e2c0c78 ("netlink:
> Reset portid after netlink_insert failure") introduced a race
> condition where if two threads tried to autobind the same socket
> one of them may end up with a zero port ID.
>
> This patch reverts that commit and instead fixes it by introducing
> a separte "bound" variable to indicate whether a user-space socket
> has been bound.
> 
> Fixes: c0bb07df7d98 ("netlink: Reset portid after netlink_insert failure")
> Reported-by: Tejun Heo <tj@kernel.org>
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> Reviewed-by: Cong Wang <cwang@twopensource.com>

Maybe add that this led to a deadlock and add a Link tag to this
thread?

> @@ -1083,10 +1083,12 @@ static int netlink_insert(struct sock *sk, u32 portid)
>  	if (err) {
>  		if (err == -EEXIST)
>  			err = -EADDRINUSE;
> -		nlk_sk(sk)->portid = 0;
>  		sock_put(sk);
> +		goto err;
>  	}
>  
> +	nlk_sk(sk)->bound = !!portid;

!! isn't necessasry and this creates ordering between two stores.
->bound must be visible only after ->portid is visible, so this should
be smp_store_release().

> @@ -2371,7 +2373,7 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
>  		dst_group = nlk->dst_group;
>  	}
>  
> -	if (!nlk->portid) {
> +	if (!nlk->bound) {

And all unlocked reads should be smp_load_acquire().

>  		err = netlink_autobind(sock);
>  		if (err)
>  			goto out;

Thanks.

-- 
tejun
