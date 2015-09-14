From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pptp: avoid releasing the sock too early
Date: Mon, 14 Sep 2015 09:43:47 -0700
Message-ID: <1442249027.14284.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442245229-31099-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, ebiederm@xmission.com, davem@davemloft.net,
	simon@farnz.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442245229-31099-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-09-14 at 11:40 -0400, Sasha Levin wrote:
> Since we're using RCU we can't free the sock structure before RCU lets us,
> otherwise we're risking getting use-after-frees accessing it:

> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  drivers/net/ppp/pptp.c   |    9 ++++++++-
>  include/linux/if_pppox.h |    1 +
>  2 files changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
> index 686f37d..cb7a029 100644
> --- a/drivers/net/ppp/pptp.c
> +++ b/drivers/net/ppp/pptp.c
> @@ -517,6 +517,13 @@ static int pptp_getname(struct socket *sock, struct sockaddr *uaddr,
>  	return 0;
>  }
>  
> +static void pptp_release_cb(struct rcu_head *rcu)
> +{
> +	struct pppox_sock *p = container_of(rcu, struct pppox_sock, rcu);
> +
> +	sock_put(sk_pppox(p));
> +}
> +
>  static int pptp_release(struct socket *sock)
>  {
>  	struct sock *sk = sock->sk;
> @@ -545,7 +552,7 @@ static int pptp_release(struct socket *sock)
>  	sock->sk = NULL;
>  
>  	release_sock(sk);
> -	sock_put(sk);
> +	call_rcu(&po->rcu, pptp_release_cb);
>  
>  	return error;
>  }
> diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
> index b49cf92..ba9c378 100644
> --- a/include/linux/if_pppox.h
> +++ b/include/linux/if_pppox.h
> @@ -55,6 +55,7 @@ struct pppox_sock {
>  		struct pptp_opt  pptp;
>  	} proto;
>  	__be16			num;
> +	struct rcu_head rcu;
>  };
>  #define pppoe_dev	proto.pppoe.dev
>  #define pppoe_ifindex	proto.pppoe.ifindex

Hmm, is the synchronize_rcu() in del_chan() still needed, and why it was
not enough ?

I believe your patch might reduce the race window, but it is not clear
it is the right fix.
