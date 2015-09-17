From: Cong Wang <cwang@twopensource.com>
Subject: Re: Possible netlink autobind regression
Date: Wed, 16 Sep 2015 22:02:00 -0700
Message-ID: <CAHA+R7OdJyZiidHarKhp-U6R5fkHj=5KjugK=XoWj=q4D8krxw@mail.gmail.com>
References: <20150917022909.GA22754@htj.duckdns.org>
	<20150917030845.GA19162@gondor.apana.org.au>
	<20150917034134.GA19327@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>,
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
In-Reply-To: <20150917034134.GA19327@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 16, 2015 at 8:41 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Thu, Sep 17, 2015 at 11:08:45AM +0800, Herbert Xu wrote:
>>
>> Good catch! I think your explanation makes perfect sense.  Linus
>> ran into this previously too after suspend-and-resume.
>
> Unfortunately you can't just postpone the setting of portid because
> once you pass it onto rhashtable the portid must never change while
> it's in custody.
>
> So what I've done is essentially revert my previous fix and instead
> add a new boolean "bound" to indicate whether the socket has been
> bound.
>
> ---8<---
> netlink: Fix autobind race condition that leads to zero port ID
>
> The commit c0bb07df7d981e4091432754e30c9c720e2c0c78 ("netlink:
> Reset portid after netlink_insert failure") introduced a race
> condition where if two threads tried to autobind the same socket
> one of them may end up with a zero port ID.
>
> This patch reverts that commit and instead fixes it by introducing
> a separte "bound" variable to indicate whether a socket has been
> bound.
>
> Fixes: c0bb07df7d98 ("netlink: Reset portid after netlink_insert failure")
> Reported-by: Tejun Heo <tj@kernel.org>
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>

We saw similar soft lockup with the one Tejun reported, in our data
center.


> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Just one comment below.

[...]

> @@ -1285,7 +1287,7 @@ static int netlink_release(struct socket *sock)
>
>         skb_queue_purge(&sk->sk_write_queue);
>
> -       if (nlk->portid) {
> +       if (nlk->bound) {
>                 struct netlink_notify n = {
>                                                 .net = sock_net(sk),
>                                                 .protocol = sk->sk_protocol,

This part doesn't look correct, seems it is checking if this is a kernel
netlink socket rather than if it is bound. But I am not sure...

Other than this, looks good to me:

Reviewed-by: Cong Wang <cwang@twopensource.com>
