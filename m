From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] l2tp: do not use udp_ioctl()
Date: Thu, 09 Feb 2017 22:17:49 +0100
Message-ID: <1486675069.3545.1.camel@redhat.com>
References: <1486654229.7793.100.camel@edumazet-glaptop3.roam.corp.google.com>
         <1486664113.7793.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39710 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932651AbdBIVRv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 16:17:51 -0500
In-Reply-To: <1486664113.7793.111.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-09 at 10:15 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> udp_ioctl(), as its name suggests, is used by UDP protocols,
> but is also used by L2TP :(
> 
> L2TP should use its own handler, because it really does not
> look the same.
> 
> SIOCINQ for instance should not assume UDP checksum or headers.
> 
> Thanks to Andrey and syzkaller team for providing the report
> and a nice reproducer.
> 
> While crashes only happen on recent kernels (after commit 
> 7c13f97ffde6 ("udp: do fwd memory scheduling on dequeue")), this
> probably needs to be backported to older kernels.
> 
> Fixes: 7c13f97ffde6 ("udp: do fwd memory scheduling on dequeue")
> Fixes: 85584672012e ("udp: Fix udp_poll() and ioctl()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/l2tp/l2tp_core.h |    1 +
>  net/l2tp/l2tp_ip.c   |   26 +++++++++++++++++++++++++-
>  net/l2tp/l2tp_ip6.c  |    2 +-
>  3 files changed, 27 insertions(+), 2 deletions(-)
> 
> diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
> index 8f560f7140a05694c13904d9b171ba67d9d11292..aebf281d09eeb31c531eb624bd2ddd78cab8da9b 100644
> --- a/net/l2tp/l2tp_core.h
> +++ b/net/l2tp/l2tp_core.h
> @@ -263,6 +263,7 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb,
>  int l2tp_nl_register_ops(enum l2tp_pwtype pw_type,
>  			 const struct l2tp_nl_cmd_ops *ops);
>  void l2tp_nl_unregister_ops(enum l2tp_pwtype pw_type);
> +int l2tp_ioctl(struct sock *sk, int cmd, unsigned long arg);
>  
>  /* Session reference counts. Incremented when code obtains a reference
>   * to a session.
> diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
> index 3d73278b86ca34bfbd774dc8f52e490169445e1b..d4e5d16d97d4b612f8a76557516288f4a011448a 100644
> --- a/net/l2tp/l2tp_ip.c
> +++ b/net/l2tp/l2tp_ip.c
> @@ -11,6 +11,7 @@
>  
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>  
> +#include <asm/ioctls.h>
>  #include <linux/icmp.h>
>  #include <linux/module.h>
>  #include <linux/skbuff.h>
> @@ -553,6 +554,29 @@ static int l2tp_ip_recvmsg(struct sock *sk, struct msghdr *msg,
>  	return err ? err : copied;
>  }
>  
> +int l2tp_ioctl(struct sock *sk, int cmd, unsigned long arg)
> +{
> +	struct sk_buff *skb;
> +	int amount;
> +
> +	switch (cmd) {
> +	case SIOCOUTQ:
> +		amount = sk_wmem_alloc_get(sk);
> +		break;
> +	case SIOCINQ:
> +		spin_lock_bh(&sk->sk_receive_queue.lock);
> +		skb = skb_peek(&sk->sk_receive_queue);
> +		amount = skb ? skb->len : 0;
> +		spin_unlock_bh(&sk->sk_receive_queue.lock);
> +		break;
> +
> +	default:
> +		return -ENOIOCTLCMD;
> +	}
> +
> +	return put_user(amount, (int __user *)arg);
> +}
> +
>  static struct proto l2tp_ip_prot = {
>  	.name		   = "L2TP/IP",
>  	.owner		   = THIS_MODULE,
> @@ -561,7 +585,7 @@ static struct proto l2tp_ip_prot = {
>  	.bind		   = l2tp_ip_bind,
>  	.connect	   = l2tp_ip_connect,
>  	.disconnect	   = l2tp_ip_disconnect,
> -	.ioctl		   = udp_ioctl,
> +	.ioctl		   = l2tp_ioctl,
>  	.destroy	   = l2tp_ip_destroy_sock,
>  	.setsockopt	   = ip_setsockopt,
>  	.getsockopt	   = ip_getsockopt,
> diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
> index 331ccf5a7bad80e011997e071489d7775b0c68c6..f47c45250f86c9189e0a6bbfd92b21cbe2069406 100644
> --- a/net/l2tp/l2tp_ip6.c
> +++ b/net/l2tp/l2tp_ip6.c
> @@ -722,7 +722,7 @@ static struct proto l2tp_ip6_prot = {
>  	.bind		   = l2tp_ip6_bind,
>  	.connect	   = l2tp_ip6_connect,
>  	.disconnect	   = l2tp_ip6_disconnect,
> -	.ioctl		   = udp_ioctl,
> +	.ioctl		   = l2tp_ioctl,
>  	.destroy	   = l2tp_ip6_destroy_sock,
>  	.setsockopt	   = ipv6_setsockopt,
>  	.getsockopt	   = ipv6_getsockopt,
> 
> 

Thank you for taking care of this! LGTM.

Acked-by: Paolo Abeni <pabeni@redhat.com>
