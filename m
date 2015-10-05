From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/3] unix: fix use-after-free in unix_dgram_poll()
Date: Mon, 05 Oct 2015 09:54:34 -0700
Message-ID: <1444064074.9555.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1443817522.git.jbaron@akamai.com>
	 <f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>
	 <87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Baron <jbaron@akamai.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-10-05 at 17:31 +0100, Rainer Weikusat wrote:

>  	atomic_long_set(&u->inflight, 0);
>  	INIT_LIST_HEAD(&u->link);
> @@ -2135,8 +2139,16 @@ static unsigned int unix_poll(struct fil
>  static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
>  				    poll_table *wait)
>  {
> -	struct sock *sk = sock->sk, *other;
> -	unsigned int mask, writable;
> +	struct sock *sk = sock->sk, *other, *pp;
> +	struct unix_sock *u;
> +	unsigned int mask, writable, dead;
> +
> +	u = unix_sk(sk);
> +	pp = u->poll_peer;
> +	if (pp) {
> +		u->poll_peer = NULL;
> +		sock_put(pp);
> +	}


This looks racy.
Multiple threads could use poll() at the same time,
and you would have too many sock_put()
