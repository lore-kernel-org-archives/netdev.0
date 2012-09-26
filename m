From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch v2 04/11] nf_conntrack_netlink: pass
 nf_conntrack_netlink module to netlink_dump_start
Date: Wed, 26 Sep 2012 11:26:32 +0200
Message-ID: <20120926092632.GA21589@1984>
References: <1348648888-24943-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1348648888-24943-4-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com, netfilter-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org, stephen.hemminger@vyatta.com,
	jengelh@inai.de
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1348648888-24943-4-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 26, 2012 at 04:41:21PM +0800, Gao feng wrote:
> use proper netlink_dump_control.done and .module to avoid panic.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/netfilter/nf_conntrack_netlink.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
> index 9807f32..509a257 100644
> --- a/net/netfilter/nf_conntrack_netlink.c
> +++ b/net/netfilter/nf_conntrack_netlink.c
> @@ -706,6 +706,7 @@ static int ctnetlink_done(struct netlink_callback *cb)
>  		nf_ct_put((struct nf_conn *)cb->args[1]);
>  	if (cb->data)
>  		kfree(cb->data);
> +	netlink_dump_done(cb);

I think you can call netlink_dump_done from af_netlink.c:

static int netlink_dump(struct sock *sk) 
        ...
        if (cb->done) {
                cb->done(cb);
                netlink_dump_done(...);
        }

Thus, you don't need to change netlink_dump_control in every netlink
subsystem.

>  	return 0;
>  }
>  
> @@ -1022,6 +1023,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
>  		struct netlink_dump_control c = {
>  			.dump = ctnetlink_dump_table,
>  			.done = ctnetlink_done,
> +			.module = THIS_MODULE,

You can do something similar to:

9f00d97 netlink: hide struct module parameter in netlink_kernel_create

by definiting netlink_dump_start as static inline and using
THIS_MODULE from there.

If I'm not missing anything, with those two changes, you will not need
to modify any caller and it will result one single patch.
