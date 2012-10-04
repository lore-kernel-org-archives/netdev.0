From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v3 02/11] inet_diag: pass inet_diag module to
 netlink_dump_start
Date: Thu, 04 Oct 2012 07:08:36 +0200
Message-ID: <1349327316.16011.11.camel@edumazet-glaptop>
References: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>
	 <1349325689-16104-2-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, steffen.klassert@secunet.com,
	netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	pablo@netfilter.org, stephen.hemminger@vyatta.com, jengelh@inai.de
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1349325689-16104-2-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-10-04 at 12:41 +0800, Gao feng wrote:
> set netlink_dump_control.module to avoid panic.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/ipv4/inet_diag.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index 535584c..5ffd7bc 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -981,6 +981,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
>  		{
>  			struct netlink_dump_control c = {
>  				.dump = inet_diag_dump_compat,
> +				.module = THIS_MODULE,
>  			};
>  			return netlink_dump_start(net->diag_nlsk, skb, nlh, &c);
>  		}
> @@ -1010,6 +1011,7 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
>  		{
>  			struct netlink_dump_control c = {
>  				.dump = inet_diag_dump,
> +				.module = THIS_MODULE,
>  			};
>  			return netlink_dump_start(net->diag_nlsk, skb, h, &c);
>  		}


I believe Pablo suggestion was to make netlink_dump_start()
automatically pass THIS_MODULE so that we dont need to change all call
sites ?

extern int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
				  const struct nlmsghdr *nlh,
				  struct netlink_dump_control *control);

static inline int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
					const struct nlmsghdr *nlh,
					struct netlink_dump_control *control)
{
	control->module = THIS_MODULE;
	return __netlink_dump_start(ssk, skb, nlh, control);
}

or :

extern int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
				  const struct nlmsghdr *nlh,
				  struct netlink_dump_control *control,
				  struct module *module);

static inline int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
					const struct nlmsghdr *nlh,
					struct netlink_dump_control *control)
{
	return __netlink_dump_start(ssk, skb, nlh, control, THIS_MODULE);
}


