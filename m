From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Fix ns_capable check in sock_diag_put_filterinfo
Date: Thu, 17 Apr 2014 01:37:09 -0700
Message-ID: <87r44w73nu.fsf@x220.int.ebiederm.org>
References: <1360f6acc2064d49a41f2d993d05cdcf8a40fc06.1397709384.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:56914 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754959AbaDQIhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 04:37:36 -0400
In-Reply-To: <1360f6acc2064d49a41f2d993d05cdcf8a40fc06.1397709384.git.luto@amacapital.net>
	(Andy Lutomirski's message of "Wed, 16 Apr 2014 21:41:34 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Lutomirski <luto@amacapital.net> writes:

> The caller needs capabilities on the namespace being queried, not on
> their own namespace.  This is a security bug, although it likely has
> only a minor impact.

Hmm.  Thinking this through.

It would likely help to rename sk_user_ns to sk_opener_user_ns to make
things clearer.

As I read net/core/sock_diag.c anyone is allowed to open a diag socket
and send messages to the kernel.

Which means the code as written is definitely wrong as checking if we
have CAP_NET_ADMIN in the user namespace in which we opened the netlink
socket is meaningless.  We could very easily have unshared the user
namespace and have no permissions whatsoever over the network namespace
we are querrying.

I see three possibilities here.
1) We simply don't care who gets to read the bpf filter of a socket.
2) We consider reading the bpf filter of a socket an information leak
   about the socket and the opener of the socket.
3) We consider reading the bpf filter of a socket something we should
   only let the administrator of a network namespace do.

I honestly don't know the intent of the check, and what we are trying to
protect against so I don't know why having permissions to protect the
bpf filter is important.

If we simply don't care we should just delete this permission check.

If we want to protect the opener of the socket we probably want
something looks a lot like ptrace_may_access(..., PTRACE_MODE_READ)
applied to the creds of the socket.  Call it

	ns_capable((sock_opener_user_ns(sk), CAP_NET_ADMIN)

for short.


And if this is something we just want to limit to administrators
of network stacks the check should be

	ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)

As Andy has coded below.

Nicolas what was the intent of having a capability check to protect the
bpf filter?  What were you trying to protect against with a capability
check on the bpf filter?

Eric


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
