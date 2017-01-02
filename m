From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Mon, 2 Jan 2017 09:59:49 -0500
Message-ID: <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>
To: Paul Blakey <paulb@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35136 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932909AbdABO7w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 09:59:52 -0500
Received: by mail-io0-f193.google.com with SMTP id f73so54323652ioe.2
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 06:59:51 -0800 (PST)
In-Reply-To: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We have been using a cookie as well for actions (which we have been
using but have been too lazy to submit so far). I am going to port
it over to the newer kernels and post it.
In our case that is intended to be opaque to the kernel i.e kernel
never inteprets it; in that case it is similar to the kernel
FIB protocol field.

In your case - could this cookie have been a class/flowid
(a 32 bit)?
And would it not make more sense for it the cookie to be
generic to all classifiers? i.e why is it specific to flower?

cheers,
jamal

On 17-01-02 08:13 AM, Paul Blakey wrote:
> This is to support saving extra data that might be helpful on retrieval.
> First use case is upcoming openvswitch flow offloads, extra data will
> include UFID and port mappings for each added flow.
>
> Signed-off-by: Paul Blakey <paulb@mellanox.com>
> Reviewed-by: Roi Dayan <roid@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/uapi/linux/pkt_cls.h |  3 +++
>  net/sched/cls_flower.c       | 22 +++++++++++++++++++++-
>  2 files changed, 24 insertions(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
> index cb4bcdc..ca9bbe3 100644
> --- a/include/uapi/linux/pkt_cls.h
> +++ b/include/uapi/linux/pkt_cls.h
> @@ -471,10 +471,13 @@ enum {
>  	TCA_FLOWER_KEY_ICMPV6_TYPE,	/* u8 */
>  	TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,/* u8 */
>
> +	TCA_FLOWER_COOKIE,		/* binary */
> +
>  	__TCA_FLOWER_MAX,
>  };
>
>  #define TCA_FLOWER_MAX (__TCA_FLOWER_MAX - 1)
> +#define FLOWER_MAX_COOKIE_SIZE 128
>
>  enum {
>  	TCA_FLOWER_KEY_FLAGS_IS_FRAGMENT = (1 << 0),
> diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
> index 333f8e2..e2f5b25 100644
> --- a/net/sched/cls_flower.c
> +++ b/net/sched/cls_flower.c
> @@ -85,6 +85,8 @@ struct cls_fl_filter {
>  	struct rcu_head	rcu;
>  	struct tc_to_netdev tc;
>  	struct net_device *hw_dev;
> +	size_t cookie_len;
> +	long cookie[0];
>  };
>
>  static unsigned short int fl_mask_range(const struct fl_flow_mask *mask)
> @@ -794,6 +796,9 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
>  	struct cls_fl_filter *fnew;
>  	struct nlattr *tb[TCA_FLOWER_MAX + 1];
>  	struct fl_flow_mask mask = {};
> +	const struct nlattr *attr;
> +	size_t cookie_len = 0;
> +	void *cookie;
>  	int err;
>
>  	if (!tca[TCA_OPTIONS])
> @@ -806,10 +811,22 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
>  	if (fold && handle && fold->handle != handle)
>  		return -EINVAL;
>
> -	fnew = kzalloc(sizeof(*fnew), GFP_KERNEL);
> +	if (tb[TCA_FLOWER_COOKIE]) {
> +		attr = tb[TCA_FLOWER_COOKIE];
> +		cookie_len = nla_len(attr);
> +		cookie = nla_data(attr);
> +		if (cookie_len > FLOWER_MAX_COOKIE_SIZE)
> +			return -EINVAL;
> +	}
> +
> +	fnew = kzalloc(sizeof(*fnew) + cookie_len, GFP_KERNEL);
>  	if (!fnew)
>  		return -ENOBUFS;
>
> +	fnew->cookie_len = cookie_len;
> +	if (cookie_len)
> +		memcpy(fnew->cookie, cookie, cookie_len);
> +
>  	err = tcf_exts_init(&fnew->exts, TCA_FLOWER_ACT, 0);
>  	if (err < 0)
>  		goto errout;
> @@ -1151,6 +1168,9 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
>
>  	nla_put_u32(skb, TCA_FLOWER_FLAGS, f->flags);
>
> +	if (f->cookie_len)
> +		nla_put(skb, TCA_FLOWER_COOKIE, f->cookie_len, f->cookie);
> +
>  	if (tcf_exts_dump(skb, &f->exts))
>  		goto nla_put_failure;
>
>
