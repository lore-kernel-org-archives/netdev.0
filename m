From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2] netlink: do not proceed if dump's start() errs
Date: Thu, 28 Sep 2017 12:40:04 +0200
Message-ID: <20170928104002.GA25114@zx2c4.com>
References: <CAHmME9oA+dE3eOCTWweJjZGL4sog30JShoCJoWaPn4JV7h3auA@mail.gmail.com>
 <20170927224144.1749-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Johannes Berg <johannes@sipsolutions.net>
To: davem@davemloft.net, johannes.berg@intel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170927224144.1749-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2017 at 12:41:44AM +0200, Jason A. Donenfeld wrote:
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 327807731b44..94c11cf0459d 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -2270,10 +2270,13 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
>  
>  	mutex_unlock(nlk->cb_mutex);
>  
> +	ret = 0;
>  	if (cb->start)
> -		cb->start(cb);
> +		ret = cb->start(cb);
> +
> +	if (!ret)
> +		ret = netlink_dump(sk);
>  
> -	ret = netlink_dump(sk);
>  	sock_put(sk);
>  
>  	if (ret)


FYI, using this horrific hack to currently work around bug:

    #define KERNEL_VERSION_THAT_HAS_NETLINK_START_FIX KERNEL_VERSION(4, 14, 0) /* Hopefully! */

    static int get(struct sk_buff *skb, struct netlink_callback *cb)
    {
    #if LINUX_VERSION_CODE < KERNEL_VERSION_THAT_HAS_NETLINK_START_FIX
        /* https://marc.info/?l=linux-netdev&m=150655213004221&w=2 */
        if (!cb->args[0]) {
            ret = get_start(cb);
            if (ret)
                return ret;
        }
    #endif
        ...
    }

    static const struct genl_ops genl_ops[] = {
        {
            .cmd = CMD_GET,
    #if LINUX_VERSION_CODE >= KERNEL_VERSION_THAT_HAS_NETLINK_START_FIX
            /* https://marc.info/?l=linux-netdev&m=150655213004221&w=2 */
            .start = get_start,
    #endif
            .dumpit = get,
            ...
        }
    }

Gross.
