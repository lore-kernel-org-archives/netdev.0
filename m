From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH]     netlink: Safer deletion of sk_bind_node
Date: Mon, 01 Sep 2014 20:12:56 -0500
Message-ID: <87ha0qdduv.fsf@x220.int.ebiederm.org>
References: <1409555309-5893-1-git-send-email-harish_kandiga@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dborkman@redhat.com>, <tgraf@suug.ch>,
	<darkjames-ws@darkjames.pl>, <rgb@redhat.com>,
	<eric.dumazet@gmail.com>, <stephen@networkplumber.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Harish Jenny K N <harish_kandiga@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409555309-5893-1-git-send-email-harish_kandiga@mentor.com>
	(Harish Jenny K. N.'s message of "Mon, 1 Sep 2014 12:38:29 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Harish Jenny K N writes:

> From: Harish Jenny K N <harish_kandiga@mentor.com>
>
>     Unable to handle kernel NULL pointer dereference at virtual address 00000000
>         (netlink_release+0x0/0x2a0) from [<8034e78c>] (sock_release+0x28/0xa4)
>         (sock_release+0x0/0xa4) from [<8034e830>] (sock_close+0x28/0x34)
>         (sock_close+0x0/0x34) from [<800f3490>] (__fput+0xf0/0x1ec)
>         (__fput+0x0/0x1ec) from [<800f3634>] (____fput+0x10/0x14)
>         (____fput+0x0/0x14) from [<80040a64>] (task_work_run+0xb8/0xd8)
>         (task_work_run+0x0/0xd8) from [<800113a0>] (do_work_pending+0xb0/0xc4)
>         (do_work_pending+0x0/0xc4) from [<8000d960>] (work_pending+0xc/0x20)
>     Call flow of the inline and static functions
>         netlink_release
>         -----netlink_remove
>         ---------__sk_del_bind_node
>         --------------__hlist_del

Is there any reason __sk_del_bind_node should not be changed instead?

If not there should be a description of what makes netlink's use of
__sk_del_bind_node special....

Eric

p.s. Your name was in your from line, but not your email address making
it hard to reply to you.

> Signed-off-by: Harish Jenny K N <harish_kandiga@mentor.com>
> ---
>  net/netlink/af_netlink.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index c416725..21a6b32 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1103,7 +1103,7 @@ static void netlink_remove(struct sock *sk)
>  
>  	netlink_table_grab();
>  	if (nlk_sk(sk)->subscriptions)
> -		__sk_del_bind_node(sk);
> +		hlist_del_init(&sk->sk_bind_node);
>  	netlink_table_ungrab();
>  }
>  
> @@ -1382,7 +1382,7 @@ netlink_update_subscriptions(struct sock *sk, unsigned int subscriptions)
>  	struct netlink_sock *nlk = nlk_sk(sk);
>  
>  	if (nlk->subscriptions && !subscriptions)
> -		__sk_del_bind_node(sk);
> +		hlist_del_init(&sk->sk_bind_node);
>  	else if (!nlk->subscriptions && subscriptions)
>  		sk_add_bind_node(sk, &nl_table[sk->sk_protocol].mc_list);
>  	nlk->subscriptions = subscriptions;
