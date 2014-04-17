From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix ns_capable check in sock_diag_put_filterinfo
Date: Wed, 16 Apr 2014 22:21:26 -0700
Message-ID: <1397712086.19600.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1360f6acc2064d49a41f2d993d05cdcf8a40fc06.1397709384.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, stable@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1360f6acc2064d49a41f2d993d05cdcf8a40fc06.1397709384.git.luto@amacapital.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-04-16 at 21:41 -0700, Andy Lutomirski wrote:
> The caller needs capabilities on the namespace being queried, not on
> their own namespace.  This is a security bug, although it likely has
> only a minor impact.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> ---
> 
> Someone should check that I'm right.  I had trouble getting 'ss -b' to
> work, even with plain old sudo.
> 
>  include/linux/sock_diag.h | 2 +-
>  net/core/sock_diag.c      | 4 ++--
>  net/packet/diag.c         | 2 +-
>  3 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
> index 54f91d3..302ab80 100644
> --- a/include/linux/sock_diag.h
> +++ b/include/linux/sock_diag.h
> @@ -23,7 +23,7 @@ int sock_diag_check_cookie(void *sk, __u32 *cookie);
>  void sock_diag_save_cookie(void *sk, __u32 *cookie);
>  
>  int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attr);
> -int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct sock *sk,
> +int sock_diag_put_filterinfo(struct sock *sk,
>  			     struct sk_buff *skb, int attrtype);
>  
>  #endif
> diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
> index a0e9cf6..6a7fae2 100644
> --- a/net/core/sock_diag.c
> +++ b/net/core/sock_diag.c
> @@ -49,7 +49,7 @@ int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attrtype)
>  }
>  EXPORT_SYMBOL_GPL(sock_diag_put_meminfo);
>  
> -int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct sock *sk,
> +int sock_diag_put_filterinfo(struct sock *sk,
>  			     struct sk_buff *skb, int attrtype)
>  {
>  	struct nlattr *attr;
> @@ -57,7 +57,7 @@ int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct sock *sk,
>  	unsigned int len;
>  	int err = 0;
>  
> -	if (!ns_capable(user_ns, CAP_NET_ADMIN)) {
> +	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)) {
>  		nla_reserve(skb, attrtype, 0);
>  		return 0;
>  	}
> diff --git a/net/packet/diag.c b/net/packet/diag.c
> index 533ce4f..435ff99 100644
> --- a/net/packet/diag.c
> +++ b/net/packet/diag.c
> @@ -172,7 +172,7 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
>  		goto out_nlmsg_trim;
>  
>  	if ((req->pdiag_show & PACKET_SHOW_FILTER) &&
> -	    sock_diag_put_filterinfo(user_ns, sk, skb, PACKET_DIAG_FILTER))
> +	    sock_diag_put_filterinfo(sk, skb, PACKET_DIAG_FILTER))
>  		goto out_nlmsg_trim;
>  
>  	return nlmsg_end(skb, nlh);

Note you would have more chances CCing the author of the chunk you
changed, and giving commit id like that :

Fixes: e8d9612c181b ("sock_diag: allow to dump bpf filters")
