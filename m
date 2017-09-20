From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 3/3] virtio-net: support XDP_REDIRECT
Date: Wed, 20 Sep 2017 15:02:48 -0700
Message-ID: <59C2E588.6060203@gmail.com>
References: <1505814163-7315-1-git-send-email-jasowang@redhat.com> <1505814163-7315-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505814163-7315-3-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/19/2017 02:42 AM, Jason Wang wrote:
> This patch tries to add XDP_REDIRECT for virtio-net. The changes are
> not complex as we could use exist XDP_TX helpers for most of the
> work. The rest is passing the XDP_TX to NAPI handler for implementing
> batching.
> 
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---

[...]

> @@ -678,12 +711,20 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  			}
>  			break;
>  		case XDP_TX:
> -			if (unlikely(!virtnet_xdp_xmit(vi, &xdp)))
> +			if (unlikely(!__virtnet_xdp_xmit(vi, &xdp)))
>  				trace_xdp_exception(vi->dev, xdp_prog, act);
> +			else
> +				*xdp_xmit = true;
>  			if (unlikely(xdp_page != page))
>  				goto err_xdp;
>  			rcu_read_unlock();
>  			goto xdp_xmit;
> +		case XDP_REDIRECT:
> +			err = xdp_do_redirect(dev, &xdp, xdp_prog);
> +			if (err)
> +				*xdp_xmit = true;

Is this a typo? Should above be

			if (!err)
				*xdp_xmit = true;

this would match the pattern in receive_small and also make more sense.

> +			rcu_read_unlock();
> +			goto xdp_xmit;
>  		default:
>  			bpf_warn_invalid_xdp_action(act);
>  		case XDP_ABORTED:
> @@ -788,7 +829,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  }
>  

[...]

Otherwise looks good to me thanks for doing this.

.John
