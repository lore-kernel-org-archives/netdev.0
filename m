From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next 1/4] bpf: xdp: Allow head adjustment in XDP
 prog
Date: Wed, 07 Dec 2016 14:34:55 +0100
Message-ID: <58480FFF.9010302@iogearbox.net>
References: <1481088714-54512-1-git-send-email-kafai@fb.com>    <1481088714-54512-2-git-send-email-kafai@fb.com>        <5847D723.3020908@iogearbox.net> <20161207114112.6ad86da3@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        David Miller <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53426 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752635AbcLGNfH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 08:35:07 -0500
In-Reply-To: <20161207114112.6ad86da3@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2016 12:41 PM, Jakub Kicinski wrote:
> On Wed, 07 Dec 2016 10:32:19 +0100, Daniel Borkmann wrote:
>> On 12/07/2016 06:31 AM, Martin KaFai Lau wrote:
>> [...]
>>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>>> index 49a81f1fc1d6..6261157f444e 100644
>>> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>>> @@ -2794,6 +2794,9 @@ static int mlx4_xdp(struct net_device *dev, struct netdev_xdp *xdp)
>>>    	case XDP_QUERY_PROG:
>>>    		xdp->prog_attached = mlx4_xdp_attached(dev);
>>>    		return 0;
>>> +	case XDP_QUERY_FEATURES:
>>> +		xdp->features = 0;
>>> +		return 0;
>>>    	default:
>>>    		return -EINVAL;
>>>    	}
>> [...]
>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>> index 1ff5ea6e1221..786ad7c67215 100644
>>> --- a/include/linux/netdevice.h
>>> +++ b/include/linux/netdevice.h
>>> @@ -30,6 +30,7 @@
>>>    #include <linux/delay.h>
>>>    #include <linux/atomic.h>
>>>    #include <linux/prefetch.h>
>>> +#include <linux/bitops.h>
>>>    #include <asm/cache.h>
>>>    #include <asm/byteorder.h>
>>>
>>> @@ -805,6 +806,13 @@ struct tc_to_netdev {
>>>    	bool egress_dev;
>>>    };
>>>
>>> +/* Driver must allow a XDP prog to extend header by
>>> + * up to XDP_PACKET_HEADROOM.  It must also fill out
>>> + * the data_hard_start value in struct xdp_buff
>>> + * before calling out the xdp_prog.
>>> + */
>>> +#define XDP_F_ADJUST_HEAD	BIT(0)
>>> +
>>>    /* These structures hold the attributes of xdp state that are being passed
>>>     * to the netdevice through the xdp op.
>>>     */
>>> @@ -821,6 +829,8 @@ enum xdp_netdev_command {
>>>    	 * return true if a program is currently attached and running.
>>>    	 */
>>>    	XDP_QUERY_PROG,
>>> +	/* Check what XDP features are supported by a device */
>>> +	XDP_QUERY_FEATURES,
>>>    };
>>>
>>>    struct netdev_xdp {
>>> @@ -830,6 +840,8 @@ struct netdev_xdp {
>>>    		struct bpf_prog *prog;
>>>    		/* XDP_QUERY_PROG */
>>>    		bool prog_attached;
>>> +		/* XDP_QUERY_FEATURES */
>>> +		u32 features;
>>>    	};
>>>    };
>>>
>> [...]
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index bffb5253e778..90696f7e6b59 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -6722,6 +6722,15 @@ int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
>>>    		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
>>>    		if (IS_ERR(prog))
>>>    			return PTR_ERR(prog);

Ohh, by the way, here you fetch the prog, grabbing a reference.

>>> +
>>> +		xdp.command = XDP_QUERY_FEATURES;
>>> +		err = ops->ndo_xdp(dev, &xdp);
>>> +		if (err)

Therefore ... bpf_prog_put() ...

>>> +			return err;
>>> +
>>> +		if (prog->xdp_adjust_head &&
>>> +		    !(xdp.features & XDP_F_ADJUST_HEAD))

... same here, otherwise we leak it!

>>> +			return -ENOTSUPP;
>>>    	}
>>>
>>>    	memset(&xdp, 0, sizeof(xdp));
>>
>> I think this interface wrt feature flags is rather odd. Why can't this be
>> done the usual/expected way we already have today for drivers with NETIF_F_*
>> flags?
>>
>> We have include/linux/netdev_features.h, there, we add all NETIF_F_XDP_*
>> feature flags that the device would then select during init, perhaps some of
>> them in future might depend on a certain setups, etc, calculating them in a
>> separate ndo_xdp() seems odd also in the sense that in-kernel users always
>> need to call ops->ndo_xdp() with XDP_QUERY_FEATURES instead of just simply
>> doing the test on dev->features & NETIF_F_XDP_* directly. This is global to
>> the device anyway and doesn't need to be stored somewhere in private data
>> area.
>
> If I may offer one potential disadvantage of just using netdev
> features :)
> - if we ever want to report something more than flags (say the length
> of headroom) we will need another interface.  People who care about

Okay, but do we want XDP_QUERY_FEATURES to be a 'super-interface' returning
everything? I mean depending on what comes up in future, I'd rather imagine
that this is still partitioned a bit further, so that f.e. queries where the
driver would need to take some state lock are only required if the caller of
ndo_xdp() is really interested in that. Some of the features might simply be
bit flags, though, some others, if the flag is set, might need a query down
to the driver.

> memory savings may also get upset if we extend struct netdevice given
> there is no way to compile XDP out, that would be an argument for
> keeping the ndo invocation.

If this is a specific concern also regarding dev feature flags, then fair
enough. Just found it odd to have an extra ndo_xdp() call for it where they
could be stored in the dev directly instead. I don't know if we ever need to
pass dev pointer via struct xdp_buff to a helper function and query anything
from there, but worst case this would then need to be changed a bit.

>> I see nothing wrong if this is exposed/made visible in the usual way through
>> ethtool -k as well. I guess at least that would be the expected way to query
>> for such driver capabilities.
>
> +1 on exposing this to user space.  Whether via ethtool -k or a
> separate XDP-specific netlink message is mostly a question of whether
> we expect the need to expose more complex capabilities than bits.
>
> Thanks!
>
