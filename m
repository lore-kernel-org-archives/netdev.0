From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: fix the printing of ifindex
Date: Wed, 02 Aug 2017 17:53:45 +0200
Message-ID: <5981F589.80000@iogearbox.net>
References: <1501688632-2709-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57207 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdHBPxr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 11:53:47 -0400
In-Reply-To: <1501688632-2709-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2017 05:43 PM, William Tu wrote:
> Save the ifindex before it gets zeroed so the invalid
> ifindex can be printed out.
>
> Signed-off-by: William Tu <u9012063@gmail.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

>   net/core/filter.c | 10 ++++++----
>   1 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 7e9708653c6f..78d00933dbe7 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -2509,15 +2509,16 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
>   {
>   	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
>   	struct net_device *fwd;
> +	u32 index = ri->ifindex;
>
>   	if (ri->map)
>   		return xdp_do_redirect_map(dev, xdp, xdp_prog);
>
> -	fwd = dev_get_by_index_rcu(dev_net(dev), ri->ifindex);
> +	fwd = dev_get_by_index_rcu(dev_net(dev), index);
>   	ri->ifindex = 0;
>   	ri->map = NULL;

Unrelated, but setting ri->map to NULL is not really needed here
given we have the ri->map test earlier.

>   	if (unlikely(!fwd)) {
> -		bpf_warn_invalid_xdp_redirect(ri->ifindex);
> +		bpf_warn_invalid_xdp_redirect(index);
>   		return -EINVAL;
>   	}
>
> @@ -2531,11 +2532,12 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb)
>   {
>   	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
>   	unsigned int len;
> +	u32 index = ri->ifindex;
>
> -	dev = dev_get_by_index_rcu(dev_net(dev), ri->ifindex);
> +	dev = dev_get_by_index_rcu(dev_net(dev), index);
>   	ri->ifindex = 0;
>   	if (unlikely(!dev)) {
> -		bpf_warn_invalid_xdp_redirect(ri->ifindex);
> +		bpf_warn_invalid_xdp_redirect(index);
>   		goto err;
>   	}
>
>
