From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: l2tp: unlock socket lock before returning from
 l2tp_ip_sendmsg
Date: Wed, 02 May 2012 15:28:38 +0200
Message-ID: <1335965318.22133.568.camel@edumazet-glaptop>
References: <1335964237-1139-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jchapman@katalix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davej@redhat.com
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335964237-1139-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-02 at 15:10 +0200, Sasha Levin wrote:
> l2tp_ip_sendmsg could return without releasing socket lock, making it all the
> way to userspace, and generating the following warning:
> 
> [  130.891594] ================================================
> [  130.894569] [ BUG: lock held when returning to user space! ]
> [  130.897257] 3.4.0-rc5-next-20120501-sasha #104 Tainted: G        W
> [  130.900336] ------------------------------------------------
> [  130.902996] trinity/8384 is leaving the kernel with locks still held!
> [  130.906106] 1 lock held by trinity/8384:
> [  130.907924]  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff82b9503f>] l2tp_ip_sendmsg+0x2f/0x550
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  net/l2tp/l2tp_ip.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
> index 585d93e..a4d8364 100644
> --- a/net/l2tp/l2tp_ip.c
> +++ b/net/l2tp/l2tp_ip.c
> @@ -442,8 +442,10 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
>  
>  		daddr = lip->l2tp_addr.s_addr;
>  	} else {
> -		if (sk->sk_state != TCP_ESTABLISHED)
> -			return -EDESTADDRREQ;
> +		if (sk->sk_state != TCP_ESTABLISHED) {
> +			rc = -EDESTADDRREQ;
> +			goto out;
> +		}
>  
>  		daddr = inet->inet_daddr;
>  		connected = 1;

Good catch, but please use existing code style in this function.

rc = -EDESTADDRREQ;
if (sk->sk_state != TCP_ESTABLISHED)
	goto out;

Also, please add in your commit message bug origin to ease stable team
work (not counting reviewers work)

Bug added in commit 2f16270f41e1 (l2tp: Fix locking in l2tp_ip.c)

Really, given the amount of patches you already sent, you should already
know that.

Thanks
